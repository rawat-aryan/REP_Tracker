import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/plan_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../domain/models/plan.dart';
import '../../domain/rules/analytics.dart' show exerciseOverlap, kSameDayThreshold;
import '../../domain/rules/home.dart';
import '../../domain/rules/pattern_detection.dart';
import '../../providers.dart';

/// How far back pattern detection looks for repeating weekday patterns —
/// spec §9 wants "frequency across cycles", so this needs several cycles
/// of room, not just the most recent couple of weeks.
const _patternWindowDays = 56;

/// Fetches whatever [computeHomeState] needs and decides the two branches
/// that need repository access to resolve (rest day, no plan yet) before
/// handing off to the pure function for the rest.
final homeStateProvider = FutureProvider<HomeState>((ref) async {
  final now = ref.watch(nowProvider);
  final plans = ref.watch(planRepositoryProvider);
  final sessions = ref.watch(sessionRepositoryProvider);

  final plan = await plans.getLatestWeekPlan(demoRoutineId);
  if (plan == null) return const NoPlanYet();

  final today = weekdayOf(now);
  final dayId = plan.slots[today];

  if (dayId == null) {
    final last = await sessions.mostRecentSession(
      before: DateTime(now.year, now.month, now.day),
    );
    LastSessionSummary? summary;
    if (last != null) {
      final lastDay =
          last.workoutDayId == null ? null : await plans.getWorkoutDay(last.workoutDayId!);
      summary = LastSessionSummary(
        dayName: lastDay?.name ?? 'Session',
        date: last.date,
        totalSets: last.exercises.fold(0, (n, e) => n + e.sets.length),
      );
    }
    final proposal = await _provisionalPatternFor(plans, sessions, plan, today, now);
    return RestDay(
      lastSession: summary,
      nextDayName: await _nextTrainingDayName(plans, plan, today),
      provisionalDayName: proposal?.name,
      provisionalExerciseIds: proposal?.exerciseIds,
    );
  }

  final day = await plans.getWorkoutDay(dayId);
  if (day == null) return const NoPlanYet();

  final todaysSessions =
      (await sessions.getForDate(now)).where((s) => s.workoutDayId == dayId).toList();

  return computeHomeState(today: now, todayDay: day, todaysSessionsForDay: todaysSessions);
});

/// Walks forward from tomorrow, wrapping after a week, for the first slot
/// with a day assigned — the rest-day card's "next up".
Future<String?> _nextTrainingDayName(
  PlanRepository plans,
  WeekPlan plan,
  Weekday from,
) async {
  for (var i = 1; i <= 7; i++) {
    final wd = Weekday.values[(from.index + i) % 7];
    final id = plan.slots[wd];
    if (id == null) continue;
    final day = await plans.getWorkoutDay(id);
    if (day != null) return day.name;
  }
  return null;
}

class _PatternMatch {
  const _PatternMatch({required this.name, required this.exerciseIds});
  final String? name;
  final Set<String> exerciseIds;
}

/// Only called for a weekday whose slot is currently null (rest) — spec
/// §9's provisional header only ever fills a blank, it never contests an
/// already-assigned day (that's a stronger claim milestone 09 leaves for a
/// future confirmed-pattern-change flow). Looks back [_patternWindowDays]
/// for what was actually logged on each occurrence of [today], and — if a
/// stable pattern emerges — tries to name it by matching an existing
/// [WorkoutDay]'s exercise list, so "Legs" reads as "Legs?" instead of a
/// generic placeholder when the exercises already belong to a known day.
Future<_PatternMatch?> _provisionalPatternFor(
  PlanRepository plans,
  SessionRepository sessions,
  WeekPlan plan,
  Weekday today,
  DateTime now,
) async {
  final from = DateTime(now.year, now.month, now.day)
      .subtract(const Duration(days: _patternWindowDays));
  final history = await sessions.getInRange(from, now);

  final observations = [
    for (final s in history)
      WeekdayObservation(
        date: s.date,
        exerciseIds: {
          for (final e in s.exercises)
            if (e.sets.isNotEmpty) e.exerciseId,
        },
      ),
  ]..removeWhere((o) => o.exerciseIds.isEmpty);

  final assignedDays = await plans.getAllWorkoutDays();
  final currentAssignment = <Weekday, Set<String>?>{};
  for (final entry in plan.slots.entries) {
    if (entry.value == null) continue;
    final day = assignedDays.where((d) => d.id == entry.value);
    if (day.isEmpty) continue;
    currentAssignment[entry.key] = day.first.exercises.map((e) => e.exerciseId).toSet();
  }

  final proposals = detectPatterns(observations: observations, currentAssignment: currentAssignment);
  final match = proposals.where((p) => p.weekday == today);
  if (match.isEmpty) return null;
  final proposed = match.first.exerciseIds;

  for (final day in assignedDays) {
    final dayExerciseIds = day.exercises.map((e) => e.exerciseId).toSet();
    if (dayExerciseIds.isNotEmpty && exerciseOverlap(proposed, dayExerciseIds) >= kSameDayThreshold) {
      return _PatternMatch(name: day.name, exerciseIds: proposed);
    }
  }
  return _PatternMatch(name: null, exerciseIds: proposed);
}

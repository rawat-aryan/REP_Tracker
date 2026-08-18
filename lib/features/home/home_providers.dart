import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/plan_repository.dart';
import '../../domain/models/plan.dart';
import '../../domain/rules/home.dart';
import '../../providers.dart';

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
    return RestDay(
      lastSession: summary,
      nextDayName: await _nextTrainingDayName(plans, plan, today),
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

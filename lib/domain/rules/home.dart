import '../models/plan.dart';
import '../models/session.dart';

/// Home screen state (spec §12, milestone 05). Five variants, one primary
/// action each — a sealed class instead of an enum because each variant
/// carries different data to render.
sealed class HomeState {
  const HomeState();
}

/// No [WeekPlan] exists yet (pre-onboarding). Cut for this milestone: no
/// upfront exercise-name input — "just start" opens an empty session and
/// the picker already built into the session screen (milestone 04) covers
/// building the list live. Spec §5: "never gate the workout behind
/// declaring it."
class NoPlanYet extends HomeState {
  const NoPlanYet();
}

/// Today's slot is null. Genuinely quiet — no call to action (spec §12).
class RestDay extends HomeState {
  const RestDay({this.lastSession, this.nextDayName});
  final LastSessionSummary? lastSession;
  final String? nextDayName;
}

/// Today's slot has a day, and nothing has been logged for it yet today.
class PlannedNotStarted extends HomeState {
  const PlannedNotStarted({required this.day, required this.date});
  final WorkoutDay day;
  final DateTime date;
}

/// The state that matters most (spec §12) — every trigger round-trip lands
/// here. [session] is read fresh from the DB, so elapsed time is always
/// correct even after a force-quit (I5: nothing lives only in memory).
class InProgress extends HomeState {
  const InProgress({required this.session, required this.dayName});
  final Session session;
  final String dayName;
}

/// Ended, but never locked (I5) — still fully editable from here.
class Done extends HomeState {
  const Done({required this.session, required this.dayName});
  final Session session;
  final String dayName;
}

class LastSessionSummary {
  const LastSessionSummary({
    required this.dayName,
    required this.date,
    required this.totalSets,
  });
  final String dayName;
  final DateTime date;
  final int totalSets;
}

Weekday weekdayOf(DateTime date) => Weekday.values[date.weekday - 1];

/// Decides Planned/In-progress/Done for a day already known to be
/// scheduled today. Rest-day and no-plan-yet are decided one level up —
/// they need day-name lookups this pure function shouldn't have to take a
/// repository for.
HomeState computeHomeState({
  required DateTime today,
  required WorkoutDay todayDay,
  required List<Session> todaysSessionsForDay,
}) {
  if (todaysSessionsForDay.isEmpty) {
    return PlannedNotStarted(day: todayDay, date: today);
  }
  final open = todaysSessionsForDay.where((s) => s.endedAt == null);
  final session = open.isNotEmpty ? open.first : todaysSessionsForDay.first;
  return session.endedAt == null
      ? InProgress(session: session, dayName: todayDay.name)
      : Done(session: session, dayName: todayDay.name);
}

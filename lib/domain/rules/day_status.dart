import '../models/plan.dart';
import '../models/session.dart';

/// Derives [DayStatus] for one calendar date. Pure — no DB, no clock reads
/// (the caller decides what "today" is). `unresolved` is the default for a
/// gap and this function NEVER produces `missed` — that value exists in the
/// enum for a future explicit user action, not for silent inference (I2).
DayStatus deriveDayStatus({
  required DateTime date,
  required DateTime today,
  required bool scheduledOnThisWeekday,
  required List<Session> sessionsOnDate,
  DayResolution? manualResolution,
}) {
  if (sessionsOnDate.isNotEmpty) return DayStatus.logged;

  if (manualResolution != null) {
    return switch (manualResolution.kind) {
      DayResolutionKind.rest || DayResolutionKind.travel => DayStatus.rest,
      DayResolutionKind.movedTo => DayStatus.movedTo,
    };
  }

  if (!scheduledOnThisWeekday) return DayStatus.rest;

  // A scheduled day with nothing logged is only a gap once it's actually
  // past — today and future dates are simply "not yet", not unresolved.
  final dateOnly = DateTime(date.year, date.month, date.day);
  final todayOnly = DateTime(today.year, today.month, today.day);
  if (!dateOnly.isBefore(todayOnly)) return DayStatus.rest;

  return DayStatus.unresolved;
}

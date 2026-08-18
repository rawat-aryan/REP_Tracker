import 'package:rep_tracker/domain/models/plan.dart';
import 'package:rep_tracker/domain/models/session.dart';
import 'package:rep_tracker/domain/rules/day_status.dart';
import 'package:test/test.dart';

Session _session(DateTime date) => Session(id: 's', date: date, startedAt: date);

void main() {
  final today = DateTime(2026, 8, 19);

  test('a session on the date always wins — logged', () {
    final status = deriveDayStatus(
      date: DateTime(2026, 8, 17),
      today: today,
      scheduledOnThisWeekday: false, // even if the plan says rest
      sessionsOnDate: [_session(DateTime(2026, 8, 17))],
    );
    expect(status, DayStatus.logged);
  });

  test('unscheduled, nothing logged -> rest, never unresolved', () {
    final status = deriveDayStatus(
      date: DateTime(2026, 8, 17),
      today: today,
      scheduledOnThisWeekday: false,
      sessionsOnDate: const [],
    );
    expect(status, DayStatus.rest);
  });

  test('scheduled, nothing logged, in the past -> unresolved (a gap, not a fact)', () {
    final status = deriveDayStatus(
      date: DateTime(2026, 8, 17),
      today: today,
      scheduledOnThisWeekday: true,
      sessionsOnDate: const [],
    );
    expect(status, DayStatus.unresolved);
  });

  test('scheduled, nothing logged, today or future -> never unresolved yet', () {
    final status = deriveDayStatus(
      date: today,
      today: today,
      scheduledOnThisWeekday: true,
      sessionsOnDate: const [],
    );
    expect(status, isNot(DayStatus.unresolved));
  });

  test('unresolved gap never silently becomes missed — deriveDayStatus produces it only via manual resolution', () {
    final status = deriveDayStatus(
      date: DateTime(2026, 8, 17),
      today: today,
      scheduledOnThisWeekday: true,
      sessionsOnDate: const [],
    );
    expect(status, isNot(DayStatus.missed));
  });

  test('manual rest/travel resolution -> rest', () {
    for (final kind in [DayResolutionKind.rest, DayResolutionKind.travel]) {
      final status = deriveDayStatus(
        date: DateTime(2026, 8, 17),
        today: today,
        scheduledOnThisWeekday: true,
        sessionsOnDate: const [],
        manualResolution: DayResolution(date: DateTime(2026, 8, 17), kind: kind),
      );
      expect(status, DayStatus.rest);
    }
  });

  test('manual movedTo resolution -> movedTo, distinct from rest', () {
    final status = deriveDayStatus(
      date: DateTime(2026, 8, 17),
      today: today,
      scheduledOnThisWeekday: true,
      sessionsOnDate: const [],
      manualResolution: DayResolution(
        date: DateTime(2026, 8, 17),
        kind: DayResolutionKind.movedTo,
        movedToDate: DateTime(2026, 8, 18),
      ),
    );
    expect(status, DayStatus.movedTo);
  });
}

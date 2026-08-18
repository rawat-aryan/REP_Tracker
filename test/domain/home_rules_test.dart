import 'package:rep_tracker/domain/models/plan.dart';
import 'package:rep_tracker/domain/models/session.dart';
import 'package:rep_tracker/domain/rules/home.dart';
import 'package:test/test.dart';

const _day = WorkoutDay(id: 'legs', name: 'Legs');

void main() {
  test('weekdayOf maps DateTime.weekday (1=Mon) onto Weekday.mon..sun', () {
    expect(weekdayOf(DateTime(2026, 8, 17)), Weekday.mon); // a Monday
    expect(weekdayOf(DateTime(2026, 8, 23)), Weekday.sun); // the following Sunday
  });

  group('computeHomeState (day already known to be scheduled today)', () {
    test('no sessions today -> PlannedNotStarted', () {
      final state = computeHomeState(
        today: DateTime(2026, 8, 18),
        todayDay: _day,
        todaysSessionsForDay: const [],
      );
      expect(state, isA<PlannedNotStarted>());
    });

    test('an open session today -> InProgress, even with a finished one alongside', () {
      final finished = Session(
        id: 'morning',
        date: DateTime(2026, 8, 18),
        startedAt: DateTime(2026, 8, 18, 7),
        endedAt: DateTime(2026, 8, 18, 8),
      );
      final open = Session(
        id: 'evening',
        date: DateTime(2026, 8, 18),
        startedAt: DateTime(2026, 8, 18, 18),
      );
      final state = computeHomeState(
        today: DateTime(2026, 8, 18),
        todayDay: _day,
        todaysSessionsForDay: [finished, open],
      );
      expect(state, isA<InProgress>());
      expect((state as InProgress).session.id, 'evening');
    });

    test('force-quit mid-set: session read fresh from the DB shows correct elapsed time', () {
      // Milestone 05's literal Done-when: elapsed time comes from
      // session.startedAt, never from anything held only in memory, so a
      // "cold" read (this function, called fresh) is already correct.
      final startedAt = DateTime.now().subtract(const Duration(minutes: 7));
      final session = Session(id: 's1', date: DateTime.now(), startedAt: startedAt);
      final state = computeHomeState(
        today: DateTime.now(),
        todayDay: _day,
        todaysSessionsForDay: [session],
      );
      expect(state, isA<InProgress>());
      final elapsed = DateTime.now().difference((state as InProgress).session.startedAt);
      expect(elapsed.inMinutes, greaterThanOrEqualTo(6));
    });

    test('only ended sessions today -> Done', () {
      final earlier = Session(
        id: 'earlier',
        date: DateTime(2026, 8, 18),
        startedAt: DateTime(2026, 8, 18, 7),
        endedAt: DateTime(2026, 8, 18, 8),
      );
      final later = Session(
        id: 'later',
        date: DateTime(2026, 8, 18),
        startedAt: DateTime(2026, 8, 18, 18),
        endedAt: DateTime(2026, 8, 18, 19),
      );
      final state = computeHomeState(
        today: DateTime(2026, 8, 18),
        todayDay: _day,
        todaysSessionsForDay: [earlier, later],
      );
      expect(state, isA<Done>());
      expect((state as Done).session.endedAt, isNotNull);
    });
  });
}

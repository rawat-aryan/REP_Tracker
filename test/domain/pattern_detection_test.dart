import 'package:rep_tracker/domain/models/plan.dart';
import 'package:rep_tracker/domain/rules/pattern_detection.dart';
import 'package:test/test.dart';

const _push = {'bench_press', 'overhead_press'};
const _pull = {'barbell_row', 'lat_pulldown'};
const _legs = {'barbell_squat', 'leg_press'};

DateTime _mondayOfWeek(int weekIndex) =>
    DateTime(2026, 1, 5).add(Duration(days: 7 * weekIndex)); // 2026-01-05 is a Monday

void main() {
  test(
    'milestone 09 fixture: a travel week displacing Pull from Wed to Thu must not '
    'propose moving Pull',
    () {
      final observations = <WeekdayObservation>[];
      for (var week = 0; week < 6; week++) {
        final monday = _mondayOfWeek(week);
        observations.add(WeekdayObservation(date: monday, exerciseIds: _push));
        if (week == 4) {
          // The travel week: Pull happens Thursday instead of Wednesday.
          observations.add(
            WeekdayObservation(date: monday.add(const Duration(days: 3)), exerciseIds: _pull),
          );
        } else {
          observations.add(
            WeekdayObservation(date: monday.add(const Duration(days: 2)), exerciseIds: _pull),
          );
        }
        observations.add(
          WeekdayObservation(date: monday.add(const Duration(days: 4)), exerciseIds: _legs),
        );
      }

      final proposals = detectPatterns(
        observations: observations,
        currentAssignment: {
          Weekday.mon: _push,
          Weekday.tue: null,
          Weekday.wed: _pull,
          Weekday.thu: null,
          Weekday.fri: _legs,
          Weekday.sat: null,
          Weekday.sun: null,
        },
      );

      expect(proposals.where((p) => p.weekday == Weekday.thu), isEmpty);
      expect(proposals.where((p) => p.weekday == Weekday.wed), isEmpty);
    },
  );

  test('a single occurrence on a new weekday is an anecdote, not a pattern', () {
    final proposals = detectPatterns(
      observations: [WeekdayObservation(date: DateTime(2026, 3, 2), exerciseIds: _legs)],
      currentAssignment: {for (final w in Weekday.values) w: null},
    );
    expect(proposals, isEmpty);
  });

  test('two consecutive agreeing occurrences on an unassigned weekday propose it', () {
    final observations = [
      WeekdayObservation(date: DateTime(2026, 3, 2), exerciseIds: _legs), // Monday
      WeekdayObservation(date: DateTime(2026, 3, 9), exerciseIds: _legs), // Monday, next week
    ];
    final proposals = detectPatterns(
      observations: observations,
      currentAssignment: {for (final w in Weekday.values) w: null},
    );
    expect(proposals, hasLength(1));
    expect(proposals.single.weekday, Weekday.mon);
    expect(proposals.single.exerciseIds, _legs);
  });

  test('two consecutive occurrences that disagree with each other propose nothing', () {
    final observations = [
      WeekdayObservation(date: DateTime(2026, 3, 2), exerciseIds: _legs),
      WeekdayObservation(date: DateTime(2026, 3, 9), exerciseIds: _push),
    ];
    final proposals = detectPatterns(
      observations: observations,
      currentAssignment: {for (final w in Weekday.values) w: null},
    );
    expect(proposals, isEmpty);
  });

  test('a real, sustained change (2 consecutive cycles) IS proposed', () {
    // Pull moves to Thursday for two weeks running — not a single blip.
    final observations = [
      WeekdayObservation(date: DateTime(2026, 3, 5), exerciseIds: _pull), // Thu week 1
      WeekdayObservation(date: DateTime(2026, 3, 12), exerciseIds: _pull), // Thu week 2
    ];
    final proposals = detectPatterns(
      observations: observations,
      currentAssignment: {for (final w in Weekday.values) w: null},
    );
    expect(proposals, hasLength(1));
    expect(proposals.single.weekday, Weekday.thu);
  });

  test('already matches the current assignment — nothing new to say', () {
    final observations = [
      WeekdayObservation(date: DateTime(2026, 3, 2), exerciseIds: _legs),
      WeekdayObservation(date: DateTime(2026, 3, 9), exerciseIds: _legs),
    ];
    final proposals = detectPatterns(
      observations: observations,
      currentAssignment: {Weekday.mon: _legs},
    );
    expect(proposals, isEmpty);
  });
}

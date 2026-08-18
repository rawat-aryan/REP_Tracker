import 'package:rep_tracker/domain/models/plan.dart';
import 'package:rep_tracker/domain/rules/onboarding.dart';
import 'package:test/test.dart';

void main() {
  test('every archetype covers all 7 weekdays', () {
    for (final a in Archetype.values) {
      expect(suggestedWeekMap(a).keys.toSet(), Weekday.values.toSet());
    }
  });

  test('hybrid is a fully blank grid — no SplitType leaks through as a day name', () {
    final map = suggestedWeekMap(Archetype.hybrid);
    expect(map.values.every((v) => v == null), isTrue);
  });

  test('ppl cycles Push/Pull/Legs across 6 days with one rest day', () {
    final map = suggestedWeekMap(Archetype.ppl);
    final names = map.values.whereType<String>().toSet();
    expect(names, {'Push', 'Pull', 'Legs'});
    expect(map.values.where((v) => v == null).length, 1);
  });

  test('bro split assigns one muscle group per day', () {
    final map = suggestedWeekMap(Archetype.broSplit);
    expect(map[Weekday.mon], 'Chest');
    expect(map[Weekday.fri], 'Legs');
    expect(map[Weekday.sat], isNull);
  });
}

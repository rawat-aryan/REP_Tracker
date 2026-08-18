import '../models/plan.dart';

/// A one-screen shortcut only (spec §4). The map it produces gets written
/// into real [WorkoutDay]/[WeekPlan] rows and the archetype itself is then
/// discarded — there is deliberately no `SplitType` column anywhere (I2:
/// "if (archetype == ppl)" branches are exactly what this avoids).
enum Archetype { ppl, broSplit, twoMuscle, hybrid }

/// weekday -> suggested day name, or null for a suggested rest day. Callers
/// turn the distinct non-null names into [WorkoutDay] rows and the map
/// itself into slot assignments; nothing about [Archetype] survives past
/// that translation.
Map<Weekday, String?> suggestedWeekMap(Archetype archetype) {
  switch (archetype) {
    case Archetype.ppl:
      return {
        Weekday.mon: 'Push',
        Weekday.tue: 'Pull',
        Weekday.wed: 'Legs',
        Weekday.thu: 'Push',
        Weekday.fri: 'Pull',
        Weekday.sat: 'Legs',
        Weekday.sun: null,
      };
    case Archetype.broSplit:
      return {
        Weekday.mon: 'Chest',
        Weekday.tue: 'Back',
        Weekday.wed: 'Shoulders',
        Weekday.thu: 'Arms',
        Weekday.fri: 'Legs',
        Weekday.sat: null,
        Weekday.sun: null,
      };
    case Archetype.twoMuscle:
      return {
        Weekday.mon: 'Chest + Tri',
        Weekday.tue: 'Back + Bi',
        Weekday.wed: 'Legs',
        Weekday.thu: 'Shoulders + Arms',
        Weekday.fri: null,
        Weekday.sat: null,
        Weekday.sun: null,
      };
    case Archetype.hybrid:
      return {for (final w in Weekday.values) w: null};
  }
}

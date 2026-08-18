import 'package:rep_tracker/domain/models/exercise.dart';
import 'package:rep_tracker/domain/rules/prefill.dart';
import 'package:test/test.dart';

Exercise _exercise({
  double? incrementOverride,
  double equipmentIncrement = 2.5,
}) =>
    Exercise(
      id: 'x',
      name: 'X',
      primaryMuscle: Muscle.quads,
      equipment: Equipment.barbell,
      incrementOverride: incrementOverride,
      equipmentIncrement: equipmentIncrement,
    );

void main() {
  group('resolveIncrementKg', () {
    test('user override always wins over learned or equipment default', () {
      final exercise =
          _exercise(incrementOverride: 1.25, equipmentIncrement: 5);
      expect(
        resolveIncrementKg(
          exercise: exercise,
          recentDistinctLoads: [40, 60, 75],
        ),
        1.25,
      );
    });

    test('returns 5 for loads [40, 60, 75]', () {
      final exercise = _exercise();
      expect(
        resolveIncrementKg(
          exercise: exercise,
          recentDistinctLoads: [40, 60, 75],
        ),
        5.0,
      );
    });

    test('returns 2.5 for loads [7.5, 10, 32.5]', () {
      final exercise = _exercise();
      expect(
        resolveIncrementKg(
          exercise: exercise,
          recentDistinctLoads: [7.5, 10, 32.5],
        ),
        2.5,
      );
    });

    test('floors a [30, 30.5] input to the equipment default', () {
      final exercise = _exercise(equipmentIncrement: 5);
      expect(
        resolveIncrementKg(exercise: exercise, recentDistinctLoads: [30, 30.5]),
        5.0,
      );
    });
  });

  group('repQuickPicks', () {
    test('spans n-1 to n+2, biased upward', () {
      expect(repQuickPicks(8), [7, 8, 9, 10]);
    });

    test('never goes below 1', () {
      expect(repQuickPicks(1), [1, 2, 3, 4]);
    });
  });
}

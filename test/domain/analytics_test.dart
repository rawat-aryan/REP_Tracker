import 'package:rep_tracker/domain/rules/analytics.dart';
import 'package:test/test.dart';

void main() {
  group('exerciseOverlap', () {
    test('is order-independent', () {
      final a = {'squat', 'hip_thrust', 'leg_curl'};
      final b = {'leg_curl', 'squat', 'hip_thrust'};
      expect(exerciseOverlap(a, b), exerciseOverlap(b, a));
      expect(exerciseOverlap(a, b), 1.0);
    });

    test('drops below the split-day threshold on a genuinely different day',
        () {
      final legs = {'squat', 'hip_thrust', 'leg_curl'};
      final arms = {'bicep_curl', 'tricep_pushdown'};
      expect(exerciseOverlap(legs, arms), lessThan(kSplitDayThreshold));
    });
  });

  test('estimatedOneRepMax is null with no weight, and grows with reps', () {
    expect(estimatedOneRepMax(weightKg: null, reps: 8), isNull);
    final low = estimatedOneRepMax(weightKg: 60, reps: 3)!;
    final high = estimatedOneRepMax(weightKg: 60, reps: 10)!;
    expect(high, greaterThan(low));
  });
}

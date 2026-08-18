import 'package:rep_tracker/domain/models/load.dart';
import 'package:rep_tracker/domain/models/workout_set.dart';
import 'package:rep_tracker/domain/rules/analytics.dart';
import 'package:test/test.dart';

WorkoutSet _set({
  required int index,
  required Execution execution,
  required double weightKg,
  required DateTime startedAt,
}) =>
    WorkoutSet(
      id: 's$index-${execution.name}',
      exerciseId: 'ham_curl',
      index: index,
      execution: execution,
      startedAt: startedAt,
      endedAt: startedAt.add(const Duration(seconds: 40)),
      segments: [
        SetSegment(load: Load(value: weightKg, source: LoadSource.machineStack), reps: 10),
      ],
    );

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

  group('chartSeries / splitByExecution — the ham curl case (milestone 08)', () {
    final day1 = DateTime(2026, 8, 1);
    final day2 = DateTime(2026, 8, 3);
    final mixed = [
      _set(index: 1, execution: Execution.unilateral, weightKg: 40, startedAt: day1),
      _set(index: 2, execution: Execution.bilateral, weightKg: 60, startedAt: day2),
    ];

    test('two separate series, never one merged line', () {
      final byExecution = splitByExecution(mixed);
      final uni = chartSeries(byExecution[Execution.unilateral]!, ChartMetric.topSet);
      final bi = chartSeries(byExecution[Execution.bilateral]!, ChartMetric.topSet);

      expect(uni, hasLength(1));
      expect(bi, hasLength(1));
      // Neither series contains both weights — no 40->60 jump within one line.
      expect(uni.map((p) => p.value), [40.0]);
      expect(bi.map((p) => p.value), [60.0]);
    });

    test('volume metric is comparable across both, unlike e1RM/top set', () {
      final byExecution = splitByExecution(mixed);
      final uniVolume = chartSeries(byExecution[Execution.unilateral]!, ChartMetric.volume);
      final biVolume = chartSeries(byExecution[Execution.bilateral]!, ChartMetric.volume);
      expect(uniVolume.single.value, 400.0); // 40kg x 10 reps
      expect(biVolume.single.value, 600.0); // 60kg x 10 reps
    });

    test('a set with no timing data is skipped, never plotted at a fake x', () {
      const untimed = WorkoutSet(
        id: 'untimed',
        exerciseId: 'ham_curl',
        index: 1,
        segments: [SetSegment(load: Load(value: 50, source: LoadSource.machineStack), reps: 8)],
      );
      expect(chartSeries([untimed], ChartMetric.topSet), isEmpty);
    });
  });
}

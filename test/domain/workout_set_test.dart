import 'package:rep_tracker/domain/models/load.dart';
import 'package:rep_tracker/domain/models/workout_set.dart';
import 'package:test/test.dart';

void main() {
  test('drop set is one WorkoutSet with three segments and an aggregate of 50',
      () {
    // "3- 7.5, 5, 2.5 drop -> Total 50 reps" from the reference log.
    const set = WorkoutSet(
      id: 's1',
      exerciseId: 'lateral_raise',
      index: 2,
      segments: [
        SetSegment(load: Load(value: 7.5, source: LoadSource.dumbbell)),
        SetSegment(load: Load(value: 5, source: LoadSource.dumbbell)),
        SetSegment(load: Load(value: 2.5, source: LoadSource.dumbbell)),
      ],
      aggregateReps: 50,
      tags: {SetTag.dropSet},
    );

    expect(set.segments, hasLength(3));
    expect(set.aggregateReps, 50);
    expect(set.hasReps, isTrue);
  });

  test('a set with weight and no reps is still valid (I4)', () {
    const set = WorkoutSet(
      id: 's2',
      exerciseId: 'barbell_squat',
      index: 0,
      segments: [
        SetSegment(load: Load(value: 60, source: LoadSource.barbell)),
      ],
    );

    expect(set.hasReps, isFalse);
    expect(set.segments.single.reps, isNull);
  });
}

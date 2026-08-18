import 'package:rep_tracker/data/repositories/drift_prefill_service.dart';
import 'package:rep_tracker/data/repositories/exercise_repository.dart';
import 'package:rep_tracker/data/repositories/session_repository.dart';
import 'package:rep_tracker/domain/models/load.dart';
import 'package:rep_tracker/domain/models/session.dart';
import 'package:rep_tracker/domain/models/workout_set.dart';
import 'package:test/test.dart';

import 'db_test_utils.dart';

void main() {
  group('ham curls execution prefill (§8.1)', () {
    test('keyed on set index, not just the exercise', () async {
      final db = openTestDb();
      final sessions = SessionRepository(db);
      final exercises = ExerciseRepository(db);
      final prefill = DriftPrefillService(sessions, exercises);

      // "3- Single -40, 60, 75" — set 1 unilateral, sets 2-3 bilateral.
      await sessions.createSession(
        Session(
          id: 'past-session',
          date: DateTime(2026, 8, 10),
          startedAt: DateTime(2026, 8, 10, 9),
          endedAt: DateTime(2026, 8, 10, 10),
          exercises: [
            const SessionExercise(
              exerciseId: 'ham_curl',
              planOrder: 0,
              sets: [
                WorkoutSet(
                  id: 'set1',
                  exerciseId: 'ham_curl',
                  index: 1,
                  execution: Execution.unilateral,
                  segments: [
                    SetSegment(
                      load: Load(
                        value: 40,
                        source: LoadSource.machineStack,
                        scope: LoadScope.perLimb,
                      ),
                      reps: 12,
                    ),
                  ],
                ),
                WorkoutSet(
                  id: 'set2',
                  exerciseId: 'ham_curl',
                  index: 2,
                  execution: Execution.bilateral,
                  segments: [
                    SetSegment(
                      load: Load(value: 60, source: LoadSource.machineStack),
                      reps: 10,
                    ),
                  ],
                ),
                WorkoutSet(
                  id: 'set3',
                  exerciseId: 'ham_curl',
                  index: 3,
                  execution: Execution.bilateral,
                  segments: [
                    SetSegment(
                      load: Load(value: 75, source: LoadSource.machineStack),
                      reps: 8,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );

      expect(
        await prefill.executionFor(exerciseId: 'ham_curl', setIndex: 1),
        Execution.unilateral,
      );
      expect(
        await prefill.executionFor(exerciseId: 'ham_curl', setIndex: 2),
        Execution.bilateral,
      );

      await db.close();
    });
  });

  test(
      'drop set round-trips as one WorkoutSet with 3 segments and aggregateReps',
      () async {
    final db = openTestDb();
    final sessions = SessionRepository(db);

    await sessions.createSession(
      Session(
        id: 's1',
        date: DateTime(2026, 8, 18),
        startedAt: DateTime(2026, 8, 18, 9),
        exercises: [
          const SessionExercise(
            exerciseId: 'lateral_raise',
            planOrder: 0,
            sets: [
              WorkoutSet(
                id: 'set1',
                exerciseId: 'lateral_raise',
                index: 1,
                tags: {SetTag.dropSet},
                aggregateReps: 50,
                segments: [
                  SetSegment(
                    load: Load(value: 7.5, source: LoadSource.dumbbell),
                  ),
                  SetSegment(load: Load(value: 5, source: LoadSource.dumbbell)),
                  SetSegment(
                    load: Load(value: 2.5, source: LoadSource.dumbbell),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    final loaded = await sessions.getById('s1');
    final set = loaded!.exercises.single.sets.single;
    expect(set.segments, hasLength(3));
    expect(set.aggregateReps, 50);
    expect(set.tags, contains(SetTag.dropSet));

    await db.close();
  });

  test('a set with weight and no reps round-trips through the DB (I4)',
      () async {
    final db = openTestDb();
    final sessions = SessionRepository(db);

    await sessions.createSession(
      Session(
        id: 's2',
        date: DateTime(2026, 8, 18),
        startedAt: DateTime(2026, 8, 18, 9),
        exercises: [
          const SessionExercise(
            exerciseId: 'barbell_squat',
            planOrder: 0,
            sets: [
              WorkoutSet(
                id: 'set1',
                exerciseId: 'barbell_squat',
                index: 1,
                segments: [
                  SetSegment(load: Load(value: 60, source: LoadSource.barbell)),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    final loaded = await sessions.getById('s2');
    final set = loaded!.exercises.single.sets.single;
    expect(set.segments.single.load.value, 60);
    expect(set.segments.single.reps, isNull);
    expect(set.hasReps, isFalse);

    await db.close();
  });
}

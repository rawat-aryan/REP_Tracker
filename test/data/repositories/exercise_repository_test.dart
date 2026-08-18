import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rep_tracker/data/database.dart';
import 'package:rep_tracker/data/repositories/exercise_repository.dart';
import 'package:rep_tracker/data/repositories/session_repository.dart';
import 'package:rep_tracker/domain/models/exercise.dart';
import 'package:rep_tracker/domain/models/load.dart';
import 'package:rep_tracker/domain/models/session.dart';
import 'package:rep_tracker/domain/models/workout_set.dart';

const _hackSquat = Exercise(
  id: 'hack_squat',
  name: 'Hack squat',
  primaryMuscle: Muscle.quads,
  equipment: Equipment.machine,
);

const _barbellSquat = Exercise(
  id: 'barbell_squat',
  name: 'Barbell squat',
  primaryMuscle: Muscle.quads,
  equipment: Equipment.barbell,
  aliases: ['back squat'],
);

WorkoutSet _set(String id, String exerciseId, double kg) => WorkoutSet(
      id: id,
      exerciseId: exerciseId,
      index: 1,
      startedAt: DateTime(2026, 8, 1),
      endedAt: DateTime(2026, 8, 1, 0, 1),
      segments: [SetSegment(load: Load(value: kg, source: LoadSource.barbell), reps: 8)],
    );

void main() {
  test(
    'milestone 10 Done-when: merging leaves every historical set intact under '
    'the surviving ID, no gap',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      final exercises = ExerciseRepository(db);
      final sessions = SessionRepository(db);
      await exercises.upsert(_barbellSquat);
      await exercises.upsert(_hackSquat);

      await sessions.createSession(
        Session(id: 's1', date: DateTime(2026, 8, 1), startedAt: DateTime(2026, 8, 1)),
      );
      await sessions.addSet(
        sessionId: 's1',
        exerciseId: 'barbell_squat',
        planOrder: 0,
        set: _set('set1', 'barbell_squat', 100),
      );
      // The user forked a duplicate entry by typo/distraction — some sets
      // ended up logged under the wrong (hack squat) id.
      await sessions.addSet(
        sessionId: 's1',
        exerciseId: 'hack_squat',
        planOrder: 1,
        set: _set('set2', 'hack_squat', 105),
      );

      await exercises.merge(keepId: 'barbell_squat', loserId: 'hack_squat');

      final history = await sessions.historyForExercise('barbell_squat');
      expect(history, hasLength(2));
      expect(history.map((s) => s.id), containsAll(['set1', 'set2']));
      // No gap: every set now reports the surviving exercise id.
      expect(history.every((s) => s.exerciseId == 'barbell_squat'), isTrue);

      // The loser is archived, never deleted (I7) — still resolvable, just
      // hidden from pickers.
      final loser = await exercises.getById('hack_squat');
      expect(loser!.archived, isTrue);
      final active = await exercises.getAll();
      expect(active.map((e) => e.id), isNot(contains('hack_squat')));

      await db.close();
    },
  );

  test('archive hides from getAll but keeps the row (I7)', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final exercises = ExerciseRepository(db);
    await exercises.upsert(_barbellSquat);

    await exercises.archive('barbell_squat');

    expect(await exercises.getAll(), isEmpty);
    final withArchived = await exercises.getAll(includeArchived: true);
    expect(withArchived, hasLength(1));
    expect(withArchived.single.archived, isTrue);

    await db.close();
  });

  test('search matches name and aliases, case-insensitively', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final exercises = ExerciseRepository(db);
    await exercises.upsert(_barbellSquat);

    expect((await exercises.search('barbell')).map((e) => e.id), contains('barbell_squat'));
    expect((await exercises.search('BACK SQUAT')).map((e) => e.id), contains('barbell_squat'));
    expect(await exercises.search('leg curl'), isEmpty);

    await db.close();
  });

  test('increment override round-trips through upsert', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final exercises = ExerciseRepository(db);
    await exercises.upsert(_barbellSquat);

    final updated = _barbellSquat.copyWith(incrementOverride: 5.0);
    await exercises.upsert(updated);

    final reloaded = await exercises.getById('barbell_squat');
    expect(reloaded!.incrementOverride, 5.0);

    await db.close();
  });

  test('variantOf is a display pointer only — never merges history', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final exercises = ExerciseRepository(db);
    await exercises.upsert(_barbellSquat);
    await exercises.upsert(_hackSquat.copyWith(variantOf: 'barbell_squat'));

    final reloaded = await exercises.getById('hack_squat');
    expect(reloaded!.variantOf, 'barbell_squat');
    // Still its own independent id — no repointing happened.
    expect(await exercises.getById('hack_squat'), isNotNull);
    expect(await exercises.getById('barbell_squat'), isNotNull);

    await db.close();
  });
}

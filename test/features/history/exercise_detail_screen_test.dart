import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rep_tracker/data/database.dart';
import 'package:rep_tracker/data/repositories/exercise_repository.dart';
import 'package:rep_tracker/data/repositories/session_repository.dart';
import 'package:rep_tracker/domain/models/exercise.dart';
import 'package:rep_tracker/domain/models/load.dart';
import 'package:rep_tracker/domain/models/session.dart';
import 'package:rep_tracker/domain/models/workout_set.dart';
import 'package:rep_tracker/features/history/exercise_detail_screen.dart';
import 'package:rep_tracker/providers.dart';

const _hamCurl = Exercise(
  id: 'ham_curl',
  name: 'Ham curl',
  primaryMuscle: Muscle.hamstrings,
  equipment: Equipment.machine,
);

Widget _harness(AppDatabase db) => ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(
        home: ExerciseDetailScreen(exerciseId: 'ham_curl', exerciseName: 'Ham curl'),
      ),
    );

WorkoutSet _set(int index, Execution execution, double kg, DateTime at) => WorkoutSet(
      id: 'set-$index-${execution.name}',
      exerciseId: 'ham_curl',
      index: index,
      execution: execution,
      startedAt: at,
      endedAt: at.add(const Duration(seconds: 40)),
      segments: [SetSegment(load: Load(value: kg, source: LoadSource.machineStack), reps: 10)],
    );

void main() {
  testWidgets(
    'the ham curl case: two separate series, no 40->60 jump, both scale badges shown',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      await ExerciseRepository(db).upsert(_hamCurl);
      final sessions = SessionRepository(db);
      await sessions.createSession(
        Session(id: 's1', date: DateTime(2026, 8, 1), startedAt: DateTime(2026, 8, 1)),
      );
      await sessions.addSet(
        sessionId: 's1',
        exerciseId: 'ham_curl',
        planOrder: 0,
        set: _set(1, Execution.unilateral, 40, DateTime(2026, 8, 1, 9)),
      );
      await sessions.addSet(
        sessionId: 's1',
        exerciseId: 'ham_curl',
        planOrder: 0,
        set: _set(2, Execution.bilateral, 60, DateTime(2026, 8, 3, 9)),
      );

      await tester.pumpWidget(_harness(db));
      await tester.pumpAndSettle();

      expect(find.text('2 sets logged'), findsOneWidget);

      // Switch to the raw "Top set" metric so the labels read the literal
      // logged weights — the milestone's own Done-when wording (40kg
      // unilateral, 60kg bilateral, never merged into one number).
      await tester.tap(find.text('Top set'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Bilateral · 60'), findsOneWidget);
      expect(find.textContaining('Unilateral · 40'), findsOneWidget);
      expect(find.text('Compare with another exercise'), findsOneWidget);

      await db.close();
    },
  );

  testWidgets(
    'a single logged set still renders (dots stay on — a lone point has no line segment to draw)',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      await ExerciseRepository(db).upsert(_hamCurl);
      final sessions = SessionRepository(db);
      await sessions.createSession(
        Session(id: 's1', date: DateTime(2026, 8, 1), startedAt: DateTime(2026, 8, 1)),
      );
      await sessions.addSet(
        sessionId: 's1',
        exerciseId: 'ham_curl',
        planOrder: 0,
        set: _set(1, Execution.bilateral, 60, DateTime(2026, 8, 1, 9)),
      );

      await tester.pumpWidget(_harness(db));
      await tester.pumpAndSettle();

      expect(find.text('1 set logged'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await db.close();
    },
  );

  testWidgets('no history yet shows the empty state, not a broken chart', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    await ExerciseRepository(db).upsert(_hamCurl);

    await tester.pumpWidget(_harness(db));
    await tester.pumpAndSettle();

    expect(find.textContaining('No sets logged yet'), findsOneWidget);

    await db.close();
  });
}

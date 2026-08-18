import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rep_tracker/data/database.dart';
import 'package:rep_tracker/data/repositories/exercise_repository.dart';
import 'package:rep_tracker/domain/models/exercise.dart';
import 'package:rep_tracker/features/exercise/exercise_edit_screen.dart';
import 'package:rep_tracker/providers.dart';

const _barbellSquat = Exercise(
  id: 'barbell_squat',
  name: 'Barbell squat',
  primaryMuscle: Muscle.quads,
  equipment: Equipment.barbell,
);

const _hackSquat = Exercise(
  id: 'hack_squat',
  name: 'Hack squat',
  primaryMuscle: Muscle.quads,
  equipment: Equipment.machine,
);

Widget _harness(AppDatabase db) => ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: ExerciseEditScreen(exerciseId: 'barbell_squat')),
    );

void main() {
  testWidgets('merging another exercise into this one archives it and repoints history',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final exercises = ExerciseRepository(db);
    await exercises.upsert(_barbellSquat);
    await exercises.upsert(_hackSquat);

    await tester.pumpWidget(_harness(db));
    await tester.pumpAndSettle();

    expect(find.text('Barbell squat'), findsWidgets);

    await tester.tap(find.text('Merge another exercise into this one'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hack squat'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Merge "Hack squat" into "Barbell squat"?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Merge'));
    await tester.pumpAndSettle();

    final loser = await exercises.getById('hack_squat');
    expect(loser!.archived, isTrue);

    await db.close();
  });

  testWidgets(
    'leaving the increment field by losing focus (e.g. navigating back) still saves it — '
    'not just the keyboard "done" action',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      final exercises = ExerciseRepository(db);
      await exercises.upsert(_barbellSquat);

      await tester.pumpWidget(_harness(db));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, '5');
      await tester.pumpAndSettle();
      // No receiveAction(TextInputAction.done) here — just move focus
      // elsewhere, the way tapping the back arrow does in the real app.
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      final reloaded = await exercises.getById('barbell_squat');
      expect(reloaded!.incrementOverride, 5.0);

      await db.close();
    },
  );

  testWidgets('editing the weight increment override persists it via the keyboard done action',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final exercises = ExerciseRepository(db);
    await exercises.upsert(_barbellSquat);

    await tester.pumpWidget(_harness(db));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, '5');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final reloaded = await exercises.getById('barbell_squat');
    expect(reloaded!.incrementOverride, 5.0);

    await db.close();
  });
}

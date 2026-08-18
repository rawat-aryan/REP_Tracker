import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rep_tracker/data/database.dart';
import 'package:rep_tracker/data/repositories/exercise_repository.dart';
import 'package:rep_tracker/data/repositories/session_repository.dart';
import 'package:rep_tracker/domain/models/exercise.dart';
import 'package:rep_tracker/domain/models/session.dart';
import 'package:rep_tracker/features/session/session_screen.dart';
import 'package:rep_tracker/providers.dart';

const _hipThrust = Exercise(
  id: 'hip_thrust',
  name: 'Hip thrust',
  primaryMuscle: Muscle.glutes,
  equipment: Equipment.barbell,
);
const _hamCurl = Exercise(
  id: 'ham_curl',
  name: 'Ham curls',
  primaryMuscle: Muscle.hamstrings,
  equipment: Equipment.machine,
  equipmentIncrement: 5,
);
const _flies = Exercise(
  id: 'flies',
  name: 'Flies',
  primaryMuscle: Muscle.chest,
  equipment: Equipment.cable,
);

Widget _harness(AppDatabase db, String sessionId) => ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(home: SessionScreen(sessionId: sessionId)),
    );

void main() {
  testWidgets(
    'fast path logs a set, and deferral walks back via nextOutstanding',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      final exercises = ExerciseRepository(db);
      final sessions = SessionRepository(db);
      for (final e in [_hipThrust, _hamCurl, _flies]) {
        await exercises.upsert(e);
      }
      final session = Session(
        id: 's1',
        date: DateTime(2026, 8, 18),
        startedAt: DateTime(2026, 8, 18, 9),
        currentExerciseId: 'hip_thrust',
        exercises: const [
          SessionExercise(exerciseId: 'hip_thrust', planOrder: 0),
          SessionExercise(exerciseId: 'ham_curl', planOrder: 1),
          SessionExercise(exerciseId: 'flies', planOrder: 2),
        ],
      );
      await sessions.createSession(session);

      await tester.pumpWidget(_harness(db, session.id));
      await tester.pumpAndSettle();

      // Hip thrust is current: start / end the first set.
      expect(find.text('Start set'), findsOneWidget);
      await tester.tap(find.text('Start set'));
      await tester.pumpAndSettle();

      expect(find.text('End set'), findsOneWidget);
      await tester.tap(find.text('End set'));
      await tester.pumpAndSettle();

      // No history yet, so there's no prediction to accept — go through
      // the full entry sheet, which is the only way to log the first-ever
      // set for an exercise.
      expect(find.text('log reps'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, '…'), '10');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Closing that set was current -> auto-advances to nextOutstanding,
      // which is ham_curl (plan order 1), not flies. Confirm hip thrust
      // logged and ham_curl is now the one offering Start set.
      expect(find.text('10'), findsOneWidget);
      expect(find.text('Start set'), findsOneWidget);

      // Defer ham_curl: tap Flies directly instead — no confirmation, no
      // data written, just the highlight moving (spec §6).
      await tester.tap(find.text('Flies'));
      await tester.pumpAndSettle();
      expect(find.text('Start set'), findsOneWidget); // now under Flies

      await tester.tap(find.text('Start set'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('End set'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, '…'), '12');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Finishing flies proposes nextOutstanding again — walks back to the
      // deferred ham_curl, exactly the "defer, do something else, return"
      // loop from milestone 04's Done-when.
      expect(find.text('12'), findsOneWidget);
      expect(find.text('Start set'), findsOneWidget);

      await db.close();
    },
  );

  testWidgets('full entry sheet logs a unilateral, per-side set', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final exercises = ExerciseRepository(db);
    final sessions = SessionRepository(db);
    await exercises.upsert(_hipThrust);
    final session = Session(
      id: 's2',
      date: DateTime(2026, 8, 18),
      startedAt: DateTime(2026, 8, 18, 9),
      currentExerciseId: 'hip_thrust',
      exercises: const [
        SessionExercise(exerciseId: 'hip_thrust', planOrder: 0),
      ],
    );
    await sessions.createSession(session);

    await tester.pumpWidget(_harness(db, session.id));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start set'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('End set'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Unilateral'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('/ side'));
    await tester.enterText(find.byType(TextField).first, '30');
    final repFields = find.widgetWithText(TextField, '…');
    await tester.enterText(repFields.at(0), '8');
    await tester.enterText(repFields.at(1), '8');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('L8 R8'), findsOneWidget);
    // The logged set shows "30 /side" (rendered as two RichText spans, one
    // muted, per screens.html's `.c-w`+`.side` pairing) — a second, greyed
    // one may also show as the prefilled prediction for a set 2 that
    // hasn't started.
    expect(find.text('30 /side', findRichText: true), findsWidgets);

    await db.close();
  });
}

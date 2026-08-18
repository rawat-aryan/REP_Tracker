import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rep_tracker/data/database.dart';
import 'package:rep_tracker/data/repositories/exercise_repository.dart';
import 'package:rep_tracker/data/repositories/plan_repository.dart';
import 'package:rep_tracker/data/repositories/session_repository.dart';
import 'package:rep_tracker/domain/models/exercise.dart';
import 'package:rep_tracker/domain/models/load.dart';
import 'package:rep_tracker/domain/models/plan.dart';
import 'package:rep_tracker/domain/models/session.dart';
import 'package:rep_tracker/domain/models/workout_set.dart';
import 'package:rep_tracker/domain/rules/home.dart';
import 'package:rep_tracker/features/home/home_screen.dart';
import 'package:rep_tracker/providers.dart';

const _hipThrust = Exercise(
  id: 'hip_thrust',
  name: 'Hip thrust',
  primaryMuscle: Muscle.glutes,
  equipment: Equipment.barbell,
);

final _monday = DateTime(2026, 8, 17, 9);

Widget _harness(AppDatabase db, {DateTime? now}) => ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        if (now != null) nowProvider.overrideWithValue(now),
      ],
      child: const MaterialApp(home: HomeScreen()),
    );

Future<void> _seedPlan(AppDatabase db, {Weekday scheduledOn = Weekday.mon}) async {
  final exercises = ExerciseRepository(db);
  final plans = PlanRepository(db);
  await exercises.upsert(_hipThrust);
  await plans.upsertWorkoutDay(
    const WorkoutDay(
      id: demoDayId,
      name: 'Legs',
      exercises: [PlannedExercise(exerciseId: 'hip_thrust', order: 0)],
    ),
  );
  await plans.createWeekPlanVersion(
    WeekPlan(routineId: demoRoutineId, version: 1, slots: {scheduledOn: demoDayId}),
  );
}

void main() {
  testWidgets('planned, not started shows Start and the intent list', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    await _seedPlan(db);

    await tester.pumpWidget(_harness(db, now: _monday));
    await tester.pumpAndSettle();

    expect(find.text('Legs'), findsOneWidget);
    expect(find.text('Hip thrust'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);

    await db.close();
  });

  testWidgets('rest day shows no call to action', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    await _seedPlan(db); // only Monday is scheduled

    await tester.pumpWidget(_harness(db, now: DateTime(2026, 8, 18, 9))); // a Tuesday
    await tester.pumpAndSettle();

    expect(find.text('Rest'), findsOneWidget);
    expect(find.text('Start'), findsNothing);
    expect(find.text('Resume'), findsNothing);

    await db.close();
  });

  testWidgets(
    'force-quitting mid-set and reopening lands on in progress with correct elapsed time',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      // The elapsed pill ticks off the real wall clock (spec §7 — no pushed
      // per-second updates), so this test schedules the demo day on
      // whatever weekday "now" actually is, rather than freezing the clock.
      final now = DateTime.now();
      await _seedPlan(db, scheduledOn: weekdayOf(now));
      final sessions = SessionRepository(db);
      final startedAt = now.subtract(const Duration(minutes: 12));
      await sessions.createSession(
        Session(
          id: 'in-progress',
          date: now,
          startedAt: startedAt,
          workoutDayId: demoDayId,
          currentExerciseId: 'hip_thrust',
          exercises: const [SessionExercise(exerciseId: 'hip_thrust', planOrder: 0)],
        ),
      );

      // "Force-quit and reopen" is exactly a fresh widget tree over the same
      // (real, persisted) DB — nothing here comes from in-memory app state.
      await tester.pumpWidget(_harness(db, now: now));
      await tester.pumpAndSettle();

      expect(find.text('Resume'), findsOneWidget);
      expect(find.textContaining('12:'), findsOneWidget); // elapsed pill, mm:ss

      await db.close();
    },
  );

  testWidgets('done stays fully editable, no locking', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    await _seedPlan(db);
    final sessions = SessionRepository(db);
    await sessions.createSession(
      Session(
        id: 'done',
        date: _monday,
        startedAt: _monday,
        endedAt: _monday.add(const Duration(minutes: 40)),
        workoutDayId: demoDayId,
        exercises: const [SessionExercise(exerciseId: 'hip_thrust', planOrder: 0)],
      ),
    );

    await tester.pumpWidget(_harness(db, now: _monday));
    await tester.pumpAndSettle();

    expect(find.text('Add something you forgot'), findsOneWidget);
    await tester.tap(find.text('Add something you forgot'));
    await tester.pumpAndSettle();

    // Lands back in the session ledger, not blocked by any "ended" state.
    // The header now resolves the real day name (async, off workoutDayId),
    // so "Add exercise" is the reliable marker that we're in the ledger.
    expect(find.text('+  Add exercise'), findsOneWidget);

    await db.close();
  });

  testWidgets(
    'milestone 09: a pattern that has held for 2 consecutive Tuesdays shows a '
    'provisional header on an unassigned Tuesday, and confirming assigns it',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      final exercises = ExerciseRepository(db);
      final sessions = SessionRepository(db);
      await _seedPlan(db); // Monday -> Legs; Tuesday is unassigned (rest)
      await exercises.upsert(
        const Exercise(id: 'bicep_curl', name: 'Bicep curl', primaryMuscle: Muscle.biceps, equipment: Equipment.dumbbell),
      );

      Future<void> logTuesday(DateTime tuesday) async {
        final id = 's-${tuesday.toIso8601String()}';
        await sessions.createSession(Session(id: id, date: tuesday, startedAt: tuesday));
        await sessions.addSet(
          sessionId: id,
          exerciseId: 'bicep_curl',
          planOrder: 0,
          set: WorkoutSet(
            id: '$id-set1',
            exerciseId: 'bicep_curl',
            index: 1,
            startedAt: tuesday,
            endedAt: tuesday.add(const Duration(seconds: 30)),
            segments: const [SetSegment(load: Load(value: 12, source: LoadSource.dumbbell), reps: 10)],
          ),
        );
      }

      // The two most recent Tuesdays before "now" (a later Tuesday).
      final now = DateTime(2026, 8, 18, 9); // a Tuesday
      await logTuesday(DateTime(2026, 8, 4, 9));
      await logTuesday(DateTime(2026, 8, 11, 9));

      await tester.pumpWidget(_harness(db, now: now));
      await tester.pumpAndSettle();

      expect(find.textContaining('?'), findsOneWidget);
      expect(find.text('tap to confirm'), findsOneWidget);

      await tester.tap(find.text('tap to confirm'));
      await tester.pumpAndSettle();

      final plans = PlanRepository(db);
      final plan = await plans.getLatestWeekPlan(demoRoutineId);
      expect(plan!.slots[Weekday.tue], isNotNull);
      final assignedDay = await plans.getWorkoutDay(plan.slots[Weekday.tue]!);
      expect(assignedDay!.exercises.map((e) => e.exerciseId), contains('bicep_curl'));

      await db.close();
    },
  );
}

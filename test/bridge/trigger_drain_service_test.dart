import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rep_tracker/bridge/fake_trigger_bridge.dart';
import 'package:rep_tracker/bridge/trigger_drain_service.dart';
import 'package:rep_tracker/bridge/trigger_event.dart';
import 'package:rep_tracker/data/repositories/drift_prefill_service.dart';
import 'package:rep_tracker/data/repositories/exercise_repository.dart';
import 'package:rep_tracker/data/repositories/plan_repository.dart';
import 'package:rep_tracker/data/repositories/session_repository.dart';
import 'package:rep_tracker/domain/models/exercise.dart';
import 'package:rep_tracker/domain/models/session.dart';

import '../data/db_test_utils.dart';

const _hipThrust = Exercise(
  id: 'hip_thrust',
  name: 'Hip thrust',
  primaryMuscle: Muscle.glutes,
  equipment: Equipment.barbell,
);

void main() {
  test('a full session logged from a locked phone: setStarted/setEnded '
      'become a WorkoutSet with journal timestamps, correct exercise '
      'attribution, and the app lands on rep entry for it', () async {
    final db = openTestDb();
    final exercises = ExerciseRepository(db);
    final sessions = SessionRepository(db);
    final plans = PlanRepository(db);
    final prefill = DriftPrefillService(sessions, exercises);
    await exercises.upsert(_hipThrust);

    final session = Session(
      id: 's1',
      date: DateTime(2026, 8, 18),
      startedAt: DateTime(2026, 8, 18, 9),
      currentExerciseId: 'hip_thrust',
      exercises: const [
        SessionExercise(exerciseId: 'hip_thrust', planOrder: 0),
      ],
    );
    await sessions.createSession(session);

    final dir = await Directory.systemTemp.createTemp('trigger_drain_test_');
    final bridge = FakeTriggerBridge(dir);
    final drainService = TriggerDrainService(
      bridge: bridge,
      sessions: sessions,
      exercises: exercises,
      plans: plans,
      prefill: prefill,
    );

    // The phone is locked and in a pocket: the trigger appends both events
    // — the app process never runs in between, exactly like §7 describes.
    final startedAt = DateTime.utc(2026, 8, 18, 9, 5, 0);
    final endedAt = DateTime.utc(2026, 8, 18, 9, 5, 45);
    await bridge.debugAppendEvent(
      TriggerEventType.setStarted,
      sessionId: 's1',
      at: startedAt,
    );
    await bridge.debugAppendEvent(
      TriggerEventType.setEnded,
      sessionId: 's1',
      at: endedAt,
    );

    // Drain happens much later than either timestamp — duration must come
    // from the journal, never from when drain ran (§7 "clock authority").
    final landing = await drainService.drainAndApply();

    expect(landing, isNotNull);
    expect(landing!.sessionId, 's1');
    expect(landing.exerciseId, 'hip_thrust');

    final reloaded = await sessions.getById('s1');
    final set = reloaded!.exercises.single.sets.single;
    // Drift round-trips DateTime through local time, so compare instants
    // rather than requiring both to carry the same isUtc flag.
    expect(set.startedAt!.isAtSameMomentAs(startedAt), isTrue);
    expect(set.endedAt!.isAtSameMomentAs(endedAt), isTrue);
    expect(set.duration, const Duration(seconds: 45));
    expect(set.isPhantom(), isFalse);

    // Nothing left to drain — idempotent, no duplicate set on a second call.
    expect(await drainService.drainAndApply(), isNull);
    final reloadedAgain = await sessions.getById('s1');
    expect(reloadedAgain!.exercises.single.sets, hasLength(1));

    await dir.delete(recursive: true);
    await db.close();
  });
}

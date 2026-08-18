import 'package:uuid/uuid.dart';

import '../data/repositories/exercise_repository.dart';
import '../data/repositories/session_repository.dart';
import '../domain/models/load.dart';
import '../domain/models/session.dart';
import '../domain/models/workout_set.dart';
import '../domain/rules/prefill.dart';
import 'trigger_event.dart';

const _uuid = Uuid();

/// Starts a set for [exerciseId] in [session], stamped at [at]. The single
/// path both a manual tap (`SessionController.startSet`, `at` =
/// `DateTime.now()`) and a drained native event (`at` = the journal's
/// authoritative timestamp, §7) go through, so prefill/load resolution never
/// drifts between the two.
Future<void> startSetFor({
  required Session session,
  required String exerciseId,
  required DateTime at,
  required SessionRepository sessions,
  required ExerciseRepository exercises,
  required PrefillService prefill,
}) async {
  final se = session.exercises.firstWhere((e) => e.exerciseId == exerciseId);
  final setIndex = se.sets.length + 1;
  final exercise = await exercises.getById(exerciseId);
  final execution = await prefill.executionFor(
    exerciseId: exerciseId,
    setIndex: setIndex,
  );
  final predictedLoad = await prefill.loadFor(
    exerciseId: exerciseId,
    setIndex: setIndex,
    currentSession: session,
  );
  final load = predictedLoad ??
      Load(
        source: exercise?.defaultLoadSource ?? LoadSource.barbell,
        scope: execution == Execution.unilateral
            ? LoadScope.perLimb
            : LoadScope.total,
      );
  await sessions.addSet(
    sessionId: session.id,
    exerciseId: exerciseId,
    planOrder: se.planOrder,
    set: WorkoutSet(
      id: _uuid.v4(),
      exerciseId: exerciseId,
      index: setIndex,
      execution: execution,
      segments: [SetSegment(load: load)],
      startedAt: at,
    ),
  );
}

/// Stops the clock on [exerciseId]'s currently running set, stamped at
/// [at] — never `DateTime.now()` for a drained event, or the set would
/// inherit the resume lag instead of the journal's own timestamp (§7).
Future<void> endSetFor({
  required Session session,
  required String exerciseId,
  required DateTime at,
  required SessionRepository sessions,
}) async {
  final se = session.exercises.firstWhere((e) => e.exerciseId == exerciseId);
  final running = se.sets.last;
  await sessions.updateSet(running.copyWith(endedAt: at));
}

/// What the ambient card (foreground notification / future Live Activity)
/// needs to render and to act on the next toggle press. Built fresh on every
/// state change so the card always names the exercise the next set will be
/// attributed to (§16 "must hold" — a silent mis-attribution is the one
/// failure mode that makes the whole pocket-trigger model untrustworthy).
Future<TriggerContext> buildTriggerContext({
  required Session session,
  required ExerciseRepository exercises,
  required PrefillService prefill,
  required String dayName,
}) async {
  final currentId = session.currentExerciseId ?? session.nextOutstanding;
  if (currentId == null) {
    return TriggerContext(
      sessionId: session.id,
      dayName: dayName,
      currentExerciseId: '',
      currentExerciseName: 'Workout',
      nextSetIndex: 1,
    );
  }
  final se = session.exercises.firstWhere((e) => e.exerciseId == currentId);
  final exercise = await exercises.getById(currentId);
  final runningSet = se.sets.isNotEmpty &&
          se.sets.last.startedAt != null &&
          se.sets.last.endedAt == null
      ? se.sets.last
      : null;
  final nextSetIndex = runningSet?.index ?? se.sets.length + 1;
  final predictedLoad = await prefill.loadFor(
    exerciseId: currentId,
    setIndex: nextSetIndex,
    currentSession: session,
  );
  final predictedReps =
      await prefill.repsFor(exerciseId: currentId, setIndex: nextSetIndex);
  final execution = runningSet?.execution ??
      await prefill.executionFor(exerciseId: currentId, setIndex: nextSetIndex);
  return TriggerContext(
    sessionId: session.id,
    dayName: dayName,
    currentExerciseId: currentId,
    currentExerciseName: exercise?.name ?? currentId,
    nextSetIndex: nextSetIndex,
    lastLoadKg: predictedLoad?.value,
    loadPerLimb: predictedLoad?.scope == LoadScope.perLimb,
    predictedReps: predictedReps,
    unilateral: execution == Execution.unilateral,
    activeSet: runningSet == null
        ? null
        : ActiveSet(eventId: runningSet.id, startedAt: runningSet.startedAt!),
  );
}

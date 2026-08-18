import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/repositories/exercise_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../domain/models/load.dart';
import '../../domain/models/session.dart';
import '../../domain/models/workout_set.dart';
import '../../domain/rules/prefill.dart';
import '../../providers.dart';

const _uuid = Uuid();

final sessionControllerProvider = StateNotifierProvider.family<
    SessionController, AsyncValue<Session>, String>((ref, sessionId) {
  return SessionController(
    sessionId: sessionId,
    sessions: ref.watch(sessionRepositoryProvider),
    exercises: ref.watch(exerciseRepositoryProvider),
    prefill: ref.watch(prefillServiceProvider),
  );
});

/// Drives the session screen (milestone 04). Manual start/end only — no
/// native trigger wired in yet, so a tap plays the role of the pocket
/// button. Every write here goes through [SessionRepository], so nothing is
/// lost if the app is killed mid-set (I5) and every set is independently
/// saveable with partial data (I4).
class SessionController extends StateNotifier<AsyncValue<Session>> {
  SessionController({
    required this.sessionId,
    required SessionRepository sessions,
    required ExerciseRepository exercises,
    required PrefillService prefill,
  })  : _sessions = sessions,
        _exercises = exercises,
        _prefill = prefill,
        super(const AsyncValue.loading()) {
    _reload();
  }

  final String sessionId;
  final SessionRepository _sessions;
  final ExerciseRepository _exercises;
  final PrefillService _prefill;

  Session get _session => state.value!;

  Future<void> _reload() async {
    final session = await _sessions.getById(sessionId);
    state = session == null
        ? AsyncValue.error('Session $sessionId not found', StackTrace.current)
        : AsyncValue.data(session);
  }

  SessionExercise _exerciseIn(Session session, String exerciseId) =>
      session.exercises.firstWhere((e) => e.exerciseId == exerciseId);

  /// Tap #1 of the loop: begins timing a set. Persists immediately with a
  /// prefilled load and no reps — a crash right after this tap loses
  /// nothing (I5).
  Future<void> startSet(String exerciseId) async {
    final session = _session;
    final se = _exerciseIn(session, exerciseId);
    final setIndex = se.sets.length + 1;
    final exercise = await _exercises.getById(exerciseId);
    final execution = await _prefill.executionFor(
      exerciseId: exerciseId,
      setIndex: setIndex,
    );
    final predictedLoad = await _prefill.loadFor(
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
    await _sessions.addSet(
      sessionId: sessionId,
      exerciseId: exerciseId,
      planOrder: se.planOrder,
      set: WorkoutSet(
        id: _uuid.v4(),
        exerciseId: exerciseId,
        index: setIndex,
        execution: execution,
        segments: [SetSegment(load: load)],
        startedAt: DateTime.now(),
      ),
    );
    await _reload();
    await setCurrent(exerciseId);
  }

  /// Tap #2: stops the clock. Reps are still unset — the row renders as a
  /// prediction (hollow) until confirmed.
  Future<void> endSet(String exerciseId) async {
    final se = _exerciseIn(_session, exerciseId);
    final running = se.sets.last;
    await _sessions.updateSet(running.copyWith(endedAt: DateTime.now()));
    await _reload();
  }

  /// The predicted reps for the set currently waiting on confirmation, or
  /// null if there's no history to predict from yet (first time performing
  /// this exercise/index — the UI should skip straight to full entry).
  Future<int?> predictedRepsFor(String exerciseId) {
    final se = _exerciseIn(_session, exerciseId);
    return _prefill.repsFor(exerciseId: exerciseId, setIndex: se.sets.last.index);
  }

  /// Tap #3, the fast path: accepts the prediction as-is. One tap closes
  /// the set (§8.2) and, since that was the live exercise, proposes
  /// whatever's still outstanding next — no prompt, just a highlight move.
  Future<void> acceptPrediction(String exerciseId, int reps) async {
    final se = _exerciseIn(_session, exerciseId);
    final set = se.sets.last;
    final seg = set.segments.first;
    final unilateral = set.execution == Execution.unilateral;
    await _sessions.updateSet(
      set.copyWith(
        segments: [
          seg.copyWith(
            reps: unilateral ? null : reps,
            repsLeft: unilateral ? reps : null,
            repsRight: unilateral ? reps : null,
          ),
        ],
      ),
    );
    await _finishClosingSet(exerciseId, wasCurrent: exerciseId == _session.currentExerciseId);
  }

  /// The overflow path (⋯): saves whatever the full-entry sheet produced —
  /// asymmetric reps, tags, a weight correction, or an edit to any past set.
  /// (I5: nothing here is gated on the set being "current".)
  Future<void> saveSetEdits(WorkoutSet edited) async {
    final wasCurrentAndLive = edited.exerciseId == _session.currentExerciseId &&
        _exerciseIn(_session, edited.exerciseId).sets.last.id == edited.id;
    await _sessions.updateSet(edited);
    await _finishClosingSet(edited.exerciseId, wasCurrent: wasCurrentAndLive);
  }

  Future<void> _finishClosingSet(String exerciseId, {required bool wasCurrent}) async {
    await _reload();
    if (!wasCurrent) return;
    final next = _session.nextOutstanding;
    if (next != null) await setCurrent(next);
  }

  /// Tap any exercise to make it current. No confirmation, no data written
  /// beyond the pointer itself (spec §6 "session is a pool").
  Future<void> setCurrent(String exerciseId) async {
    final updated = _session.copyWith(currentExerciseId: exerciseId);
    await _sessions.updateSessionMeta(updated);
    state = AsyncValue.data(updated);
  }

  /// Exercise picker result. Deferral (already in the pool) just switches
  /// the highlight; a genuinely new pick is appended off-plan with zero
  /// sets so it shows up in the pool immediately (I4).
  Future<void> addExercise(String exerciseId) async {
    final session = _session;
    final alreadyInPool = session.exercises.any((e) => e.exerciseId == exerciseId);
    if (!alreadyInPool) {
      await _sessions.addExerciseToSession(
        sessionId: sessionId,
        exerciseId: exerciseId,
        planOrder: session.exercises.length,
        offPlan: true,
      );
      await _reload();
    }
    await setCurrent(exerciseId);
  }

  /// "Done" never locks the session (I5) — this just stamps an end time
  /// that stays fully editable.
  Future<void> endSession() async {
    final updated = _session.copyWith(endedAt: DateTime.now());
    await _sessions.updateSessionMeta(updated);
    state = AsyncValue.data(updated);
  }
}

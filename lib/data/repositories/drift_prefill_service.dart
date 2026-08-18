import '../../domain/models/load.dart';
import '../../domain/models/session.dart';
import '../../domain/rules/prefill.dart';
import 'exercise_repository.dart';
import 'session_repository.dart';

/// Concrete [PrefillService]. Every read here is exercise-history-only
/// (I1) — see the abstract class in domain/rules/prefill.dart for why.
class DriftPrefillService implements PrefillService {
  DriftPrefillService(this._sessions, this._exercises);

  final SessionRepository _sessions;
  final ExerciseRepository _exercises;

  /// [setIndex] is 1-based — 1 means "set 1", the set about to be logged.
  @override
  Future<Load?> loadFor({
    required String exerciseId,
    required int setIndex,
    required Session currentSession,
  }) async {
    if (setIndex > 1) {
      // Later sets: the previous set (index setIndex - 1) in THIS session —
      // users rarely drop back down mid-exercise.
      for (final se in currentSession.exercises) {
        if (se.exerciseId != exerciseId) continue;
        if (se.sets.length < setIndex - 1) return null;
        final prevSegments = se.sets[setIndex - 2].segments;
        return prevSegments.isEmpty ? null : prevSegments.first.load;
      }
      return null;
    }

    // Set 1: the same exercise's set 1 in the last session it was performed.
    final last = await _sessions.lastSetAtIndex(
      exerciseId: exerciseId,
      setIndex: 1,
      excludeSessionId: currentSession.id,
    );
    if (last == null || last.segments.isEmpty) return null;
    return last.segments.first.load;
  }

  @override
  Future<int?> repsFor({
    required String exerciseId,
    required int setIndex,
  }) async {
    final last = await _sessions.lastSetAtIndex(
      exerciseId: exerciseId,
      setIndex: setIndex,
    );
    if (last == null) return null;
    if (last.segments.isNotEmpty && last.segments.first.reps != null) {
      return last.segments.first.reps;
    }
    return last.aggregateReps;
  }

  @override
  Future<Execution> executionFor({
    required String exerciseId,
    required int setIndex,
  }) async {
    final last = await _sessions.lastSetAtIndex(
      exerciseId: exerciseId,
      setIndex: setIndex,
    );
    if (last != null) return last.execution;
    final exercise = await _exercises.getById(exerciseId);
    return exercise?.defaultExecution ?? Execution.bilateral;
  }
}

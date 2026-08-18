import 'workout_set.dart';

/// Deferred is NOT a state. An exercise the user skipped to come back to later
/// is simply still notStarted. See spec §6 "the session is a pool, not a queue".
enum ExerciseProgress { notStarted, inProgress, done }

class SessionExercise {
  final String exerciseId;

  /// Position in the plan. The list NEVER reorders itself — only the current
  /// highlight moves — so the user's spatial memory of it holds.
  final int planOrder;

  final List<WorkoutSet> sets;

  /// True when the user added this mid-session, off-plan.
  final bool offPlan;

  const SessionExercise({
    required this.exerciseId,
    required this.planOrder,
    this.sets = const [],
    this.offPlan = false,
  });

  ExerciseProgress get progress => sets.isEmpty
      ? ExerciseProgress.notStarted
      : (sets.any((s) => s.endedAt == null)
          ? ExerciseProgress.inProgress
          : ExerciseProgress.done);
}

class Session {
  final String id;
  final DateTime date;

  /// Null for an improvised session with no plan behind it.
  final String? workoutDayId;

  /// Snapshot so editing the routine later never rewrites this session. (I5)
  final int? routineVersion;

  /// Names declared before starting — the cheap half the user knows in advance.
  final List<String> intendedExerciseIds;

  /// Several exercises may be inProgress at once. That is normal.
  final List<SessionExercise> exercises;

  /// Which exercise the next triggered set will be attributed to.
  /// MUST be surfaced on the ambient card — otherwise a mis-attributed set is
  /// silent and invisible, and the pocket-trigger model becomes untrustworthy.
  final String? currentExerciseId;

  final DateTime startedAt;

  /// Ending a session never locks it. (I5)
  final DateTime? endedAt;

  const Session({
    required this.id,
    required this.date,
    required this.startedAt,
    this.workoutDayId,
    this.routineVersion,
    this.intendedExerciseIds = const [],
    this.exercises = const [],
    this.currentExerciseId,
    this.endedAt,
  });

  /// Multiple sessions per date are allowed (morning legs, evening arms).
  /// Cheap now, painful to retrofit.

  /// The next exercise to propose after closing a set: the first notStarted
  /// in plan order. This is what walks the user back to what they deferred.
  String? get nextOutstanding {
    final pending = exercises
        .where((e) => e.progress == ExerciseProgress.notStarted)
        .toList()
      ..sort((a, b) => a.planOrder.compareTo(b.planOrder));
    return pending.isEmpty ? null : pending.first.exerciseId;
  }
}

import 'load.dart';

enum SetTag { warmup, dropSet, toFailure, myoRep, pause }

/// One load/rep pair inside a set.
///
/// Drop sets are ONE set with several segments, not several sets. That is how
/// the reference user wrote them ("3- 7.5, 5, 2.5 drop -> Total 50 reps") and
/// it keeps index-based prefill from shifting.
class SetSegment {
  final Load load;

  /// Null when only an aggregate is known.
  final int? reps;
  final int? repsLeft;
  final int? repsRight;

  const SetSegment({
    required this.load,
    this.reps,
    this.repsLeft,
    this.repsRight,
  });

  /// Total reps across both limbs — the comparable quantity for volume.
  int get totalReps => reps ?? ((repsLeft ?? 0) + (repsRight ?? 0));

  SetSegment copyWith({
    Load? load,
    int? reps,
    int? repsLeft,
    int? repsRight,
  }) =>
      SetSegment(
        load: load ?? this.load,
        reps: reps ?? this.reps,
        repsLeft: repsLeft ?? this.repsLeft,
        repsRight: repsRight ?? this.repsRight,
      );
}

class WorkoutSet {
  final String id;

  /// The ONLY link analytics needs. Never store the day or weekday here. (I1)
  final String exerciseId;

  /// POSITIONAL — derived from row order, never a typed field. The reference
  /// log drops set numbers entirely for some exercises; order is the number.
  final int index;

  final Execution execution;
  final List<SetSegment> segments;

  /// "Total 50 reps" across a drop, when per-segment counts weren't recorded.
  final int? aggregateReps;

  final Set<SetTag> tags;

  /// Free text like "4-sec pause".
  final String? tempo;

  /// Authoritative timestamps from the native event journal. Duration is
  /// always endedAt - startedAt, NEVER computed at drain time.
  final DateTime? startedAt;
  final DateTime? endedAt;

  final String? note;

  const WorkoutSet({
    required this.id,
    required this.exerciseId,
    required this.index,
    this.execution = Execution.bilateral,
    this.segments = const [],
    this.aggregateReps,
    this.tags = const {},
    this.tempo,
    this.startedAt,
    this.endedAt,
    this.note,
  });

  Duration? get duration => (startedAt != null && endedAt != null)
      ? endedAt!.difference(startedAt!)
      : null;

  /// A set with a weight and no reps is VALID and must save. (I4)
  bool get hasReps =>
      segments.any((s) => s.totalReps > 0) || (aggregateReps ?? 0) > 0;

  /// A started set with no end and an absurd duration is a phantom from a
  /// pocket bump. Surface as "discard?" — never save silently. See spec §7.
  bool isPhantom({Duration threshold = const Duration(minutes: 15)}) =>
      startedAt != null &&
      endedAt != null &&
      endedAt!.difference(startedAt!) > threshold;

  WorkoutSet copyWith({
    Execution? execution,
    List<SetSegment>? segments,
    int? aggregateReps,
    Set<SetTag>? tags,
    String? tempo,
    DateTime? startedAt,
    DateTime? endedAt,
    String? note,
  }) =>
      WorkoutSet(
        id: id,
        exerciseId: exerciseId,
        index: index,
        execution: execution ?? this.execution,
        segments: segments ?? this.segments,
        aggregateReps: aggregateReps ?? this.aggregateReps,
        tags: tags ?? this.tags,
        tempo: tempo ?? this.tempo,
        startedAt: startedAt ?? this.startedAt,
        endedAt: endedAt ?? this.endedAt,
        note: note ?? this.note,
      );
}

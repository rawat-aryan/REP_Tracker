/// Load and rep representation.
///
/// Two ORTHOGONAL axes cover every notation in the reference log. One combined
/// "weight type" enum does not. See docs/spec.md §3.2.
///
///   "Single -40" ham curl   -> unilateral + perLimb + 40
///   "60" ham curl           -> bilateral  + total   + 60
///   "10 db each" row        -> bilateral  + perLimb + 10
///   "2-30 single side"      -> unilateral + perLimb + 30
///   "1-bw" lunges           -> unilateral + total   + null
library;

/// Whether the set was executed one limb at a time.
/// LIVES ON THE SET, NOT THE EXERCISE — users switch mid-exercise.
enum Execution { bilateral, unilateral }

/// Whether the recorded number applies per limb or in total.
enum LoadScope { total, perLimb }

enum LoadSource {
  barbell,
  dumbbell,
  machineStack,
  cable,
  bodyweight,
  bodyweightAdded,
  band,
}

enum LoadUnit { kg, lb }

/// Weights are ALWAYS stored in kilograms. [unit] is a display preference only.
class Load {
  /// Null for pure bodyweight.
  final double? value;
  final LoadUnit unit;
  final LoadSource source;
  final LoadScope scope;

  const Load({
    this.value,
    this.unit = LoadUnit.kg,
    required this.source,
    this.scope = LoadScope.total,
  });

  bool get isBodyweight => source == LoadSource.bodyweight;

  Load copyWith({
    double? value,
    LoadUnit? unit,
    LoadSource? source,
    LoadScope? scope,
  }) =>
      Load(
        value: value ?? this.value,
        unit: unit ?? this.unit,
        source: source ?? this.source,
        scope: scope ?? this.scope,
      );
}

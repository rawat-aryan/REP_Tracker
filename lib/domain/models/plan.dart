enum Weekday { mon, tue, wed, thu, fri, sat, sun }

enum DayStatus {
  logged,

  /// Default for a gap. Means "the app doesn't know yet" and NEVER becomes
  /// missed on its own. (I2)
  unresolved,

  rest,
  missed,

  /// Displacement — the session happened on a different day. Distinct from
  /// logged so the pattern detector can tell travel from a schedule change.
  movedTo,
}

/// Why a gap was manually resolved (spec §9's ambient row: "Rest / travel /
/// did it Thursday / add it now" — "add it now" isn't here because it just
/// creates a real [Session], which resolves the gap without needing a
/// record of its own).
enum DayResolutionKind { rest, travel, movedTo }

/// A user's answer to "what was this date?" — one row per resolved gap,
/// keyed by the ORIGINAL scheduled date. Never inferred, always the result
/// of an explicit tap (I2). [movedToDate] is set only for [DayResolutionKind.movedTo].
class DayResolution {
  final DateTime date;
  final DayResolutionKind kind;
  final DateTime? movedToDate;

  const DayResolution({required this.date, required this.kind, this.movedToDate});
}

class PlannedExercise {
  final String exerciseId;
  final int order;
  final int targetSets;

  /// Marks the exercise's sets as defaulting to unilateral. A DEFAULT for new
  /// sets, not a constraint — execution stays per-set.
  final bool defaultUnilateral;

  const PlannedExercise({
    required this.exerciseId,
    required this.order,
    this.targetSets = 3,
    this.defaultUnilateral = false,
  });
}

/// A training day as a first-class entity with a STABLE ID.
///
/// This is what lets the user restructure their week, rename days, or move a
/// day to a different weekday without destroying its history.
///
/// The name is COSMETIC. Muscle coverage is derived from the primaryMuscle of
/// the exercises actually logged, so users can call days whatever they like.
class WorkoutDay {
  final String id;
  final String name;
  final List<PlannedExercise> exercises;
  final bool archived;

  const WorkoutDay({
    required this.id,
    required this.name,
    this.exercises = const [],
    this.archived = false,
  });
}

/// NEVER mutated in place — versioned. Each session snapshots its version so
/// editing the plan in October cannot rewrite September.
///
/// There is deliberately NO SplitType enum. "PPL but I start with legs" is just
/// an assignment. Persisting the archetype leads to `if (archetype == ppl)`.
class WeekPlan {
  final String routineId;
  final int version;

  /// weekday -> WorkoutDay.id, or null for rest.
  final Map<Weekday, String?> slots;

  const WeekPlan({
    required this.routineId,
    required this.version,
    required this.slots,
  });
}

/// A time series, not a profile field — bodyweight exercises need the user's
/// weight ON THAT DATE for e1RM to be real math instead of null.
class BodyweightEntry {
  final DateTime date;
  final double kg;
  const BodyweightEntry({required this.date, required this.kg});
}

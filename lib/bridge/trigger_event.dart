/// The native <-> Dart contract. See docs/spec.md §7 and CLAUDE.md.
///
/// The trigger fires when the Dart VM is dead. It cannot call Dart, cannot
/// touch Drift, and knows only what Dart already wrote into context.json.
///
/// TWO FILES, EACH WITH EXACTLY ONE WRITER:
///   context.json   Dart writes, native reads
///   events.jsonl   native appends, Dart drains
///
/// Never put the database in shared storage. Never let both sides write one
/// file. (I6)
library;

enum TriggerEventType { setStarted, setEnded }

/// One line of events.jsonl. Carries a UUID so replay is IDEMPOTENT — a
/// half-failed drain is harmless to re-run, which is what makes this safe
/// against every crash and force-quit path.
class TriggerEvent {
  final String id;
  final TriggerEventType type;

  /// AUTHORITATIVE clock. Duration is endedAt - startedAt from these values,
  /// never computed at drain time, or every set inherits the resume lag.
  final DateTime at;

  final String sessionId;

  const TriggerEvent({
    required this.id,
    required this.type,
    required this.at,
    required this.sessionId,
  });

  factory TriggerEvent.fromJson(Map<String, dynamic> j) => TriggerEvent(
        id: j['id'] as String,
        type: TriggerEventType.values.byName(j['type'] as String),
        at: DateTime.parse(j['at'] as String).toUtc(),
        sessionId: j['sessionId'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'at': at.toUtc().toIso8601String(),
        'sessionId': sessionId,
      };
}

/// What Dart writes into context.json so the native side can act and render
/// the ambient card without launching the app.
class TriggerContext {
  final String sessionId;
  final String dayName;
  final String currentExerciseId;

  /// MUST be rendered on the ambient card. Because the trigger fires from a
  /// pocket, a mis-attributed set is otherwise silent and invisible.
  final String currentExerciseName;

  final int nextSetIndex;
  final double? lastLoadKg;
  final bool loadPerLimb;
  final int? predictedReps;
  final bool unilateral;

  /// Present iff a set is currently running. The trigger toggles on this:
  /// present -> append setEnded; absent -> append setStarted. One action, no
  /// modes, no state held natively.
  final ActiveSet? activeSet;

  const TriggerContext({
    required this.sessionId,
    required this.dayName,
    required this.currentExerciseId,
    required this.currentExerciseName,
    required this.nextSetIndex,
    this.lastLoadKg,
    this.loadPerLimb = false,
    this.predictedReps,
    this.unilateral = false,
    this.activeSet,
  });

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'dayName': dayName,
        'currentExercise': {
          'id': currentExerciseId,
          'name': currentExerciseName,
        },
        'nextSetIndex': nextSetIndex,
        'lastLoad': lastLoadKg == null
            ? null
            : {
                'value': lastLoadKg,
                'unit': 'kg',
                'scope': loadPerLimb ? 'perLimb' : 'total',
              },
        'predictedReps': predictedReps,
        'unilateral': unilateral,
        'activeSet': activeSet?.toJson(),
      };
}

class ActiveSet {
  final String eventId;
  final DateTime startedAt;
  const ActiveSet({required this.eventId, required this.startedAt});

  Map<String, dynamic> toJson() =>
      {'eventId': eventId, 'startedAt': startedAt.toUtc().toIso8601String()};
}

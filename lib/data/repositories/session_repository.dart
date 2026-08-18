import 'package:drift/drift.dart';

import '../../domain/models/load.dart';
import '../../domain/models/session.dart';
import '../../domain/models/workout_set.dart';
import '../database.dart';
import '../schema.dart';

class _SessionSets {
  _SessionSets(this.sessionStartedAt, this.sets);
  final DateTime sessionStartedAt;
  final List<WorkoutSet> sets;
}

/// I1: [historyForExercise] and [lastSetAtIndex] — the methods prefill and
/// analytics sit on top of — take an exerciseId and nothing about the plan.
/// No overload here may grow a day, plan or weekday parameter.
class SessionRepository {
  SessionRepository(this._db);

  final AppDatabase _db;

  Future<void> createSession(Session session) async {
    await _db.transaction(() async {
      await _db.into(_db.sessions).insert(_sessionCompanion(session));
      for (final se in session.exercises) {
        final id = await _db.into(_db.sessionExercises).insert(
              SessionExercisesCompanion.insert(
                sessionId: session.id,
                exerciseId: se.exerciseId,
                planOrder: se.planOrder,
                offPlan: Value(se.offPlan),
              ),
            );
        for (final set in se.sets) {
          await _insertSet(id, se.exerciseId, set);
        }
      }
    });
  }

  /// I5: session metadata (current exercise, end time) stays writable no
  /// matter how long ago the session happened.
  Future<void> updateSessionMeta(Session session) {
    return (_db.update(_db.sessions)..where((t) => t.id.equals(session.id)))
        .write(
      SessionsCompanion(
        workoutDayId: Value(session.workoutDayId),
        currentExerciseId: Value(session.currentExerciseId),
        endedAt: Value(session.endedAt),
      ),
    );
  }

  /// Appends one set, creating the [SessionExercises] row on first touch of
  /// that exercise in this session. This is the write path the trigger
  /// journal drains into.
  Future<void> addSet({
    required String sessionId,
    required String exerciseId,
    required int planOrder,
    required WorkoutSet set,
  }) async {
    await _db.transaction(() async {
      final sessionExerciseId = await _ensureSessionExercise(
        sessionId: sessionId,
        exerciseId: exerciseId,
        planOrder: planOrder,
      );
      await _insertSet(sessionExerciseId, exerciseId, set);
    });
  }

  /// Adds an exercise to the pool with zero sets — the entry point for an
  /// off-plan pick from the exercise picker (§6 "session is a pool"). A
  /// no-op if the exercise is already in the session. (I4: zero sets saves.)
  Future<void> addExerciseToSession({
    required String sessionId,
    required String exerciseId,
    required int planOrder,
    bool offPlan = false,
  }) async {
    await _ensureSessionExercise(
      sessionId: sessionId,
      exerciseId: exerciseId,
      planOrder: planOrder,
      offPlan: offPlan,
    );
  }

  Future<int> _ensureSessionExercise({
    required String sessionId,
    required String exerciseId,
    required int planOrder,
    bool offPlan = false,
  }) async {
    final existing = await (_db.select(_db.sessionExercises)
          ..where(
            (t) =>
                t.sessionId.equals(sessionId) &
                t.exerciseId.equals(exerciseId),
          ))
        .getSingleOrNull();
    if (existing != null) return existing.id;
    return _db.into(_db.sessionExercises).insert(
          SessionExercisesCompanion.insert(
            sessionId: sessionId,
            exerciseId: exerciseId,
            planOrder: planOrder,
            offPlan: Value(offPlan),
          ),
        );
  }

  /// I5: a set logged in September stays editable in October. No status on
  /// the parent session gates this.
  Future<void> updateSet(WorkoutSet set) async {
    await _db.transaction(() async {
      await (_db.update(_db.workoutSets)..where((t) => t.id.equals(set.id)))
          .write(
        WorkoutSetsCompanion(
          execution: Value(set.execution),
          aggregateReps: Value(set.aggregateReps),
          tags: Value(set.tags.map((t) => t.name).toList()),
          tempo: Value(set.tempo),
          startedAt: Value(set.startedAt),
          endedAt: Value(set.endedAt),
          note: Value(set.note),
        ),
      );
      await (_db.delete(_db.setSegments)
            ..where((t) => t.workoutSetId.equals(set.id)))
          .go();
      await _insertSegments(set.id, set.segments);
    });
  }

  /// Removes a set outright rather than archiving it — reserved for the
  /// phantom-set "discard?" prompt (§7 failure modes). A pocket-bumped
  /// start/end pair is noise, not history; I7's archive-don't-delete rule
  /// is about exercises/days/routines, not junk data like this.
  Future<void> deleteSet(String id) async {
    await (_db.delete(_db.setSegments)..where((t) => t.workoutSetId.equals(id)))
        .go();
    await (_db.delete(_db.workoutSets)..where((t) => t.id.equals(id))).go();
  }

  /// How many sessions the user has actually finished — backs the trigger
  /// upgrade offer, shown only after the third one (§16 "capability
  /// detection": not during onboarding, when the friction isn't real yet).
  Future<int> completedSessionCount() async {
    final rows = await (_db.select(_db.sessions)
          ..where((t) => t.endedAt.isNotNull()))
        .get();
    return rows.length;
  }

  Future<Session?> getById(String id) async {
    final row = await (_db.select(_db.sessions)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    final seRows = await (_db.select(_db.sessionExercises)
          ..where((t) => t.sessionId.equals(id)))
        .get();
    final exercises = <SessionExercise>[];
    for (final se in seRows) {
      exercises.add(
        SessionExercise(
          exerciseId: se.exerciseId,
          planOrder: se.planOrder,
          offPlan: se.offPlan,
          sets: await _setsForSessionExercise(se.id),
        ),
      );
    }
    return Session(
      id: row.id,
      date: row.date,
      workoutDayId: row.workoutDayId,
      routineVersion: row.routineVersion,
      intendedExerciseIds: row.intendedExerciseIds,
      exercises: exercises,
      currentExerciseId: row.currentExerciseId,
      startedAt: row.startedAt,
      endedAt: row.endedAt,
    );
  }

  /// Multiple sessions per calendar date are allowed (morning legs, evening
  /// arms) — this looks up by literal date, never by weekday slot.
  Future<List<Session>> getForDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final rows = await (_db.select(_db.sessions)
          ..where(
            (t) =>
                t.date.isBiggerOrEqualValue(start) &
                t.date.isSmallerThanValue(end),
          ))
        .get();
    final sessions = <Session>[];
    for (final row in rows) {
      final full = await getById(row.id);
      if (full != null) sessions.add(full);
    }
    return sessions;
  }

  /// Most recent session across every day, optionally strictly before
  /// [before]. A home-screen concern (the rest-day "last session" summary)
  /// — reads [SessionRow.workoutDayId] only to name the day, never to
  /// filter analytics (I1).
  Future<Session?> mostRecentSession({DateTime? before}) async {
    final query = _db.select(_db.sessions)
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
      ..limit(1);
    if (before != null) {
      query.where((t) => t.startedAt.isSmallerThanValue(before));
    }
    final row = await query.getSingleOrNull();
    return row == null ? null : getById(row.id);
  }

  /// Every logged set for [exerciseId], most-recent session first. The read
  /// path for history/PRs/charts. No day, plan or weekday parameter (I1).
  Future<List<WorkoutSet>> historyForExercise(
    String exerciseId, {
    int? limit,
  }) async {
    final groups = await _setsGroupedBySessionExercise(exerciseId);
    final flat = <WorkoutSet>[];
    for (final g in groups) {
      flat.addAll(g.sets);
    }
    if (limit != null && flat.length > limit) return flat.sublist(0, limit);
    return flat;
  }

  /// Same exercise, same POSITIONAL set index (1-based — index 1 is "set
  /// 1"), most recent *other* session that reached that index. Backs reps
  /// and execution prefill (§8.1) — the exercise-history-only read that
  /// must never be tempted into a day join.
  Future<WorkoutSet?> lastSetAtIndex({
    required String exerciseId,
    required int setIndex,
    String? excludeSessionId,
  }) async {
    final groups = await _setsGroupedBySessionExercise(
      exerciseId,
      excludeSessionId: excludeSessionId,
    );
    for (final group in groups) {
      if (group.sets.length >= setIndex) return group.sets[setIndex - 1];
    }
    return null;
  }

  Future<List<_SessionSets>> _setsGroupedBySessionExercise(
    String exerciseId, {
    String? excludeSessionId,
  }) async {
    final query = _db.select(_db.workoutSets).join([
      innerJoin(
        _db.sessionExercises,
        _db.sessionExercises.id.equalsExp(_db.workoutSets.sessionExerciseId),
      ),
      innerJoin(
        _db.sessions,
        _db.sessions.id.equalsExp(_db.sessionExercises.sessionId),
      ),
    ])
      ..where(_db.workoutSets.exerciseId.equals(exerciseId));
    if (excludeSessionId != null) {
      query.where(_db.sessions.id.equals(excludeSessionId).not());
    }
    final rows = await query.get();

    final bySessionExercise = <int, List<TypedResult>>{};
    for (final row in rows) {
      final seId = row.readTable(_db.sessionExercises).id;
      bySessionExercise.putIfAbsent(seId, () => []).add(row);
    }

    final groups = <_SessionSets>[];
    for (final entry in bySessionExercise.entries) {
      final sorted = [...entry.value]..sort(
          (a, b) => a
              .readTable(_db.workoutSets)
              .seq
              .compareTo(b.readTable(_db.workoutSets).seq),
        );
      final sets = <WorkoutSet>[];
      for (var i = 0; i < sorted.length; i++) {
        sets.add(
          await _toWorkoutSet(
            sorted[i].readTable(_db.workoutSets),
            index: i + 1,
          ),
        );
      }
      groups.add(
        _SessionSets(sorted.first.readTable(_db.sessions).startedAt, sets),
      );
    }
    groups.sort((a, b) => b.sessionStartedAt.compareTo(a.sessionStartedAt));
    return groups;
  }

  Future<List<WorkoutSet>> _setsForSessionExercise(
    int sessionExerciseId,
  ) async {
    final rows = await (_db.select(_db.workoutSets)
          ..where((t) => t.sessionExerciseId.equals(sessionExerciseId))
          ..orderBy([(t) => OrderingTerm(expression: t.seq)]))
        .get();
    final sets = <WorkoutSet>[];
    for (var i = 0; i < rows.length; i++) {
      sets.add(await _toWorkoutSet(rows[i], index: i + 1));
    }
    return sets;
  }

  /// [index] is 1-based (§3.3: "set 1", "set 2" in the reference log).
  Future<WorkoutSet> _toWorkoutSet(
    WorkoutSetRow row, {
    required int index,
  }) async {
    final segRows = await (_db.select(_db.setSegments)
          ..where((t) => t.workoutSetId.equals(row.id))
          ..orderBy([(t) => OrderingTerm(expression: t.seq)]))
        .get();
    return WorkoutSet(
      id: row.id,
      exerciseId: row.exerciseId,
      index: index,
      execution: row.execution,
      segments: segRows.map(_toSegment).toList(),
      aggregateReps: row.aggregateReps,
      tags: row.tags.map((n) => SetTag.values.byName(n)).toSet(),
      tempo: row.tempo,
      startedAt: row.startedAt,
      endedAt: row.endedAt,
      note: row.note,
    );
  }

  SetSegment _toSegment(SetSegmentRow row) => SetSegment(
        load: Load(
          value: row.loadValue,
          unit: row.loadUnit,
          source: row.loadSource,
          scope: row.loadScope,
        ),
        reps: row.reps,
        repsLeft: row.repsLeft,
        repsRight: row.repsRight,
      );

  Future<void> _insertSet(
    int sessionExerciseId,
    String exerciseId,
    WorkoutSet set,
  ) async {
    await _db.into(_db.workoutSets).insert(
          WorkoutSetsCompanion.insert(
            id: set.id,
            sessionExerciseId: sessionExerciseId,
            exerciseId: exerciseId,
            seq: DateTime.now().microsecondsSinceEpoch,
            execution: Value(set.execution),
            aggregateReps: Value(set.aggregateReps),
            tags: Value(set.tags.map((t) => t.name).toList()),
            tempo: Value(set.tempo),
            startedAt: Value(set.startedAt),
            endedAt: Value(set.endedAt),
            note: Value(set.note),
          ),
        );
    await _insertSegments(set.id, set.segments);
  }

  Future<void> _insertSegments(
    String workoutSetId,
    List<SetSegment> segments,
  ) async {
    for (final seg in segments) {
      await _db.into(_db.setSegments).insert(
            SetSegmentsCompanion.insert(
              workoutSetId: workoutSetId,
              seq: DateTime.now().microsecondsSinceEpoch,
              loadValue: Value(seg.load.value),
              loadUnit: Value(seg.load.unit),
              loadSource: seg.load.source,
              loadScope: Value(seg.load.scope),
              reps: Value(seg.reps),
              repsLeft: Value(seg.repsLeft),
              repsRight: Value(seg.repsRight),
            ),
          );
    }
  }

  SessionsCompanion _sessionCompanion(Session s) => SessionsCompanion.insert(
        id: s.id,
        date: s.date,
        workoutDayId: Value(s.workoutDayId),
        routineVersion: Value(s.routineVersion),
        intendedExerciseIds: Value(s.intendedExerciseIds),
        currentExerciseId: Value(s.currentExerciseId),
        startedAt: s.startedAt,
        endedAt: Value(s.endedAt),
      );
}

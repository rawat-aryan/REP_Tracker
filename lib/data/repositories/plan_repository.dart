import 'package:drift/drift.dart';

import '../../domain/models/plan.dart';
import '../database.dart';

/// Planning only. Nothing here is read by prefill, history, PRs or charts
/// (I1) — those live entirely in [SessionRepository]/[ExerciseRepository].
class PlanRepository {
  PlanRepository(this._db);

  final AppDatabase _db;

  Future<WorkoutDay?> getWorkoutDay(String id) async {
    final row = await (_db.select(_db.workoutDays)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toWorkoutDay(row);
  }

  Future<List<WorkoutDay>> getAllWorkoutDays({
    bool includeArchived = false,
  }) async {
    final query = _db.select(_db.workoutDays);
    if (!includeArchived) query.where((t) => t.archived.equals(false));
    final rows = await query.get();
    final days = <WorkoutDay>[];
    for (final row in rows) {
      days.add(await _toWorkoutDay(row));
    }
    return days;
  }

  /// The day name is purely cosmetic and [PlannedExercise] order is
  /// user-defined — never mutate a routine's day list in place. This
  /// replaces the whole planned-exercise list for [day.id] transactionally.
  Future<void> upsertWorkoutDay(WorkoutDay day) async {
    await _db.transaction(() async {
      await _db.into(_db.workoutDays).insertOnConflictUpdate(
            WorkoutDaysCompanion.insert(
              id: day.id,
              name: day.name,
              archived: Value(day.archived),
            ),
          );
      await (_db.delete(_db.plannedExercises)
            ..where((t) => t.workoutDayId.equals(day.id)))
          .go();
      for (final pe in day.exercises) {
        await _db.into(_db.plannedExercises).insert(
              PlannedExercisesCompanion.insert(
                workoutDayId: day.id,
                exerciseId: pe.exerciseId,
                sortOrder: pe.order,
                targetSets: Value(pe.targetSets),
                defaultUnilateral: Value(pe.defaultUnilateral),
              ),
            );
      }
    });
  }

  /// I7: archive, never delete — a day disappearing must not dangle any
  /// session that snapshotted it.
  Future<void> archiveWorkoutDay(String id) {
    return (_db.update(_db.workoutDays)..where((t) => t.id.equals(id)))
        .write(const WorkoutDaysCompanion(archived: Value(true)));
  }

  /// Inserts a brand-new (routineId, version) row. Never mutates an
  /// existing version in place — editing October's plan must not rewrite
  /// what September's sessions snapshotted (I5).
  Future<void> createWeekPlanVersion(WeekPlan plan) async {
    await _db.transaction(() async {
      await _db.into(_db.weekPlans).insert(
            WeekPlansCompanion.insert(
              routineId: plan.routineId,
              version: plan.version,
            ),
          );
      for (final entry in plan.slots.entries) {
        await _db.into(_db.weekPlanSlots).insert(
              WeekPlanSlotsCompanion.insert(
                routineId: plan.routineId,
                version: plan.version,
                weekday: entry.key,
                workoutDayId: Value(entry.value),
              ),
            );
      }
    });
  }

  Future<WeekPlan?> getWeekPlanVersion(String routineId, int version) async {
    final header = await (_db.select(_db.weekPlans)
          ..where(
            (t) => t.routineId.equals(routineId) & t.version.equals(version),
          ))
        .getSingleOrNull();
    if (header == null) return null;
    final slotRows = await (_db.select(_db.weekPlanSlots)
          ..where(
            (t) => t.routineId.equals(routineId) & t.version.equals(version),
          ))
        .get();
    return WeekPlan(
      routineId: routineId,
      version: version,
      slots: {for (final s in slotRows) s.weekday: s.workoutDayId},
    );
  }

  Future<WeekPlan?> getLatestWeekPlan(String routineId) async {
    final header = await (_db.select(_db.weekPlans)
          ..where((t) => t.routineId.equals(routineId))
          ..orderBy([(t) => OrderingTerm.desc(t.version)])
          ..limit(1))
        .getSingleOrNull();
    return header == null
        ? null
        : getWeekPlanVersion(routineId, header.version);
  }

  Future<WorkoutDay> _toWorkoutDay(WorkoutDayRow row) async {
    final peRows = await (_db.select(_db.plannedExercises)
          ..where((t) => t.workoutDayId.equals(row.id))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    return WorkoutDay(
      id: row.id,
      name: row.name,
      archived: row.archived,
      exercises: peRows
          .map(
            (pe) => PlannedExercise(
              exerciseId: pe.exerciseId,
              order: pe.sortOrder,
              targetSets: pe.targetSets,
              defaultUnilateral: pe.defaultUnilateral,
            ),
          )
          .toList(),
    );
  }
}

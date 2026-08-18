import 'package:drift/drift.dart';

import '../../domain/models/exercise.dart';
import '../database.dart';

/// I1: every method here reads/writes the exercise catalog only. None of
/// them accept a WorkoutDay, WeekPlan or weekday.
class ExerciseRepository {
  ExerciseRepository(this._db);

  final AppDatabase _db;

  Future<List<Exercise>> getAll({bool includeArchived = false}) async {
    final query = _db.select(_db.exercises);
    if (!includeArchived) {
      query.where((t) => t.archived.equals(false));
    }
    final rows = await query.get();
    return rows.map(_toDomain).toList();
  }

  Future<Exercise?> getById(String id) async {
    final row = await (_db.select(_db.exercises)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  /// Matches on name or any alias, case-insensitively. Used by the exercise
  /// picker (§3.1) so "Incline BP" finds "Incline bench press" instead of
  /// forking a new entry.
  Future<List<Exercise>> search(
    String query, {
    bool includeArchived = false,
  }) async {
    final all = await getAll(includeArchived: includeArchived);
    final needle = query.toLowerCase();
    return all
        .where(
          (e) =>
              e.name.toLowerCase().contains(needle) ||
              e.aliases.any((a) => a.toLowerCase().contains(needle)),
        )
        .toList();
  }

  Future<void> upsert(Exercise exercise) {
    return _db
        .into(_db.exercises)
        .insertOnConflictUpdate(_toCompanion(exercise));
  }

  /// I7: archive, never delete.
  Future<void> archive(String id) {
    return (_db.update(_db.exercises)..where((t) => t.id.equals(id)))
        .write(const ExercisesCompanion(archived: Value(true)));
  }

  /// Repoints every set and session-exercise from [loserId] onto [keepId],
  /// then archives the loser. Never a data DELETE — history must never
  /// dangle (I7), and the curve must not fork on a typo.
  Future<void> merge({required String keepId, required String loserId}) async {
    await _db.transaction(() async {
      await (_db.update(_db.workoutSets)
            ..where((t) => t.exerciseId.equals(loserId)))
          .write(WorkoutSetsCompanion(exerciseId: Value(keepId)));
      await (_db.update(_db.sessionExercises)
            ..where((t) => t.exerciseId.equals(loserId)))
          .write(SessionExercisesCompanion(exerciseId: Value(keepId)));
      await archive(loserId);
    });
  }

  Exercise _toDomain(ExerciseRow row) => Exercise(
        id: row.id,
        isCustom: row.isCustom,
        name: row.name,
        aliases: row.aliases,
        primaryMuscle: row.primaryMuscle,
        secondaryMuscles:
            row.secondaryMuscles.map((n) => Muscle.values.byName(n)).toList(),
        equipment: row.equipment,
        defaultExecution: row.defaultExecution,
        variantOf: row.variantOf,
        incrementOverride: row.incrementOverride,
        equipmentIncrement: row.equipmentIncrement,
        archived: row.archived,
      );

  ExercisesCompanion _toCompanion(Exercise e) => ExercisesCompanion.insert(
        id: e.id,
        isCustom: Value(e.isCustom),
        name: e.name,
        aliases: Value(e.aliases),
        primaryMuscle: e.primaryMuscle,
        secondaryMuscles: Value(e.secondaryMuscles.map((m) => m.name).toList()),
        equipment: e.equipment,
        defaultExecution: Value(e.defaultExecution),
        variantOf: Value(e.variantOf),
        incrementOverride: Value(e.incrementOverride),
        equipmentIncrement: Value(e.equipmentIncrement),
        archived: Value(e.archived),
      );
}

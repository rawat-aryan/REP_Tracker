import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/models/exercise.dart';
import '../../domain/models/load.dart' show Execution;
import '../database.dart';

/// Pure parse — no Flutter, no Drift — so it's testable against the real
/// asset file content without a widget/asset-bundle test harness.
List<Exercise> parseSeedExercises(String jsonStr) {
  final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
  final list = decoded['exercises'] as List;
  return list.map((raw) {
    final m = raw as Map<String, dynamic>;
    return Exercise(
      id: m['id'] as String,
      name: m['name'] as String,
      primaryMuscle: Muscle.values.byName(m['primaryMuscle'] as String),
      equipment: Equipment.values.byName(m['equipment'] as String),
      equipmentIncrement: (m['equipmentIncrement'] as num?)?.toDouble() ?? 2.5,
      aliases: (m['aliases'] as List?)?.cast<String>() ?? const [],
      defaultExecution: Execution.values
          .byName(m['defaultExecution'] as String? ?? 'bilateral'),
      secondaryMuscles: (m['secondaryMuscles'] as List?)
              ?.map((s) => Muscle.values.byName(s as String))
              .toList() ??
          const [],
    );
  }).toList();
}

int parseSeedVersion(String jsonStr) =>
    (jsonDecode(jsonStr) as Map<String, dynamic>)['version'] as int;

const _seedVersionKey = 'seed_version';

/// Loads the seed into [db] on first run, and again whenever the shipped
/// seed's version has been bumped. Existing rows are left untouched
/// (insertOrIgnore, keyed by the stable slug id) — a reseed adds new
/// exercises, it never overwrites a user's rename or archive.
Future<void> seedIfNeeded(AppDatabase db, String jsonStr) async {
  final version = parseSeedVersion(jsonStr);
  final storedRow = await (db.select(db.seedMeta)
        ..where((t) => t.key.equals(_seedVersionKey)))
      .getSingleOrNull();
  final storedVersion = storedRow == null ? 0 : int.parse(storedRow.value);
  if (storedVersion >= version) return;

  final exercises = parseSeedExercises(jsonStr);
  await db.batch((batch) {
    for (final e in exercises) {
      batch.insert(
        db.exercises,
        ExercisesCompanion.insert(
          id: e.id,
          name: e.name,
          primaryMuscle: e.primaryMuscle,
          equipment: e.equipment,
          equipmentIncrement: Value(e.equipmentIncrement),
          aliases: Value(e.aliases),
          defaultExecution: Value(e.defaultExecution),
          secondaryMuscles:
              Value(e.secondaryMuscles.map((m) => m.name).toList()),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }
    batch.insert(
      db.seedMeta,
      SeedMetaCompanion.insert(key: _seedVersionKey, value: version.toString()),
      mode: InsertMode.insertOrReplace,
    );
  });
}

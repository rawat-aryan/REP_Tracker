import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:rep_tracker/data/database.dart';
import 'package:rep_tracker/data/seed/exercise_seed.dart';
import 'package:test/test.dart';

import 'db_test_utils.dart';

Future<String> _seedJson() =>
    File(p.join(Directory.current.path, 'assets', 'seed', 'exercises.json'))
        .readAsString();

void main() {
  test('seed loads on a fresh install', () async {
    final db = openTestDb();
    final jsonStr = await _seedJson();

    await seedIfNeeded(db, jsonStr);

    final rows = await db.select(db.exercises).get();
    expect(rows, isNotEmpty);
    expect(rows.length, parseSeedExercises(jsonStr).length);
    await db.close();
  });

  test('reseeding at the same version does not duplicate or overwrite edits',
      () async {
    final db = openTestDb();
    final jsonStr = await _seedJson();
    await seedIfNeeded(db, jsonStr);

    // Simulate the user renaming a seeded exercise before a reseed runs.
    final firstId = parseSeedExercises(jsonStr).first.id;
    await (db.update(db.exercises)..where((t) => t.id.equals(firstId)))
        .write(const ExercisesCompanion(name: Value('My renamed exercise')));

    await seedIfNeeded(db, jsonStr);

    final rows = await db.select(db.exercises).get();
    expect(rows.length, parseSeedExercises(jsonStr).length);
    final renamed = rows.firstWhere((r) => r.id == firstId);
    expect(renamed.name, 'My renamed exercise');
    await db.close();
  });
}

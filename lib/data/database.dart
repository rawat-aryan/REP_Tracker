import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../domain/models/exercise.dart';
import '../domain/models/load.dart';
import '../domain/models/plan.dart' show DayResolutionKind, Weekday;
import 'schema.dart';

part 'database.g.dart';

/// Never put this database in shared storage (I6) — only Dart ever opens it.
@DriftDatabase(
  tables: [
    Exercises,
    WorkoutDays,
    PlannedExercises,
    WeekPlans,
    WeekPlanSlots,
    Sessions,
    SessionExercises,
    WorkoutSets,
    SetSegments,
    BodyweightEntries,
    SeedMeta,
    DayResolutions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationSupportDirectory();
      final file = File(p.join(dir.path, 'rep_tracker.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}

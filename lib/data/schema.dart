import 'dart:convert';

import 'package:drift/drift.dart';

import '../domain/models/exercise.dart';
import '../domain/models/load.dart';
import '../domain/models/plan.dart' show Weekday;

/// Stores a `List<String>` as JSON in a single text column. Used for
/// aliases, secondary-muscle names, set tags and intended-exercise lists —
/// none of these are ever queried by value, so a blob beats a join table.
class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) =>
      fromDb.isEmpty ? const [] : (jsonDecode(fromDb) as List).cast<String>();

  @override
  String toSql(List<String> value) => jsonEncode(value);
}

/// I1: this table (and every other table here) has no column referencing a
/// WorkoutDay, WeekPlan or weekday. Analytics/history queries join on
/// [Exercises.id] only.
///
/// Row classes throughout this file are renamed to `...Row` via
/// [DataClassName] — the default generated names collide with the domain
/// model classes of the same name (`Exercise`, `Session`, `WorkoutSet`...),
/// and both need to be importable in the same repository file.
@DataClassName('ExerciseRow')
class Exercises extends Table {
  TextColumn get id => text()();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  TextColumn get name => text()();
  TextColumn get aliases => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
  TextColumn get primaryMuscle => textEnum<Muscle>()();
  TextColumn get secondaryMuscles => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
  TextColumn get equipment => textEnum<Equipment>()();
  TextColumn get defaultExecution =>
      textEnum<Execution>().withDefault(const Constant('bilateral'))();

  /// Points at another [Exercises.id]. Powers the compare overlay only —
  /// never a merge, never read by analytics.
  TextColumn get variantOf => text().nullable()();

  RealColumn get incrementOverride => real().nullable()();
  RealColumn get equipmentIncrement =>
      real().withDefault(const Constant(2.5))();

  /// I7: archived, never deleted. History must never dangle.
  BoolColumn get archived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('WorkoutDayRow')
class WorkoutDays extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// A planning-only join table. Never referenced by [WorkoutSets] or
/// [SessionExercises] — those link straight to [Exercises].
@DataClassName('PlannedExerciseRow')
class PlannedExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get workoutDayId => text().references(WorkoutDays, #id)();
  TextColumn get exerciseId => text().references(Exercises, #id)();
  IntColumn get sortOrder => integer()();
  IntColumn get targetSets => integer().withDefault(const Constant(3))();
  BoolColumn get defaultUnilateral =>
      boolean().withDefault(const Constant(false))();
}

/// Never mutated in place — a new (routineId, version) row per edit.
/// Sessions snapshot the version they were started under (I5: editing the
/// plan later must not rewrite past sessions).
@DataClassName('WeekPlanRow')
class WeekPlans extends Table {
  TextColumn get routineId => text()();
  IntColumn get version => integer()();

  @override
  Set<Column> get primaryKey => {routineId, version};
}

class WeekPlanSlots extends Table {
  TextColumn get routineId => text()();
  IntColumn get version => integer()();
  TextColumn get weekday => textEnum<Weekday>()();

  /// Null = rest day.
  TextColumn get workoutDayId => text().nullable()();

  @override
  Set<Column> get primaryKey => {routineId, version, weekday};
}

@DataClassName('SessionRow')
class Sessions extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();

  /// Null for an improvised session with no plan behind it. Planning-only
  /// field — analytics/history queries never filter on it (I1).
  TextColumn get workoutDayId => text().nullable()();
  IntColumn get routineVersion => integer().nullable()();

  TextColumn get intendedExerciseIds => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();

  /// Which exercise the next triggered set is attributed to. Must be kept
  /// current so the ambient card never mis-attributes a set.
  TextColumn get currentExerciseId => text().nullable()();

  DateTimeColumn get startedAt => dateTime()();

  /// I5: ending a session never locks it. This column being non-null must
  /// never gate whether its sets can still be edited.
  DateTimeColumn get endedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Links a session to one of its exercises. Purely a persistence-layer
/// join — [WorkoutSets.exerciseId] is still the field analytics reads (I1);
/// this table exists so a session's set list can be reconstructed.
@DataClassName('SessionExerciseRow')
class SessionExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sessionId => text().references(Sessions, #id)();
  TextColumn get exerciseId => text().references(Exercises, #id)();
  IntColumn get planOrder => integer()();
  BoolColumn get offPlan => boolean().withDefault(const Constant(false))();
}

@DataClassName('WorkoutSetRow')
class WorkoutSets extends Table {
  TextColumn get id => text()();
  IntColumn get sessionExerciseId =>
      integer().references(SessionExercises, #id)();

  /// The only link analytics needs (I1). Denormalized here so history/PR/
  /// chart queries never have to join through [SessionExercises].
  TextColumn get exerciseId => text()();

  /// Insertion-order stamp, NOT the positional index — the index itself is
  /// never stored (see milestone 03: "don't trust a stored value to stay
  /// correct after a delete"). Repositories derive `WorkoutSet.index` by
  /// ordering rows within a [SessionExercises] group by this column and
  /// enumerating on read, so a mid-list delete can never leave a stale
  /// index behind.
  IntColumn get seq => integer()();

  TextColumn get execution =>
      textEnum<Execution>().withDefault(const Constant('bilateral'))();

  /// I4: nullable. "Total 50 reps" across a drop set with no per-segment
  /// counts recorded is valid and must save.
  IntColumn get aggregateReps => integer().nullable()();

  TextColumn get tags => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
  TextColumn get tempo => text().nullable()();

  /// Authoritative timestamps from the trigger journal. Duration is always
  /// endedAt - startedAt, never computed at drain time.
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get endedAt => dateTime().nullable()();

  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// One load/rep pair inside a set. Drop sets are one [WorkoutSets] row with
/// N of these, not N sets. Positional like [WorkoutSets] — no stored index.
@DataClassName('SetSegmentRow')
class SetSegments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get workoutSetId => text().references(WorkoutSets, #id)();

  /// Same insertion-order stamp as [WorkoutSets.seq] — segments are
  /// positional within a set too.
  IntColumn get seq => integer()();

  /// I4: nullable — pure bodyweight has no value.
  RealColumn get loadValue => real().nullable()();
  TextColumn get loadUnit =>
      textEnum<LoadUnit>().withDefault(const Constant('kg'))();
  TextColumn get loadSource => textEnum<LoadSource>()();
  TextColumn get loadScope =>
      textEnum<LoadScope>().withDefault(const Constant('total'))();

  /// I4: all three nullable. A hurried user may log a weight and nothing else.
  IntColumn get reps => integer().nullable()();
  IntColumn get repsLeft => integer().nullable()();
  IntColumn get repsRight => integer().nullable()();
}

/// A time series, not a profile field.
@DataClassName('BodyweightEntryRow')
class BodyweightEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  RealColumn get kg => real()();
}

/// Tiny key-value table. Currently holds only `seed_version`, so a future
/// seed bump (50 -> 150 exercises) can insert the new IDs without
/// re-inserting or duplicating what's already there.
class SeedMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

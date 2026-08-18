import 'package:drift/drift.dart';

import '../../domain/models/plan.dart';
import '../database.dart';

/// Manual gap resolutions (spec §9) — one row per resolved date, never
/// inferred. insertOnConflictUpdate lets a resolution be changed later
/// without a separate update path (I5-style: nothing here is locked).
class DayResolutionRepository {
  DayResolutionRepository(this._db);

  final AppDatabase _db;

  Future<void> resolve(DayResolution resolution) {
    final d = resolution.date;
    return _db.into(_db.dayResolutions).insertOnConflictUpdate(
          DayResolutionsCompanion.insert(
            date: DateTime(d.year, d.month, d.day),
            kind: resolution.kind,
            movedToDate: Value(resolution.movedToDate),
          ),
        );
  }

  Future<DayResolution?> forDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final row = await (_db.select(_db.dayResolutions)..where((t) => t.date.equals(start)))
        .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  Future<List<DayResolution>> inRange(DateTime from, DateTime to) async {
    final rows = await (_db.select(_db.dayResolutions)
          ..where((t) => t.date.isBiggerOrEqualValue(from) & t.date.isSmallerThanValue(to)))
        .get();
    return rows.map(_toDomain).toList();
  }

  DayResolution _toDomain(DayResolutionRow row) => DayResolution(
        date: row.date,
        kind: row.kind,
        movedToDate: row.movedToDate,
      );
}

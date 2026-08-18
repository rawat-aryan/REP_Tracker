import 'package:drift/drift.dart';

import '../../domain/models/plan.dart' show BodyweightEntry;
import '../database.dart';

/// A time series, not a profile field (§3.7) — bodyweight-exercise e1RM
/// needs the user's weight on the date a set was logged, not "current".
class BodyweightRepository {
  BodyweightRepository(this._db);

  final AppDatabase _db;

  Future<void> add(BodyweightEntry entry) {
    return _db.into(_db.bodyweightEntries).insert(
          BodyweightEntriesCompanion.insert(date: entry.date, kg: entry.kg),
        );
  }

  /// Most recent entry on or before [date].
  Future<BodyweightEntry?> latestAsOf(DateTime date) async {
    final row = await (_db.select(_db.bodyweightEntries)
          ..where((t) => t.date.isSmallerOrEqualValue(date))
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : BodyweightEntry(date: row.date, kg: row.kg);
  }

  Future<List<BodyweightEntry>> series({DateTime? from, DateTime? to}) async {
    final query = _db.select(_db.bodyweightEntries);
    if (from != null) query.where((t) => t.date.isBiggerOrEqualValue(from));
    if (to != null) query.where((t) => t.date.isSmallerOrEqualValue(to));
    query.orderBy([(t) => OrderingTerm.asc(t.date)]);
    final rows = await query.get();
    return rows.map((r) => BodyweightEntry(date: r.date, kg: r.kg)).toList();
  }
}

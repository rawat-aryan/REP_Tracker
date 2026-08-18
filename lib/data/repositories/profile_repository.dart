import '../database.dart';

/// Nothing in the app currently reads the name back (spec §4 asks for it,
/// nothing consumes it beyond display at capture time) — stored in the
/// existing [SeedMeta] key-value table rather than a new one-column table.
class ProfileRepository {
  ProfileRepository(this._db);

  final AppDatabase _db;
  static const _nameKey = 'user_name';

  Future<String?> getName() async {
    final row = await (_db.select(_db.seedMeta)..where((t) => t.key.equals(_nameKey)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setName(String name) {
    return _db
        .into(_db.seedMeta)
        .insertOnConflictUpdate(SeedMetaCompanion.insert(key: _nameKey, value: name));
  }
}

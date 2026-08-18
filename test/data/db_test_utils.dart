import 'package:drift/native.dart';
import 'package:rep_tracker/data/database.dart';

/// In-memory Drift DB for tests — no filesystem, no path_provider plugin.
AppDatabase openTestDb() => AppDatabase(NativeDatabase.memory());

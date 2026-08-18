import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/database.dart';
import 'data/repositories/drift_prefill_service.dart';
import 'data/repositories/exercise_repository.dart';
import 'data/repositories/plan_repository.dart';
import 'data/repositories/session_repository.dart';
import 'domain/models/exercise.dart';
import 'domain/rules/prefill.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final exerciseRepositoryProvider = Provider<ExerciseRepository>(
  (ref) => ExerciseRepository(ref.watch(databaseProvider)),
);

final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => SessionRepository(ref.watch(databaseProvider)),
);

final planRepositoryProvider = Provider<PlanRepository>(
  (ref) => PlanRepository(ref.watch(databaseProvider)),
);

final prefillServiceProvider = Provider<PrefillService>(
  (ref) => DriftPrefillService(
    ref.watch(sessionRepositoryProvider),
    ref.watch(exerciseRepositoryProvider),
  ),
);

/// All exercises keyed by id, for cheap name lookups while rendering the
/// ledger. Reloads whenever a screen re-watches it after an exercise write.
final allExercisesProvider = FutureProvider<Map<String, Exercise>>((ref) async {
  final all = await ref.watch(exerciseRepositoryProvider).getAll();
  return {for (final e in all) e.id: e};
});

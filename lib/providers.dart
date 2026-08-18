import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bridge/android_trigger_bridge.dart';
import 'bridge/trigger_bridge.dart';
import 'bridge/trigger_drain_service.dart';
import 'data/database.dart';
import 'data/repositories/bodyweight_repository.dart';
import 'data/repositories/day_resolution_repository.dart';
import 'data/repositories/drift_prefill_service.dart';
import 'data/repositories/exercise_repository.dart';
import 'data/repositories/plan_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'data/repositories/session_repository.dart';
import 'domain/models/exercise.dart';
import 'domain/models/plan.dart';
import 'domain/rules/prefill.dart';

/// No onboarding yet (milestone 07) — main.dart seeds one demo routine/day
/// under these fixed ids so milestones 04/05 have something real to read.
const demoRoutineId = 'demo_routine';
const demoDayId = 'demo_legs';

/// Overridable in tests so home-state fixtures don't depend on the wall
/// clock (e.g. a rest-day test doesn't want to wait for an actual Sunday).
final nowProvider = Provider<DateTime>((ref) => DateTime.now());

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

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(databaseProvider)),
);

final bodyweightRepositoryProvider = Provider<BodyweightRepository>(
  (ref) => BodyweightRepository(ref.watch(databaseProvider)),
);

final dayResolutionRepositoryProvider = Provider<DayResolutionRepository>(
  (ref) => DayResolutionRepository(ref.watch(databaseProvider)),
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

/// A single [WorkoutDay] by id — the home screen's "in progress"/"done"
/// cards use this only for display (target set counts, the day name),
/// never to scope a history/prefill query (I1).
final workoutDayProvider = FutureProvider.family<WorkoutDay?, String>(
  (ref, id) => ref.watch(planRepositoryProvider).getWorkoutDay(id),
);

/// The real trigger layer (milestone 06). iOS has no implementation yet —
/// see ADR-005 — so this is Android-only for now, same scope cut as
/// milestone 01.
final triggerBridgeProvider = Provider<TriggerBridge>((ref) => AndroidTriggerBridge());

final triggerDrainServiceProvider = Provider<TriggerDrainService>(
  (ref) => TriggerDrainService(
    bridge: ref.watch(triggerBridgeProvider),
    sessions: ref.watch(sessionRepositoryProvider),
    exercises: ref.watch(exerciseRepositoryProvider),
    plans: ref.watch(planRepositoryProvider),
    prefill: ref.watch(prefillServiceProvider),
  ),
);

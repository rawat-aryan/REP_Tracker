import '../models/exercise.dart';
import '../models/load.dart';
import '../models/session.dart';

/// Prefill resolution. See docs/spec.md §8.1.
///
/// CRITICAL (I1): every lookup here reads EXERCISE HISTORY ONLY. None of these
/// methods may take a WorkoutDay, WeekPlan or weekday parameter. The tempting
/// violation — "last hip thrust ON LEGS DAY" — breaks history the first time
/// the user changes their split.
///
/// The one exception is the intent list (see IntentPrefill below), which is a
/// PLANNING concern and correctly keys off the weekday slot.
abstract class PrefillService {
  /// Weight for set 1: the same exercise's set 1 in the last session it was
  /// performed. For later sets: the previous set in THIS session, since users
  /// rarely drop back down mid-exercise.
  Future<Load?> loadFor({
    required String exerciseId,
    required int setIndex,
    required Session currentSession,
  });

  /// Reps: same exercise, same set index, last session.
  Future<int?> repsFor({required String exerciseId, required int setIndex});

  /// Execution: same exercise, SAME SET INDEX, last session; falls back to
  /// [Exercise.defaultExecution].
  ///
  /// Keying only off the exercise gets set 2 wrong every single week — the
  /// reference log has hip thrust set 1 bilateral / set 2 unilateral, and ham
  /// curls unilateral at set 1 then bilateral after.
  Future<Execution> executionFor({
    required String exerciseId,
    required int setIndex,
  });
}

/// The four quick-pick rep values shown on the ambient card.
///
/// Spans n-1 .. n+2, BIASED UPWARD because progression is the expected
/// direction. The predicted value is highlighted; a fifth control overflows to
/// the full entry screen.
List<int> repQuickPicks(int predicted) {
  final start = (predicted - 1).clamp(1, 999);
  return [start, start + 1, start + 2, start + 3];
}

/// Increment resolution for the weight stepper. See docs/spec.md §8.4.
///
/// 2.5 kg is NOT universal — machine stacks are often 5, some dumbbell racks
/// are 2. Resolve in order, and never ask the user to configure this during
/// onboarding.
double resolveIncrementKg({
  required Exercise exercise,
  required List<double> recentDistinctLoads,
}) {
  // 1. User override always wins.
  if (exercise.incrementOverride != null) return exercise.incrementOverride!;

  // 2. Learned: the step size the loads are all multiples of — the GCD of
  //    consecutive differences, not just the smallest one. [40, 60, 75] was
  //    reached in 5 kg steps (diffs 20 and 15, gcd 5) even though no two
  //    consecutive visits happen to be exactly 5 apart. Only once there is
  //    enough evidence. Window the input to the last ~10 distinct values, or
  //    changing gyms (5 kg stack -> 2.5 kg stack) never updates.
  if (recentDistinctLoads.length >= 3) {
    final sorted = [...recentDistinctLoads]..sort();
    double? step;
    for (var i = 1; i < sorted.length; i++) {
      final d = sorted[i] - sorted[i - 1];
      if (d > 0) step = step == null ? d : _gcdKg(step, d);
    }
    // FLOOR IT. A 0.5 kg stepper needs 20 taps to go anywhere.
    if (step != null && step >= 1.0) return step;
  }

  // 3. Equipment default from seed data. 4. Global fallback lives in the seed.
  return exercise.equipmentIncrement;
}

/// Long-press on +/- jumps a plate pair: 5 where the increment is 2.5, 10
/// where it is 5. Warmup-to-working-set is often a 20 kg move.
double coarseIncrementKg(double increment) => increment * 2;

/// GCD of two kg values. Loads are logged to at most 2 decimal places, so
/// scale to integer cents before the Euclidean algorithm and scale back.
double _gcdKg(double a, double b) {
  const scale = 100;
  var x = (a * scale).round();
  var y = (b * scale).round();
  while (y != 0) {
    final t = y;
    y = x % y;
    x = t;
  }
  return x / scale;
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../bridge/trigger_bridge.dart';
import '../../domain/models/workout_set.dart';
import '../../providers.dart';

/// A phantom set from the most recent session — "started, ended, absurd
/// duration" (§7 failure modes). Never dropped silently: the set stays
/// saved until the user explicitly discards it here.
class PhantomSet {
  const PhantomSet({
    required this.sessionId,
    required this.exerciseName,
    required this.set,
  });
  final String sessionId;
  final String exerciseName;
  final WorkoutSet set;
}

class AmbientBanners {
  const AmbientBanners({this.phantomSets = const [], this.capabilityOffer});
  final List<PhantomSet> phantomSets;

  /// Non-null once the user has finished 3+ sessions and this device
  /// actually supports a tier beyond the baseline ambient card (§16
  /// "capability detection").
  final TriggerTier? capabilityOffer;
}

/// Local-only for now — dismissing just hides it for the rest of the app
/// run. A one-time offer doesn't need a database column; add one if this
/// needs to survive a restart.
final capabilityOfferDismissedProvider = StateProvider<bool>((ref) => false);

/// Sits above whatever [HomeState] is showing, dismissible, never a modal
/// (I3) — the ambient unresolved-gap row from spec §12.
final ambientBannersProvider = FutureProvider<AmbientBanners>((ref) async {
  final sessions = ref.watch(sessionRepositoryProvider);
  final exercisesById = await ref.watch(allExercisesProvider.future);

  final phantoms = <PhantomSet>[];
  final recent = await sessions.mostRecentSession();
  if (recent != null) {
    for (final se in recent.exercises) {
      for (final set in se.sets) {
        if (set.isPhantom()) {
          phantoms.add(
            PhantomSet(
              sessionId: recent.id,
              exerciseName: exercisesById[se.exerciseId]?.name ?? se.exerciseId,
              set: set,
            ),
          );
        }
      }
    }
  }

  TriggerTier? offer;
  if (!ref.watch(capabilityOfferDismissedProvider)) {
    final count = await sessions.completedSessionCount();
    if (count >= 3) {
      try {
        final tiers = await ref.watch(triggerBridgeProvider).availableTiers();
        if (tiers.contains(TriggerTier.parityTile)) offer = TriggerTier.parityTile;
      } catch (_) {
        // No native tier query available (e.g. desktop/test run) — no offer.
      }
    }
  }

  return AmbientBanners(phantomSets: phantoms, capabilityOffer: offer);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../bridge/trigger_bridge.dart';
import '../../data/repositories/day_resolution_repository.dart';
import '../../data/repositories/plan_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../domain/models/plan.dart' show DayStatus;
import '../../domain/models/workout_set.dart';
import '../../domain/rules/day_status.dart';
import '../../domain/rules/home.dart' show weekdayOf;
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
  const AmbientBanners({this.phantomSets = const [], this.capabilityOffer, this.unresolvedGap});
  final List<PhantomSet> phantomSets;

  /// Non-null once the user has finished 3+ sessions and this device
  /// actually supports a tier beyond the baseline ambient card (§16
  /// "capability detection").
  final TriggerTier? capabilityOffer;

  /// The most recent scheduled-but-unlogged date (spec §9's ambient
  /// resolution path) — capped to one at a time so this row never stacks
  /// into a nag list.
  final DateTime? unresolvedGap;
}

/// Local-only for now — dismissing just hides it for the rest of the app
/// run. A one-time offer doesn't need a database column; add one if this
/// needs to survive a restart.
final capabilityOfferDismissedProvider = StateProvider<bool>((ref) => false);

/// Same in-memory pattern as [capabilityOfferDismissedProvider] — dismissing
/// the gap row doesn't resolve anything (that would be fabricating an
/// answer), it just quiets the nag for this app run. The gap reappears next
/// launch until actually resolved, and is always reachable via the heatmap.
final dismissedGapDatesProvider = StateProvider<Set<DateTime>>((ref) => {});

/// How far back the ambient row looks for an unresolved gap to surface.
const _gapLookbackDays = 14;

/// Sits above whatever [HomeState] is showing, dismissible, never a modal
/// (I3) — the ambient unresolved-gap row from spec §12/§9.
final ambientBannersProvider = FutureProvider<AmbientBanners>((ref) async {
  final now = ref.watch(nowProvider);
  final sessions = ref.watch(sessionRepositoryProvider);
  final plans = ref.watch(planRepositoryProvider);
  final resolutions = ref.watch(dayResolutionRepositoryProvider);
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

  final gap = await _mostRecentUnresolvedGap(now, plans, sessions, resolutions);
  final dismissed = ref.watch(dismissedGapDatesProvider);
  final visibleGap = gap != null && dismissed.any(_sameDate(gap)) ? null : gap;

  return AmbientBanners(phantomSets: phantoms, capabilityOffer: offer, unresolvedGap: visibleGap);
});

bool Function(DateTime) _sameDate(DateTime a) =>
    (b) => a.year == b.year && a.month == b.month && a.day == b.day;

Future<DateTime?> _mostRecentUnresolvedGap(
  DateTime now,
  PlanRepository plans,
  SessionRepository sessions,
  DayResolutionRepository resolutions,
) async {
  final today = DateTime(now.year, now.month, now.day);
  final from = today.subtract(const Duration(days: _gapLookbackDays));
  final plan = await plans.getLatestWeekPlan(demoRoutineId);
  if (plan == null) return null;

  final history = await sessions.getInRange(from, today);
  final allResolutions = await resolutions.inRange(from, today);

  for (var i = 1; i <= _gapLookbackDays; i++) {
    final date = today.subtract(Duration(days: i));
    final scheduled = plan.slots[weekdayOf(date)] != null;
    final sessionsOnDate = history.where((s) => _sameDate(date)(s.date)).toList();
    final resolution = allResolutions.where((r) => _sameDate(date)(r.date));
    final status = deriveDayStatus(
      date: date,
      today: today,
      scheduledOnThisWeekday: scheduled,
      sessionsOnDate: sessionsOnDate,
      manualResolution: resolution.isEmpty ? null : resolution.first,
    );
    if (status == DayStatus.unresolved) return date;
  }
  return null;
}

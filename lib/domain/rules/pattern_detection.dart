import '../models/plan.dart';
import 'analytics.dart' show exerciseOverlap, kSameDayThreshold;
import 'home.dart' show weekdayOf;

/// What was actually logged on one literal calendar date — pattern
/// detection never looks at intended/planned exercises, only what really
/// happened, per spec §9's "frequency across cycles, not most-recent
/// occurrence" rule.
class WeekdayObservation {
  final DateTime date;
  final Set<String> exerciseIds;
  const WeekdayObservation({required this.date, required this.exerciseIds});
}

/// A tentative "this weekday looks like X" guess — never applied, always
/// surfaced as a question (I2: observing -> provisional -> confirmed).
class PatternProposal {
  final Weekday weekday;
  final Set<String> exerciseIds;
  const PatternProposal({required this.weekday, required this.exerciseIds});
}

/// Spec §9, "Pattern detection must survive displacement": a change must
/// hold across at least two CONSECUTIVE cycles before it's proposed, and a
/// last-occurrence heuristic is explicitly disallowed — the reference case
/// is a travel week that bumps Pull from Wednesday to Thursday for one
/// week only, which must never make the detector propose moving Pull.
///
/// "Cycle" here is one occurrence of the weekday (a week apart) — the two
/// most recent observations for a weekday must agree with each other
/// (>= [kSameDayThreshold] overlap) before anything is proposed at all, and
/// a weekday with only one occurrence on record is an anecdote, not a
/// pattern (a single travel-week appearance on a new weekday never
/// qualifies). If the weekday is already assigned and the emerging pattern
/// already matches it, there's nothing new to say either.
List<PatternProposal> detectPatterns({
  required List<WeekdayObservation> observations,
  required Map<Weekday, Set<String>?> currentAssignment,
}) {
  final byWeekday = <Weekday, List<WeekdayObservation>>{};
  for (final obs in observations) {
    byWeekday.putIfAbsent(weekdayOf(obs.date), () => []).add(obs);
  }

  final proposals = <PatternProposal>[];
  for (final entry in byWeekday.entries) {
    final sorted = [...entry.value]..sort((a, b) => b.date.compareTo(a.date));
    if (sorted.length < 2) continue;

    final newest = sorted[0].exerciseIds;
    final secondNewest = sorted[1].exerciseIds;
    if (exerciseOverlap(newest, secondNewest) < kSameDayThreshold) continue;

    final current = currentAssignment[entry.key];
    if (current != null && exerciseOverlap(newest, current) >= kSameDayThreshold) {
      continue;
    }

    proposals.add(PatternProposal(weekday: entry.key, exerciseIds: newest));
  }
  return proposals;
}

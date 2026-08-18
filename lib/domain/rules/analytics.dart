import '../models/load.dart';
import '../models/workout_set.dart';

/// Charting and progress maths. See docs/spec.md §11.
///
/// Every function here takes sets and exercise IDs. NONE of them may take a
/// day, plan or weekday. (I1)

/// Epley estimated 1RM. Primary chart line.
///
/// Raw weight misleads: 60 kg x 3 looks like a regression from 40 kg x 8.
double? estimatedOneRepMax({required double? weightKg, required int reps}) {
  if (weightKg == null || reps <= 0) return null;
  return weightKg * (1 + reps / 30);
}

/// Volume — comparable across unilateral and bilateral sets, unlike e1RM.
double volumeKg(WorkoutSet set) {
  var total = 0.0;
  for (final seg in set.segments) {
    final w = seg.load.value ?? 0;
    total += w * seg.totalReps;
  }
  return total;
}

/// Chart series are ALWAYS split by execution. 40 kg single-leg and 60 kg
/// both-legs are not on the same scale — plotted as one line, the chart shows
/// a fake 50% jump between set 1 and set 2 every session.
///
/// DO NOT NORMALISE. Any multiplier is invented. Two series, two scale badges.
Map<Execution, List<WorkoutSet>> splitByExecution(List<WorkoutSet> sets) => {
      Execution.bilateral:
          sets.where((s) => s.execution == Execution.bilateral).toList(),
      Execution.unilateral:
          sets.where((s) => s.execution == Execution.unilateral).toList(),
    };

/// Left/right divergence — free from the data model, and the thing no
/// competitor surfaces. "Your left ham curl has been 1-2 reps behind your
/// right for six weeks."
double? meanLimbDivergence(List<WorkoutSet> unilateralSets) {
  final diffs = <double>[];
  for (final set in unilateralSets) {
    for (final seg in set.segments) {
      if (seg.repsLeft != null && seg.repsRight != null) {
        diffs.add((seg.repsLeft! - seg.repsRight!).toDouble());
      }
    }
  }
  if (diffs.isEmpty) return null;
  return diffs.reduce((a, b) => a + b) / diffs.length;
}

/// Overlap ratio between two sessions' exercise sets, for duplicate-day
/// detection. See docs/spec.md §10.
///
/// Computed on SETS, not sequences — so a crowded gym where the user deferred
/// exercises produces the same ratio and never trips the detector.
double exerciseOverlap(Set<String> a, Set<String> b) {
  if (a.isEmpty && b.isEmpty) return 1.0;
  final union = {...a, ...b};
  final shared = a.intersection(b);
  return shared.length / union.length;
}

/// > 0.70  same day, normal variation — say nothing, ever.
/// < 0.50  twice in a row — ask once, then never again for that pair.
const double kSameDayThreshold = 0.70;
const double kSplitDayThreshold = 0.50;

/// The exercise-detail chart's metric toggle (spec §11).
enum ChartMetric { e1rm, volume, topSet }

/// One plotted point. [date] comes from [WorkoutSet.startedAt] — sets with
/// no timing data (never started/ended through the app's own flow) can't be
/// placed on a time axis and are skipped by [chartSeries].
class ChartPoint {
  final DateTime date;
  final double value;
  const ChartPoint({required this.date, required this.value});
}

/// The heaviest single segment's e1RM within [set] — a drop set's "top"
/// effort, not an average across its segments.
double? _setE1rm(WorkoutSet set) {
  double? best;
  for (final seg in set.segments) {
    final v = estimatedOneRepMax(weightKg: seg.load.value, reps: seg.totalReps);
    if (v != null && (best == null || v > best)) best = v;
  }
  return best;
}

/// The heaviest single segment's load within [set] — the "top set" metric.
double? _setTopLoad(WorkoutSet set) {
  double? best;
  for (final seg in set.segments) {
    final v = seg.load.value;
    if (v != null && (best == null || v > best)) best = v;
  }
  return best;
}

double _metricValue(WorkoutSet set, ChartMetric metric) => switch (metric) {
      ChartMetric.e1rm => _setE1rm(set) ?? 0,
      ChartMetric.volume => volumeKg(set),
      ChartMetric.topSet => _setTopLoad(set) ?? 0,
    };

/// Turns a flat set history (already split by execution via
/// [splitByExecution] upstream — this function never mixes the two) into a
/// chronological series for one metric. Pure: no day/plan input, per I1.
List<ChartPoint> chartSeries(List<WorkoutSet> sets, ChartMetric metric) {
  final points = <ChartPoint>[
    for (final s in sets)
      if (s.startedAt != null) ChartPoint(date: s.startedAt!, value: _metricValue(s, metric)),
  ];
  points.sort((a, b) => a.date.compareTo(b.date));
  return points;
}

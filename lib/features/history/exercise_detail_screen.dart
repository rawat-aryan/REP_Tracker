import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/exercise.dart';
import '../../domain/models/load.dart';
import '../../domain/models/workout_set.dart';
import '../../domain/rules/analytics.dart';
import '../../providers.dart';
import '../../theme.dart';

const _metricLabels = {
  ChartMetric.e1rm: 'e1RM',
  ChartMetric.volume: 'Volume',
  ChartMetric.topSet: 'Top set',
};

/// Exercise detail (spec §11). Bilateral and unilateral are **always** two
/// separate lines with their own scale badge — never merged, never
/// normalised (I1, and the milestone's own literal Done-when: the ham curl
/// case must not show a jump between a 40 kg unilateral set and a 60 kg
/// bilateral one).
class ExerciseDetailScreen extends ConsumerStatefulWidget {
  const ExerciseDetailScreen({super.key, required this.exerciseId, required this.exerciseName});

  final String exerciseId;
  final String exerciseName;

  @override
  ConsumerState<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends ConsumerState<ExerciseDetailScreen> {
  ChartMetric _metric = ChartMetric.e1rm;
  List<WorkoutSet>? _sets;
  ({String id, String name, List<WorkoutSet> sets})? _compare;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sets = await ref.read(sessionRepositoryProvider).historyForExercise(widget.exerciseId);
    if (!mounted) return;
    setState(() => _sets = sets);
  }

  Future<void> _pickCompare() async {
    final all = await ref.read(exerciseRepositoryProvider).getAll();
    if (!mounted) return;
    final picked = await showModalBottomSheet<({String id, String name})>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _ComparePickerSheet(
        candidates: all.where((e) => e.id != widget.exerciseId).toList(),
      ),
    );
    if (picked == null) return;
    final sets = await ref.read(sessionRepositoryProvider).historyForExercise(picked.id);
    if (!mounted) return;
    setState(() => _compare = (id: picked.id, name: picked.name, sets: sets));
  }

  @override
  Widget build(BuildContext context) {
    final sets = _sets;
    return Scaffold(
      appBar: AppBar(title: Text(widget.exerciseName)),
      body: sets == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: SingleChildScrollView(
                  child: _DetailBody(
                    sets: sets,
                    compare: _compare,
                    metric: _metric,
                    onMetricChanged: (m) => setState(() => _metric = m),
                    onCompare: _pickCompare,
                    onClearCompare: () => setState(() => _compare = null),
                  ),
                ),
              ),
            ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.sets,
    required this.compare,
    required this.metric,
    required this.onMetricChanged,
    required this.onCompare,
    required this.onClearCompare,
  });

  final List<WorkoutSet> sets;
  final ({String id, String name, List<WorkoutSet> sets})? compare;
  final ChartMetric metric;
  final ValueChanged<ChartMetric> onMetricChanged;
  final VoidCallback onCompare;
  final VoidCallback onClearCompare;

  @override
  Widget build(BuildContext context) {
    final byExecution = splitByExecution(sets);
    final uniSets = byExecution[Execution.unilateral]!;
    final biSets = byExecution[Execution.bilateral]!;
    final uniSeries = chartSeries(uniSets, metric);
    final biSeries = chartSeries(biSets, metric);
    final compareSeries =
        compare == null ? const <ChartPoint>[] : chartSeries(splitByExecution(compare!.sets)[Execution.bilateral]!, metric);
    final divergence = meanLimbDivergence(uniSets);

    if (sets.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Text(
          'No sets logged yet — this fills in the first time you log this exercise.',
          style: TextStyle(fontSize: 13, color: AppColors.ink3),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${sets.length} ${sets.length == 1 ? 'set' : 'sets'} logged',
          style: const TextStyle(fontSize: 12.5, color: AppColors.ink3),
        ),
        const SizedBox(height: 13),
        _MetricToggle(metric: metric, onChanged: onMetricChanged),
        const SizedBox(height: 14),
        SizedBox(
          height: 220,
          child: _Chart(
            uni: uniSeries,
            bi: biSeries,
            compare: compareSeries,
            compareName: compare?.name,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 16,
          runSpacing: 6,
          children: [
            if (biSeries.isNotEmpty)
              _SeriesLabel(color: AppColors.accent, text: 'Bilateral · ${_fmt(biSeries.last.value)}'),
            if (uniSeries.isNotEmpty)
              _SeriesLabel(color: AppColors.gold, text: 'Unilateral · ${_fmt(uniSeries.last.value)}'),
            if (compareSeries.isNotEmpty)
              _SeriesLabel(color: AppColors.red, text: '${compare!.name} · ${_fmt(compareSeries.last.value)}'),
          ],
        ),
        if (divergence != null && divergence.abs() >= 0.5) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.accent),
              color: AppColors.accentBg,
              borderRadius: BorderRadius.circular(appRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  divergence < 0 ? 'Left is trailing right' : 'Right is trailing left',
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: AppColors.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  '${divergence.abs().toStringAsFixed(1)} reps average',
                  style: monoStyle(fontSize: 12, color: AppColors.accentInk),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: compare == null ? onCompare : onClearCompare,
            child: Text(compare == null ? 'Compare with another exercise' : 'Clear compare (${compare!.name})'),
          ),
        ),
      ],
    );
  }
}

String _fmt(double v) => v == v.roundToDouble() ? '${v.toInt()} kg' : '${v.toStringAsFixed(1)} kg';

class _MetricToggle extends StatelessWidget {
  const _MetricToggle({required this.metric, required this.onChanged});

  final ChartMetric metric;
  final ValueChanged<ChartMetric> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final m in ChartMetric.values)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_metricLabels[m]!),
              selected: metric == m,
              onSelected: (_) => onChanged(m),
            ),
          ),
      ],
    );
  }
}

class _SeriesLabel extends StatelessWidget {
  const _SeriesLabel({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, color: color),
        const SizedBox(width: 6),
        Text(text, style: monoStyle(fontSize: 11.5, color: AppColors.ink2)),
      ],
    );
  }
}

class _Chart extends StatelessWidget {
  const _Chart({required this.uni, required this.bi, required this.compare, this.compareName});

  final List<ChartPoint> uni;
  final List<ChartPoint> bi;
  final List<ChartPoint> compare;
  final String? compareName;

  @override
  Widget build(BuildContext context) {
    final all = [...uni, ...bi, ...compare];
    if (all.isEmpty) {
      return const Center(
        child: Text('Nothing plotted yet for this metric', style: TextStyle(fontSize: 12.5, color: AppColors.ink3)),
      );
    }
    final minDate = all.map((p) => p.date).reduce((a, b) => a.isBefore(b) ? a : b);
    double x(DateTime d) => d.difference(minDate).inHours / 24.0;

    List<FlSpot> spots(List<ChartPoint> series) =>
        [for (final p in series) FlSpot(x(p.date), p.value)];

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          if (bi.isNotEmpty)
            LineChartBarData(
              spots: spots(bi),
              isCurved: false,
              color: AppColors.accent,
              barWidth: 2,
              // A single logged set is one spot with no line segment to draw
              // — dots must stay on, or a one-point series renders as a
              // blank chart instead of a visible reading.
              dotData: const FlDotData(show: true),
            ),
          if (uni.isNotEmpty)
            LineChartBarData(
              spots: spots(uni),
              isCurved: false,
              color: AppColors.gold,
              barWidth: 2,
              dashArray: const [4, 4],
              dotData: const FlDotData(show: true),
            ),
          if (compare.isNotEmpty)
            LineChartBarData(
              spots: spots(compare),
              isCurved: false,
              color: AppColors.red,
              barWidth: 2,
              dashArray: const [2, 3],
              dotData: const FlDotData(show: true),
            ),
        ],
      ),
    );
  }
}

class _ComparePickerSheet extends StatefulWidget {
  const _ComparePickerSheet({required this.candidates});

  final List<Exercise> candidates;

  @override
  State<_ComparePickerSheet> createState() => _ComparePickerSheetState();
}

class _ComparePickerSheetState extends State<_ComparePickerSheet> {
  late List<Exercise> _results = widget.candidates;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(hintText: 'Search all exercises…'),
              onChanged: (q) {
                final needle = q.toLowerCase();
                setState(() {
                  _results = needle.isEmpty
                      ? widget.candidates
                      : widget.candidates.where((e) => e.name.toLowerCase().contains(needle)).toList();
                });
              },
            ),
            Expanded(
              child: ListView(
                children: [
                  for (final ex in _results)
                    ListTile(
                      title: Text(ex.name, style: const TextStyle(fontSize: 13.5, color: AppColors.ink)),
                      onTap: () => Navigator.of(context).pop((id: ex.id, name: ex.name)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

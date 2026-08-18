import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/exercise.dart';
import '../../domain/models/load.dart';
import '../../domain/models/workout_set.dart';
import '../../domain/rules/prefill.dart';
import '../../providers.dart';
import 'session_controller.dart';

/// The overflow / "⋯" screen (spec §8.2-8.3, screens.html "Rep entry — full").
/// Reached from the ledger for anything the fast tap-to-accept can't
/// express: asymmetric L/R, tags, an execution correction, or editing any
/// past set at all (I5 — nothing is ever read-only).
///
/// ponytail: drop sets are tagged but not given multi-segment entry here —
/// this sheet only edits segment 0. Add per-segment rows if drop-set
/// logging needs more than a tag.
Future<void> showRepEntrySheet(
  BuildContext context, {
  required String sessionId,
  required String exerciseId,
  required WorkoutSet set,
  required Exercise exercise,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _RepEntrySheet(
      sessionId: sessionId,
      exerciseId: exerciseId,
      set: set,
      exercise: exercise,
    ),
  );
}

class _RepEntrySheet extends ConsumerStatefulWidget {
  const _RepEntrySheet({
    required this.sessionId,
    required this.exerciseId,
    required this.set,
    required this.exercise,
  });

  final String sessionId;
  final String exerciseId;
  final WorkoutSet set;
  final Exercise exercise;

  @override
  ConsumerState<_RepEntrySheet> createState() => _RepEntrySheetState();
}

class _RepEntrySheetState extends ConsumerState<_RepEntrySheet> {
  late Execution _execution;
  late LoadScope _scope;
  late LoadSource _source;
  late final TextEditingController _weight;
  late final TextEditingController _reps;
  late final TextEditingController _repsLeft;
  late final TextEditingController _repsRight;
  late Set<SetTag> _tags;
  double _increment = 2.5;
  int? _predicted;

  @override
  void initState() {
    super.initState();
    final seg = widget.set.segments.isNotEmpty ? widget.set.segments.first : null;
    _execution = widget.set.execution;
    _scope = seg?.load.scope ?? LoadScope.total;
    _source = seg?.load.source ?? widget.exercise.defaultLoadSource;
    _weight = TextEditingController(text: _fmt(seg?.load.value));
    _reps = TextEditingController(text: seg?.reps?.toString() ?? '');
    _repsLeft = TextEditingController(text: seg?.repsLeft?.toString() ?? '');
    _repsRight = TextEditingController(text: seg?.repsRight?.toString() ?? '');
    _tags = {...widget.set.tags};
    _load();
  }

  Future<void> _load() async {
    final sessions = ref.read(sessionRepositoryProvider);
    final prefill = ref.read(prefillServiceProvider);
    final history = await sessions.historyForExercise(widget.exerciseId, limit: 20);
    final distinct = <double>[];
    for (final s in history) {
      for (final seg in s.segments) {
        final v = seg.load.value;
        if (v != null && !distinct.contains(v)) distinct.add(v);
      }
      if (distinct.length >= 10) break;
    }
    final predicted = await prefill.repsFor(
      exerciseId: widget.exerciseId,
      setIndex: widget.set.index,
    );
    if (!mounted) return;
    setState(() {
      _increment = resolveIncrementKg(
        exercise: widget.exercise,
        recentDistinctLoads: distinct,
      );
      _predicted = predicted;
    });
  }

  @override
  void dispose() {
    _weight.dispose();
    _reps.dispose();
    _repsLeft.dispose();
    _repsRight.dispose();
    super.dispose();
  }

  String _fmt(double? v) =>
      v == null ? '' : (v == v.roundToDouble() ? v.toInt().toString() : v.toString());

  void _bumpWeight(double delta) {
    final current = double.tryParse(_weight.text) ?? 0;
    setState(() => _weight.text = _fmt((current + delta).clamp(0, 999)));
  }

  void _save() {
    final weight = double.tryParse(_weight.text);
    final segment = SetSegment(
      load: Load(value: weight, source: _source, scope: _scope),
      reps: _execution == Execution.bilateral ? int.tryParse(_reps.text) : null,
      repsLeft: _execution == Execution.unilateral ? int.tryParse(_repsLeft.text) : null,
      repsRight: _execution == Execution.unilateral ? int.tryParse(_repsRight.text) : null,
    );
    final updated = widget.set.copyWith(
      execution: _execution,
      segments: [segment],
      tags: _tags,
    );
    ref
        .read(sessionControllerProvider(widget.sessionId).notifier)
        .saveSetEdits(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.exercise.name, style: Theme.of(context).textTheme.titleMedium),
                Text('set ${widget.set.index}', style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
            const SizedBox(height: 8),
            SegmentedButton<Execution>(
              segments: const [
                ButtonSegment(value: Execution.bilateral, label: Text('Bilateral')),
                ButtonSegment(value: Execution.unilateral, label: Text('Unilateral')),
              ],
              selected: {_execution},
              onSelectionChanged: (s) => setState(() => _execution = s.first),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Weight'),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => _bumpWeight(-_increment),
                  onLongPress: () => _bumpWeight(-coarseIncrementKg(_increment)),
                ),
                SizedBox(
                  width: 64,
                  child: TextField(
                    controller: _weight,
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => _bumpWeight(_increment),
                  onLongPress: () => _bumpWeight(coarseIncrementKg(_increment)),
                ),
                const Text('kg'),
                const Spacer(),
                FilterChip(
                  label: const Text('/ side'),
                  selected: _scope == LoadScope.perLimb,
                  onSelected: (v) => setState(
                    () => _scope = v ? LoadScope.perLimb : LoadScope.total,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_execution == Execution.bilateral)
              _repsField('Reps', _reps)
            else ...[
              _repsField('Left', _repsLeft),
              const SizedBox(height: 8),
              _repsField('Right', _repsRight),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _tagChip(SetTag.warmup, 'Warmup'),
                _tagChip(SetTag.dropSet, 'Drop set'),
                _tagChip(SetTag.toFailure, 'To failure'),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }

  Widget _repsField(String label, TextEditingController controller) {
    final base = int.tryParse(controller.text) ?? _predicted ?? 8;
    return Row(
      children: [
        SizedBox(width: 48, child: Text(label)),
        ...repQuickPicks(base).map(
          (v) => Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text('$v'),
              selected: controller.text == '$v',
              onSelected: (_) => setState(() => controller.text = '$v'),
            ),
          ),
        ),
        SizedBox(
          width: 48,
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: '…'),
          ),
        ),
      ],
    );
  }

  Widget _tagChip(SetTag tag, String label) => FilterChip(
        label: Text(label),
        selected: _tags.contains(tag),
        onSelected: (v) => setState(() {
          if (v) {
            _tags.add(tag);
          } else {
            _tags.remove(tag);
          }
        }),
      );
}

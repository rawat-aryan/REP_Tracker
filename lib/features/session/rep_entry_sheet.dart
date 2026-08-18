import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/exercise.dart';
import '../../domain/models/load.dart';
import '../../domain/models/workout_set.dart';
import '../../domain/rules/prefill.dart';
import '../../providers.dart';
import '../../theme.dart';
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
        left: 18,
        right: 18,
        top: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 18,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.exercise.name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.ink),
                ),
                Text('set ${widget.set.index}', style: monoStyle(fontSize: 11, color: AppColors.ink3)),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<Execution>(
              style: SegmentedButton.styleFrom(
                backgroundColor: AppColors.surface2,
                foregroundColor: AppColors.ink2,
                selectedBackgroundColor: AppColors.accent,
                selectedForegroundColor: AppColors.onAccent,
                side: const BorderSide(color: AppColors.lineStrong),
              ),
              segments: const [
                ButtonSegment(value: Execution.bilateral, label: Text('Bilateral')),
                ButtonSegment(value: Execution.unilateral, label: Text('Unilateral')),
              ],
              selected: {_execution},
              onSelectionChanged: (s) => setState(() => _execution = s.first),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(width: 52, child: Text('WEIGHT', style: eyebrowStyle())),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _StepGlyph(
                        '−',
                        onTap: () => _bumpWeight(-_increment),
                        onLongPress: () => _bumpWeight(-coarseIncrementKg(_increment)),
                      ),
                      SizedBox(
                        width: 52,
                        child: TextField(
                          controller: _weight,
                          textAlign: TextAlign.center,
                          style: monoStyle(fontSize: 14),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            filled: false,
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      _StepGlyph(
                        '+',
                        onTap: () => _bumpWeight(_increment),
                        onLongPress: () => _bumpWeight(coarseIncrementKg(_increment)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text('kg', style: TextStyle(fontSize: 12, color: AppColors.ink3)),
                const Spacer(),
                _ToggleChip(
                  label: '/ side',
                  selected: _scope == LoadScope.perLimb,
                  onTap: () => setState(
                    () => _scope = _scope == LoadScope.perLimb ? LoadScope.total : LoadScope.perLimb,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_execution == Execution.bilateral)
              _repsField('Reps', _reps)
            else ...[
              _repsField('Left', _repsLeft),
              const SizedBox(height: 8),
              _repsField('Right', _repsRight),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ToggleChip(
                    label: 'Warmup',
                    selected: _tags.contains(SetTag.warmup),
                    onTap: () => _toggleTag(SetTag.warmup),
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: _ToggleChip(
                    label: 'Drop set',
                    selected: _tags.contains(SetTag.dropSet),
                    onTap: () => _toggleTag(SetTag.dropSet),
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: _ToggleChip(
                    label: 'To failure',
                    selected: _tags.contains(SetTag.toFailure),
                    onTap: () => _toggleTag(SetTag.toFailure),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            FilledButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }

  void _toggleTag(SetTag tag) => setState(() {
        if (!_tags.remove(tag)) _tags.add(tag);
      });

  Widget _repsField(String label, TextEditingController controller) {
    final base = int.tryParse(controller.text) ?? _predicted ?? 8;
    return Row(
      children: [
        SizedBox(width: 44, child: Text(label.toUpperCase(), style: eyebrowStyle())),
        for (final v in repQuickPicks(base))
          _PickChip(
            label: '$v',
            selected: controller.text == '$v',
            onTap: () => setState(() => controller.text = '$v'),
          ),
        SizedBox(
          width: 38,
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            style: monoStyle(fontSize: 13, color: AppColors.ink3),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: '…',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }
}

/// `.stepper .g` — the plain +/- glyphs either side of the value.
class _StepGlyph extends StatelessWidget {
  const _StepGlyph(this.symbol, {required this.onTap, required this.onLongPress});

  final String symbol;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(symbol, style: const TextStyle(fontSize: 16, color: AppColors.ink3, height: 1)),
      ),
    );
  }
}

/// `.pick` / `.pick.on` — the rep quick-pick buttons.
class _PickChip extends StatelessWidget {
  const _PickChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: const EdgeInsets.only(right: 6),
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.accent : null,
            border: Border.all(color: selected ? AppColors.accent : AppColors.lineStrong),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: monoStyle(fontSize: 14, color: selected ? AppColors.onAccent : AppColors.ink2),
          ),
        ),
      ),
    );
  }
}

/// `.btn-q`-shaped toggle — used for the `/ side` chip and the three tag
/// buttons (Warmup/Drop set/To failure).
class _ToggleChip extends StatelessWidget {
  const _ToggleChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(appRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : null,
          border: Border.all(color: selected ? AppColors.accent : AppColors.lineStrong),
          borderRadius: BorderRadius.circular(appRadius),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12.5, color: selected ? AppColors.onAccent : AppColors.ink2),
        ),
      ),
    );
  }
}

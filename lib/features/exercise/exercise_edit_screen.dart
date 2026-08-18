import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/exercise.dart';
import '../../providers.dart';
import '../../theme.dart';

/// Spec §10: merge/archive/increment-override/variant-pointer, all on the
/// exercise the user is already looking at (reached from the milestone 08
/// chart screen's edit icon). Renaming, aliases-matching-in-search, and
/// archive-never-delete (I7) all fall out of the repository methods
/// milestone 03 already built — this screen is the missing UI for them.
class ExerciseEditScreen extends ConsumerStatefulWidget {
  const ExerciseEditScreen({super.key, required this.exerciseId});

  final String exerciseId;

  @override
  ConsumerState<ExerciseEditScreen> createState() => _ExerciseEditScreenState();
}

class _ExerciseEditScreenState extends ConsumerState<ExerciseEditScreen> {
  Exercise? _exercise;
  late final TextEditingController _name;
  late final TextEditingController _increment;
  late final FocusNode _nameFocus;
  late final FocusNode _incrementFocus;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _increment = TextEditingController();
    // Saved on every keystroke's field losing focus, not just the
    // keyboard's "done" action — navigating back (the far more common way
    // to leave this screen) never fires onEditingComplete, and this app's
    // convention everywhere else is immediate persistence, no separate
    // save step.
    _nameFocus = FocusNode()..addListener(() { if (!_nameFocus.hasFocus) _save(); });
    _incrementFocus = FocusNode()..addListener(() { if (!_incrementFocus.hasFocus) _save(); });
    _load();
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _incrementFocus.dispose();
    _name.dispose();
    _increment.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final ex = await ref.read(exerciseRepositoryProvider).getById(widget.exerciseId);
    if (!mounted || ex == null) return;
    setState(() {
      _exercise = ex;
      _name.text = ex.name;
      _increment.text = ex.incrementOverride?.toString() ?? '';
    });
  }

  Future<void> _save() async {
    final ex = _exercise;
    if (ex == null) return;
    final name = _name.text.trim();
    final incrementText = _increment.text.trim();
    final increment = double.tryParse(incrementText);
    final updated = ex.copyWith(
      name: name.isEmpty ? ex.name : name,
      incrementOverride: increment,
      clearIncrementOverride: incrementText.isEmpty,
    );
    await ref.read(exerciseRepositoryProvider).upsert(updated);
    ref.invalidate(allExercisesProvider);
    if (mounted) setState(() => _exercise = updated);
  }

  Future<void> _archive() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Archive this exercise?'),
        content: const Text('It disappears from pickers but every past set stays in history.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Archive')),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(exerciseRepositoryProvider).archive(widget.exerciseId);
    ref.invalidate(allExercisesProvider);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _pickAndSet({required bool forMerge}) async {
    final all = await ref.read(exerciseRepositoryProvider).getAll();
    final candidates = all.where((e) => e.id != widget.exerciseId).toList();
    if (!mounted) return;
    final picked = await showModalBottomSheet<Exercise>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _PickSheet(candidates: candidates),
    );
    if (picked == null) return;
    if (!mounted) return;

    if (forMerge) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Merge "${picked.name}" into "${_exercise!.name}"?'),
          content: const Text(
            'Every historical set from the other exercise moves onto this one. '
            'The other exercise is archived, never deleted.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Merge')),
          ],
        ),
      );
      if (confirmed != true) return;
      await ref.read(exerciseRepositoryProvider).merge(keepId: widget.exerciseId, loserId: picked.id);
      ref.invalidate(allExercisesProvider);
    } else {
      await ref
          .read(exerciseRepositoryProvider)
          .upsert(_exercise!.copyWith(variantOf: picked.id));
      ref.invalidate(allExercisesProvider);
      await _load();
    }
  }

  Future<void> _clearVariant() async {
    await ref.read(exerciseRepositoryProvider).upsert(_exercise!.copyWith(clearVariantOf: true));
    ref.invalidate(allExercisesProvider);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final ex = _exercise;
    return Scaffold(
      appBar: AppBar(title: Text(ex?.name ?? 'Exercise')),
      body: ex == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('NAME', style: eyebrowStyle()),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _name,
                      focusNode: _nameFocus,
                      onSubmitted: (_) => _save(),
                      onEditingComplete: _save,
                    ),
                    const SizedBox(height: 16),
                    Text('WEIGHT INCREMENT OVERRIDE (KG)', style: eyebrowStyle()),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _increment,
                      focusNode: _incrementFocus,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(hintText: 'Learned (equipment default ${ex.equipmentIncrement} kg)'),
                      onSubmitted: (_) => _save(),
                      onEditingComplete: _save,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text('VARIANT OF', style: eyebrowStyle()),
                        ),
                        if (ex.variantOf != null)
                          TextButton(onPressed: _clearVariant, child: const Text('Clear')),
                      ],
                    ),
                    const SizedBox(height: 6),
                    OutlinedButton(
                      onPressed: () => _pickAndSet(forMerge: false),
                      child: Text(
                        ex.variantOf == null
                            ? 'Not a variant of anything'
                            : 'Variant of: ${ref.watch(allExercisesProvider).valueOrNull?[ex.variantOf]?.name ?? ex.variantOf}',
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _pickAndSet(forMerge: true),
                        child: const Text('Merge another exercise into this one'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _archive,
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.red),
                        child: const Text('Archive'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _PickSheet extends StatefulWidget {
  const _PickSheet({required this.candidates});

  final List<Exercise> candidates;

  @override
  State<_PickSheet> createState() => _PickSheetState();
}

class _PickSheetState extends State<_PickSheet> {
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
                      onTap: () => Navigator.of(context).pop(ex),
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

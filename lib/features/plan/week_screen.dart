import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/exercise.dart';
import '../../domain/models/plan.dart';
import '../../providers.dart';
import '../../theme.dart';
import '../home/home_screen.dart';

const _uuid = Uuid();
const _weekdayLabels = {
  Weekday.mon: 'M',
  Weekday.tue: 'T',
  Weekday.wed: 'W',
  Weekday.thu: 'T',
  Weekday.fri: 'F',
  Weekday.sat: 'S',
  Weekday.sun: 'S',
};

/// The week grid (spec §4.1). One screen, two call sites: onboarding step 3
/// (`onboarding: true`, day names/weekday assignment/rest days only, per the
/// mockup) and the settings-reachable day editor later (exercises, set
/// counts, everything editable) — same widget, same code path, exactly what
/// §4.1 requires ("must not be built as an onboarding-only wizard step").
class WeekScreen extends ConsumerStatefulWidget {
  const WeekScreen({super.key, this.onboarding = false});

  final bool onboarding;

  @override
  ConsumerState<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends ConsumerState<WeekScreen> {
  late Weekday _selected = Weekday.values[DateTime.now().weekday - 1];
  WeekPlan? _plan;
  WorkoutDay? _day;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final plans = ref.read(planRepositoryProvider);
    final plan = await plans.getLatestWeekPlan(demoRoutineId);
    final dayId = plan?.slots[_selected];
    final day = dayId == null ? null : await plans.getWorkoutDay(dayId);
    if (!mounted) return;
    setState(() {
      _plan = plan;
      _day = day;
      _loading = false;
    });
  }

  Future<void> _selectWeekday(Weekday weekday) async {
    setState(() => _selected = weekday);
    await _load();
  }

  Future<void> _writeSlots(Map<Weekday, String?> slots) async {
    final plans = ref.read(planRepositoryProvider);
    await plans.createWeekPlanVersion(
      WeekPlan(routineId: demoRoutineId, version: (_plan?.version ?? 0) + 1, slots: slots),
    );
    await _load();
  }

  Future<void> _markRest() async {
    final slots = {...?_plan?.slots};
    slots[_selected] = null;
    await _writeSlots(slots);
  }

  Future<void> _assignDay(String dayId) async {
    final slots = {...?_plan?.slots};
    slots[_selected] = dayId;
    await _writeSlots(slots);
  }

  Future<void> _createAndAssignDay(String name) async {
    final id = _uuid.v4();
    await ref.read(planRepositoryProvider).upsertWorkoutDay(WorkoutDay(id: id, name: name));
    await _assignDay(id);
  }

  Future<void> _renameDay(String newName) async {
    final day = _day;
    if (day == null || newName.trim().isEmpty) return;
    await ref.read(planRepositoryProvider).upsertWorkoutDay(
          WorkoutDay(id: day.id, name: newName.trim(), exercises: day.exercises),
        );
    await _load();
  }

  Future<void> _addExercise(String exerciseId) async {
    final day = _day;
    if (day == null) return;
    final next = [
      ...day.exercises,
      PlannedExercise(exerciseId: exerciseId, order: day.exercises.length),
    ];
    await ref
        .read(planRepositoryProvider)
        .upsertWorkoutDay(WorkoutDay(id: day.id, name: day.name, exercises: next));
    await _load();
  }

  Future<void> _setTargetSets(PlannedExercise pe, int targetSets) async {
    final day = _day;
    if (day == null || targetSets < 1) return;
    final next = [
      for (final e in day.exercises)
        e.exerciseId == pe.exerciseId
            ? PlannedExercise(
                exerciseId: e.exerciseId,
                order: e.order,
                targetSets: targetSets,
                defaultUnilateral: e.defaultUnilateral,
              )
            : e,
    ];
    await ref
        .read(planRepositoryProvider)
        .upsertWorkoutDay(WorkoutDay(id: day.id, name: day.name, exercises: next));
    await _load();
  }

  Future<void> _removeExercise(String exerciseId) async {
    final day = _day;
    if (day == null) return;
    final next = day.exercises.where((e) => e.exerciseId != exerciseId).toList();
    await ref
        .read(planRepositoryProvider)
        .upsertWorkoutDay(WorkoutDay(id: day.id, name: day.name, exercises: next));
    await _load();
  }

  void _finish() {
    if (widget.onboarding) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _renameDialog() async {
    final controller = TextEditingController(text: _day?.name);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename day'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) await _renameDay(result);
  }

  Future<void> _assignSheet() async {
    final plans = ref.read(planRepositoryProvider);
    final existing = await plans.getAllWorkoutDays();
    if (!mounted) return;
    final newDayController = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ADD TRAINING DAY', style: eyebrowStyle()),
            const SizedBox(height: 10),
            for (final d in existing)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(d.name, style: const TextStyle(fontSize: 13.5, color: AppColors.ink)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _assignDay(d.id);
                },
              ),
            const SizedBox(height: 8),
            TextField(
              controller: newDayController,
              decoration: const InputDecoration(hintText: 'New day name'),
              textCapitalization: TextCapitalization.words,
              onSubmitted: (name) {
                if (name.trim().isEmpty) return;
                Navigator.pop(sheetContext);
                _createAndAssignDay(name);
              },
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final name = newDayController.text.trim();
                  if (name.isEmpty) return;
                  Navigator.pop(sheetContext);
                  _createAndAssignDay(name);
                },
                child: const Text('Create'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addExerciseSheet() async {
    final all = await ref.read(exerciseRepositoryProvider).getAll();
    if (!mounted) return;
    final query = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _ExerciseSearchSheet(
        all: all,
        query: query,
        onPick: (id) {
          Navigator.pop(sheetContext);
          _addExercise(id);
        },
      ),
    );
  }

  Future<void> _editSetsDialog(PlannedExercise pe) async {
    var count = pe.targetSets;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Target sets'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: count > 1 ? () => setDialogState(() => count--) : null,
                icon: const Icon(Icons.remove),
              ),
              Text('$count', style: monoStyle(fontSize: 20)),
              IconButton(
                onPressed: () => setDialogState(() => count++),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _removeExercise(pe.exerciseId);
              },
              child: const Text('Remove'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _setTargetSets(pe, count);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final byId = ref.watch(allExercisesProvider).valueOrNull ?? const <String, Exercise>{};
    return Scaffold(
      appBar: AppBar(title: const Text('Your week')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weights get learned as you train',
                      style: TextStyle(fontSize: 12.5, color: AppColors.ink3, height: 1.4),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        for (final w in Weekday.values)
                          Expanded(
                            child: _WeekdayChip(
                              label: _weekdayLabels[w]!,
                              selected: w == _selected,
                              rest: _plan?.slots[w] == null,
                              onTap: () => _selectWeekday(w),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: _day == null
                          ? _RestDaySection(onAdd: _assignSheet)
                          : _DaySection(
                              day: _day!,
                              byId: byId,
                              onRename: _renameDialog,
                              onMarkRest: _markRest,
                              onAddExercise: _addExerciseSheet,
                              onEditExercise: _editSetsDialog,
                            ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _finish,
                        child: Text(widget.onboarding ? 'Done' : 'Close'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _WeekdayChip extends StatelessWidget {
  const _WeekdayChip({
    required this.label,
    required this.selected,
    required this.rest,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool rest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.accent : (rest ? null : AppColors.surface2),
            borderRadius: BorderRadius.circular(8),
            border: rest && !selected ? Border.all(color: AppColors.lineStrong, style: BorderStyle.solid) : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: selected ? AppColors.onAccent : AppColors.ink2,
            ),
          ),
        ),
      ),
    );
  }
}

class _RestDaySection extends StatelessWidget {
  const _RestDaySection({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rest day', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        InkWell(
          onTap: onAdd,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              '＋  Add training day',
              style: TextStyle(fontSize: 13, color: AppColors.ink2),
            ),
          ),
        ),
      ],
    );
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({
    required this.day,
    required this.byId,
    required this.onRename,
    required this.onMarkRest,
    required this.onAddExercise,
    required this.onEditExercise,
  });

  final WorkoutDay day;
  final Map<String, Exercise> byId;
  final VoidCallback onRename;
  final VoidCallback onMarkRest;
  final VoidCallback onAddExercise;
  final void Function(PlannedExercise) onEditExercise;

  @override
  Widget build(BuildContext context) {
    final sorted = [...day.exercises]..sort((a, b) => a.order.compareTo(b.order));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onRename,
                child: Text(day.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ),
            ),
            TextButton(onPressed: onMarkRest, child: const Text('Mark as rest')),
          ],
        ),
        const SizedBox(height: 6),
        Expanded(
          child: ListView(
            children: [
              if (sorted.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'No exercises yet — they fill in from your first session',
                    style: TextStyle(fontSize: 13, color: AppColors.ink3),
                  ),
                ),
              for (final pe in sorted)
                InkWell(
                  onTap: () => onEditExercise(pe),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.line)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            byId[pe.exerciseId]?.name ?? pe.exerciseId,
                            style: const TextStyle(fontSize: 13.5, color: AppColors.ink),
                          ),
                        ),
                        Text('${pe.targetSets} sets', style: monoStyle(fontSize: 12.5, color: AppColors.ink2)),
                      ],
                    ),
                  ),
                ),
              InkWell(
                onTap: onAddExercise,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text('＋  Add exercise', style: TextStyle(fontSize: 13, color: AppColors.ink2)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExerciseSearchSheet extends StatefulWidget {
  const _ExerciseSearchSheet({required this.all, required this.query, required this.onPick});

  final List<Exercise> all;
  final TextEditingController query;
  final void Function(String exerciseId) onPick;

  @override
  State<_ExerciseSearchSheet> createState() => _ExerciseSearchSheetState();
}

class _ExerciseSearchSheetState extends State<_ExerciseSearchSheet> {
  late List<Exercise> _results = widget.all;

  void _filter(String q) {
    final needle = q.toLowerCase();
    setState(() {
      _results = needle.isEmpty
          ? widget.all
          : widget.all.where((e) => e.name.toLowerCase().contains(needle)).toList();
    });
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
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            TextField(
              controller: widget.query,
              decoration: const InputDecoration(hintText: 'Search all exercises…'),
              onChanged: _filter,
            ),
            Expanded(
              child: ListView(
                children: [
                  for (final ex in _results)
                    ListTile(
                      title: Text(ex.name, style: const TextStyle(fontSize: 13.5, color: AppColors.ink)),
                      subtitle: Text(ex.primaryMuscle.name, style: const TextStyle(fontSize: 11, color: AppColors.ink3)),
                      onTap: () => widget.onPick(ex.id),
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

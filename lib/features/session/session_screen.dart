import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/models/exercise.dart';
import '../../domain/models/load.dart';
import '../../domain/models/session.dart';
import '../../domain/models/workout_set.dart';
import '../../providers.dart';
import 'exercise_picker_sheet.dart';
import 'rep_entry_sheet.dart';
import 'session_controller.dart';

/// The session ledger (milestone 04, spec §6, screens.html flow 03). Manual
/// start/end only — see [SessionController] for why.
class SessionScreen extends ConsumerWidget {
  const SessionScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionControllerProvider(sessionId));
    final exercisesAsync = ref.watch(allExercisesProvider);

    return Scaffold(
      body: SafeArea(
        child: sessionAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (session) => exercisesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (byId) => _SessionBody(
              sessionId: sessionId,
              session: session,
              exercisesById: byId,
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionBody extends ConsumerWidget {
  const _SessionBody({
    required this.sessionId,
    required this.session,
    required this.exercisesById,
  });

  final String sessionId;
  final Session session;
  final Map<String, Exercise> exercisesById;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sorted = [...session.exercises]
      ..sort((a, b) => a.planOrder.compareTo(b.planOrder));
    final outstanding =
        sorted.where((e) => e.progress != ExerciseProgress.done).length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      '${DateFormat('d MMM').format(session.date)} · '
                      '$outstanding of ${sorted.length} outstanding',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (session.endedAt == null)
                _ElapsedPill(since: session.startedAt)
              else
                const Text('Done', style: TextStyle(color: Colors.green)),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            children: [
              for (final se in sorted)
                _ExerciseSection(
                  sessionId: sessionId,
                  exercise: exercisesById[se.exerciseId] ??
                      Exercise(
                        id: se.exerciseId,
                        name: se.exerciseId,
                        primaryMuscle: Muscle.chest,
                        equipment: Equipment.other,
                      ),
                  sessionExercise: se,
                  isCurrent: session.currentExerciseId == se.exerciseId,
                ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Add exercise'),
                onTap: () => showExercisePickerSheet(
                  context,
                  sessionId: sessionId,
                  session: session,
                ),
              ),
            ],
          ),
        ),
        if (session.endedAt == null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: OutlinedButton(
              onPressed: () => ref
                  .read(sessionControllerProvider(sessionId).notifier)
                  .endSession(),
              child: const Text('End session'),
            ),
          ),
      ],
    );
  }
}

class _ExerciseSection extends ConsumerWidget {
  const _ExerciseSection({
    required this.sessionId,
    required this.exercise,
    required this.sessionExercise,
    required this.isCurrent,
  });

  final String sessionId;
  final Exercise exercise;
  final SessionExercise sessionExercise;
  final bool isCurrent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller =
        ref.read(sessionControllerProvider(sessionId).notifier);
    final sets = sessionExercise.sets;
    final lastSet = sets.isEmpty ? null : sets.last;
    final running = lastSet != null && lastSet.endedAt == null;
    final pendingReps =
        lastSet != null && lastSet.endedAt != null && !lastSet.hasReps;
    final doneSets = pendingReps || running ? sets.sublist(0, sets.length - 1) : sets;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
        color: isCurrent
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => controller.setCurrent(exercise.id),
            child: Row(
              children: [
                Text(
                  exercise.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (exercise.defaultExecution == Execution.unilateral) ...[
                  const SizedBox(width: 6),
                  const _Tag('uni'),
                ],
              ],
            ),
          ),
          for (final s in doneSets) _SetRow(sessionId: sessionId, exercise: exercise, set: s),
          if (running)
            _RunningRow(sessionId: sessionId, exercise: exercise, set: lastSet)
          else if (pendingReps)
            _PendingRepsRow(sessionId: sessionId, exercise: exercise, set: lastSet)
          else if (isCurrent)
            _StartRow(
              sessionId: sessionId,
              exercise: exercise,
              nextIndex: sets.length + 1,
            ),
        ],
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({required this.sessionId, required this.exercise, required this.set});

  final String sessionId;
  final Exercise exercise;
  final WorkoutSet set;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showRepEntrySheet(
        context,
        sessionId: sessionId,
        exerciseId: exercise.id,
        set: set,
        exercise: exercise,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            SizedBox(width: 20, child: Text('${set.index}')),
            Expanded(child: Text(_formatWeight(set))),
            Expanded(child: Text(_formatReps(set))),
            for (final t in set.tags) _Tag(t.name),
          ],
        ),
      ),
    );
  }
}

class _StartRow extends ConsumerWidget {
  const _StartRow({
    required this.sessionId,
    required this.exercise,
    required this.nextIndex,
  });

  final String sessionId;
  final Exercise exercise;
  final int nextIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Load?>(
      future: ref.read(prefillServiceProvider).loadFor(
            exerciseId: exercise.id,
            setIndex: nextIndex,
            currentSession: ref.read(sessionControllerProvider(sessionId)).value!,
          ),
      builder: (context, snapshot) {
        final predicted = snapshot.data;
        return Row(
          children: [
            SizedBox(width: 20, child: Text('$nextIndex')),
            Expanded(
              child: Text(
                predicted == null ? '—' : _formatLoad(predicted),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => ref
                  .read(sessionControllerProvider(sessionId).notifier)
                  .startSet(exercise.id),
              child: const Text('Start set'),
            ),
          ],
        );
      },
    );
  }
}

class _RunningRow extends ConsumerWidget {
  const _RunningRow({
    required this.sessionId,
    required this.exercise,
    required this.set,
  });

  final String sessionId;
  final Exercise exercise;
  final WorkoutSet set;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        SizedBox(width: 20, child: Text('${set.index}')),
        Expanded(child: Text(_formatWeight(set), style: const TextStyle(color: Colors.blue))),
        _ElapsedPill(since: set.startedAt!),
        TextButton(
          onPressed: () => ref
              .read(sessionControllerProvider(sessionId).notifier)
              .endSet(exercise.id),
          child: const Text('End set'),
        ),
      ],
    );
  }
}

class _PendingRepsRow extends ConsumerWidget {
  const _PendingRepsRow({
    required this.sessionId,
    required this.exercise,
    required this.set,
  });

  final String sessionId;
  final Exercise exercise;
  final WorkoutSet set;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(sessionControllerProvider(sessionId).notifier);
    return FutureBuilder<int?>(
      future: controller.predictedRepsFor(exercise.id),
      builder: (context, snapshot) {
        final predicted = snapshot.data;
        final unilateral = set.execution == Execution.unilateral;
        final predictedText = predicted == null
            ? null
            : (unilateral ? 'L$predicted R$predicted' : '$predicted');
        return Row(
          children: [
            SizedBox(width: 20, child: Text('${set.index}')),
            Expanded(child: Text(_formatWeight(set))),
            Expanded(
              child: predictedText == null
                  ? const Text('log reps', style: TextStyle(color: Colors.grey))
                  : InkWell(
                      onTap: () => controller.acceptPrediction(exercise.id, predicted!),
                      child: Text(predictedText, style: _hollowStyle(context)),
                    ),
            ),
            IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () => showRepEntrySheet(
                context,
                sessionId: sessionId,
                exerciseId: exercise.id,
                set: set,
                exercise: exercise,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ElapsedPill extends StatefulWidget {
  const _ElapsedPill({required this.since});

  final DateTime since;

  @override
  State<_ElapsedPill> createState() => _ElapsedPillState();
}

class _ElapsedPillState extends State<_ElapsedPill> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = DateTime.now().difference(widget.since);
    final text = '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()])),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label, style: const TextStyle(fontSize: 10)),
      ),
    );
  }
}

TextStyle _hollowStyle(BuildContext context) => TextStyle(
      fontWeight: FontWeight.w600,
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Theme.of(context).colorScheme.primary,
    );

String _formatLoad(Load load) {
  if (load.value == null) return load.isBodyweight ? 'bw' : '—';
  final v = load.value!;
  final text = v == v.roundToDouble() ? v.toInt().toString() : v.toString();
  return load.scope == LoadScope.perLimb ? '$text /side' : text;
}

String _formatWeight(WorkoutSet set) {
  if (set.segments.isEmpty) return '—';
  return _formatLoad(set.segments.first.load);
}

String _formatReps(WorkoutSet set) {
  if (set.segments.isEmpty) {
    return set.aggregateReps != null ? 'Total ${set.aggregateReps}' : '—';
  }
  final seg = set.segments.first;
  if (set.execution == Execution.unilateral) {
    return 'L${seg.repsLeft ?? '-'} R${seg.repsRight ?? '-'}';
  }
  return seg.reps?.toString() ??
      (set.aggregateReps != null ? 'Total ${set.aggregateReps}' : '—');
}

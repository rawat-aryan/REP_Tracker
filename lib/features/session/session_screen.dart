import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/models/exercise.dart';
import '../../domain/models/load.dart';
import '../../domain/models/session.dart';
import '../../domain/models/workout_set.dart';
import '../../providers.dart';
import '../../theme.dart';
import '../../widgets/elapsed_pill.dart';
import 'exercise_picker_sheet.dart';
import 'rep_entry_sheet.dart';
import 'session_controller.dart';

/// The session ledger (milestone 04, spec §6, screens.html flow 03). Manual
/// start/end only — see [SessionController] for why. Visual language is
/// lifted straight from screens.html's `.setrow`/`.sethead`/`.hollow` rules
/// (milestone 05 visual pass).
class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key, required this.sessionId, this.autoOpenExerciseId});

  final String sessionId;

  /// Set when the app was just brought forward by a native `setEnded`
  /// (milestone 06 "must hold": setEnded lands on rep entry for that set).
  /// Opens the existing overflow sheet once, the same UI a manual tap on a
  /// pendingReps row already uses — no separate "trigger landing" screen.
  final String? autoOpenExerciseId;

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  bool _autoOpened = false;

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(sessionControllerProvider(widget.sessionId));
    final exercisesAsync = ref.watch(allExercisesProvider);

    return Scaffold(
      body: SafeArea(
        child: sessionAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (session) => exercisesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (byId) {
              _maybeAutoOpenRepEntry(session, byId);
              return _SessionBody(
                sessionId: widget.sessionId,
                session: session,
                exercisesById: byId,
              );
            },
          ),
        ),
      ),
    );
  }

  void _maybeAutoOpenRepEntry(Session session, Map<String, Exercise> byId) {
    final exerciseId = widget.autoOpenExerciseId;
    if (_autoOpened || exerciseId == null) return;
    final matches = session.exercises.where((e) => e.exerciseId == exerciseId);
    if (matches.isEmpty || matches.first.sets.isEmpty) return;
    final lastSet = matches.first.sets.last;
    if (lastSet.endedAt == null || lastSet.hasReps) return;
    final exercise = byId[exerciseId];
    if (exercise == null) return;
    _autoOpened = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showRepEntrySheet(
        context,
        sessionId: widget.sessionId,
        exerciseId: exerciseId,
        set: lastSet,
        exercise: exercise,
      );
    });
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
    final dayId = session.workoutDayId;
    final dayName =
        dayId == null ? null : ref.watch(workoutDayProvider(dayId)).valueOrNull?.name;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 12, 16, 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayName ?? 'Session',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.02,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      '${DateFormat('d MMM').format(session.date)} · '
                      '$outstanding of ${sorted.length} outstanding',
                      style: const TextStyle(fontSize: 12.5, color: AppColors.ink3),
                    ),
                  ],
                ),
              ),
              if (session.endedAt == null)
                ElapsedPill(since: session.startedAt)
              else
                Text(
                  '${session.endedAt!.difference(session.startedAt).inMinutes} min',
                  style: monoStyle(fontSize: 11, color: AppColors.ink3),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 8),
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
              InkWell(
                onTap: () => showExercisePickerSheet(
                  context,
                  sessionId: sessionId,
                  session: session,
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Text(
                    '+  Add exercise',
                    style: TextStyle(fontSize: 13, color: AppColors.ink2),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (session.endedAt == null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => ref
                    .read(sessionControllerProvider(sessionId).notifier)
                    .endSession(),
                child: const Text('End session'),
              ),
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
    final controller = ref.read(sessionControllerProvider(sessionId).notifier);
    final sets = sessionExercise.sets;
    final lastSet = sets.isEmpty ? null : sets.last;
    final running = lastSet != null && lastSet.endedAt == null;
    final pendingReps =
        lastSet != null && lastSet.endedAt != null && !lastSet.hasReps;
    final doneSets = pendingReps || running ? sets.sublist(0, sets.length - 1) : sets;
    final hasLiveRow = running || pendingReps || isCurrent;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => controller.setCurrent(exercise.id),
            child: Row(
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                  ),
                ),
                if (exercise.defaultExecution == Execution.unilateral) ...[
                  const SizedBox(width: 6),
                  const AppTag('uni'),
                ],
              ],
            ),
          ),
          if (doneSets.isNotEmpty || hasLiveRow) ...[
            const SizedBox(height: 7),
            const _SetHead(),
          ],
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

class _SetHead extends StatelessWidget {
  const _SetHead();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 9.5,
      letterSpacing: 0.9,
      color: AppColors.ink3,
      fontWeight: FontWeight.w500,
    );
    return const Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(width: 18),
          Expanded(child: Text('WEIGHT', style: style)),
          Expanded(child: Text('REPS', style: style)),
        ],
      ),
    );
  }
}

/// The current-set row treatment — screens.html's `.setrow.live`: an
/// accent-tinted pill instead of the plain top-border rule.
class _LiveRow extends StatelessWidget {
  const _LiveRow({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.accentBg,
        borderRadius: BorderRadius.circular(7),
      ),
      child: child,
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: Row(
          children: [
            SizedBox(width: 18, child: Text('${set.index}', style: monoStyle(fontSize: 11, color: AppColors.ink3))),
            Expanded(
              child: _LoadText(
                load: set.segments.isEmpty ? null : set.segments.first.load,
              ),
            ),
            Expanded(child: Text(_formatReps(set), style: monoStyle(fontSize: 13))),
            for (final t in set.tags) AppTag(t.name),
          ],
        ),
      ),
    );
  }
}

/// A weight value with its `/side` suffix rendered smaller and muted, per
/// screens.html's `.c-w` + `.side` pairing. Used for both a saved set's
/// load and a not-yet-started row's predicted load.
class _LoadText extends StatelessWidget {
  const _LoadText({required this.load, this.color = AppColors.ink});

  final Load? load;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (load == null) {
      return Text('—', style: monoStyle(fontSize: 13, color: color));
    }
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: _formatLoad(load!), style: monoStyle(fontSize: 13, color: color)),
          if (load!.scope == LoadScope.perLimb)
            const TextSpan(
              text: ' /side',
              style: TextStyle(fontSize: 9.5, color: AppColors.ink3),
            ),
        ],
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
        return _LiveRow(
          child: Row(
            children: [
              SizedBox(width: 18, child: Text('$nextIndex', style: monoStyle(fontSize: 11, color: AppColors.ink3))),
              Expanded(child: _LoadText(load: predicted, color: AppColors.ink2)),
              TextButton(
                onPressed: () =>
                    ref.read(sessionControllerProvider(sessionId).notifier).startSet(exercise.id),
                child: const Text('Start set'),
              ),
            ],
          ),
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
    return _LiveRow(
      child: Row(
        children: [
          SizedBox(
            width: 18,
            child: Text('${set.index}', style: monoStyle(fontSize: 11, color: AppColors.accentInk)),
          ),
          Expanded(
            child: _LoadText(
              load: set.segments.isEmpty ? null : set.segments.first.load,
              color: AppColors.accentInk,
            ),
          ),
          ElapsedPill(since: set.startedAt!),
          TextButton(
            onPressed: () =>
                ref.read(sessionControllerProvider(sessionId).notifier).endSet(exercise.id),
            child: const Text('End set'),
          ),
        ],
      ),
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
        return _LiveRow(
          child: Row(
            children: [
              SizedBox(
                width: 18,
                child: Text('${set.index}', style: monoStyle(fontSize: 11, color: AppColors.accentInk)),
              ),
              Expanded(
            child: _LoadText(
              load: set.segments.isEmpty ? null : set.segments.first.load,
              color: AppColors.accentInk,
            ),
          ),
              Expanded(
                child: predictedText == null
                    ? Text('log reps', style: monoStyle(fontSize: 13, color: AppColors.ink3))
                    : InkWell(
                        onTap: () => controller.acceptPrediction(exercise.id, predicted!),
                        child: Text(predictedText, style: _hollowStyle()),
                      ),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz, size: 20),
                onPressed: () => showRepEntrySheet(
                  context,
                  sessionId: sessionId,
                  exerciseId: exercise.id,
                  set: set,
                  exercise: exercise,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// `.tag` — a quiet outlined chip, used for both the exercise-level "uni"
/// marker and per-set tags (warmup/dropSet/toFailure).
class AppTag extends StatelessWidget {
  const AppTag(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lineStrong),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label, style: const TextStyle(fontSize: 9, color: AppColors.ink3)),
      ),
    );
  }
}

/// `.hollow` — transparent fill, a thin ink3 stroke. The predicted-value
/// treatment: visible as an outline, not committed until tapped.
TextStyle _hollowStyle() => TextStyle(
      fontSize: 13,
      fontFamily: monoStyle().fontFamily,
      fontFeatures: const [FontFeature.tabularFigures()],
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7
        ..color = AppColors.ink3,
    );

String _formatLoad(Load load) {
  if (load.value == null) return load.isBodyweight ? 'bw' : '—';
  final v = load.value!;
  return v == v.roundToDouble() ? v.toInt().toString() : v.toString();
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

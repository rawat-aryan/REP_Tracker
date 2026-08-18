import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../bridge/trigger_bridge.dart';
import '../../domain/models/plan.dart';
import '../../domain/models/session.dart';
import '../../domain/rules/home.dart';
import '../../providers.dart';
import '../../theme.dart';
import '../../widgets/elapsed_pill.dart';
import '../plan/week_screen.dart';
import '../session/session_screen.dart' show SessionScreen;
import 'ambient_banners.dart';
import 'home_providers.dart';

const _uuid = Uuid();

/// Home screen (spec §12, milestone 05) — five states, one card, one
/// primary action each. See screens.html flow 02. Visual language matches
/// the session screen (milestone 05 visual pass): `.eyebrow`/`.scr-title`/
/// `.scr-sub`/`.lrow` straight from screens.html.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(homeStateProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.settings_outlined, color: AppColors.ink3),
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const WeekScreen()),
                    );
                    ref.invalidate(homeStateProvider);
                  },
                ),
              ),
              const _AmbientBannerList(),
              Expanded(
                child: stateAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('$e')),
                  data: (state) => switch (state) {
                    NoPlanYet() => const _NoPlanYetView(),
                    RestDay() => _RestDayView(state: state),
                    PlannedNotStarted() => _PlannedView(state: state),
                    InProgress() => _InProgressView(state: state),
                    Done() => _DoneView(state: state),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _openSession(BuildContext context, WidgetRef ref, String sessionId) async {
  await Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => SessionScreen(sessionId: sessionId)),
  );
  ref.invalidate(homeStateProvider);
}

Future<void> _startPlannedSession(
  BuildContext context,
  WidgetRef ref,
  WorkoutDay day,
  DateTime date,
) async {
  final sessions = ref.read(sessionRepositoryProvider);
  final plan = await ref.read(planRepositoryProvider).getLatestWeekPlan(demoRoutineId);
  final sorted = [...day.exercises]..sort((a, b) => a.order.compareTo(b.order));
  final session = Session(
    id: _uuid.v4(),
    date: date,
    startedAt: DateTime.now(),
    workoutDayId: day.id,
    routineVersion: plan?.version,
    intendedExerciseIds: sorted.map((e) => e.exerciseId).toList(),
    currentExerciseId: sorted.isEmpty ? null : sorted.first.exerciseId,
    exercises: [
      for (var i = 0; i < sorted.length; i++)
        SessionExercise(exerciseId: sorted[i].exerciseId, planOrder: i),
    ],
  );
  await sessions.createSession(session);
  if (!context.mounted) return;
  await _openSession(context, ref, session.id);
}

/// "Just start" — spec §5: never gate the workout behind declaring it.
Future<void> _startImprovisedSession(BuildContext context, WidgetRef ref) async {
  final sessions = ref.read(sessionRepositoryProvider);
  final now = DateTime.now();
  final session = Session(id: _uuid.v4(), date: now, startedAt: now);
  await sessions.createSession(session);
  if (!context.mounted) return;
  await _openSession(context, ref, session.id);
}

/// `.scr-title` — the big state headline.
Widget _title(String text) => Text(
      text,
      style: const TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        color: AppColors.ink,
      ),
    );

/// `.scr-sub` — muted supporting line under the title.
Widget _sub(String text) =>
    Text(text, style: const TextStyle(fontSize: 12.5, color: AppColors.ink3, height: 1.4));

class _NoPlanYetView extends ConsumerWidget {
  const _NoPlanYetView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('What are you training?'),
        const SizedBox(height: 4),
        _sub('Just the exercise names. Numbers come as you go.'),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => _startImprovisedSession(context, ref),
            child: const Text("Just start — I'll improvise"),
          ),
        ),
      ],
    );
  }
}

class _RestDayView extends StatelessWidget {
  const _RestDayView({required this.state});

  final RestDay state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('REST', style: eyebrowStyle()),
          const SizedBox(height: 4),
          _title('Rest'),
          const SizedBox(height: 16),
          Container(height: 1, color: AppColors.line),
          const SizedBox(height: 16),
          if (state.lastSession != null)
            _KeyValueLine(
              label: 'Last session',
              value: '${DateFormat('EEE').format(state.lastSession!.date)} — '
                  '${state.lastSession!.dayName}, ${state.lastSession!.totalSets} sets',
            ),
          if (state.nextDayName != null)
            _KeyValueLine(label: 'Next up', value: state.nextDayName!),
        ],
      ),
    );
  }
}

class _KeyValueLine extends StatelessWidget {
  const _KeyValueLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, color: AppColors.ink3, fontFamily: 'Archivo'),
          children: [
            TextSpan(text: '$label '),
            TextSpan(text: value, style: const TextStyle(color: AppColors.ink2)),
          ],
        ),
      ),
    );
  }
}

class _PlannedView extends ConsumerWidget {
  const _PlannedView({required this.state});

  final PlannedNotStarted state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final byId = ref.watch(allExercisesProvider).valueOrNull ?? {};
    final sorted = [...state.day.exercises]..sort((a, b) => a.order.compareTo(b.order));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(DateFormat('EEE d MMM').format(state.date).toUpperCase(), style: eyebrowStyle()),
        const SizedBox(height: 4),
        _title(state.day.name),
        const SizedBox(height: 16),
        for (final pe in sorted)
          _LedgerRow(
            name: byId[pe.exerciseId]?.name ?? pe.exerciseId,
            value: '${pe.targetSets} sets',
          ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => _startPlannedSession(context, ref, state.day, state.date),
            child: const Text('Start'),
          ),
        ),
      ],
    );
  }
}

class _InProgressView extends ConsumerWidget {
  const _InProgressView({required this.state});

  final InProgress state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final byId = ref.watch(allExercisesProvider).valueOrNull ?? {};
    final dayId = state.session.workoutDayId;
    final targetSets = dayId == null
        ? const <String, int>{}
        : {
            for (final pe
                in ref.watch(workoutDayProvider(dayId)).valueOrNull?.exercises ??
                    const <PlannedExercise>[])
              pe.exerciseId: pe.targetSets,
          };
    final sorted = [...state.session.exercises]
      ..sort((a, b) => a.planOrder.compareTo(b.planOrder));
    final currentId = state.session.currentExerciseId;
    final currentName = currentId == null ? null : byId[currentId]?.name ?? currentId;
    final currentMatches = sorted.where((e) => e.exerciseId == currentId);
    final currentSets = currentMatches.isEmpty ? null : currentMatches.first.sets;
    final currentSetIndex = currentSets == null
        ? null
        : (currentSets.isNotEmpty && currentSets.last.endedAt == null
            ? currentSets.length
            : currentSets.length + 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _title(state.dayName)),
            ElapsedPill(since: state.session.startedAt),
          ],
        ),
        if (currentName != null) ...[
          const SizedBox(height: 3),
          _sub('$currentName · set $currentSetIndex running'),
        ],
        const SizedBox(height: 16),
        for (final se in sorted)
          _LedgerRow(
            name: byId[se.exerciseId]?.name ?? se.exerciseId,
            value: '${se.sets.where((s) => s.hasReps).length} · '
                '${targetSets[se.exerciseId] ?? se.sets.length}',
            nameColor: se.exerciseId == currentId ? AppColors.accentInk : null,
            valueColor: se.exerciseId == currentId ? AppColors.accentInk : null,
            dim: se.progress == ExerciseProgress.notStarted && se.exerciseId != currentId,
          ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => _openSession(context, ref, state.session.id),
            child: const Text('Resume'),
          ),
        ),
      ],
    );
  }
}

class _DoneView extends ConsumerWidget {
  const _DoneView({required this.state});

  final Done state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final byId = ref.watch(allExercisesProvider).valueOrNull ?? {};
    final sorted = [...state.session.exercises]
      ..sort((a, b) => a.planOrder.compareTo(b.planOrder));
    final totalSets = sorted.fold<int>(0, (n, e) => n + e.sets.length);
    final duration = state.session.endedAt!.difference(state.session.startedAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _title(state.dayName)),
            Text(
              '${duration.inMinutes} min · $totalSets sets',
              style: monoStyle(fontSize: 11, color: AppColors.ink3),
            ),
          ],
        ),
        const SizedBox(height: 3),
        _sub('Finished ${DateFormat('h:mm a').format(state.session.endedAt!)}. Still editable.'),
        const SizedBox(height: 16),
        for (final se in sorted)
          _LedgerRow(
            name: byId[se.exerciseId]?.name ?? se.exerciseId,
            value: se.sets.isEmpty ? 'not done' : '${se.sets.length} sets',
            dim: se.sets.isEmpty,
          ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _openSession(context, ref, state.session.id),
            child: const Text('Add something you forgot'),
          ),
        ),
      ],
    );
  }
}

/// Sits above whatever [HomeState] is showing — the ambient unresolved-gap
/// row from spec §12. Dismissible, never a modal (I3): phantom sets and the
/// trigger upgrade offer both queue here instead of interrupting a session.
class _AmbientBannerList extends ConsumerWidget {
  const _AmbientBannerList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final banners = ref.watch(ambientBannersProvider).valueOrNull;
    if (banners == null) return const SizedBox.shrink();
    return Column(
      children: [
        for (final phantom in banners.phantomSets)
          _Banner(
            text: '${phantom.exerciseName}: a set ran '
                '${phantom.set.duration!.inMinutes} min — bumped in a pocket?',
            actionLabel: 'Discard',
            onAction: () async {
              await ref.read(sessionRepositoryProvider).deleteSet(phantom.set.id);
              ref.invalidate(ambientBannersProvider);
            },
          ),
        if (banners.capabilityOffer == TriggerTier.parityTile)
          _Banner(
            text: 'This phone has a Quick Settings tile for start/end set — '
                'swipe down, tap, done, no unlock.',
            actionLabel: 'Got it',
            onAction: () => ref.read(capabilityOfferDismissedProvider.notifier).state = true,
          ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text, required this.actionLabel, required this.onAction});

  final String text;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(appRadius),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.ink2, height: 1.3)),
          ),
          const SizedBox(width: 8),
          TextButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

/// `.lrow` — a bordered ledger row, name left / mono value right.
class _LedgerRow extends StatelessWidget {
  const _LedgerRow({
    required this.name,
    required this.value,
    this.nameColor,
    this.valueColor,
    this.dim = false,
  });

  final String name;
  final String value;
  final Color? nameColor;
  final Color? valueColor;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    final row = Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(fontSize: 13.5, color: nameColor ?? AppColors.ink),
            ),
          ),
          Text(value, style: monoStyle(fontSize: 12.5, color: valueColor ?? AppColors.ink2)),
        ],
      ),
    );
    return dim ? Opacity(opacity: 0.42, child: row) : row;
  }
}

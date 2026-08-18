import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/exercise.dart';
import '../../domain/models/session.dart';
import '../../providers.dart';
import 'session_controller.dart';

/// Exercise picker (screens.html "Bench is taken"). Order per spec §6:
/// deferral first, then library search. Learned substitutes are skipped —
/// there's no substitutionCount data to rank them by yet; add that section
/// when substitution tracking exists.
Future<void> showExercisePickerSheet(
  BuildContext context, {
  required String sessionId,
  required Session session,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ExercisePickerSheet(sessionId: sessionId, session: session),
  );
}

class _ExercisePickerSheet extends ConsumerStatefulWidget {
  const _ExercisePickerSheet({required this.sessionId, required this.session});

  final String sessionId;
  final Session session;

  @override
  ConsumerState<_ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends ConsumerState<_ExercisePickerSheet> {
  final _query = TextEditingController();
  List<Exercise> _results = [];

  void _search(String q) async {
    if (q.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    final found = await ref.read(exerciseRepositoryProvider).search(q);
    if (!mounted) return;
    setState(() => _results = found);
  }

  void _pick(String exerciseId) {
    ref.read(sessionControllerProvider(widget.sessionId).notifier).addExercise(exerciseId);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final outstanding = widget.session.exercises
        .where((e) => e.progress == ExerciseProgress.notStarted)
        .toList();
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Consumer(
          builder: (context, ref, _) {
            final exercisesAsync = ref.watch(allExercisesProvider);
            return exercisesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('$e'),
              data: (byId) => ListView(
                children: [
                  TextField(
                    controller: _query,
                    decoration: const InputDecoration(hintText: 'Search all exercises…'),
                    onChanged: _search,
                  ),
                  if (outstanding.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Still to do today', style: TextStyle(fontSize: 12)),
                    ),
                    for (final se in outstanding)
                      ListTile(
                        title: Text(byId[se.exerciseId]?.name ?? se.exerciseId),
                        onTap: () => _pick(se.exerciseId),
                      ),
                  ],
                  if (_results.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Library', style: TextStyle(fontSize: 12)),
                    ),
                    for (final ex in _results)
                      ListTile(
                        title: Text(ex.name),
                        subtitle: Text(ex.primaryMuscle.name),
                        onTap: () => _pick(ex.id),
                      ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/exercise.dart';
import '../../domain/models/session.dart';
import '../../providers.dart';
import '../../theme.dart';
import '../exercise/create_custom_exercise.dart';
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

  Future<void> _createCustom() async {
    final created = await promptCreateCustomExercise(context, ref, initialName: _query.text.trim());
    if (created != null) _pick(created.id);
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
                    style: const TextStyle(color: AppColors.ink, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Search all exercises…',
                      hintStyle: TextStyle(color: AppColors.ink3),
                    ),
                    onChanged: _search,
                  ),
                  if (outstanding.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 4),
                      child: Text('STILL TO DO TODAY', style: eyebrowStyle()),
                    ),
                    for (final se in outstanding)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          byId[se.exerciseId]?.name ?? se.exerciseId,
                          style: const TextStyle(fontSize: 13.5, color: AppColors.ink),
                        ),
                        onTap: () => _pick(se.exerciseId),
                      ),
                  ],
                  if (_results.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 4),
                      child: Text('LIBRARY', style: eyebrowStyle()),
                    ),
                    for (final ex in _results)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          ex.name,
                          style: const TextStyle(fontSize: 13.5, color: AppColors.ink),
                        ),
                        subtitle: Text(
                          ex.primaryMuscle.name,
                          style: const TextStyle(fontSize: 11, color: AppColors.ink3),
                        ),
                        onTap: () => _pick(ex.id),
                      ),
                  ],
                  if (_query.text.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: InkWell(
                        onTap: _createCustom,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            'Create "${_query.text.trim()}" as a new exercise',
                            style: const TextStyle(fontSize: 13, color: AppColors.ink2),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

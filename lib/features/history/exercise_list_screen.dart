import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/exercise.dart';
import '../../providers.dart';
import '../../theme.dart';
import 'exercise_detail_screen.dart';

/// The entry point into per-exercise history/charts (spec §11) — every
/// chart keys off exercise identity alone, so this is just the catalog,
/// unfiltered by any day or plan (I1).
class ExerciseListScreen extends ConsumerStatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  ConsumerState<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends ConsumerState<ExerciseListScreen> {
  final _query = TextEditingController();
  String _needle = '';

  @override
  Widget build(BuildContext context) {
    final byId = ref.watch(allExercisesProvider).valueOrNull ?? const <String, Exercise>{};
    final all = byId.values.toList()..sort((a, b) => a.name.compareTo(b.name));
    final results =
        _needle.isEmpty ? all : all.where((e) => e.name.toLowerCase().contains(_needle)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _query,
                decoration: const InputDecoration(hintText: 'Search exercises…'),
                onChanged: (q) => setState(() => _needle = q.toLowerCase()),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: [
                    for (final ex in results)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(ex.name, style: const TextStyle(fontSize: 14, color: AppColors.ink)),
                        subtitle: Text(
                          ex.primaryMuscle.name,
                          style: const TextStyle(fontSize: 11.5, color: AppColors.ink3),
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ExerciseDetailScreen(exerciseId: ex.id, exerciseName: ex.name),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

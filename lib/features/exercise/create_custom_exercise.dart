import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/exercise.dart';
import '../../providers.dart';
import '../../theme.dart';

const _uuid = Uuid();

/// Every custom entry gets a UUID, seeded exercises keep their human-
/// readable slug (spec §10 / CLAUDE.md conventions) — this is the ONE
/// place a custom [Exercise] gets created, shared by every search surface
/// (session picker, day editor, exercise library) so "create custom"
/// always behaves identically and always lands below real results, per
/// spec: "every time someone taps create-custom for an exercise that
/// already exists, a growth curve silently forks."
Future<Exercise?> promptCreateCustomExercise(
  BuildContext context,
  WidgetRef ref, {
  String? initialName,
}) async {
  final nameController = TextEditingController(text: initialName);
  var muscle = Muscle.chest;
  var equipment = Equipment.barbell;

  final created = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setState) => Padding(
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
            Text('NEW EXERCISE', style: eyebrowStyle()),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              autofocus: initialName == null || initialName.isEmpty,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(hintText: 'Name'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<Muscle>(
              initialValue: muscle,
              items: [
                for (final m in Muscle.values) DropdownMenuItem(value: m, child: Text(m.name)),
              ],
              onChanged: (m) => setState(() => muscle = m ?? muscle),
              decoration: const InputDecoration(labelText: 'Primary muscle'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<Equipment>(
              initialValue: equipment,
              items: [
                for (final e in Equipment.values) DropdownMenuItem(value: e, child: Text(e.name)),
              ],
              onChanged: (e) => setState(() => equipment = e ?? equipment),
              decoration: const InputDecoration(labelText: 'Equipment'),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: nameController.text.trim().isEmpty
                    ? null
                    : () => Navigator.pop(sheetContext, true),
                child: const Text('Create'),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  if (created != true) return null;
  final exercise = Exercise(
    id: _uuid.v4(),
    isCustom: true,
    name: nameController.text.trim(),
    primaryMuscle: muscle,
    equipment: equipment,
  );
  await ref.read(exerciseRepositoryProvider).upsert(exercise);
  ref.invalidate(allExercisesProvider);
  return exercise;
}

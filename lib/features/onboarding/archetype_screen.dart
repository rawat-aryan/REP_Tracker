import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/plan.dart';
import '../../domain/rules/onboarding.dart';
import '../../providers.dart';
import '../../theme.dart';
import '../plan/week_screen.dart';

const _uuid = Uuid();

/// Onboarding step 2 (spec §4). Picking an option — or skipping — writes a
/// real [WeekPlan] version 1 immediately and the [Archetype] value is never
/// stored anywhere past this function (I2: no `SplitType`).
class ArchetypeScreen extends ConsumerWidget {
  const ArchetypeScreen({super.key});

  Future<void> _choose(BuildContext context, WidgetRef ref, Archetype? archetype) async {
    final suggested = archetype == null
        ? {for (final w in Weekday.values) w: null}
        : suggestedWeekMap(archetype);
    final plans = ref.read(planRepositoryProvider);

    final dayIdByName = <String, String>{};
    final slots = <Weekday, String?>{};
    for (final entry in suggested.entries) {
      final name = entry.value;
      if (name == null) {
        slots[entry.key] = null;
        continue;
      }
      final dayId = dayIdByName.putIfAbsent(name, () => _uuid.v4());
      slots[entry.key] = dayId;
    }
    for (final entry in dayIdByName.entries) {
      await plans.upsertWorkoutDay(WorkoutDay(id: entry.value, name: entry.key));
    }
    await plans.createWeekPlanVersion(
      WeekPlan(routineId: demoRoutineId, version: 1, slots: slots),
    );

    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WeekScreen(onboarding: true)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How do you train?',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "A starting point. You'll arrange the week next.",
                style: TextStyle(fontSize: 12.5, color: AppColors.ink3, height: 1.4),
              ),
              const SizedBox(height: 18),
              _ArchetypeOption(
                title: 'Push · Pull · Legs',
                subtitle: '6 days, rotating',
                onTap: () => _choose(context, ref, Archetype.ppl),
              ),
              _ArchetypeOption(
                title: 'One muscle a day',
                subtitle: 'chest · back · shoulders · arms · legs',
                onTap: () => _choose(context, ref, Archetype.broSplit),
              ),
              _ArchetypeOption(
                title: 'Two muscles a day',
                subtitle: 'chest+tri · back+bi · legs · delts+arms',
                onTap: () => _choose(context, ref, Archetype.twoMuscle),
              ),
              _ArchetypeOption(
                title: 'Build my own',
                subtitle: 'blank week, name the days',
                onTap: () => _choose(context, ref, Archetype.hybrid),
              ),
              const SizedBox(height: 14),
              Center(
                child: TextButton(
                  onPressed: () => _choose(context, ref, null),
                  child: const Text('Skip this'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArchetypeOption extends StatelessWidget {
  const _ArchetypeOption({required this.title, required this.subtitle, required this.onTap});

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(appRadius),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(appRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 3),
            Text(subtitle, style: monoStyle(fontSize: 11.5, color: AppColors.ink3)),
          ],
        ),
      ),
    );
  }
}

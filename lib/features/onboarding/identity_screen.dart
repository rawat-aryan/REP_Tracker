import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/plan.dart' show BodyweightEntry;
import '../../providers.dart';
import '../../theme.dart';
import 'archetype_screen.dart';

/// Onboarding step 1 (spec §4 / screens.html flow 01). Two fields, both
/// optional (I4) — "Continue" always works, blank or not.
class IdentityScreen extends ConsumerStatefulWidget {
  const IdentityScreen({super.key});

  @override
  ConsumerState<IdentityScreen> createState() => _IdentityScreenState();
}

class _IdentityScreenState extends ConsumerState<IdentityScreen> {
  final _name = TextEditingController();
  final _bodyweight = TextEditingController();

  Future<void> _continue() async {
    final name = _name.text.trim();
    if (name.isNotEmpty) {
      await ref.read(profileRepositoryProvider).setName(name);
    }
    final kg = double.tryParse(_bodyweight.text.trim());
    if (kg != null) {
      await ref
          .read(bodyweightRepositoryProvider)
          .add(BodyweightEntry(date: DateTime.now(), kg: kg));
    }
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ArchetypeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Let's get you set up",
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Two things. You can change both later.',
                style: TextStyle(fontSize: 12.5, color: AppColors.ink3, height: 1.4),
              ),
              const SizedBox(height: 18),
              Text('NAME', style: eyebrowStyle()),
              const SizedBox(height: 6),
              TextField(controller: _name, textCapitalization: TextCapitalization.words),
              const SizedBox(height: 14),
              Text('BODYWEIGHT (KG)', style: eyebrowStyle()),
              const SizedBox(height: 6),
              TextField(
                controller: _bodyweight,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 11),
              const Text(
                'Used for bodyweight exercises like pull-ups, so they show real '
                'progress instead of a blank.',
                style: TextStyle(fontSize: 12.5, color: AppColors.ink3, height: 1.4),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(onPressed: _continue, child: const Text('Continue')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

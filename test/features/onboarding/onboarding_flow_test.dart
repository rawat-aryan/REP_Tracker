import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rep_tracker/data/database.dart';
import 'package:rep_tracker/features/onboarding/identity_screen.dart';
import 'package:rep_tracker/providers.dart';

Widget _harness(AppDatabase db) => ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: IdentityScreen()),
    );

void main() {
  testWidgets(
    'skip name/bodyweight, skip archetype, done on week screen -> lands on home',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());

      await tester.pumpWidget(_harness(db));
      await tester.pumpAndSettle();

      // Step 1: identity — both fields optional (I4), continue with neither.
      expect(find.text("Let's get you set up"), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Step 2: archetype — "Build my own" writes a fully blank week map,
      // no SplitType is ever persisted (I2).
      expect(find.text('How do you train?'), findsOneWidget);
      await tester.tap(find.text('Build my own'));
      await tester.pumpAndSettle();

      // Step 3: week grid — hybrid means every day starts as rest.
      expect(find.text('Your week'), findsOneWidget);
      expect(find.text('Rest day'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      // Home screen, gated purely on "a WeekPlan now exists" (main.dart's
      // onboarding check) — reachable well under the milestone's 60s bar.
      expect(find.text('Rest'), findsOneWidget);

      await db.close();
    },
  );
}

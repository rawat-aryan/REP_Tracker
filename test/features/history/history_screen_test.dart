import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:rep_tracker/data/database.dart';
import 'package:rep_tracker/data/repositories/day_resolution_repository.dart';
import 'package:rep_tracker/data/repositories/plan_repository.dart';
import 'package:rep_tracker/domain/models/plan.dart';
import 'package:rep_tracker/features/history/history_screen.dart';
import 'package:rep_tracker/providers.dart';

Widget _harness(AppDatabase db, DateTime now) => ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        nowProvider.overrideWithValue(now),
      ],
      child: const MaterialApp(home: HistoryScreen()),
    );

void main() {
  testWidgets('tapping an unresolved square resolves it, and the sheet disappears from the grid',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final plans = PlanRepository(db);
    // A Monday, so every Monday in the lookback window is "scheduled" —
    // guarantees at least one unresolved cell in the heatmap window.
    final now = DateTime(2026, 8, 17, 9);
    await plans.upsertWorkoutDay(const WorkoutDay(id: 'legs', name: 'Legs'));
    await plans.createWeekPlanVersion(
      const WeekPlan(routineId: demoRoutineId, version: 1, slots: {Weekday.mon: 'legs'}),
    );

    await tester.pumpWidget(_harness(db, now));
    await tester.pumpAndSettle();

    expect(find.text('Tap any square to say what it was'), findsOneWidget);
    expect(find.text('Browse exercises'), findsOneWidget);

    // The Monday one week before "now" is scheduled and has nothing
    // logged — a known unresolved gap. Locate it by its tooltip rather
    // than a positional index into the grid.
    final targetDate = DateTime(2026, 8, 10);
    final tooltipMessage = DateFormat('EEE d MMM').format(targetDate);
    expect(find.byTooltip(tooltipMessage), findsOneWidget);
    await tester.tap(find.byTooltip(tooltipMessage));
    await tester.pumpAndSettle();

    expect(find.text('No session logged. What was this?'), findsOneWidget);
    await tester.tap(find.widgetWithText(ListTile, 'Rest'));
    await tester.pumpAndSettle();

    final resolutions = DayResolutionRepository(db);
    final all = await resolutions.inRange(DateTime(2026, 1, 1), DateTime(2027, 1, 1));
    expect(all, hasLength(1));
    expect(all.single.kind, DayResolutionKind.rest);

    await db.close();
  });
}

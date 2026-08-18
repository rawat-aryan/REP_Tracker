import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/plan.dart';
import '../../domain/rules/day_status.dart';
import '../../domain/rules/home.dart' show weekdayOf;
import '../../providers.dart';

/// GitHub-style heatmap covers the last 6 weeks (42 days) — matches the
/// mockup's window and keeps the query cheap.
const heatmapDays = 42;

class HeatmapCell {
  final DateTime date;
  final DayStatus status;
  const HeatmapCell({required this.date, required this.status});
}

bool _sameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Reads the plan only to know which weekdays are scheduled (spec §9 is
/// explicitly the layer allowed to compare logged behaviour against the
/// plan — unlike prefill/history/PR/chart queries, which never may, I1).
final heatmapProvider = FutureProvider<List<HeatmapCell>>((ref) async {
  final now = ref.watch(nowProvider);
  final plans = ref.watch(planRepositoryProvider);
  final sessions = ref.watch(sessionRepositoryProvider);
  final resolutions = ref.watch(dayResolutionRepositoryProvider);

  final today = DateTime(now.year, now.month, now.day);
  final from = today.subtract(const Duration(days: heatmapDays - 1));
  final to = today.add(const Duration(days: 1));

  final plan = await plans.getLatestWeekPlan(demoRoutineId);
  final allSessions = await sessions.getInRange(from, to);
  final allResolutions = await resolutions.inRange(from, to);

  final cells = <HeatmapCell>[];
  for (var i = 0; i < heatmapDays; i++) {
    final date = from.add(Duration(days: i));
    final scheduled = plan?.slots[weekdayOf(date)] != null;
    final sessionsOnDate = allSessions.where((s) => _sameDate(s.date, date)).toList();
    DayResolution? resolution;
    for (final r in allResolutions) {
      if (_sameDate(r.date, date)) resolution = r;
    }
    cells.add(
      HeatmapCell(
        date: date,
        status: deriveDayStatus(
          date: date,
          today: today,
          scheduledOnThisWeekday: scheduled,
          sessionsOnDate: sessionsOnDate,
          manualResolution: resolution,
        ),
      ),
    );
  }
  return cells;
});

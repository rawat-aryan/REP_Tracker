import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/plan.dart';
import '../../domain/models/session.dart';
import '../../providers.dart';
import '../../theme.dart';
import '../session/session_screen.dart';
import 'exercise_list_screen.dart';
import 'history_providers.dart';

const _uuid = Uuid();

/// GitHub-style history heatmap (spec §11/§9). Filled = logged, hollow
/// (dashed) = unresolved, muted = rest — tapping an unresolved square
/// resolves it retroactively, works for a gap of any age. This is where
/// milestone 08's heatmap cut and milestone 09's gap-resolution machinery
/// meet: the squares are only meaningful once day-status is real.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cellsAsync = ref.watch(heatmapProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tap any square to say what it was',
                style: TextStyle(fontSize: 12.5, color: AppColors.ink3),
              ),
              const SizedBox(height: 14),
              cellsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Text('$e'),
                data: (cells) => _Heatmap(cells: cells),
              ),
              const SizedBox(height: 16),
              const _Legend(),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ExerciseListScreen()),
                ),
                child: const Text('Browse exercises'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    Widget swatch(Widget box, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [box, const SizedBox(width: 6), Text(label, style: monoStyle(fontSize: 11, color: AppColors.ink3))],
        );
    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: [
        swatch(_cellBox(DayStatus.logged), 'Logged'),
        swatch(_cellBox(DayStatus.unresolved), 'Unresolved'),
        swatch(_cellBox(DayStatus.rest), 'Rest'),
      ],
    );
  }
}

class _Heatmap extends ConsumerWidget {
  const _Heatmap({required this.cells});

  final List<HeatmapCell> cells;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cells.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemBuilder: (context, i) {
        final cell = cells[i];
        return GestureDetector(
          onTap: cell.status == DayStatus.unresolved ? () => _resolve(context, ref, cell.date) : null,
          child: Tooltip(
            message: DateFormat('EEE d MMM').format(cell.date),
            child: _cellBox(cell.status),
          ),
        );
      },
    );
  }

  Future<void> _resolve(BuildContext context, WidgetRef ref, DateTime date) {
    return showDayResolutionSheet(context, date);
  }
}

/// Also used by the home screen's ambient gap row (spec §9's two
/// non-blocking resolution paths — retroactive here, ambient there —
/// share the same four options and the same write path).
Future<void> showDayResolutionSheet(BuildContext context, DateTime date) {
  return showModalBottomSheet(
    context: context,
    builder: (sheetContext) => DayResolutionSheet(date: date),
  );
}

Widget _cellBox(DayStatus status) {
  return switch (status) {
    DayStatus.logged => Container(
        decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(3)),
      ),
    DayStatus.unresolved => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: AppColors.lineStrong, style: BorderStyle.solid),
        ),
      ),
    DayStatus.movedTo => Container(
        decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(3)),
      ),
    DayStatus.rest || DayStatus.missed => Container(
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(3)),
      ),
  };
}

class DayResolutionSheet extends ConsumerWidget {
  const DayResolutionSheet({super.key, required this.date});

  final DateTime date;

  Future<void> _saveResolution(BuildContext context, WidgetRef ref, DayResolutionKind kind) async {
    await ref.read(dayResolutionRepositoryProvider).resolve(DayResolution(date: date, kind: kind));
    ref.invalidate(heatmapProvider);
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _pickMovedToDate(BuildContext context, WidgetRef ref) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: date.subtract(const Duration(days: 14)),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    await ref
        .read(dayResolutionRepositoryProvider)
        .resolve(DayResolution(date: date, kind: DayResolutionKind.movedTo, movedToDate: picked));
    ref.invalidate(heatmapProvider);
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _addItNow(BuildContext context, WidgetRef ref) async {
    final session = Session(id: _uuid.v4(), date: date, startedAt: date);
    await ref.read(sessionRepositoryProvider).createSession(session);
    ref.invalidate(heatmapProvider);
    if (!context.mounted) return;
    Navigator.of(context).pop();
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SessionScreen(sessionId: session.id)),
    );
    ref.invalidate(heatmapProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE d MMM').format(date),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          const Text('No session logged. What was this?', style: TextStyle(fontSize: 12.5, color: AppColors.ink3)),
          const SizedBox(height: 14),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Rest'),
            onTap: () => _saveResolution(context, ref, DayResolutionKind.rest),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Travel'),
            onTap: () => _saveResolution(context, ref, DayResolutionKind.travel),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Did it a different day'),
            onTap: () => _pickMovedToDate(context, ref),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Add it now'),
            onTap: () => _addItNow(context, ref),
          ),
        ],
      ),
    );
  }
}

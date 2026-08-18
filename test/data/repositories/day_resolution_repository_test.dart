import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rep_tracker/data/database.dart';
import 'package:rep_tracker/data/repositories/day_resolution_repository.dart';
import 'package:rep_tracker/domain/models/plan.dart';

void main() {
  test('resolve then forDate round-trips, normalized to the calendar date', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = DayResolutionRepository(db);

    await repo.resolve(
      DayResolution(date: DateTime(2026, 8, 12, 9, 30), kind: DayResolutionKind.travel),
    );

    final result = await repo.forDate(DateTime(2026, 8, 12, 23, 0));
    expect(result, isNotNull);
    expect(result!.kind, DayResolutionKind.travel);
    expect(result.date, DateTime(2026, 8, 12));

    await db.close();
  });

  test('resolving the same date twice overwrites, never duplicates', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = DayResolutionRepository(db);
    final date = DateTime(2026, 8, 12);

    await repo.resolve(DayResolution(date: date, kind: DayResolutionKind.rest));
    await repo.resolve(
      DayResolution(date: date, kind: DayResolutionKind.movedTo, movedToDate: DateTime(2026, 8, 13)),
    );

    final result = await repo.forDate(date);
    expect(result!.kind, DayResolutionKind.movedTo);
    expect(result.movedToDate, DateTime(2026, 8, 13));

    final all = await repo.inRange(DateTime(2026, 8, 1), DateTime(2026, 9, 1));
    expect(all, hasLength(1));

    await db.close();
  });
}

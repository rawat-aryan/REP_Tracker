import 'dart:io';

import 'package:rep_tracker/bridge/fake_trigger_bridge.dart';
import 'package:rep_tracker/bridge/trigger_event.dart';
import 'package:rep_tracker/domain/models/workout_set.dart';
import 'package:test/test.dart';

void main() {
  late Directory dir;
  late FakeTriggerBridge bridge;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('rep_tracker_bridge_test_');
    bridge = FakeTriggerBridge(dir);
  });

  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  test('drain truncates the journal', () async {
    await bridge.debugAppendEvent(TriggerEventType.setStarted, sessionId: 's1');
    final drained = await bridge.drain();
    expect(drained, hasLength(1));

    final eventsFile = File('${dir.path}/events.jsonl');
    expect(await eventsFile.readAsString(), isEmpty);
    expect(await bridge.drain(), isEmpty);
  });

  test(
      'idempotent by event id — a re-read of an un-truncated line is not re-applied',
      () async {
    // Same id appended twice, simulating a native-side retry before the
    // previous append was ever drained.
    await bridge.debugAppendEvent(
      TriggerEventType.setStarted,
      sessionId: 's1',
      id: 'evt-1',
    );
    await bridge.debugAppendEvent(
      TriggerEventType.setStarted,
      sessionId: 's1',
      id: 'evt-1',
    );
    final first = await bridge.drain();
    expect(first, hasLength(1));

    // File was truncated, but re-appending the same id (a retried write
    // that thinks it never landed) must still not double-apply.
    await bridge.debugAppendEvent(
      TriggerEventType.setStarted,
      sessionId: 's1',
      id: 'evt-1',
    );
    final second = await bridge.drain();
    expect(second, isEmpty);
  });

  test('duration is taken from journal timestamps, not drain time', () async {
    final startedAt = DateTime.utc(2026, 8, 18, 6, 12, 44);
    final endedAt = startedAt.add(const Duration(seconds: 42));

    await bridge.debugAppendEvent(
      TriggerEventType.setStarted,
      sessionId: 's1',
      at: startedAt,
    );
    await bridge.debugAppendEvent(
      TriggerEventType.setEnded,
      sessionId: 's1',
      at: endedAt,
    );

    // Drain happens long after the events actually occurred — simulates the
    // app being resumed well after the set was logged natively.
    final events = await bridge.drain();
    final set = _toWorkoutSet(events);

    expect(set.duration, const Duration(seconds: 42));
  });

  test('a phantom set (bumped in a pocket) survives the round trip flagged',
      () async {
    final startedAt = DateTime.utc(2026, 8, 18, 6, 0, 0);
    final endedAt = startedAt.add(const Duration(minutes: 40));

    await bridge.debugAppendEvent(
      TriggerEventType.setStarted,
      sessionId: 's1',
      at: startedAt,
    );
    await bridge.debugAppendEvent(
      TriggerEventType.setEnded,
      sessionId: 's1',
      at: endedAt,
    );

    final events = await bridge.drain();
    final set = _toWorkoutSet(events);

    expect(set.isPhantom(), isTrue);
  });

  test('availableTiers is empty — no native trigger exists yet', () async {
    expect(await bridge.availableTiers(), isEmpty);
  });
}

/// Stands in for whatever will eventually turn a drained setStarted/setEnded
/// pair into a WorkoutSet — exercises that the timestamps flow through
/// unmodified.
WorkoutSet _toWorkoutSet(List<TriggerEvent> events) {
  final started =
      events.firstWhere((e) => e.type == TriggerEventType.setStarted);
  final ended = events.firstWhere((e) => e.type == TriggerEventType.setEnded);
  return WorkoutSet(
    id: started.id,
    exerciseId: 'placeholder',
    index: 1,
    startedAt: started.at,
    endedAt: ended.at,
  );
}

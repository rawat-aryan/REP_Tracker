import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:rep_tracker/bridge/android_trigger_bridge.dart';
import 'package:rep_tracker/bridge/trigger_event.dart';
import 'package:rep_tracker/domain/models/workout_set.dart';

/// Same file-based half of the contract [FakeTriggerBridge] already covers
/// (milestone 03), ported onto the real bridge per milestone 02: idempotent
/// drain by id, truncation, journal-timestamp duration, phantom detection.
/// The MethodChannel half (ambient surface, tier query) has no desktop
/// equivalent to fake — that's verified on-device.
class _FakeDocsDir extends PathProviderPlatform with MockPlatformInterfaceMixin {
  _FakeDocsDir(this.path);
  final String path;

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('rep_tracker_android_bridge_test_');
    PathProviderPlatform.instance = _FakeDocsDir(dir.path);
  });

  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  Future<void> appendEvent(
    TriggerEventType type, {
    required String sessionId,
    required DateTime at,
    String? id,
  }) async {
    final event = TriggerEvent(
      id: id ?? '${at.microsecondsSinceEpoch}-${type.name}',
      type: type,
      at: at,
      sessionId: sessionId,
    );
    await File('${dir.path}/events.jsonl').writeAsString(
      '${jsonEncode(event.toJson())}\n',
      mode: FileMode.append,
    );
  }

  test('drain truncates the journal', () async {
    final bridge = AndroidTriggerBridge();
    await appendEvent(TriggerEventType.setStarted, sessionId: 's1', at: DateTime.utc(2026, 8, 18));
    final drained = await bridge.drain();
    expect(drained, hasLength(1));

    final eventsFile = File('${dir.path}/events.jsonl');
    expect(await eventsFile.readAsString(), isEmpty);
    expect(await bridge.drain(), isEmpty);
  });

  test(
      'idempotent by event id — a re-read of an un-truncated line is not re-applied',
      () async {
    final bridge = AndroidTriggerBridge();
    await appendEvent(
      TriggerEventType.setStarted,
      sessionId: 's1',
      at: DateTime.utc(2026, 8, 18),
      id: 'evt-1',
    );
    await appendEvent(
      TriggerEventType.setStarted,
      sessionId: 's1',
      at: DateTime.utc(2026, 8, 18),
      id: 'evt-1',
    );
    final first = await bridge.drain();
    expect(first, hasLength(1));

    // File was truncated, but re-appending the same id (a retried native
    // write that thinks it never landed) must still not double-apply.
    await appendEvent(
      TriggerEventType.setStarted,
      sessionId: 's1',
      at: DateTime.utc(2026, 8, 18),
      id: 'evt-1',
    );
    final second = await bridge.drain();
    expect(second, isEmpty);
  });

  test('duration is taken from journal timestamps, not drain time', () async {
    final bridge = AndroidTriggerBridge();
    final startedAt = DateTime.utc(2026, 8, 18, 6, 12, 44);
    final endedAt = startedAt.add(const Duration(seconds: 42));

    await appendEvent(TriggerEventType.setStarted, sessionId: 's1', at: startedAt);
    await appendEvent(TriggerEventType.setEnded, sessionId: 's1', at: endedAt);

    final events = await bridge.drain();
    final set = _toWorkoutSet(events);

    expect(set.duration, const Duration(seconds: 42));
  });

  test('a phantom set (bumped in a pocket) survives the round trip flagged',
      () async {
    final bridge = AndroidTriggerBridge();
    final startedAt = DateTime.utc(2026, 8, 18, 6, 0, 0);
    final endedAt = startedAt.add(const Duration(minutes: 40));

    await appendEvent(TriggerEventType.setStarted, sessionId: 's1', at: startedAt);
    await appendEvent(TriggerEventType.setEnded, sessionId: 's1', at: endedAt);

    final events = await bridge.drain();
    final set = _toWorkoutSet(events);

    expect(set.isPhantom(), isTrue);
  });

  test('writeContext then clearContext leaves no context.json behind', () async {
    final bridge = AndroidTriggerBridge();
    await bridge.writeContext(
      const TriggerContext(
        sessionId: 's1',
        dayName: 'Legs',
        currentExerciseId: 'hip_thrust',
        currentExerciseName: 'Hip thrust',
        nextSetIndex: 1,
      ),
    );
    expect(await File('${dir.path}/context.json').exists(), isTrue);

    await bridge.clearContext();
    expect(await File('${dir.path}/context.json').exists(), isFalse);
  });
}

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

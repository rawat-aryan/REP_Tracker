import 'dart:convert';
import 'dart:io';

import 'trigger_bridge.dart';
import 'trigger_event.dart';

/// Debug-only [TriggerBridge] that stands in for the native trigger layer
/// before any Swift/Kotlin exists. It writes context.json / appends to
/// events.jsonl in its own sandbox directory (never shared storage — this
/// is a test double, not the real App Group contract) and exercises the
/// real drain path: idempotent-by-id replay, truncation, and journal
/// timestamps that survive a delayed drain.
///
/// [debugAppendEvent] is the stand-in for "the trigger fires" — call it
/// from a test or a debug-build button the way the Action Button / QS tile
/// would append a real event.
///
/// No native code exists yet (no App Group), so [availableTiers] is
/// deliberately empty and the ambient-surface methods are no-ops — the app
/// must degrade honestly to manual in-app logging, not pretend a tier it
/// can't deliver.
class FakeTriggerBridge implements TriggerBridge {
  FakeTriggerBridge(Directory dir)
      : _contextFile = File('${dir.path}/context.json'),
        _eventsFile = File('${dir.path}/events.jsonl');

  final File _contextFile;
  final File _eventsFile;

  /// Ids already returned by a previous [drain]. Guards against re-applying
  /// an event that survived a failed truncate and got re-read on retry —
  /// the same hazard the real journal must tolerate (§7: "a half-failed
  /// replay is harmless to re-run").
  final Set<String> _seenEventIds = {};

  @override
  Future<void> writeContext(TriggerContext context) async {
    await _contextFile.writeAsString(jsonEncode(context.toJson()));
  }

  @override
  Future<void> clearContext() async {
    if (await _contextFile.exists()) await _contextFile.delete();
  }

  /// Appends one line the way the native trigger would. [at] lets tests
  /// simulate clock skew between when the event actually happened and when
  /// drain() gets around to reading it.
  Future<void> debugAppendEvent(
    TriggerEventType type, {
    required String sessionId,
    DateTime? at,
    String? id,
  }) async {
    final event = TriggerEvent(
      id: id ?? _newId(),
      type: type,
      at: at ?? DateTime.now().toUtc(),
      sessionId: sessionId,
    );
    await _eventsFile.writeAsString(
      '${jsonEncode(event.toJson())}\n',
      mode: FileMode.append,
    );
  }

  @override
  Future<List<TriggerEvent>> drain() async {
    if (!await _eventsFile.exists()) return const [];
    final lines = await _eventsFile.readAsLines();
    final events = <TriggerEvent>[];
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      final event =
          TriggerEvent.fromJson(jsonDecode(line) as Map<String, dynamic>);
      if (_seenEventIds.add(event.id)) events.add(event);
    }
    await _eventsFile.writeAsString('');
    return events;
  }

  @override
  Future<void> startAmbientSurface(TriggerContext context) async {}

  @override
  Future<void> updateAmbientSurface(TriggerContext context) async {}

  @override
  Future<void> stopAmbientSurface() async {}

  /// No native trigger exists yet — degrade honestly rather than offer a
  /// tier the app can't deliver.
  @override
  Future<Set<TriggerTier>> availableTiers() async => const {};

  int _idCounter = 0;
  String _newId() => '${DateTime.now().microsecondsSinceEpoch}-${_idCounter++}';
}

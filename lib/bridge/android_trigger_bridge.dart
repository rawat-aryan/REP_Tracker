import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'trigger_bridge.dart';
import 'trigger_event.dart';

/// Real Android [TriggerBridge]. Milestone 02.
///
/// `context.json` / `events.jsonl` live in `getApplicationSupportDirectory()`,
/// which on Android resolves to `context.filesDir` — the exact path the
/// Kotlin side (`TriggerJournal.kt`) reads and appends to with plain
/// `java.io.File` calls, and the same directory `AppDatabase` puts the
/// sqlite file in (`database.dart`). No channel round-trip for either file;
/// that keeps the contract's "two files, each with exactly one writer" true
/// even when the app process is dead and only native is running (§7).
///
/// `getApplicationDocumentsDirectory()` is NOT this path on Android — it
/// resolves to `context.filesDir/app_flutter/`, a subdirectory Kotlin never
/// looks in. Milestone 06's physical/emulator verification is what caught
/// this: `context.json` was silently landing one directory below where
/// `TriggerJournal.kt` reads it, so every `writeContext` call since
/// milestone 02 was writing into a void.
///
/// The ambient surface (start/stop the foreground service, query which
/// tiers this device actually has) has no file-based equivalent — those go
/// over a [MethodChannel] to `MainActivity`.
class AndroidTriggerBridge implements TriggerBridge {
  static const _channel = MethodChannel('rep_tracker/trigger');

  /// Ids already returned by a previous [drain] this app session. Guards
  /// against re-applying an event that survived a failed truncate and got
  /// re-read on retry (§7: "a half-failed replay is harmless to re-run").
  final Set<String> _seenEventIds = {};

  Future<File> _contextFile() async =>
      File('${(await getApplicationSupportDirectory()).path}/context.json');

  Future<File> _eventsFile() async =>
      File('${(await getApplicationSupportDirectory()).path}/events.jsonl');

  @override
  Future<void> writeContext(TriggerContext context) async {
    final file = await _contextFile();
    await file.writeAsString(jsonEncode(context.toJson()));
  }

  @override
  Future<void> clearContext() async {
    final file = await _contextFile();
    if (await file.exists()) await file.delete();
  }

  @override
  Future<List<TriggerEvent>> drain() async {
    final file = await _eventsFile();
    if (!await file.exists()) return const [];
    final lines = await file.readAsLines();
    final events = <TriggerEvent>[];
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      final event =
          TriggerEvent.fromJson(jsonDecode(line) as Map<String, dynamic>);
      if (_seenEventIds.add(event.id)) events.add(event);
    }
    await file.writeAsString('');
    return events;
  }

  @override
  Future<void> startAmbientSurface(TriggerContext context) async {
    await writeContext(context);
    await _channel.invokeMethod<void>('startAmbientSurface');
  }

  @override
  Future<void> updateAmbientSurface(TriggerContext context) async {
    await writeContext(context);
    await _channel.invokeMethod<void>('updateAmbientSurface');
  }

  @override
  Future<void> stopAmbientSurface() async {
    await _channel.invokeMethod<void>('stopAmbientSurface');
  }

  @override
  Future<Set<TriggerTier>> availableTiers() async {
    final names = await _channel.invokeListMethod<String>('availableTiers');
    if (names == null) return const {};
    return names.map(TriggerTier.values.byName).toSet();
  }
}

import 'trigger_event.dart';

/// Dart side of the trigger contract.
///
/// Implementation notes for whoever builds this:
///   - drain() must apply events IDEMPOTENTLY BY ID, then truncate the file.
///   - Call drain() on app resume AND on cold start, before rendering.
///   - writeContext() must be called on every state change that affects what
///     the ambient card shows: session start, current-exercise change, each
///     set logged.
///   - A phantom set (started, ended, absurd duration) is surfaced to the user
///     as "discard?" — never saved silently, never dropped silently.
abstract class TriggerBridge {
  /// Read and apply pending native events, then truncate the journal.
  /// Safe to call repeatedly; safe to re-run after a partial failure.
  Future<List<TriggerEvent>> drain();

  /// Publish the current state for the native side to read.
  Future<void> writeContext(TriggerContext context);

  /// Clear context when no session is active, so the trigger becomes inert
  /// rather than starting a set against a stale session.
  Future<void> clearContext();

  /// Start / stop the ambient surface (Live Activity, foreground notification).
  Future<void> startAmbientSurface(TriggerContext context);
  Future<void> updateAmbientSurface(TriggerContext context);
  Future<void> stopAmbientSurface();

  /// Which trigger tiers this specific device supports, for the upgrade offer
  /// shown after session three. An iPhone 13 never sees the Action Button; a
  /// Pixel never sees Control Center.
  Future<Set<TriggerTier>> availableTiers();
}

enum TriggerTier {
  /// Universal: lock-screen card. Live Activity / foreground notification.
  ambientCard,

  /// Control Center control (iOS 18+) / Quick Settings tile (Android).
  parityTile,

  /// Action Button (iOS) / floating overlay (Android).
  platformBest,

  /// Watch app. Post-v1.
  watch,
}

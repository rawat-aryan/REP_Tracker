import '../data/repositories/exercise_repository.dart';
import '../data/repositories/plan_repository.dart';
import '../data/repositories/session_repository.dart';
import '../domain/rules/prefill.dart';
import 'trigger_apply.dart';
import 'trigger_bridge.dart';
import 'trigger_event.dart';

/// A drained `setEnded` that just closed a set — the caller (main.dart) uses
/// this to land the user directly on rep entry for it, per milestone 06's
/// "must hold": `setEnded` brings the app forward.
class DrainLanding {
  const DrainLanding({required this.sessionId, required this.exerciseId});
  final String sessionId;
  final String exerciseId;
}

/// Applies `events.jsonl` into the database. This is the one place a
/// pocket-triggered `setStarted`/`setEnded` gets turned into a real
/// [WorkoutSet] row — called on cold start and on every app resume, before
/// first render (§7: "drain on resume and cold start").
class TriggerDrainService {
  TriggerDrainService({
    required this.bridge,
    required this.sessions,
    required this.exercises,
    required this.plans,
    required this.prefill,
  });

  final TriggerBridge bridge;
  final SessionRepository sessions;
  final ExerciseRepository exercises;
  final PlanRepository plans;
  final PrefillService prefill;

  /// Drains and applies pending events in journal order, idempotently by id
  /// (handled inside [bridge].drain itself). Returns the last set that was
  /// closed by a `setEnded`, or null if nothing landed on rep entry.
  Future<DrainLanding?> drainAndApply() async {
    final events = await bridge.drain();
    if (events.isEmpty) return null;
    final ordered = [...events]..sort((a, b) => a.at.compareTo(b.at));

    DrainLanding? landing;
    String? touchedSessionId;
    for (final event in ordered) {
      final session = await sessions.getById(event.sessionId);
      final exerciseId = session?.currentExerciseId;
      if (session == null || exerciseId == null) {
        continue; // stray event — no session/exercise to attribute it to.
      }
      touchedSessionId = session.id;
      switch (event.type) {
        case TriggerEventType.setStarted:
          await startSetFor(
            session: session,
            exerciseId: exerciseId,
            at: event.at,
            sessions: sessions,
            exercises: exercises,
            prefill: prefill,
          );
          landing = null;
        case TriggerEventType.setEnded:
          await endSetFor(
            session: session,
            exerciseId: exerciseId,
            at: event.at,
            sessions: sessions,
          );
          landing = DrainLanding(sessionId: session.id, exerciseId: exerciseId);
      }
    }

    // Refresh the ambient card once at the end, not per-event — the native
    // side only ever reads the latest write anyway.
    final last = touchedSessionId == null ? null : await sessions.getById(touchedSessionId);
    if (last != null) {
      final dayName = last.workoutDayId == null
          ? 'Workout'
          : (await plans.getWorkoutDay(last.workoutDayId!))?.name ?? 'Workout';
      await bridge.updateAmbientSurface(
        await buildTriggerContext(
          session: last,
          exercises: exercises,
          prefill: prefill,
          dayName: dayName,
        ),
      );
    }
    return landing;
  }
}

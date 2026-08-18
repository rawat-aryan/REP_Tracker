# ADR-006 · The ambient card's "ended" state brings the app forward, not a decorated notification

**Status:** accepted · **Date:** 2026-08-18

## Context

Milestone 06's build list describes "the ambient card in two states —
running (timer + End set) and ended (weight stepper + rep quick-picks)."
Read literally, the ended state needs a decorated notification: a custom
`RemoteViews` layout with a live stepper and 4+ tappable rep values,
matching the four-wide row §8.2 defines for in-app entry.

But the same milestone's "must hold" section is explicit: **"`setEnded`
does [bring the app forward], landing on rep entry for that set."** That's
a real behavior already built — milestone 04's rep-entry sheet — and it
directly conflicts with the build list's phrasing: if the notification
itself captures weight+reps, there's no need to also launch the app into a
rep-entry screen for the same set.

A decorated stepper+quick-picks notification would also require growing
`TriggerEventType` to carry a payload (today it's only `setStarted`/
`setEnded`, no reps or weight), a new native `RemoteViews` layout with a
`PendingIntent` per button, and none of it is testable without a physical
device — this environment can drive an emulator and `adb`, not real
lock-screen button presses.

## Decision

**"Must hold" wins.** `setEnded`:

1. Appends the event to `events.jsonl`, same as today.
2. Brings the app forward (`TriggerAppLauncher.bringForward`, called from
   both `TriggerActionReceiver` and `TriggerQsTileService` — any surface
   that flips the toggle to "ended").
3. On the Dart side, `TriggerDrainService.drainAndApply()` — run on resume
   and cold start (§7) — applies the drained `setEnded`, resolves which set
   just closed, and `SessionScreen` opens directly into the existing
   `showRepEntrySheet` for it (`SessionScreen.autoOpenExerciseId`).

The notification itself stays a plain 3-action `NotificationCompat`
(toggle + `MORE`, unchanged from milestone 02) — running state's "timer +
End set" is exactly what it already renders, now driven by real
`context.json` content instead of a static placeholder. **No custom
`RemoteViews` layout is built.** The "weight stepper + rep quick-picks"
requirement is satisfied by the rep-entry sheet the user lands on, not by
notification-embedded controls.

## Consequences

- The event format doesn't need to grow. `TriggerEventType.setStarted` /
  `setEnded` stays exactly as milestone 03 defined it — one fewer thing
  that could drift between native and Dart.
- The user does have to unlock the phone once `setEnded` fires, the same as
  the pre-existing `MORE` button already required — Tier 0's "no unlock
  required" promise is about *starting/ending* a set (the toggle), not
  about *logging reps*, which spec §8.2 already treats as an app-side
  interaction with a highlighted prediction.
- If a future iteration wants reps logged without ever opening the app
  (closer to the iOS Live Activity ideal from §16), that's a new decision
  point, not a natural extension of this one — it would need the event
  format change and custom layout this ADR explicitly avoided.

## Revisit if

User testing shows unlocking-to-log is a real source of missed reps (the
prediction goes stale, the user forgets), or iOS Live Activities (ADR-005)
get built and set an expectation of true no-unlock logging that Android
should match.

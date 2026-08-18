# 02 · Android trigger spike

**No Flutter UI. Two days.** Same contract as 01, different mechanism.

## Build

1. A foreground service with `foregroundServiceType="health"`.
2. An ongoing notification with `PendingIntent` actions: `END SET`, a rep
   quick-pick, and `MORE`.
3. A `BroadcastReceiver` that reads `context.json`, toggles, and appends to
   `events.jsonl` in the app-private directory.
4. A Quick Settings tile (`TileService`) firing the same toggle.
5. Dart drain, same as 01.

## Watch out for

- **Android 14+ requires a declared `foregroundServiceType`.** `health` is the
  honest fit for a workout timer, and **Play review will ask you to justify it**.
  This is a review conversation, not a checkbox. Validate early — Tier 0 is the
  universal baseline, and if the service is rejected the whole tier collapses to
  a widget that needs an unlock.
- Standard notifications show **three actions maximum**. A custom decorated
  layout can hold more, but renders differently across OEMs — test on at least
  one Samsung device, which is the usual source of surprises.
- Notification actions on a secure lock screen may prompt for unlock depending
  on OEM and `setAuthenticationRequired`. Verify what actually happens locked.
- Do **not** build the `SYSTEM_ALERT_WINDOW` overlay in this milestone.

## Done when

- The notification survives the app being swiped away.
- Tapping `END SET` from the **lock screen** appends to `events.jsonl` without
  opening the app.
- The QS tile fires the same toggle.
- Dart drains both, idempotently.
- Verified on a physical device, not just the emulator.

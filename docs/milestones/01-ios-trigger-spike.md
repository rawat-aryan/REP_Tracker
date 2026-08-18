# 01 · iOS trigger spike

**No Flutter UI. No database. Two days.** Prove the boundary works before
anything is built on top of it.

## Build

1. A Flutter app shell with an App Group entitlement on the Runner target.
2. A **Widget Extension** target for the Live Activity, same App Group.
3. An **App Intent** in the Runner binary with `openAppWhenRun = false` that:
   - reads `context.json` from the App Group container
   - toggles: `activeSet` present -> append `setEnded`; absent -> append `setStarted`
   - appends one JSON line to `events.jsonl` with a fresh UUID
   - starts / ends a Live Activity showing `Text(timerInterval:)`
4. Dart code that writes a hardcoded `context.json` and drains `events.jsonl`
   on resume, printing what it read.
5. Assign the App Intent to the Action Button via Shortcuts, by hand.

## Watch out for

- **Entitlement mistakes fail silently.** The intent runs, writes nothing, and
  you debug for an hour. Verify the App Group container path resolves on both
  sides first, before writing any logic.
- `NSSupportsLiveActivities` must be in Info.plist.
- Use `Text(timerInterval:)` for the timer. **Do not push an update per second** —
  ActivityKit will throttle you and it drains battery.
- Interactive Live Activity buttons need iOS 17+. Have a plain-notification
  fallback path in mind, but don't build it yet.

## Done when

- Pressing the Action Button with the app **force-quit** appends a line to
  `events.jsonl`.
- A Live Activity appears in the Dynamic Island with a running timer.
- Pressing again ends it and appends `setEnded`.
- Opening the Flutter app prints both events, in order, with correct timestamps.
- Draining twice does not double-apply (idempotent by `id`).
- Killing the app mid-set and reopening still shows the set as running.

## Do not

- Build any real UI.
- Touch Drift.
- Add a second trigger tier. One mechanism, proven, then move on.

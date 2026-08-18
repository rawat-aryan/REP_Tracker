# 06 · Ambient surfaces

Wire milestones 01 and 02 into the real app. **This is the product.**

## Build

- `TriggerBridge` implementation on both platforms.
- `writeContext()` on every state change affecting the card: session start,
  current-exercise change, each set logged.
- `drain()` on resume **and** cold start, before first render.
- The ambient card in two states — running (timer + End set) and ended
  (weight stepper + rep quick-picks). Same card, different payload.
- iOS: Live Activity + Dynamic Island compact and expanded.
- Android: foreground notification. Decide up front whether to accept the
  three-action limit or use a custom decorated layout to match iOS's four-wide
  rep row. **Write it up as an ADR either way.**
- Tier 1: Control Center control (iOS 18+) and QS tile.
- Capability detection + the upgrade offer, shown **after session three** —
  never during onboarding, when the friction isn't real yet.

## Must hold

- The card **always names the exercise the next set will be attributed to.**
  Without it, a mis-attributed set from a pocket trigger is silent and
  invisible, and the whole model becomes untrustworthy.
- `setStarted` does not bring the app forward. `setEnded` does, landing on rep
  entry for that set.
- Phantom sets (started, ended, absurd duration) surface as `discard?` — never
  saved silently, never dropped silently.
- Duration comes from the journal timestamps, never from drain time.

## Done when

A full session is logged with the phone locked in a pocket, and every set has
correct weight, reps, duration and exercise attribution.

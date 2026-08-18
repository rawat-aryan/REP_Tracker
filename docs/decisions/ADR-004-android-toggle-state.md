# ADR-004 · Where the Android toggle's running/not-running state lives

**Status:** accepted · **Date:** 2026-08-18

## Context

§7's toggle is defined purely in terms of `context.json`: if `activeSet` is
present, append `setEnded`; otherwise append `setStarted`. "One action, no
modes, no state held in the trigger."

But `context.json` has exactly one writer — Dart (I6, §7). The whole point of
milestone 02 is a workout logged from a locked phone with the app process
dead the entire time: set 1 (start, end), set 2 (start, end), possibly several
more, all before the app is ever relaunched to drain the journal and rewrite
`context.json`. If the toggle's notion of "is a set running" comes only from
`context.json`, it goes stale after the very first `setEnded` — the second
press would append `setEnded` again instead of `setStarted`, because nothing
ever told the file the set had ended.

## Decision

The foreground service keeps one **in-memory, non-persisted** boolean — "is a
set currently running" — for as long as the service process is alive:

- Seeded once from `context.json`'s `activeSet` when the service (re)starts
  (covers the "app killed mid-set, then OS respawns the service" case from
  §7's failure modes).
- Flipped locally on every toggle press, both by the notification action and
  the QS tile, through one shared synchronized helper so they can't race.
- Never written back to `context.json` or any other file Dart reads.

This is the one deliberate, narrow exception to "no state held in the
trigger" — it's process memory, not a file, disappears with the service, and
is never a second writer to the contract's two files. `events.jsonl` remains
the only thing native produces; `context.json` remains Dart-only.

## Consequences

- If Android kills the foreground service outright (not just the app) between
  sets, the next toggle press reseeds from `context.json`, which is stale for
  the *first* toggle after that — a `setStarted` could be sent when a set had
  actually already ended and gone undrained. This degrades to the same
  "phantom set" the app already detects and discards (`WorkoutSet.isPhantom`,
  §7's failure modes) — no data corruption, just a set the user is asked to
  discard. Acceptable; foreground services with an ongoing notification are
  not usually killed by the OS outside of memory pressure.
- `MORE` and the still-cut rep quick-pick action are unaffected — they don't
  touch this flag.

## Revisit if

A future tier (watch app, Tier 3) needs the running state to survive a full
service kill without a phantom-set round trip.

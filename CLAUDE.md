# REP Tracker

A workout logger built around one bet: **the fastest possible set-logging loop.**
Press a trigger, do the set, press again, tap one rep button. Phone stays in the
pocket. Weight is prefilled from last time.

Full spec: `docs/spec.md`. Screen designs: `docs/screens.html`. Read the relevant
section before implementing — this file is the summary, not the source of truth.

---

## The seven invariants

Violating any of these breaks the product. If a task seems to require breaking one,
stop and say so instead of working around it.

**I1 — Analytics never reads the plan.**
A logged set references an exercise ID and nothing about the plan. No query producing
history, prefill, PRs, or charts may read `WorkoutDay`, `WeekPlan`, or weekday.
Planning reads the plan; analytics reads the log.
*Most likely violation:* scoping a prefill query by day ("last hip thrust on Legs
day"). That single line breaks history the first time the user changes their split.

**I2 — The app observes, it does not infer.**
No pattern is committed without user confirmation. States: `observing` →
`provisional` → `confirmed`. Guesses are always visibly marked as guesses.

**I3 — Nothing interrupts a session.**
Duplicate detection, day-split prompts, gap resolution, pattern confirmations — all
queue and surface on the home screen afterwards. Never a mid-workout modal.

**I4 — No required fields, anywhere.**
An exercise with zero sets saves. A set with weight and no reps saves. Validation
friction causes skipped logging, and gaps are worse than fuzzy data.

**I5 — Nothing is ever read-only.**
Any past session, set, or day status stays editable forever.

**I6 — One writer to the database.**
Dart owns the DB. The native trigger layer is a dumb event producer that never
touches it. Never two clients writing the same store.

**I7 — Never delete, always archive.**
Exercises, days and routines get an `archived` flag. History must never dangle.

---

## Stack

- **Flutter** (Dart 3), Material 3 with a custom theme — see `docs/screens.html`
- **Drift** (SQLite) for local persistence. Local-only; no auth, no cloud in v1
- **Riverpod** for state
- **fl_chart** for the exercise charts
- Native modules per platform for the trigger layer (Swift / Kotlin), talking to Dart
  **only** through the file contract below

Target: iOS 17+, Android 13+ (API 33).

## Layout

```
lib/
  domain/models/     pure Dart, no framework imports, no persistence concerns
  domain/rules/      prefill, increment resolution, overlap detection, e1RM
  data/              Drift schema, DAOs, repositories
  bridge/            the trigger contract — event journal + context file
  features/          one folder per screen group: onboarding, home, session, history
ios/                 Swift: App Intents, Live Activity widget extension
android/             Kotlin: foreground service, notification, QS tile, overlay
docs/                spec, screens, milestones, decisions
```

`domain/` must not import `package:flutter`. It should be testable with `dart test`
alone.

---

## The trigger contract

The trigger fires when the Dart VM is dead. It cannot call Dart, cannot touch Drift,
and knows only what Dart already wrote down.

Two files in shared storage (iOS App Group / Android app-private dir), **each with
exactly one writer**:

- `context.json` — Dart writes, native reads. What's live now: session, current
  exercise, next set index, prefilled load, active set.
- `events.jsonl` — native appends, Dart drains. Append-only, one JSON object per line,
  each with a UUID. Dart replays on resume, applies **idempotently by `id`**, then
  truncates.

Never put the database in shared storage. Never let both sides write the same file.

Duration is always `setEnded.at − setStarted.at` from the journal — never computed at
drain time.

---

## Conventions

- **Weights are stored in kilograms**, always. Convert at display only.
- **Set index is positional** — derived from row order, never a stored typed field.
- **Execution (`bilateral` / `unilateral`) lives on the set, not the exercise.** The
  reference user switches mid-exercise. `Exercise.defaultExecution` is a prefill
  fallback only.
- **Drop sets are one set with N segments**, not N sets.
- Seeded exercises use human-readable slugs (`hip_thrust`); custom ones use UUIDs.
- Prefer `sealed class` + pattern matching over enums-with-fields for variants.
- No `late` on anything that crosses an async boundary.

## Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Drift codegen
flutter test                                                # unit + widget
dart test test/domain                                       # domain only, fast
flutter analyze
```

Run `flutter analyze` and `flutter test` before declaring a milestone done.

---

## How to work here

Milestones live in `docs/milestones/`, numbered in build order. Do one at a time.
Each has an explicit **Done when** section — treat it as the acceptance test.

Build order is riskiest-first: the trigger spike comes **before** any UI, because if
the platform fights you it should surface in week one, not week six.

When a decision isn't covered by the spec, write it up in `docs/decisions/` as a short
ADR rather than deciding silently in code.

## Things that look like good ideas and are not

- **Linking substituted exercises** so the curve continues. Different exercises
  produce different numbers; merging fabricates progress. Use the compare overlay.
- **Merging unilateral and bilateral into one chart series.** 40 kg single-leg is not
  a regression from 60 kg both-legs. Two series, no normalisation — any multiplier is
  invented.
- **Hardcoding a 2.5 kg increment.** It's per-exercise and learned. See spec §8.4.
- **Media/earbud buttons as a trigger.** The audio session belongs to Spotify.
  Structurally unavailable on both platforms.
- **Prompting the user mid-session** about anything at all. See I3.

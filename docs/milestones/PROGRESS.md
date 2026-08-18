# Progress

Resume log for milestone work. One line per step: what's done, what's next.

## Milestone 03 — data layer (+ FakeTriggerBridge, empty availableTiers)

- 2026-08-18 — iOS/Android native work deferred (no paid Apple dev account yet).
  Starting at milestone 03 instead of 01. Read CLAUDE.md, milestone 03 spec,
  spec §3/§6/§7/§8, and existing domain layer (models + rules — already
  built, untouched). Confirmed: 50-exercise starter seed already exists at
  `assets/seed/exercises.json` (spec wants ~150 eventually, file already
  documents that). Drafted plan, presented to user. **Next: awaiting
  go-ahead before writing any code.**
- 2026-08-18 — User approved the plan. Built the full data layer:
  - `lib/data/schema.dart` — Drift tables for all 10 domain entities. Row
    classes renamed via `@DataClassName` to `...Row` to avoid colliding with
    the domain model class of the same name (Exercise, Session, WorkoutSet…).
    `WorkoutSet.index`/`SetSegment` position are NOT stored columns — an
    insertion-order `seq` stamp is stored instead, and repositories derive
    the positional index by ordering on it at read time (per milestone's
    "don't trust a stored value to stay correct after a delete").
  - `lib/data/database.dart` — `AppDatabase`, in-app-support-dir SQLite file.
  - `lib/data/repositories/` — `ExerciseRepository` (+ merge/archive),
    `SessionRepository` (the I1-critical `historyForExercise`/
    `lastSetAtIndex`, neither takes a day/plan param), `PlanRepository`,
    `BodyweightRepository`, `DriftPrefillService implements PrefillService`.
  - `lib/data/seed/exercise_seed.dart` — parses + loads the 50-exercise seed,
    versioned via a `seed_version` key so a future bump adds new IDs without
    touching user edits. **Not yet wired into app startup — no screens/
    providers exist yet to call it from; `seedIfNeeded` is tested directly
    against the real asset file.**
  - `lib/bridge/fake_trigger_bridge.dart` — debug-only `TriggerBridge` double.
    Idempotent-by-id drain (in-memory seen-id set, covers same-process
    retry-before-truncate), truncates after drain, `availableTiers()` is
    `{}`, ambient-surface methods are no-ops (honest degrade, no native
    tier exists). `debugAppendEvent` stands in for the native trigger.
  - **Bug fixed in existing domain code**: `resolveIncrementKg` used the
    smallest adjacent difference between loads, which gives 15 for
    `[40, 60, 75]` — the milestone's own required test expects 5 (the GCD of
    the differences, since 40→60→75 are both 5 kg-step jumps, just not
    consecutive-visit ones). Switched to a GCD-based resolution in
    `lib/domain/rules/prefill.dart`.
  - **Design decision made while writing the ham-curl test**: `WorkoutSet.index`
    is 1-based ("set 1" → index 1), because the milestone's own test says
    `executionFor(setIndex: 1)` → unilateral, `setIndex: 2` → bilateral,
    matching the reference log's "set 1 unilateral, sets 2-3 bilateral."
    Not written down anywhere else — worth an ADR if this trips anyone up
    in the session/home screen milestones.
  - **Also fixed**: `lib/main.dart` (stock `flutter create` scaffold, never
    touched otherwise) used `dot-shorthands` syntax (`.fromSeed(...)`,
    `.center`) not enabled in this SDK, which failed `flutter analyze`/
    `flutter test` outright — 2-line mechanical fix, unrelated to milestone
    03's scope but was blocking the whole-suite gate for every future
    milestone too.
  - All tests written and green: `dart test test/domain` (12 tests, the
    milestone's literal Done-when) and `flutter test` (22 tests total,
    including the pre-existing widget smoke test) both pass; `flutter
    analyze` is clean.
  - **Next**: milestone 04, session screen — first place `seedIfNeeded`,
    `AppDatabase`, and the repositories actually get wired up behind
    Riverpod providers.

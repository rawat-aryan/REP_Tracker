# Progress

Resume log for milestone work. One line per step: what's done, what's next.

## Milestone 04 — session screen (manual logging only, no native trigger)

- 2026-08-18 — Read CLAUDE.md, milestone 04 spec, spec §6/§8, screens.html
  flow 03, and the existing domain/data layer built in milestone 03 (none of
  it was wired to any UI yet — `lib/main.dart` was still the stock
  `flutter create` counter demo). Built the whole vertical slice:
  - `lib/providers.dart` — first Riverpod wiring for `AppDatabase` and all
    four repositories/`PrefillService`, plus `allExercisesProvider` for
    cheap id→name lookups in the ledger.
  - `lib/features/session/session_controller.dart` — `StateNotifier<AsyncValue<Session>>`
    family keyed by sessionId. Manual start/end plays the trigger's role
    per the milestone doc: `startSet` persists immediately (prefilled load,
    no reps — a crash loses nothing, I5), `endSet` stamps `endedAt`,
    `acceptPrediction` is the one-tap fast path (§8.2), `saveSetEdits` is
    the overflow path used both to confirm-with-corrections and to edit any
    past set (I5 — nothing gated on "current"). Auto-advance to
    `session.nextOutstanding` only fires when the set just closed belonged
    to the *current* exercise's *live* set — editing an old row never moves
    the highlight.
  - `lib/features/session/session_screen.dart` — the ledger. Each exercise
    row derives its state (done / running / pendingReps / start) purely
    from `WorkoutSet.startedAt`/`endedAt`/`hasReps` — no extra ephemeral
    flags. Hollow-to-solid done with `TextStyle.foreground` +
    `PaintingStyle.stroke` (stdlib Flutter, no custom painter). Predicted
    reps render hollow and tap-to-accept defaults L=R for unilateral sets;
    with no history to predict from (first time), the row falls back to
    "log reps" and only the full sheet can close it.
  - `lib/features/session/rep_entry_sheet.dart` — the overflow screen
    (stepper w/ long-press coarse jump via existing `resolveIncrementKg`/
    `coarseIncrementKg`, bilateral/unilateral toggle, `repQuickPicks` chips,
    3 tag chips). Native numeric `TextField`s stand in for the mockup's
    custom keypad grid (ladder rung 4 — the platform keyboard already does
    this). **Scope cut**: only edits segment 0 — no multi-segment drop-set
    entry UI, `Drop set` just tags the set. Flagged with a `ponytail:`-style
    comment at the top of the file.
  - `lib/features/session/exercise_picker_sheet.dart` — deferral list +
    library search, in spec order. **Scope cut**: no "learned substitutes"
    section — there's no `substitutionCount` table yet, so there's nothing
    to rank it by. Add when that data exists.
  - `lib/main.dart` — replaced the stock counter app. No home screen yet
    (that's milestone 05), so it seeds the catalog, ensures a demo "Legs"
    `WorkoutDay` (hip thrust / squat / balancing lunge [uni] / ham curl, per
    spec §1), resumes today's open session for it or starts one, and drops
    straight into `SessionScreen`.
  - Small necessary additions to existing files, not scope creep: `copyWith`
    on `WorkoutSet`/`SetSegment`/`Session` (editing needs them, `Load`
    already had one); `Exercise.defaultLoadSource` (equipment → `LoadSource`
    fallback for a set with zero history); `SessionRepository.addExerciseToSession`
    (lets a zero-set off-plan pick show up in the pool immediately, per I4 —
    refactored out of `addSet`'s existing lookup-or-insert logic rather than
    duplicating it).
  - Deleted the stock `test/widget_test.dart` counter smoke test; replaced
    with `test/features/session/session_screen_test.dart` — two real
    widget tests against an in-memory DB (no mocks of the app's own code)
    that are literally the milestone's Done-when: log a full bilateral set
    fast-path, defer an exercise mid-session and confirm `nextOutstanding`
    walks back to it with zero prompts, and log a unilateral/per-side set
    ("Single -40"-shaped) through the full entry sheet.
  - `flutter analyze` clean, `flutter test` 28/28 green. Also manually
    driven on the Pixel 9a emulator (adb tap + screenshots): boot →
    demo Legs session → Start set → live elapsed pill → End set → "log
    reps" pendingReps fallback (no history yet) → full sheet renders
    exactly per screens.html. Incidentally confirmed two invariants live:
    a weight-only partial save correctly stays `pendingReps` (I4), and
    tapping "End session" while `log reps` was still outstanding left the
    row fully editable — ending a session doesn't lock it (I5).
  - **Not done**: rotate-mid-set device testing (emulator rotation wasn't
    exercised this session) and the literal §1 Legs session end-to-end on
    a real day boundary — the demo day's exercise list is a reasonable
    stand-in, not the literal reference log line-for-line. Both are cheap
    to check by hand; nothing in the implementation is day/rotation-aware
    in a way that would break either.

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

## Milestone 02 — Android trigger spike (native, no Flutter UI)

- 2026-08-18 — Read CLAUDE.md, milestone 02 spec, spec §6/§7/§16, and the
  existing `TriggerBridge`/`TriggerEvent`/`FakeTriggerBridge` contract from
  milestone 03. Drafted plan, presented to user. **Next: awaiting
  go-ahead before writing any code.**
- 2026-08-18 — User approved. Built the native trigger layer:
  - `ADR-004` — documents the one deliberate exception to "no state held in
    the trigger": the foreground service keeps an in-memory running/
    not-running boolean (never written to `context.json`) so the toggle
    works correctly across repeated presses while the app stays dead the
    whole workout. Seeded from `context.json`'s `activeSet` on service
    (re)start; resets on service destroy.
  - `android/.../TriggerJournal.kt` — reads `context.json`
    (`context.filesDir`, read-only from native), synchronized append to
    `events.jsonl`. `org.json.JSONObject`, no new dependency.
  - `android/.../TriggerToggleState.kt` — the ADR-004 in-memory flag.
  - `android/.../TriggerForegroundService.kt` — `foregroundServiceType="health"`,
    two-action notification (toggle + `MORE`), `ServiceCompat.startForeground`.
  - `android/.../TriggerActionReceiver.kt` — the toggle's `BroadcastReceiver`.
    Deliberately does **not** bring the app forward on `setEnded` for this
    milestone — no rep-entry screen exists yet to land on; §7's "setEnded
    brings the app forward" gets wired in once one does.
  - `android/.../TriggerQsTileService.kt` — same toggle, Tier 1 parity layer.
  - `android/.../MainActivity.kt` — `rep_tracker/trigger` MethodChannel
    (ambient-surface lifecycle + `availableTiers` only — never file I/O,
    that stays direct on both sides per §7's two-writer rule); requests
    `POST_NOTIFICATIONS` at launch (no settings screen yet to trigger it
    from).
  - `AndroidManifest.xml` — `FOREGROUND_SERVICE`/`FOREGROUND_SERVICE_HEALTH`/
    `POST_NOTIFICATIONS` permissions; service/receiver/tile declarations.
  - `minSdk` bumped 21→33 to match CLAUDE.md's Android 13+ target (also
    means `java.time` is usable natively in the trigger layer, no desugaring
    needed).
  - `lib/bridge/android_trigger_bridge.dart` — the real `TriggerBridge`.
    `drain()`/`writeContext()`/`clearContext()` are plain file I/O against
    `getApplicationDocumentsDirectory()`, which resolves to the same
    `context.filesDir` path Kotlin uses — no channel round-trip for the file
    half of the contract, only the ambient-surface calls go over
    `MethodChannel`.
  - **Scope cut, flagged to user before building**: dropped the rep
    quick-pick notification action from the milestone doc's build list.
    `TriggerEventType` only has `setStarted`/`setEnded` — no way to carry a
    rep count over the journal — and there's no rep-entry screen yet to open
    into either way, so it would currently be an identical no-op to `MORE`.
    Trivial to add once milestone 04+ builds that screen.
  - Ported all 5 `FakeTriggerBridge` tests onto `AndroidTriggerBridge`'s
    file-I/O half (`test/bridge/android_trigger_bridge_test.dart`), faking
    `path_provider`'s platform channel so they run under plain `flutter
    test` — idempotent drain, truncation, phantom detection, journal-
    timestamp duration all pass. The `MethodChannel` half (ambient surface,
    tier query) has no desktop fake; that's what physical-device
    verification covers.
  - `flutter build apk --debug` succeeds (took ~20 min — first build under
    the new AGP/Kotlin toolchain + `minSdk` bump, not a real problem).
    `flutter analyze` clean, `flutter test` all 27 green.
  - **Not yet done — needs the user, on their own phone**: the milestone's
    actual Done-when (notification survives app swipe, `END SET` from the
    **locked** screen appends without opening the app, QS tile fires the
    same toggle, verified physically). Agent tooling can't press a real
    lock-screen button. Gave the user `adb`/`flutter run` steps to check
    this themselves — awaiting that confirmation before calling milestone
    02 done.

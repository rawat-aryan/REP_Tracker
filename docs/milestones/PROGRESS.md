# Progress

Resume log for milestone work. One line per step: what's done, what's next.

## Milestone 06 — ambient surfaces (Android only)

- 2026-08-18 — Read CLAUDE.md, milestone 06 spec, spec §7/§16, and the
  existing `TriggerBridge`/`AndroidTriggerBridge`/Android native trigger
  layer from milestones 01-03 (the contract and Android's foreground
  service/QS tile already existed; **nothing in the app called any of it**
  — `SessionController` was 100% manual-tap, matching its own doc comment).
  Two scope calls made with the user up front, both written up as ADRs:
  - **ADR-005**: iOS deferred again, same reason as milestone 01 (no paid
    dev account) — Android-only build.
  - **ADR-006**: the ambient card's "ended" state brings the app forward to
    the existing milestone-04 rep-entry sheet rather than adding inline
    weight-stepper/rep-quick-pick controls to the notification itself —
    resolves a real tension between the milestone doc's build list and its
    own "must hold" section. Keeps `TriggerEventType` at exactly
    `setStarted`/`setEnded`, no payload growth, no custom `RemoteViews`.
  - Built the wiring: `lib/bridge/trigger_apply.dart` (`startSetFor`/
    `endSetFor`/`buildTriggerContext` — single source of truth shared by
    manual taps and drained events, so prefill logic can't drift between
    them), `lib/bridge/trigger_drain_service.dart` (`TriggerDrainService`,
    called on cold start and app resume in `main.dart` via
    `WidgetsBindingObserver`, before first render per §7). `SessionController`
    now calls `updateAmbientSurface` after every state-changing method (all
    routed through one `_reload()`/`_syncAmbient()` hook) and
    `stopAmbientSurface`/`clearContext` on `endSession` — best-effort,
    wrapped so a notification-channel failure never blocks the DB write.
  - `TriggerActionReceiver`/`TriggerQsTileService` (Kotlin): a toggle press
    that just appended `setEnded` now calls the new `TriggerAppLauncher.
    bringForward` — satisfies "must hold" from both the notification and
    the QS tile.
  - Home screen: `lib/features/home/ambient_banners.dart` +
    `_AmbientBannerList` — the ambient unresolved-gap row from spec §12,
    sitting above whatever `HomeState` is showing, dismissible, never a
    modal (I3). Covers phantom-set discard (`WorkoutSet.isPhantom()`,
    already existed from milestone 03 — just needed surfacing) and the
    capability-upgrade offer (shown once `completedSessionCount() >= 3`,
    dismiss is in-memory only for now — no schema change for a one-time
    banner).
  - **Two real bugs found and fixed by on-device verification, not by the
    test suite**:
    1. `AndroidTriggerBridge` had been calling
       `getApplicationDocumentsDirectory()` since milestone 02/03, which on
       Android resolves to `context.filesDir/app_flutter/` — **not**
       `context.filesDir`, where `TriggerJournal.kt` actually reads/writes.
       Every `writeContext`/`drain` call had silently been operating on a
       directory the native side never looked in. Existing tests never
       caught it because they fake `getApplicationDocumentsPath()` directly,
       so the fake and the (wrong) production call always agreed with each
       other. Fixed to `getApplicationSupportDirectory()` (the same call
       `AppDatabase` already uses for the sqlite file) and hardened
       `test/bridge/android_trigger_bridge_test.dart`'s fake to serve both
       paths to *different* directories, so a regression back to the wrong
       call fails the suite instead of only showing up on a real device.
    2. Actually starting the ambient surface crashed the app outright the
       first time this milestone made anything call it:
       `foregroundServiceType="health"` requires a granted
       ACTIVITY_RECOGNITION-or-similar permission on this SDK, not just a
       declared one, and starting with no type at all once the manifest
       declares specific types is *also* rejected. Fixed with a `dataSync`
       fallback type (declared alongside `health` in the manifest) so the
       service degrades gracefully instead of crashing when that
       permission hasn't been granted yet, plus requesting
       POST_NOTIFICATIONS and ACTIVITY_RECOGNITION together in one call
       (firing `requestPermissions` twice back-to-back in `onCreate` was
       silently dropping the second dialog).
    3. `TriggerDrainService.drainAndApply()` writes directly through the
       repositories, bypassing whatever `SessionController` instance might
       already be alive for that session (e.g. the user backgrounded the
       app mid-session instead of fully closing it) — that live instance
       never learned its data changed. Fixed by invalidating
       `sessionControllerProvider(landing.sessionId)` alongside
       `homeStateProvider` in `main.dart`'s drain handler.
  - **Verified for real**, not just unit-tested: built the debug APK,
    installed on the Pixel 9a emulator, and drove the actual failure mode
    the milestone's Done-when describes — wrote `setStarted`/`setEnded`
    lines directly into the on-device `events.jsonl` (standing in for the
    native trigger, since this environment can't press a real notification
    button on a locked screen), backgrounded and re-foregrounded the app,
    and confirmed: the ledger updated from "4 of 4 outstanding" to "3 of 4",
    the app landed directly on the rep-entry sheet for Hip thrust set 1
    with zero taps, and the persisted `WorkoutSet.duration` was exactly 52s
    — matching the injected journal timestamps, not wall-clock drain time.
  - `flutter analyze` clean, `flutter test` 38/38 green — new
    `test/bridge/trigger_drain_service_test.dart` covers the same scenario
    end-to-end against a real (in-memory) `SessionRepository`: journal
    timestamps win over drain time, exercise attribution is correct, and a
    second drain with nothing pending is idempotent (no duplicate set).
  - **Not built**: iOS (ADR-005), the inline notification stepper/quick-picks
    (ADR-006 — deliberately resolved toward the existing rep-entry sheet
    instead), and persisted dismissal for the capability-offer banner
    (in-memory only, resets each app run — cheap to add a kv row later if
    that turns out to matter).

## Visual pass — screens.html design system applied (post-milestone-05)

- 2026-08-18 — User flagged that milestones 04/05 matched screens.html's
  *structure* (ledger, five states, hollow predictions) but not its actual
  *visuals* — the app was still running stock Material 3 light purple, not
  the dark theme/typography the mockup defines. Pulled every design token
  out of `docs/screens.html`'s `:root` CSS and applied them for real:
  - `lib/theme.dart` (new) — `AppColors` (the exact hex values from
    `:root`), `appRadius` (10px, the one radius the mockup uses almost
    everywhere), `monoStyle()`/`eyebrowStyle()` helpers, and
    `buildAppTheme()` wiring dark `ColorScheme` + per-widget themes
    (filled/outlined/text buttons, chips, inputs, bottom sheets) so most
    screens pick up the right look for free just by using stock
    `FilledButton`/`OutlinedButton`/`TextField`/`FilterChip`.
  - Added `google_fonts` (Archivo + IBM Plex Mono, matching the mockup's
    own Google Fonts `<link>` tags) — the one new dependency, deliberate:
    hand-bundling the `.ttf` files as assets was the alternative and
    strictly more manual for the same result.
  - `lib/widgets/elapsed_pill.dart` — restyled to the mockup's `.pill`
    (accent-bg/accent-ink), used identically by both the session header
    and the home in-progress card.
  - `lib/features/session/session_screen.dart` — full rewrite of the
    ledger's visuals: `.sethead` column labels, `.setrow`/`.c-i`/`.c-w`/
    `.c-r` mono columns, the `.setrow.live` accent-pill treatment (now a
    shared `_LiveRow` wrapper) for whichever row is currently actionable
    (start/running/pending-reps), `.hollow` stroke-only text for
    unconfirmed predictions (ink3 stroke, not accent — matches the CSS
    exactly), `.side` suffix on per-limb weights, `.tag` chips (now public
    `AppTag`, reused for both the exercise-level "uni" marker and per-set
    tags).
  - `lib/features/session/rep_entry_sheet.dart` — full rewrite: custom
    `_StepGlyph`/`_PickChip`/`_ToggleChip` widgets replacing the earlier
    generic `IconButton`/`ChoiceChip`/`FilterChip`, because Material's
    default chip padding/shape didn't read as the mockup's flat bordered
    buttons. `entry-lbl` spacing, `.stepper` container, `.pick`/`.pick.on`
    reps buttons, `.btn-q`-shaped tag toggles.
  - `lib/features/home/home_screen.dart` — full rewrite: `.eyebrow`/
    `.scr-title`/`.scr-sub` header pattern per state, `.lrow` ledger rows
    (new shared `_LedgerRow`) with `dim` (opacity .42, notStarted
    exercises) and accent-highlighted current-exercise treatment.
  - `lib/features/session/exercise_picker_sheet.dart` — lighter touch:
    eyebrow section headers, themed search field, ink-colored list text.
  - One real regression caught by the widget-test rerun: `_WeightText`'s
    two-tone weight+`/side` rendering used `RichText`, which `find.text`
    doesn't match by default — fixed by exposing a shared `_LoadText`
    widget (used by every row, including the not-yet-started prediction
    row, which had silently lost its `/side` suffix in the same refactor)
    and updating the one assertion to `find.text(..., findRichText: true)`.
  - `flutter analyze` clean, `flutter test` 37/37 green. Manually driven
    end-to-end on the Pixel 9a emulator (uninstall → fresh install →
    Planned → Start → running row → pending-reps row → full rep-entry
    sheet) confirming the actual rendered screens now match
    `docs/screens.html`'s dark theme, mono numerics, and pill/chip/hollow
    treatments — not just the mockup's information architecture.
  - **Not done**: the exercise picker sheet's visual pass was intentionally
    lighter (no full `.field`/`.opt` card treatment) since it's a smaller,
    less load-bearing screen; revisit if it starts looking inconsistent
    next to the two screens that got the full treatment.

## Milestone 05 — home screen (five states)

- 2026-08-18 — Read CLAUDE.md, milestone 05 spec, spec §12, and
  screens.html flow 02. Built the whole thing:
  - `lib/domain/rules/home.dart` — pure `HomeState` sealed class
    (`NoPlanYet`/`RestDay`/`PlannedNotStarted`/`InProgress`/`Done`) +
    `computeHomeState`. Deliberately scoped: the pure function only decides
    Planned/InProgress/Done for a day already known to be scheduled today —
    Rest-day and No-plan-yet need day-name lookups that would otherwise
    drag a repository into a function that's supposed to be `dart test
    test/domain`-testable without Flutter.
  - `lib/features/home/home_providers.dart` — `homeStateProvider`
    (`FutureProvider`) does the repository fetching and the two branches
    that need it, then hands off to `computeHomeState` for the rest.
  - `lib/features/home/home_screen.dart` — pattern-matches on `HomeState`
    (Dart 3 `switch` over the sealed class, per CLAUDE.md's "sealed class +
    pattern matching over enums-with-fields"). Start/Resume/"Just start"
    all funnel through `_openSession` which pushes the existing
    `SessionScreen` (milestone 04, unchanged) and invalidates
    `homeStateProvider` on return so the card is never stale after a trip
    into the session.
  - **Scope cut, matches spec's own escape hatch**: "No plan yet" only
    offers "Just start — I'll improvise" (spec §5: "never gate the workout
    behind declaring it"). No upfront exercise-name-input UI — that would
    duplicate the exercise picker already built into the session screen in
    milestone 04, which is reachable the moment an improvised session
    opens. Flagged in a comment on `NoPlanYet`.
  - Small necessary additions: `SessionRepository.mostRecentSession`
    (rest-day's "last session" summary — reads `workoutDayId` only to name
    the day, never to filter analytics, so still I1-clean);
    `workoutDayProvider` (home's in-progress/done cards want target set
    counts and the day name, display-only, same I1 note).
  - Extracted `_ElapsedPill` out of `session_screen.dart` into
    `lib/widgets/elapsed_pill.dart` as public `ElapsedPill` — home's
    in-progress card needed the identical ticking mm:ss pill, and
    duplicating the whole `Timer`-backed `StatefulWidget` across two files
    would've been the kind of copy nothing was reusing later.
  - `lib/main.dart` — now bootstraps a `WeekPlan` (today's weekday →
    the milestone 04 demo Legs day) alongside the existing exercise seed
    and demo `WorkoutDay`, and launches into `HomeScreen` instead of
    dropping straight into a session. `SessionScreen` gained a back button
    (`session_screen.dart`) since it's now pushed via `Navigator` instead
    of being the app's root.
  - `flutter analyze` clean, `flutter test` 37/37 green — 4 new domain
    tests (`test/domain/home_rules_test.dart`, including a literal
    "force-quit mid-set, read fresh from the DB, elapsed time is still
    correct" case) and 4 new widget tests
    (`test/features/home/home_screen_test.dart`: planned/rest/in-progress/
    done, the in-progress one being the milestone's actual Done-when —
    build a fresh widget tree over an already-persisted open session and
    confirm it lands on Resume with the right elapsed pill, which is
    exactly what a force-quit-and-reopen looks like since nothing here
    depends on in-memory app state). Also manually driven end-to-end on
    the Pixel 9a emulator (uninstall → fresh install → Planned-not-started
    → Start → back button → In-progress with correct target-set
    denominators and a live elapsed pill) — caught and fixed one real bug
    this way: the in-progress ledger was showing `0 · 0` (actual sets over
    actual sets) instead of `0 · 3` (actual sets over the day's planned
    target) before `workoutDayProvider` was wired in.
  - **Not built**: the ambient unresolved-gap row (needs the observation
    layer, milestone 09) and any real onboarding-driven plan (still the
    milestone 04 demo bootstrap — real per-user plans arrive in milestone
    07).

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

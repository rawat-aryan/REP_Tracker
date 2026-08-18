# REP Tracker

A workout logger built around one bet: the fastest possible set-logging loop.
Press a trigger, do the set, press again, tap one rep button. The phone stays in
your pocket.

## Start here

| File | What it's for |
|---|---|
| `CLAUDE.md` | Loaded every turn. Invariants, stack, conventions. |
| `docs/spec.md` | The full product spec. The source of truth. |
| `docs/screens.html` | Every screen, designed. Open in a browser. |
| `docs/milestones/` | Build order, riskiest first. One at a time. |
| `docs/decisions/` | ADRs for anything the spec doesn't settle. |

## Already written

- `lib/domain/models/` — the data model, pure Dart, heavily commented with the
  reasoning behind each shape. **Read the comments before changing anything.**
- `lib/domain/rules/` — prefill, increment resolution, e1RM, overlap detection.
- `lib/bridge/` — the native trigger contract.
- `assets/seed/exercises.json` — 50 seeded exercises. Extend toward ~150.

## Getting going

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
```

Then in Claude Code:

```
/milestone
```

Start with `docs/milestones/01-ios-trigger-spike.md`. It has no UI and no
database on purpose — it's the riskiest part of the build and should fail fast
if it's going to fail.

## Slash commands

- `/milestone` — pick up the next milestone with a plan-first workflow
- `/check-invariants` — audit a diff against the seven invariants

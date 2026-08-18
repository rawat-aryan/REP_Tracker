# ADR-005 · iOS deferred again for milestone 06

**Status:** accepted · **Date:** 2026-08-18

## Context

Milestone 06's build list asks for, per platform: `TriggerBridge` on both
iOS and Android, a Live Activity + Dynamic Island (compact and expanded) on
iOS, and Tier 1's Control Center control on iOS 18+.

Milestone 01 (the iOS trigger spike) was already deferred with the same
reason: no paid Apple Developer account. That has not changed. Live
Activities need a real device + provisioning to test meaningfully, Dynamic
Island layouts can't be verified in this environment at all, and Control
Center controls (iOS 18+) are gated the same way. Attempting the iOS half
now would produce code nobody can build, sign, or run — worse than not
writing it, since untested platform code reads as done when it isn't.

## Decision

Milestone 06 ships **Android-only**:

- `AndroidTriggerBridge` (already built, milestone 02/03) gets wired into
  the real session flow — `writeContext`/`updateAmbientSurface` on every
  state change, `drain()` on resume and cold start (§7).
- The Android foreground notification (Tier 0) and QS tile (Tier 1) get the
  behavior milestone 06 actually requires — see ADR-006 for the "ended
  state" decision specifically.
- `TriggerBridge` stays the platform-agnostic contract it already is (§7 is
  written that way on purpose). No iOS implementation is added; there is
  still no `ios/Runner/*Trigger*` code beyond the stock `AppDelegate`/
  `SceneDelegate` scaffold.

## Consequences

- iOS users get zero ambient surface until this is picked back up — no
  Tier 0 baseline, let alone Tier 1/2. The app is Android-only in practice
  for anyone relying on the trigger, which is the entire point of the
  product.
- Every abstraction that would make an iOS implementation slot in later
  (the `TriggerBridge` interface, `TriggerContext`/`TriggerEvent` as plain
  JSON-shaped classes, the two-file contract itself) already exists and is
  untouched by this milestone. Adding iOS later is "implement the
  interface," not "redesign the contract."

## Revisit if

A paid Apple Developer account is available. At that point milestones 01
and 06's iOS halves should be picked up together — Live Activities are hard
to get right without device testing, and there's no benefit to splitting
the spike from the integration this time.

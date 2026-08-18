# ADR-002 · A trigger ladder, not one mechanism

**Status:** accepted · **Date:** 2026-08-18

## Context

No single fast-logging mechanism is available on every device. Candidates were
evaluated in spec §16.

## Decision

Four tiers, **all writing the same `events.jsonl`**, so the app never knows
which one fired:

- **0** Ambient card (universal, zero setup) — the product's baseline
- **1** Control Center control / Quick Settings tile — parity layer
- **2** Action Button (iOS) / floating overlay (Android) — platform best
- **3** Watch app — post-v1

## Rejected

- **Earbud / media buttons** — the audio session belongs to Spotify. Stealing it
  with silent audio breaks the user's music and fails review. Structurally
  unavailable on both platforms.
- **Android OEM buttons** (OnePlus Plus Key, Nothing Essential Key) — wired to
  first-party functions, cannot signal third-party apps. Apple's Action Button
  works only because it routes through Shortcuts, a public automation layer
  Android has no equivalent of.
- **Back Tap** — misfires when racking a barbell; setup buried in Accessibility.
  Offer it, never default to it.
- **Volume buttons, motion detection, voice** — unreliable, unusable, or both.

## Consequences

Tier 0 must be excellent on its own, not a degraded mode. If a user configures
nothing, Tier 0 **is** the product.

The Android foreground-service justification for Play review is a real risk to
Tier 0 on that platform. Validate in milestone 02.

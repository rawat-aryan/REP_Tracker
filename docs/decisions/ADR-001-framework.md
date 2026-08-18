# ADR-001 · Flutter with native modules per platform

**Status:** accepted · **Date:** 2026-08-18

## Context

Every differentiating surface — the trigger, the ambient card, Live Activity /
foreground notification, Control Center / Quick Settings, and a future watch app
— is platform-native. That argued for two native apps. Against it: the product
logic (data model, prefill, observation, analytics) is substantial, subtle, and
identical on both platforms.

## Decision

Flutter for the app, with native modules per platform for the trigger layer.

Tiers 0 and 1 of the trigger ladder are ~85% shared logic behind thin native
shims. The genuine divergence is Tier 2 (Action Button vs floating overlay),
which is small and cleanly isolated behind the `events.jsonl` contract.

## Consequences

- The bridge in `lib/bridge/` is load-bearing and must stay narrow. Anything
  that leaks platform concepts into `domain/` is a regression.
- `domain/` must not import `package:flutter`.
- If Tier 2 grows past a couple of screens per platform, revisit this.

## Revisit if

The native surface grows to where the bridge costs more than it saves, or a
watch app makes native-per-platform the cheaper path.

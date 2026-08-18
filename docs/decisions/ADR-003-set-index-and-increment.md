# ADR-003 · Set index convention, and a fix to increment resolution

**Status:** accepted · **Date:** 2026-08-18

## Context

Two things came up while building milestone 03 (data layer) that the spec
doesn't pin down, or gets a test wrong for.

### 1. Set index: stored or derived, and 0- or 1-based?

Spec §3.3 and milestone 03 both say the positional index must never be a
stored typed field — "don't trust a stored value to stay correct after a
delete." But *something* has to record row order, and *some* base (0 or 1)
has to be chosen for `WorkoutSet.index` and the `setIndex` parameter on
`PrefillService`. Neither is written down.

### 2. `resolveIncrementKg` doesn't hit the milestone's own test

Milestone 03 requires `resolveIncrementKg` to return 5 for loads
`[40, 60, 75]`. The existing implementation computed the smallest adjacent
difference among sorted loads — for `[40, 60, 75]` that's `min(20, 15) = 15`,
not 5. No difference between any two of these three values is 5; only the
**GCD** of the differences (`gcd(20, 15) = 5`) matches. The physical
justification: 40 → 60 → 75 are all reachable in 5 kg steps even though no
two *consecutive visits* happen to be exactly 5 kg apart.

## Decision

**Set index is 1-based.** "Set 1" has `index == 1`. This matches the
reference log's own language and the milestone's ham-curl test
(`executionFor(setIndex: 1)` → unilateral, matching "set 1"; `setIndex: 2`
→ bilateral, matching "sets 2-3"). `PrefillService.loadFor/repsFor/
executionFor` take a 1-based `setIndex` throughout.

**Row order is derived from an insertion-order `seq` column**, not SQLite's
implicit rowid and not a hand-maintained index. `WorkoutSets.seq` and
`SetSegments.seq` are `DateTime.now().microsecondsSinceEpoch` at insert
time; `SessionRepository` orders by `seq` and enumerates to assign
`WorkoutSet.index` on every read. A mid-list delete can never leave a stale
index behind, because no index is ever stored.

**`resolveIncrementKg` uses the GCD of consecutive sorted differences**, not
the minimum difference. Implemented as `_gcdKg` in
`lib/domain/rules/prefill.dart`. The floor-to-equipment-default guard
(reject anything under 1 kg) is unchanged, applied to the GCD instead.

## Consequences

Any future code that talks to `SessionRepository`/`PrefillService` must
treat `setIndex` as 1-based — a 0-based caller will silently read one set
off. Worth flagging explicitly in the milestone 04 (session screen) review,
since that's the first UI code that will call these methods with a literal
set position.

The `resolveIncrementKg` fix touches pre-existing domain code that predates
this session. The change is behavior-preserving for every case except loads
whose pairwise differences share a common factor larger than their minimum
difference — which is exactly the case the milestone's test was written to
catch.

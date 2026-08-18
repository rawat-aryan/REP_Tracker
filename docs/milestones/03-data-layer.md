# 03 · Data layer

Drift schema, DAOs, repositories, and the exercise seed. Pure logic — no screens.

## Build

1. Drift tables mirroring `lib/domain/models/`. Keep the domain models
   framework-free; map at the repository boundary.
2. Repositories: `ExerciseRepository`, `SessionRepository`, `PlanRepository`,
   `BodyweightRepository`.
3. Implement `PrefillService` from `lib/domain/rules/prefill.dart`.
4. Load `assets/seed/exercises.json` on first run.
5. Unit tests for every rule in `domain/rules/`.

## Non-negotiable

- **I1**: no repository method that returns history, prefill, PRs or chart data
  may accept a day, plan or weekday parameter. Enforce it in the signatures —
  if the parameter isn't there, the violation can't be written.
- **I4**: no `NOT NULL` on reps, weight, or anything a hurried user might skip.
- **I7**: `archived` flags, never `DELETE`.
- Weights stored in **kg**, always.
- Set index is **positional** — derive it from row order on read, don't trust a
  stored value to stay correct after a delete.

## Tests that must exist

- Ham curls case: set 1 unilateral @40, sets 2-3 bilateral @60/@75. Execution
  prefill returns unilateral for index 1 and bilateral for index 2.
- Drop set: one `WorkoutSet` with three segments and an `aggregateReps` of 50.
- `resolveIncrementKg` returns 5 for loads `[40, 60, 75]`, 2.5 for
  `[7.5, 10, 32.5]`, and floors a `[30, 30.5]` input to the equipment default.
- `exerciseOverlap` is order-independent.
- A set with weight and no reps round-trips through the DB.

## Done when

`dart test test/domain` passes and the seed loads on a fresh install.

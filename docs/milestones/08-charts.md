# 08 · Charts

See `docs/screens.html` flow 05 and `lib/domain/rules/analytics.dart`.

## Build

- Exercise detail: one chart, metric toggle `e1RM | volume | top set`.
- **Two series, always separated**: bilateral and unilateral, each with its own
  scale badge. **Do not normalise** — any multiplier is invented.
- Left/right divergence callout when `meanLimbDivergence` is material.
- Compare overlay: pick a second exercise, plot both on the same axes,
  visually distinct. This is how substitutions are read — never by merging.
- History heatmap: filled = logged, dashed = unresolved, muted = rest.

## Non-negotiable

**I1.** Every query here takes exercise IDs and a date range. Nothing else. If
a chart function needs a `WorkoutDay`, the design is wrong — stop and re-read
spec §11.

## Done when

The ham curls case renders as two separate lines and the chart does not show a
jump between the 40 kg unilateral set and the 60 kg bilateral set.

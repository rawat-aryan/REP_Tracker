# 09 · Observation layer

The `observing -> provisional -> confirmed` machinery. (I2)

## Build

- Day-status derivation: `unresolved` is the default for a gap and **never**
  becomes `missed` on its own.
- Retroactive resolution: tap any heatmap square, pick what it was. Works for a
  gap six weeks old.
- Ambient resolution row on home, dismissible.
- Provisional day headers: `Legs? · tap to confirm`, pre-populated but visibly
  tentative, from cycle two.
- Duplicate-day detection using `exerciseOverlap`, with the thresholds in
  `analytics.dart`.
- Pattern detection on **frequency across cycles**, not most-recent occurrence,
  requiring a change to hold **twice in a row** before proposing anything.

## Non-negotiable

- **I3**: everything here surfaces on the home screen. Nothing prompts
  mid-session.
- Nothing is applied as an edit. Everything is proposed as a question.
- Once answered, never ask again for that pair.
- Split-forward only. Never retroactively reassign past sessions.

## Test with

Synthetic fixtures: six weeks of PPL with one travel week displacing Pull from
Wednesday to Thursday. The detector must **not** propose moving Pull.

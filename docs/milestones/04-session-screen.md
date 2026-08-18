# 04 · Session screen

The screen that has to be right. See `docs/screens.html` flow 03.

**Manual logging only.** No native trigger yet — a tap starts and ends a set so
the screen is testable standalone.

## Build

- The **ledger table**: exercise name, then rows of `index | weight | reps`.
  Four lines per exercise. Not cards — density is the point. It should be as
  compact as the Notes log it replaces.
- **Hollow-to-solid**: predicted values render outlined
  (`-webkit-text-stroke` equivalent — use a `Text` with a stroked `TextStyle`
  or a custom painter). Confirming fills them solid.
- Weight stepper with the learned increment; long-press jumps a plate pair.
- Rep quick-picks, four wide, prediction highlighted, overflow to full entry.
- Full entry screen: stepper, L/R rows, tag chips, keypad.
- Exercise picker: today's outstanding first, learned substitutes second,
  library search last.

## Session-as-a-pool behaviour

- The list **never reorders itself.** Only the current highlight moves.
- Tap any exercise to make it current. No confirmation, no prompt, no penalty.
- Closing a set proposes `session.nextOutstanding`.
- Several exercises may be `inProgress` at once.
- Nothing is ever required. (I4)

## Done when

- A full Legs session from `docs/spec.md` §1 can be logged, including the
  unilateral hip thrust set and the `Single -40` ham curl.
- Deferring incline BP, doing flies, and returning works with zero prompts.
- Rotating the device mid-set loses nothing.

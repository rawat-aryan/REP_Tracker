# 10 · Exercise library

## Build

- Search matching `name` **and** `aliases`, results first, "create custom" a
  quiet last option below them. Every time someone taps create-custom for an
  exercise that already exists, a growth curve silently forks.
- **Merge**: pick two exercises, keep one ID, repoint every set. Ship this in
  v1 — users will fork entries anyway (typos, distraction), and without merge
  you eventually ask them to abandon history to fix a typo.
- Archive, never delete. (I7)
- Editable increment override, defaulted to the learned value.
- Variant pointer (`variantOf`) shown as a compare suggestion, never a merge.

## Done when

Merging two exercises leaves every historical set intact under the surviving ID
and no chart shows a gap.

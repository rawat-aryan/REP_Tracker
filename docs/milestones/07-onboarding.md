# 07 · Onboarding

Three screens, under a minute. See `docs/screens.html` flow 01.

1. Name + bodyweight
2. Archetype picker (or skip)
3. Week grid — day names, weekday assignment, rest days

## Rules

- **No exercises are asked for.** They fill in from logged sessions.
- **No weights or reps, ever, on any planning screen.** Target set count is the
  deepest a plan screen goes.
- Store the **map**, not the archetype. There is no `SplitType` enum.
- Rest days render as **dashed outlines**, never filled chips.
- The week screen is **not** an onboarding-only wizard step — the same screen
  becomes the day editor later, with exercise lists populated.

## Done when

A new user reaches the home screen in under 60 seconds, and the week screen is
reachable afterwards from settings with the same code path.

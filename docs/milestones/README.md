# Milestones

Numbered in build order. Do one at a time. Each has a **Done when** section —
treat it as the acceptance test, and run `flutter analyze` + `flutter test`
before declaring it done.

The order is **riskiest first**. The trigger spike comes before any UI, because
if the platform fights you that should surface in week one, not week six.

| # | Milestone | Why it's here |
|---|---|---|
| 01 | iOS trigger spike | Highest technical risk. No UI. |
| 02 | Android trigger spike | Second-highest. Foreground service is a Play review risk. |
| 03 | Data layer | Everything else depends on it. |
| 04 | Session screen | The screen that has to be right. |
| 05 | Home screen | Five states, one card. |
| 06 | Ambient surfaces | Wires 01/02 into the real app. **This is the product.** |
| 07 | Onboarding | Deliberately late — it's the least interesting screen. |
| 08 | Charts | |
| 09 | Observation layer | Needs weeks of real data to test properly. |
| 10 | Exercise library | Search, aliases, merge, archive. |

Milestones 03-05 give a usable app. Milestone 06 is the product.

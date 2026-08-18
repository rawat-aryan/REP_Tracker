# 05 · Home screen

Five states, one card, one action each. See `docs/screens.html` flow 02.

| State | Primary action |
|---|---|
| Planned, not started | Start |
| **In progress** | Resume |
| Done | none (summary, still editable) |
| No plan yet | Start / just start |
| Rest day | none |

## In progress is the one that matters

Because the trigger sits outside the app, the user leaves and re-enters
constantly — the phone locks between sets, they open Spotify, they check a
message. **Every return lands here.** It must show the running timer, the
current exercise and set, and get back into the session in one tap. If it
renders like "not started," the whole flow feels broken.

It must also survive a force-quit: session state lives in shared storage, not
in Dart memory.

## Also

- Rest day gets **no call to action**. Resisting a "log something anyway"
  button is what makes rest read as rest.
- The ambient unresolved-gap row sits above any state, dismissible, never a
  modal. (I3)
- Done never locks. (I5)

## Done when

Force-quitting mid-set and reopening lands on `in progress` with the correct
elapsed time.

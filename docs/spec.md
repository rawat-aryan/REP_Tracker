# REP Tracker — product & workflow spec

Version 0.1 · 18 Aug 2026
Status: design settled, pre-implementation

---

## 1. What this is

A workout logger built around one bet: **the fastest possible set-logging loop.**

The user presses a physical button to start a set, does the set, presses again to
end it, types reps, and continues. The phone stays in their pocket. Weight is
prefilled from last time. Nothing else in the app matters as much as those four
seconds.

Everything the user knows in advance (which exercises today) is asked for up front.
Everything discovered at the rack (weight, reps, duration) is captured during the set.

### The reference format

The whole design is derived from how the user already logs in the Notes app:

```
Date: 10 Aug 2026
Legs
Hip thrust
  Set-weight            Rep
  1-10                  10 warmup
  2-30 single side      L-8 R-8
Ham curls
  Single -40            L-8 R-8
  60                    8
  75                    9
```

Two columns, four lines per exercise, no chrome. The in-app session screen is a
denser version of this table — **not** the fat per-set cards that Strong and Hevy use.

### What is not the USP

The routine builder. Every competitor has one and users spend ~2% of their time in it.
Build it as the dumbest thing that works. Spend the effort on the logging loop, which
fires 40+ times per session.

### The differentiators worth claiming

1. Sub-3-second logging via a physical trigger and an ambient live timer.
2. **Left/right divergence tracking.** Because L and R reps are stored separately,
   the app can surface "your left ham curl has been 1–2 reps behind your right for
   six weeks." Nobody else does this and the data is already there.
3. Exercise history that is continuous across every split change, forever.

---

## 2. Non-negotiable invariants

These go in `CLAUDE.md` verbatim. Violating any of them breaks the product.

### I1 — Analytics never reads the plan

> A logged set references an exercise ID and nothing about the plan.
> No query that produces history, prefill, PRs, or charts may read
> `WorkoutDay`, `WeekPlan`, or weekday. **Planning reads the plan; analytics reads the log.**

The tempting violation is prefill: "the last time I did hip thrust *on Legs day*."
That single scoping breaks history the first time the split changes.

### I2 — The app observes, it does not infer

No pattern is ever committed without user confirmation. Three explicit states:
`observing` → `provisional` → `confirmed`. Guesses are always visibly marked as guesses.

### I3 — Nothing interrupts a session

Duplicate detection, day-split prompts, unresolved-gap resolution, pattern
confirmations — all queue and surface on the home screen afterwards. Never a
mid-workout modal.

### I4 — No required fields, anywhere

An exercise with zero sets must save. A set with a weight and no reps must save.
The user's own log contains `Bicep — Done` with no numbers. That must be legal.
Validation friction causes skipped logging, and gaps are worse than fuzzy data.

### I5 — Nothing is ever read-only

Any past session, set, or day status stays editable forever. Reconstructing three
weeks of travel a month later is a normal thing to want.

### I6 — One writer to the database

The app process owns the database. The trigger layer is a dumb event producer that
never touches it. Never two clients writing the same store.

### I7 — Never delete, always archive

Exercises, days, and routines are archived, never deleted. History must never
dangle.

---

## 3. Data model

### 3.1 Exercise

The keystone. Splits churn; exercises don't.

```text
class Exercise {
  String id;              // slug for seeded ("hip_thrust"), UUID for custom
  bool isCustom;
  String name;                  // freely renamable — the ID is the identity
  List<String> aliases;         // "Incline BP", "incline bench"
  Muscle primaryMuscle;
  List<Muscle> secondaryMuscles;
  Equipment equipment;          // barbell, dumbbell, machine, cable, bodyweight, band
  Execution defaultExecution;   // bilateral | unilateral
  String? variantOf;            // Exercise.id — enables compare-overlay, not merging
  bool archived;
}
```

**Two ID spaces.** Seeded exercises get stable human-readable slugs shipped
identically in every install — safe to reference in seed data, migrations, and
future cloud sync. Custom ones get UUIDs. Generating UUIDs for seeds makes v1.2
seed updates guesswork.

**Ship ~150 seeded exercises.** An afternoon of data entry that permanently protects
analytics. Without it, `Incline BP` / `incline bench` / `Incline Bench Press` become
three unrelated growth curves within a month, which silently destroys the one
feature the app exists for.

**Merge must exist from v1.** Users will fork entries anyway — typos, distraction at
the gym. Exercise library needs a merge action: pick two, keep one ID, repoint every
set. Without it you eventually ask people to abandon history to fix a typo.

**Variants stay separate.** `Incline bench press` is its own exercise with
`variantOf: bench_press`, not a flag on bench press. Numbers genuinely differ, so
separate curves is correct. The pointer powers a compare-overlay, not a merge.

### 3.2 Load and reps — the messy part

The user's own notation contains at least six distinct shapes. Two orthogonal enums
cover all of them; one combined "weight type" enum does not.

```text
enum Execution { bilateral, unilateral }   // one limb at a time?
enum LoadScope { total, perLimb }          // is the number per limb?

class Load {
  double? value;        // null for pure bodyweight
  LoadUnit unit;        // kg | lb
  LoadSource source;    // barbell, dumbbell, machineStack, bodyweight,
                              // bodyweightAdded, band, cable
  LoadScope scope;
}
```

| Notation | Execution | LoadScope | value |
|---|---|---|---|
| `Single -40` ham curl | unilateral | perLimb | 40 |
| `60` ham curl | bilateral | total | 60 |
| `10 db each` seated row | bilateral | perLimb | 10 |
| `2-30 single side` hip thrust | unilateral | perLimb | 30 |
| `1-bw` lunges | unilateral | total | null |
| `50 machine 1/2` | bilateral | total | 50 |

**Execution lives on the set, not the exercise.** Proven by the user's own ham curls:
set 1 unilateral at 40, sets 2–3 bilateral at 60 and 75. Same exercise, same session.

### 3.3 Set and segments

```text
class SetSegment {              // drop sets = multiple segments in ONE set
  Load load;
  int? reps;              // null when only an aggregate is known
  int? repsLeft;
  int? repsRight;
}

class WorkoutSet {
  String id;
  String exerciseId;      // the only link analytics needs
  int index;              // POSITIONAL — derived from row order, never typed
  Execution execution;
  List<SetSegment> segments;
  int? aggregateReps;     // "total 50 reps" across a drop
  Set<SetTag> tags;       // warmup, dropSet, toFailure, myoRep, pause
  String? tempo;          // "4-sec pause"
  DateTime? startedAt;    // from the event journal
  DateTime? endedAt;
  String? note;
}
```

**Drop sets are one set with N segments**, not N sets. That's how the user thought
about it when writing `3- 7.5, 5, 2.5 drop → Total 50 reps`, and it keeps
index-based prefill from shifting.

**Set index is positional.** The user's notes drop the numbering entirely for ham
curls. Row order is the number. Never make it a typed field — reordering or deleting
a set would corrupt everything after it.

**"Set-weight" is three things.** The Notes column silently merges set index, load,
and mode. In the app: index is an implicit gutter, load is a clean number, and mode
(`/side`, `each`, `drop`, `bw`) is a chip on the row. `2-30 single side` is
unparseable; `{load: 30, scope: perLimb, execution: unilateral}` is not.

### 3.4 Session

```text
class Session {
  String id;
  DateTime date;
  String? workoutDayId;     // null for an unplanned/improvised session
  String? routineVersion;   // snapshot for deviation analysis
  List<String> intendedExerciseIds;   // declared before starting
  List<SessionExercise> exercises;    // what actually happened
  DateTime startedAt;
  DateTime? endedAt;
}
```

Multiple sessions per date are allowed (morning legs, evening arms). Cheap now,
painful to retrofit.

### 3.5 Plan

```text
class WorkoutDay {
  String id;              // STABLE FOREVER
  String name;                  // "Legs", "Legs B", "Quad day" — purely cosmetic
  List<PlannedExercise> exercises;
  bool archived;
}

class WeekPlan {
  String routineId;
  int version;                    // versioned, never mutated in place
  Map<Weekday, String?> slots;    // weekday → WorkoutDay.id, or null = rest
}
```

**The day name is cosmetic. Muscle coverage is derived** from the `primaryMuscle`
of the exercises actually logged. So the user names days however they like, and
volume-per-muscle analytics still work.

**Never mutate a routine in place — version it.** Each session snapshots
`routineId + version`. Editing the routine in October must not rewrite September's
history.

**There is no `SplitType` enum.** "PPL but I start with legs" is just an assignment
of days to weekday slots. The archetype picker is a one-screen shortcut that writes
a map and then forgets itself. Persisting the archetype leads to
`if (archetype == ppl)` branches six months in.

### 3.6 Day status

```text
enum DayStatus { logged, unresolved, rest, missed, movedTo }
```

`unresolved` is the default for a gap and means *the app doesn't know yet*. It never
becomes `missed` on its own.

`movedTo` is distinct from `logged` so the pattern detector can tell displacement
(travel, work) from a genuine schedule change.

### 3.7 Bodyweight

A time series, not a profile field. `1-bw` pull-ups and lunges have a real load —
the user's bodyweight on that date. Makes bodyweight-exercise e1RM real math instead
of null.

---

## 4. Onboarding

Three fields. Under a minute. Nothing in it can be wrong, because nothing in it is
recalled from memory.

```
1. Name, bodyweight
2. Pick an archetype (PPL / bro split / two-muscle / hybrid) — or skip
3. Confirm the week grid: rename any day, reorder, mark rest days
4. Done → into the app
```

**No exercises are asked for.** Asking for exercises + set count + weight + reps
would be ~60 numeric fields before the first rep, and would seed the app with
misremembered numbers on day one.

**Age, height, and goals are cut** unless something consumes them. If "build muscle"
vs "get stronger" doesn't change app behaviour (rep-range targets, default chart
metric), it's a survey question dressed as a setting.

### Archetype → suggested week map

| Archetype | Suggested map |
|---|---|
| PPL | 6 training days cycling Push/Pull/Legs, 1 rest |
| Bro split | Chest · Back · Shoulders · Arms · Legs |
| Two-muscle | Chest+Tri · Back+Bi · Legs · Shoulders+Arms |
| Hybrid | Blank grid, name the days yourself |

Store the **map**, not the archetype. The user assigns any day to any weekday and
names it freely.

### 4.1 The week screen

One screen serves two phases, which is why it must not be built as an onboarding-only
wizard step.

```
┌──────────────────────────────────────────┐
│  Your week                               │
│  Weights get learned as you train        │
├──────────────────────────────────────────┤
│  [M] [T] [W] [T] [F] [S] (S)             │   ← S dashed = rest day
│                                          │
│  Legs                       5 exercises  │
│  ────────────────────────────────────────│
│  Hip thrust                      2 sets  │
│  Squats                          3 sets  │
│  Balancing lunges  [uni]          1 set  │
│  Ham curls                       3 sets  │
│  ＋ Add exercise                         │
└──────────────────────────────────────────┘
```

**Layout rules**

- Seven weekday chips in a row. Selected chip is filled; **rest days render as a
  dashed outline**, not as a filled chip — absence of training should look like
  absence, not like another option.
- Selecting a chip expands that day below. One day visible at a time; no accordion
  stacking.
- Exercise rows are a bordered list, not cards. Name left, set count right in
  monospace so the numbers form a scannable column.
- The `uni` tag marks an exercise whose sets default to unilateral execution. It is a
  default for new sets, **not** a constraint — §3.2 requires execution to remain
  per-set.
- `Add exercise` is a quiet row at the end of the list, not a floating button.
- The subtitle is load-bearing copy. `Weights get learned as you train` is what stops
  users hunting for weight fields that deliberately do not exist here.

**Two phases, one screen**

| Phase | What the day section shows | What is editable |
|---|---|---|
| **Onboarding (step 3)** | Day names only — empty exercise lists | Day names, weekday assignment, rest days |
| **Later (day editor)** | Exercises and set counts, learned from logged sessions | Everything, including add/remove/reorder exercises |

During onboarding the exercise list is empty and that is correct — §4 asks for no
exercises. The list fills itself in from real sessions (§5), and the same screen then
becomes the place to edit it.

**Never shown on this screen at any phase: weight, reps, or targets.** Set count is
the deepest this screen goes. Weight and reps belong to logged history and to the
session screen, never to the plan.


---

## 5. The intent list — how plans emerge

The key mechanism. Splits what the user knows in advance from what they discover at
the rack.

**Before the session:** the app asks only for exercise *names* for today. Cheap to
type, and known before leaving the house.

**During the session:** sets, weight, reps, duration, unilateral flags are captured
per set.

### The template is never a separate object

Last cycle's list is the default value for this cycle's:

- Week 1 Monday: empty. User types six exercises.
- Week 2 Monday: pre-filled with those six. Add one, remove one, start.
- Week 5 Monday: user stops looking and just hits start.

No "save as routine?" prompt, no template editor, no drift between plan and reality.
The plan is an emergent property of the log.

**Two rules:** the prefill must be visibly editable and never silently committed, and
there must always be a `just start` option that opens an empty session. Never gate
the workout behind declaring it.

### In-session deviation

The intent list is reorderable and skippable mid-session (machine occupied, feeling
strong). Exercises added off-plan are appended. Deviation is derivable by comparing
the session to its template snapshot — enabling a later "you've added a 4th squat set
for six weeks running, update the plan?" prompt (on the home screen, never mid-set).

---

## 6. Session lifecycle & the logging loop

```
Home card  →  Session (set table)  →  Set running  →  Log reps
                    ↑                                      |
                    └──────────────────────────────────────┘
```

1. Home shows today's card. Tap start.
2. Session opens as the dense set table, exercises in intent order.
3. **Trigger** → `setStarted`. Timer runs. An ambient surface shows it. App does not
   come to the foreground.
4. User does the set. Phone in pocket.
5. **Trigger** → `setEnded`. Rep entry is presented for that set.
6. Reps entered. Back to the table. Repeat.
7. End session → summary.

### What the trigger must satisfy

Platform-independent requirements. How each is met is a platform decision, not a
product one.

| Requirement | Why |
|---|---|
| Reachable without unlocking or opening the app | The loop must survive the phone being in a pocket |
| Physical or near-physical, low false-positive rate | A trigger that fires when a barbell is racked produces phantom sets |
| Setup in one screen, not buried in system settings | Anything deeper is an onboarding cliff for non-technical users |
| Stateless from the user's view — one action toggles | Set running? End it. Not running? Start it. No modes |
| An ambient surface showing the live timer | Otherwise the user has no confirmation the set is being tracked |

### The start/end asymmetry

| Event | Brings app forward? | Why |
|---|---|---|
| `setStarted` | No | User is mid-lift. Nothing should take the screen. |
| `setEnded` | Yes | Reps must be typed, and ambient surfaces generally can't take text input. The bar is racked — interrupting is fine. |

Fallback if that feels aggressive: end silently, mark the set `pendingReps`, and let
the ambient surface show `tap to log`. But then reps are entered from memory later,
which defeats the point.

### The session is a pool, not a queue

Gyms are crowded. The bench is taken, so the user does flies, then comes back to
incline BP. Nothing was substituted and nothing was skipped — the exercise was
**deferred within the session**.

Three states per exercise: `notStarted`, `inProgress`, `done`. **Deferred is not a
state** — a deferred exercise is simply still `notStarted`.

Rules:

- **The list never reorders itself.** It stays in plan order so the user's spatial
  memory of it holds. Only the current-exercise highlight moves.
- **Tap any exercise to make it current.** No confirmation, no "skip?" prompt, no
  penalty, no data written.
- **On closing a set, propose the next `notStarted` exercise in plan order.** This
  naturally walks the user back to what they deferred, which is the time-saving
  behaviour the whole feature exists for.
- **Multiple exercises may be `inProgress` simultaneously.** Two sets of incline BP
  done and flies started is a normal state.
- Anything still `notStarted` at session end shows quietly in the summary as
  `n not done`, tappable to add. No prompt. (§I4)

**Safety property:** the ambient card must always name the exercise the next set will
be attributed to. Because the trigger fires from a pocket, a mis-attributed set is
otherwise silent and invisible. `Hip thrust · set 3` on the card is what makes the
pocket-trigger model trustworthy.

**Accepted trade-off:** switching current exercise requires opening the app for one
tap. Correct, because the user is walking to a different machine anyway, and the
alternative is a guessing game about which exercise the trigger meant.

### Substitution is a different thing

Deferral is reordering. **Substitution** is the squat rack being taken all session and
doing hack squats instead: a new exercise enters the session, squats stay unlogged.

Per §11, substituted exercises are **never linked** — no merged curve. The exercise
picker offers, in order:

1. Exercises already in today's list (deferral)
2. Learned substitutes for the one being skipped
3. Full library search

Track a lightweight `substitutionCount` keyed on the exercise pair, used **only** for
picker ranking. Never a data link, never visible in analytics.

### Deferral must not trip the duplicate-day detector

A heavily-deferred session produces the same exercise *set* as last week in a
different order. Overlap in §10 is computed on sets, not sequences, so a crowded gym
never trips it. Heavy *substitution* could — which is why the rule there is **twice in
a row**, not once.

### Session close

"Done" does **not** lock the session. The user remembers an extra set of calves on
the drive home. Keep it open and editable all day; roll closed at midnight or on the
next session start; still editable from history after that.

---

## 7. The trigger boundary

Platform-agnostic. The trigger runs in a different process from the app, and this
section describes the contract between them regardless of how either is built.

### The core problem

The trigger fires when the app process is not running. It cannot call into app code,
cannot touch the database, and knows only what the app already wrote down.

**Do not put the database in shared storage with both sides writing.** That means a
second copy of the schema in the trigger layer plus cross-process locking, and it
will corrupt a session.

### Two files, each with exactly one writer

```
trigger  ──reads──▶  context.json   ◀──writes──  app
trigger ──appends─▶  events.jsonl   ──drained──▶ app
```

**`context.json`** — the app writes, the trigger only reads. Everything the trigger
needs to act and to render the ambient surface:

```json
{
  "sessionId": "…",
  "dayName": "Legs",
  "currentExercise": { "id": "hip_thrust", "name": "Hip thrust" },
  "nextSetIndex": 3,
  "lastLoad": { "value": 30, "unit": "kg", "scope": "perLimb" },
  "activeSet": { "eventId": "…", "startedAt": "2026-08-18T06:12:44Z" }
}
```

**`events.jsonl`** — the trigger appends, the app drains. Append-only, one JSON
object per line, each carrying a UUID:

```json
{"id":"…","type":"setStarted","at":"2026-08-18T06:12:44Z","sessionId":"…"}
{"id":"…","type":"setEnded","at":"2026-08-18T06:13:26Z","sessionId":"…"}
```

The app replays on resume, applies by `id` idempotently, then truncates. A
half-failed replay is harmless to re-run — that is what makes this safe against every
crash and force-quit path.

### The toggle

The trigger reads `context.json`: if `activeSet` is present, append `setEnded`;
otherwise append `setStarted`. One action, no modes, no state held in the trigger.

### The ambient timer

The timer surface must tick from a start timestamp on-device, with no per-second
updates pushed to it. Pushing an update every second drains battery and, on some
platforms, gets throttled.

### Failure modes to handle up front

- **Phantom set.** The trigger is bumped in a pocket. A `setStarted` with no
  `setEnded` and a 40-minute duration is obviously garbage — surface as `discard?`,
  do not save.
- **Clock authority.** Duration is `setEnded.at − setStarted.at` from the journal,
  never computed at drain time, or every set inherits the resume lag.
- **App killed mid-set.** The session and its start timestamp live in shared storage,
  not in app memory.

### Still open

The trigger mechanism, the ambient surface, and the framework are **not yet decided**
and are deliberately absent from this spec. See §16.

---

## 8. Prefill and the entry controls

### 8.1 Where each prefilled value comes from

| Value | Source |
|---|---|
| Weight — set 1 of an exercise | Same exercise's set 1 in the last session it was performed |
| Weight — later sets | The previous set in **this** session (users rarely drop back down mid-exercise) |
| Reps | Same exercise, same set index, last session |
| Execution (bi/unilateral) | Same exercise, **same set index**, last session → falls back to `Exercise.defaultExecution` |
| Load scope, unit, tags | Carried from the same source as weight |
| Today's intent list | Last session in this **weekday slot** |

Everything except the intent list reads **exercise history only** — never the plan.
(§I1)

**Execution must be keyed on set index, not just the exercise.** The reference log has
hip thrust set 1 bilateral and set 2 unilateral, and ham curls unilateral at set 1
then bilateral after. Keyed only off the exercise, the app gets set 2 wrong every
single week.

Prefill renders as **ghost text / a highlighted default**. One tap accepts, adjusting
overrides, and it is **never auto-committed**. Silent wrong data is worse than an
empty field.

Because prefill reads exercise history and not the template, the app is useful from
the second time an exercise is performed — day 3 or 4 — whether or not it knows what
"Legs day" means yet.

### 8.2 Reps — discrete quick-picks

Four tappable values plus an overflow. One tap closes the set.

```
reps   [ 7 ]  [ 8 ]  [ 9 ]  [ 10 ]  [ ⋯ ]
```

- Range spans `n−1` to `n+2` where `n` is the prefilled prediction — **biased upward**,
  because progression is the expected direction.
- The predicted value is visually highlighted.
- `⋯` opens the app for anything unusual: a drop set, an asymmetric L/R, a count
  outside the range.

Reps get discrete buttons rather than a stepper because they land within ±2 of last
time almost always, and one tap beats two.

**Unilateral sets:** show L/R pickers only when the *predicted set* is unilateral
(per §8.1). Default `L = R` on a single tap; asymmetry is the app-opening case.
Switching execution mid-exercise is also app-opening — rare enough that it should
cost the ambient surface no space.

### 8.3 Weight — stepper with a per-exercise increment

```
weight   [ − ]  30 kg  [ + ]   / side
```

Weight is **known before the set** — the bar was already loaded — so it must not
compete with reps for attention at set-end. It sits as a prefilled chip the user only
touches when it is wrong.

Weight gets a stepper rather than discrete buttons because its range is wider and
less predictable (warmup to working set can be a 20 kg jump) and `±` compounds.

**`long-press` on `+`/`−` jumps a plate pair** — 5 kg where the increment is 2.5, 10
where it is 5. Four taps beats eight for a warmup-to-working-set move.

### 8.4 Increment resolution order

2.5 kg is **not** universal — it depends on the equipment. Resolve in this order:

1. **User override** for that exercise, if set. Always wins.
2. **Learned** — the smallest positive difference among distinct loads logged for that
   exercise, once there are ≥3 distinct values.
3. **Equipment default** from seed data: barbell 2.5, dumbbell 2.5, machine stack 5,
   cable 2.5, bodyweight n/a.
4. **Global fallback** — 2.5 kg / 5 lb.

Two guards:

- **Floor it.** A learned value below 1 kg (someone logged 30 and 30.5 once) clamps to
  the equipment default. A 0.5 kg stepper needs 20 taps to go anywhere.
- **Recompute on a window** — the last ~10 distinct loads, not all history. Otherwise
  changing gyms (5 kg stack → 2.5 kg stack) never updates, because two-year-old values
  still pin the minimum.

Expose the increment as an editable field on the exercise, defaulted to the learned
value. It is the escape hatch for gyms with odd plates.

Never ask the user to configure this during onboarding. It is learned, and wrong
occasionally, which is what the override is for.

---

## 9. Observation, not inference

### The three states

| State | When | Behaviour |
|---|---|---|
| `observing` | day 1 onward | No plan exists. User logs freely. App proposes nothing. |
| `provisional` | after ~1 cycle repeats | App has a guess. Shows it visibly marked as a guess. Never silently applies it. |
| `confirmed` | user says yes | Drives prefill and the heatmap. Stops asking. |

One session is an anecdote — never propose a template after a single day. But note
the tension: fourteen days of a blank screen is the worst version of the app,
delivered during exactly the window when people quit. The resolution is that prefill
doesn't need a plan (see §8), so the app is useful on day 4 regardless.

From cycle two, show a provisional day header — `Legs? · tap to confirm` —
pre-populated but visibly tentative. After two clean cycles, ask once, then stop.

### Pattern detection must survive displacement

The user skips Wednesday's Pull and does it Thursday. A last-occurrence heuristic
concludes "Thursday is Pull day" and rewrites the week off one disruption.

**Rules:**
- Infer on **frequency across cycles**, not most-recent occurrence.
- A change must hold across **at least two consecutive cycles** before being proposed.
- Always proposed as a question, never applied as an edit.

### Resolving gaps

A gap is an unresolved observation, not a fact. Two non-blocking resolution paths:

- **Retroactive** — tap any hollow square in the history heatmap, pick what it was.
  Works for a gap six weeks old.
- **Ambient** — a dismissible row at the top of the home screen:
  `Wed 12 Aug — no session logged. Rest / travel / did it Thursday / add it now`

Never a modal. Never blocks the session about to start.

---

## 10. Duplicate days (Legs A / Legs B)

The general case, not an outlier — Push A/B and Pull A/B work identically. The user
hits legs twice a week with partly different exercises.

Structurally already handled: `WorkoutDay` has a stable ID separate from its name, so
"Legs" and "Legs B" are simply two days. Nothing new in the model.

### Detection

Compare exercise sets by overlap ratio (shared ÷ total distinct):

| Overlap | Action |
|---|---|
| >70% | Same day, normal variation. Say nothing, ever. |
| <50%, twice in a row | Ask once. |

Wording must not expose the data model:

> **Your Thursday legs sessions look different from Monday's.**
> Track them separately so each keeps its own history?
> `Keep separate` · `Same day` · `Ask me later`

Whichever they pick, don't ask again for that pair.

### If "same day"

One `WorkoutDay` used in two weekday slots with a variable exercise list. The intent
list must then key off the **weekday slot**, or Thursday opens pre-filled with
Monday's exercises. Per-exercise prefill is unaffected — it never reads days.

### If "keep separate"

**Split forward only.** Create `Legs B` from Thursday onward; leave history where it
is. Retroactively reassigning past sessions means guessing which ones were "really"
Legs B — don't guess. Offer manual bulk reassignment in history if ever needed.

Exercise-level curves are untouched either way, because they never read the day.

### Continuity guarantees

- **Exercise-level continuity is load-bearing and absolute.** Change PPL → Arnold →
  upper/lower → anything: hip thrust is one unbroken curve.
- **Day-level continuity is best-effort.** It genuinely breaks when Push splits into
  Chest+Tri and Shoulders — one day becomes two and there's no honest way to divide
  its history. Build nothing that depends on it; promise nothing about it.

---

## 11. Analytics & charts

### Per-exercise page

One chart, metric toggle: `e1RM | volume | top set`.

**Two series, always separated: `bilateral` and `unilateral`.** 40 kg single-leg and
60 kg both-legs are not on the same scale. Plotted as one line, the ham curl chart
shows a fake 50% jump between set 1 and set 2 every session.

**Do not normalize.** Any multiplier is invented. Show two series with their own
y-scale badges. Volume (`load × total reps across limbs`) *is* comparable across both
and makes a decent unified secondary line.

### Metrics

- **e1RM** — Epley: `w × (1 + r/30)`. Primary line. Raw weight misleads: 60 kg × 3
  looks like regression from 40 kg × 8.
- **Volume** — `load × reps`, summed. Secondary series.
- **Left/right divergence** — free from the data model, unique to this app.

### Substitutions — compare, never merge

Swapping barbell squat for hack squat: do **not** link them to continue the curve.
Different exercises produce different numbers; merging fabricates a discontinuity
that reads as progress or regression.

Instead: a **compare overlay** on the exercise page — pick a second exercise, both
plot on the same axes, visually distinct. Same insight, no lie in the data.

### History heatmap

GitHub-style. Filled = logged, hollow = unresolved, muted = rest. Tap any square to
annotate retroactively. Because status is largely derived, changing cadence
recomputes the whole history correctly.

---

## 12. Home screen — five states

| State | Shows | Primary action |
|---|---|---|
| **Planned, not started** | Day name, intent list (prefilled), date | `Start` |
| **In progress** | Running timer, current exercise + set, struck-through completed | `Resume` |
| **Done** | Exercise list with set counts, duration, total sets | none (summary) |
| **No plan yet** | Exercise-name input, prefilled from last cycle if any | `Start` / `just start` |
| **Rest day** | Last session summary, next session's day name | none |

**In progress is the state that matters most and is easiest to under-build.** Because
the trigger sits outside the app, the user leaves and re-enters constantly —
phone locks between sets, they open Spotify, check a message. Every return lands
here. If it renders the same as "not started," the whole flow feels broken.

**Rest day should be genuinely quiet.** Resisting the urge to add a "log a workout
anyway!" button is what makes rest days feel like rest.

Above any state, when needed: the ambient unresolved-gap row, dismissible.

---

## 13. Heart rate

**A phone alone cannot measure heart rate.** No optical sensor. Platform health
stores only surface what some other device wrote.

Per-set HR requires an Apple Watch or a BLE chest strap (e.g. Polar H10 via
BLE). Park it as v2 and be honest that it implies buying hardware.

The eventual feature — HR curve overlaid on set duration, showing cardiac load under
tension — is good, but it is not v1.

---

## 14. Cut from v1

- **Camera-based rep counting.** Incompatible with this product by construction: the
  camera flow needs the phone propped up framing the user; the trigger flow
  needs it in a pocket. You cannot do both in one session, and nobody props a phone
  up for hip thrusts.
- **Heart rate** — needs hardware (§13).
- **Cloud sync / accounts** — local-only v1, embedded database, no auth.
- **Social, sharing, programs marketplace.**

---

## 15. Build order

Riskiest thing first.

1. **Trigger spike, ~2 days, no UI.** Physical trigger → append to `events.jsonl` →
   read it back in app code. This is the riskiest part of the build; if the platform
   fights you, find out in week one, not week six.
2. **Data layer.** Exercise, Load, WorkoutSet, Session, WorkoutDay, WeekPlan + the
   ~150-exercise seed.
3. **Session screen.** The dense table. Manual logging only, no trigger.
4. **Home screen, five states.**
5. **Wire the trigger in.** Ambient timer surface, the start/end asymmetry.
6. **Onboarding + week grid.**
7. **Charts** — e1RM, volume, dual series, compare overlay.
8. **Observation layer** — provisional days, gap resolution, duplicate detection.
9. **Exercise library management** — search, aliases, merge, archive.

Steps 2–4 are a usable app. Step 5 is the product.

---

## 16. The trigger ladder

Not one mechanism — a ladder. **Every tier writes the same `events.jsonl`**, so the
app never knows which one fired. That is why §7 is a contract: tiers can be added per
platform without touching product logic.

### Tier 0 — ambient card (baseline, universal)

An ongoing lock-screen card with the quick-pick controls from §8.

- **iOS:** Live Activity with App Intent buttons (iOS 17+), plain notification fallback.
- **Android:** foreground-service notification with `PendingIntent` actions.

Works on 100% of devices, zero setup, no unlock required. **This is what the product
is if the user configures nothing** — it must be good on its own, not a degraded mode.
Everything above is optional acceleration.

On iOS the surface is continuous — the same card renders on the lock screen, in
Notification Centre, and in the Dynamic Island while the user is in another app. One
thing to build, visible everywhere.

### Tier 1 — parity layer

- **iOS 18+:** Control Center control.
- **Android:** Quick Settings tile.

Both are swipe-plus-tap from any screen including locked, both are add-once in system
UI, both feel near-identical. **Design this interaction once and it lands on both
platforms.**

### Tier 2 — platform best (genuinely divergent)

- **iOS:** the Action Button. One press, screen off, no unlock.
- **Android:** a floating overlay bubble via `SYSTEM_ALERT_WINDOW` — persistent over
  any app while unlocked. iOS has no equivalent and never will.

### Tier 3 — watch app

The honest endgame: no phone contact at all, and it solves heart rate (§13). Post-v1.

### Mechanisms evaluated and rejected

| Mechanism | Why not |
|---|---|
| **Earbud / media button** | `MPRemoteCommandCenter` (iOS) and `MediaSession` (Android) deliver media events only to the app owning the audio session — that is Spotify. Stealing it with silent audio breaks the user's music and fails review. Attractive and structurally unavailable. |
| **Android OEM buttons** (OnePlus Plus Key, Nothing Essential Key) | Wired to a fixed set of first-party functions; cannot launch or signal third-party apps. Apple's Action Button works because it routes through Shortcuts, a public automation layer. **Android has no OS-level equivalent.** Assume unavailable; treat any opening as a bonus. |
| **Back Tap (iOS)** | Misfires constantly — racking a barbell, phone against a leg on a bench. Setup buried in Accessibility → Touch. Offer as an option; never default. |
| **Volume buttons** | Requires an accessibility service on Android; unreliable and a review risk. |
| **Motion auto-detection** | Accuracy far too low to be trusted with the user's data. |
| **Voice** | Works, but socially unusable in a gym. Free add-on at best. |
| **Home screen widget** | Requires unlock and a home-screen visit. Strictly worse than Tier 1. |

### Capability detection

Offer the upgrade **after the user's second or third logged session** — not during
onboarding, when they have not yet felt the friction. Show only what their specific
device supports: an iPhone 13 never sees the Action Button; a Pixel never sees Control
Center.

### Platform costs to budget for

- **Android 14+ foreground service** requires a declared `foregroundServiceType`.
  `health` is the honest fit for a workout timer, and Play review will ask you to
  justify it. Doable, but it is a review conversation, not a checkbox.
- **`SYSTEM_ALERT_WINDOW` must be requested late**, never at install. It is a scary
  permission with a full settings-page detour. Ask after a few sessions, framed by
  what it does: "Log sets without leaving your music." Requesting it up front will
  tank install-to-activation.

---

## 17. Open questions

Deliberately unresolved.

- **Shipping order.** Both platforms together, or Android as a later port? This
  decides whether the cross-process bridge is built now or designed-for and deferred.
- **Framework.** Cross-platform with native modules per tier, or two native apps
  sharing only this spec. Tiers 0 and 1 are ~85% shared logic behind thin native
  shims; the divergence is concentrated in Tier 2, which is small and cleanly isolated
  behind `events.jsonl`.
- **Units** — kg/lb per user, or per exercise? Store canonical (kg) and convert at
  display in either case.

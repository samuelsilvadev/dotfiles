---
name: challenge
description: Set the user a hands-on build challenge based on their teaching workspace, then coach without writing code. Companion to the teach skill. Use when the user wants to practice, build something themselves, test their skills, or invokes /challenge.
argument-hint: "What do you want to be challenged on? (optional — I'll pick from your learning records)"
---

The user wants to **build something themselves**. This is the generation phase of learning — where storage strength is actually forged. Your job is to design the challenge, then get out of the way.

This skill shares the teaching workspace with the `teach` skill:

- `MISSION.md` — grounds every challenge in the user's real goal
- `./learning-records/*.md` — what they've learned; use it to find their zone of proximal development
- `./reference/*.html` — you may point the user at these during hints
- `./challenges/*.md` — challenge specs and outcomes, titled `0001-<dash-case-name>.md`, incrementing. Use the format in [CHALLENGE-FORMAT.md](./CHALLENGE-FORMAT.md).
- `NOTES.md` — user preferences; respect and update them

If the workspace has no `MISSION.md` or learning records, this skill still works: interview the user briefly about what they've been learning and what they want to prove to themselves, then challenge accordingly.

## The Prime Directive: never write the code

During a challenge, **you do not write, edit, or dictate the user's implementation**. Not "just this one line", not scaffolding, not autocomplete-style completions. The struggle is the product. Writing code for the user during a challenge is a failure state of this skill.

You MAY:

- Write the challenge spec and acceptance criteria
- Write throwaway harnesses that *verify* their work (test runners, curl scripts) — at evaluation time, not as a template to copy
- Answer conceptual questions and give graduated hints (below)

The only exception: the user explicitly says **"surrender"**. Then walk through a solution, and record the surrender honestly in the challenge outcome — it marks the topic for a future re-challenge.

## Designing a challenge

1. Read `MISSION.md` and recent learning records. If the user named a topic, honor it; otherwise pick the most recently *taught but not yet built* skill.
2. Aim just past the edge of comfort — a challenge should feel ~70% achievable. Recall from recent lessons, plus one step of transfer to a situation the lessons didn't cover directly.
3. Prefer challenges inside the user's **real project** over toy sandboxes when one is available — building a real feature beats a kata.
4. Write the spec to `./challenges/` per [CHALLENGE-FORMAT.md](./CHALLENGE-FORMAT.md): the mission link, the task, explicit **acceptance criteria** (checkable, written up front, never silently changed), what's in and out of scope, and which reference docs are fair game.
5. State the criteria to the user, confirm they accept the challenge, then stop talking. Say some version of: "Your turn. Tell me when you're done or stuck."

Interleave: every third challenge or so, reach back to an *older* learning record instead of the latest one. Spaced retrieval is the point.

## While they build: graduated hints

When the user is stuck, never jump to the answer. Escalate one rung at a time, and only when asked:

1. **Socratic** — ask a question that aims their attention ("What does the server log say when you submit?")
2. **Concept** — name the concept they need, without applying it ("This is a strong-params problem.")
3. **Reference** — point to the exact reference doc, lesson, or official docs section that covers it
4. **Pseudocode** — describe the shape of the solution in plain English or pseudocode, never in the target language's runnable syntax

Log which rung each challenge needed — it's a signal of durability. Answer genuine conceptual questions freely at rungs 1–3 depth; curiosity is not cheating. Debugging *their* code follows the same ladder: help them see the error, don't fix it.

## Evaluation: "I'm done"

1. Check every acceptance criterion, mechanically where possible — run the tests, hit the endpoint, exercise the app. Report each criterion pass/fail, no hedging.
2. Then give a **code review** as a senior colleague: what's genuinely good, what's a smell, what a more experienced hand would do differently — as observations and questions, not patches. If something should be refactored, describe the destination and let them drive.
3. If criteria fail, that's not the end — it's another loop. Back to hints.
4. When it passes, record the outcome in the challenge file (result, hint rungs used, review notes, what to re-challenge later) and add a learning record if a non-obvious insight surfaced.
5. Celebrate proportionally. A hard-won pass with zero hints deserves to be named as such.

## Calibration

- Finished fast with no hints → next challenge steps further (bigger transfer, less familiar territory), and say so.
- Needed rung 4 or surrendered → schedule a *variant* of the same skill soon (different surface, same muscle), and note it in the challenge outcome.
- Track patterns in `NOTES.md` — e.g. "strong on models, avoids writing tests" — and design future challenges to hit avoided areas.

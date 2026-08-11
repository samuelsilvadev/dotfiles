# Challenge Format

Challenges live in `./challenges/`, titled `0001-<dash-case-name>.md`, number incrementing each time. The file is written in two moments: the **spec** before the user starts, the **outcome** after evaluation. Never rewrite the spec after the challenge begins — if scope must change, note it under Outcome.

```md
# 0001: <Challenge name>

**Status**: proposed | in-progress | passed | passed-with-hints | surrendered | abandoned
**Date set**: YYYY-MM-DD
**Skill under test**: <the skill from the learning records this exercises>
**Mission link**: <one line on how this serves MISSION.md>
**Builds on**: <learning records / prior challenges, e.g. 0003, LR-0007>

## The task

<2–6 sentences. What to build, where (real project path or sandbox), and the
one-step transfer: what makes this slightly beyond what the lessons showed.>

## Acceptance criteria

- [ ] <Checkable criterion — a command to run, a behavior to demonstrate>
- [ ] <...>

## Rules

- Fair game: <reference docs, official docs, prior lessons allowed>
- Out of scope: <what NOT to build, to keep it timeboxed>
- Estimated size: <e.g. "one sitting, ~45 min">

## Outcome

_(filled in at evaluation)_

**Result**: <status + date>
**Hint rungs used**: none | 1-socratic | 2-concept | 3-reference | 4-pseudocode | surrender
**Criteria**: <pass/fail per criterion, with evidence — test output, curl result>
**Review notes**: <the 2–3 most important observations from code review>
**Re-challenge**: <what variant to set later, if any, and roughly when>
```

Keep specs short. If a spec needs more than a screen, the challenge is too big — split it.

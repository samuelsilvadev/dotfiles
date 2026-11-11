---
name: intent-spec-plan
description: Turn new work into a Linear ticket (intent and spec), a technical plan attached to it as a Linear document, and sub-issues once the plan is approved, then keep every decision recorded and the plan current until the work is verified in production. Also reviews an existing Linear ticket (for example one a PM wrote) against this format and reports what is missing or unclear. Use when starting a feature, bug fix or change that needs a ticket, when given a Linear ticket to review, analyse or pick up, when asked to plan work, write a spec, create Linear tickets or sub-issues, attach a plan, or record a decision on a ticket.
---

# Intent, spec, plan

Five stages, each with a gate. Never skip a gate, even when told to "just do it".

| Stage | Output | Gate |
| --- | --- | --- |
| 1. Ticket | Linear issue with Intent and Spec | User approves the draft |
| 2. Plan | Linear document attached to the issue | User approves the plan |
| 3. Sub-issues | One sub-issue per plan step | Created only after stage 2 |
| 4. Build | PRs and manual steps, plan kept current | Each departure recorded in the same turn |
| 5. Verify and close | Every "Done when" ticked with evidence | Only then mark Done |

Worked example: ENGA-6119 (ticket, attached plan, sub-issues ENGA-6120 to ENGA-6123).

When the user hands you an existing ticket, start with "Reviewing an existing ticket" below, then continue from the first stage that isn't complete.

## Reviewing an existing ticket

Use this when the ticket already exists (often written by a PM) and the user gives you its ID or link.

1. **Read everything:** `get_issue` with relations and documents, `list_comments` (decisions often hide in comments), the sub-issues, any attached plan document, and linked Slack threads or PRs. Then read the code the ticket touches, so you can tell whether the spec matches how the system works today.
2. **Check it against the stage 1 template** and, when a plan exists, the stage 2 template. For each section, ask:
   * **Problem:** is the current behaviour described, with numbers that show its size?
   * **Outcome:** can someone tell, after shipping, whether it was achieved?
   * **Constraints:** are limits that the code or data imply (capacity, cost, other systems, rollout) stated?
   * **Expected behaviour:** is every case covered, including empty, error, duplicate, permission and existing-data cases? Does any rule contradict another, or the code?
   * **Done when:** are the items observable in production, rather than "feature built" or "sub-issues closed"?
   * **Decisions:** does each one have an owner and a date? Are decisions made in comments missing from the description?
   * **Trade-offs and out of scope:** are the obvious adjacent cases explicitly in or out?
   * **Wording:** are there undefined terms, vague words ("fast", "some users", "handle properly"), or the same thing under two names?
3. **Report in the terminal**, before touching the ticket:
   * **Missing:** sections or cases with nothing written, each with a one-line suggestion.
   * **Unclear:** quotes from the ticket that allow more than one reading, each with the readings spelled out.
   * **Conflicts:** statements that contradict each other or the code, with the file or query that shows it.
   * **Questions for the author:** only the ones you can't answer from the code or data, phrased so the author can answer in one line.
   * **Good to go:** what is already solid, briefly, so the author knows what not to rework.
4. **Then offer, don't impose:** a draft comment for the author with the questions (shown first, with the disclaimer), or a restructured description in this format. The restructure keeps the author's text byte for byte where it stays, marks what you added, and is only applied with the user's approval. Never delete the author's content. Move it under the right heading instead.
5. Once the gaps are resolved and recorded, continue with stage 2.

## Ground rules

* **Show every Linear write as a draft first** (new issue, description edit, document, comment) and wait for approval, even when the user says "post it". Status changes and adding PR links to a plan you own don't need a draft.
* **Research before writing.** Read the code, check production data read-only, and answer questions yourself. Only genuine judgment calls go to the user or to "Open questions".
* **Every decision is written down before the turn ends.** Product decisions go on the ticket, implementation decisions on the plan (see "Where decisions live"). If the user declines to record something, respect that.
* **Writing style:** plain headline plus sub-bullets, short sentences, the same term for the same thing throughout. Code and file references only on a trailing `Where:` line. One issue ID per line (Linear renders IDs as full-title chips). Dependencies by step number. Sizes as XS (hours), S (a day), M (2 to 3 days), L (1 to 2 weeks), XL (more), never eng-weeks. No em dashes.
* **Disclaimer:** start every Claude-written description, document and comment with `> Written by Claude, reviewed by <name>.` (or `pending <name>'s review` for a plan not yet approved).

## Stage 1: the ticket

1. Search first: `list_issues` with a keyword query and a recent `createdAt`. Update a matching issue rather than creating a duplicate.
2. Copy team, parent, assignee and cycle from the parent or related issue. Ask only if there is none.
3. Draft the description with this template and show it:

```markdown
> Written by Claude, reviewed by <name>. The build plan is in the attached document.

## Intent

### Problem
* What is wrong or missing today, with the numbers that show its size.

### Outcome
* What is true once this ships, in user or business terms.

### Constraints
* Limits the solution must respect (capacity, cost, other systems).

## Spec

### Expected behaviour
| Case | Behaviour | Where it shows |
| --- | --- | --- |
* One bullet per rule that the table doesn't cover.

### Done when
- [ ] Observable outcomes in production, each saying where to see it (a page, an alert, a query). Never "all sub-issues are closed".

### Decisions
* <Name> (YYYY-MM-DD): the decision, and the reason when it isn't obvious.

### Accepted trade-offs
* What we knowingly don't handle, and why that's acceptable.

### Out of scope
* Related work we're explicitly not doing here.
```

Intent is what a product owner reviews. Spec is what an engineer builds from and checks against.

## Stage 2: the plan

Create it with `save_document` and `issue: <ID>` so it's attached to the ticket. Title: `Plan: <short name>`. Template:

```markdown
> Written by Claude, pending <name>'s review. The intent, spec and product decisions live on the issue; this document covers how we build it.

## Sub-issues
(filled in after approval, one ID per line)

## Flow after the change
(Mermaid, only when flow or branching changes; render it in both themes first)

## Steps

### 1. <Outcome-named title> (<size>, one PR | manual)
* What changes, one bullet per piece.
* Specs: the behaviours the specs cover.
* Proof in production: the page, alert, log query or console check that shows it worked.
* Done when: merged and deployed, plus the proof above.
* Where: files or classes.
* PR: (filled in when opened)

## Order
* Step 2 depends on step 1.

## Risks
* Riskiest step first. For each: what could go wrong, and how it's contained (ordering, scoping, a check before a write, a spec).

## Planning decisions
Proposed by Claude, pending approval:
* Implementation choices the user hasn't made yet.

## Open questions
* Only genuine judgment calls, or "None".

## Changes after approval
* <Name> (YYYY-MM-DD): what changed from the approved plan, and why.
```

Each step is one PR or one manual task, mergeable on its own (one PR per need). A manual production step gets its full script on its sub-issue: reads with expected values, then each write separately, then a fresh verify query.

## Stage 3: sub-issues

Only after the user approves the plan:

1. Update the plan header to `approved by <name> on <date>` and the planning decisions line to `approved with the plan on <date>`.
2. Create one sub-issue per step with `parentId`, the same team, assignee and cycle, and `blockedBy` from "Order". Template:

```markdown
> Written by Claude. Step N of the plan attached to <PARENT-ID>.

* Two to four bullets on what this step delivers.

### Done when
- [ ] Merged and deployed.
- [ ] The production proof from the plan step, in one line.

Where: files or classes.
```

1. Fill in the plan's "Sub-issues" section, one ID per line.

## Stage 4: during the build

* **Plan departures:** when a PR differs from its step (a rename, a different approach, a dropped piece), update the step and add a "Changes after approval" entry in the same turn.
* **New product decisions** (from the user, a review thread or a production finding) go on the ticket's "Decisions" with name and date. Accepted review findings that the user wants recorded go under "Accepted trade-offs".
* **PR links:** add `PR: #123` to the step when it opens.
* **Manual steps:** put the script on the sub-issue before it runs, and keep it in sync if it changes.

## Stage 5: verify and close

1. Close a sub-issue only when its "Done when" is met. Merged isn't enough when the proof is in production: leave it In Review and tick each box with its evidence (counts, alert text, a screenshot link) as it arrives.
2. Before closing the parent, run a final check: compare every plan step with what merged, record any departure still missing from "Changes after approval", and add `Final check (<date>): every step matches what merged.` to the plan.
3. Tick the parent's "Done when" with evidence, then mark it Done.

## Where decisions live

| Decision | Where |
| --- | --- |
| Product or business rule (what the system does) | Ticket, "Decisions" |
| Known gap we accept | Ticket, "Accepted trade-offs" |
| Implementation choice before approval | Plan, "Planning decisions" |
| Change to an approved plan | Plan, "Changes after approval" |
| Detail of a manual production step | Its sub-issue |

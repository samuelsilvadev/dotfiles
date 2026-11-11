---
name: create-pr
description: Open a pull request following Amplemarket engineering conventions. Use whenever asked to create, open, draft or write up a PR (ampledash, sherlock, ampledash-infra and other amplemarket repos), including stacked PRs and PR body rewrites.
---

# Create a PR

Follow this end to end. The body rules are hard rules, not preferences.

## 1. Before writing anything

- **One PR per need.** If the work covers several distinct needs, split it into one draft PR per need, each mergeable on its own, and stack only where there is a real dependency. Propose the breakdown and merge order first.
- **Stacks use `gh stack`** (`gh stack init <bottom> ... <top>`, `gh stack submit --auto`), never hand-chained `--base` branches. After a squash-merged bottom PR, restack with `git rebase --onto origin/master <merged-branch> <next-branch>`. Run `gh stack view` before calling a commit "misplaced". Run slow rebases with `run_in_background`.
- **Branch from `origin/master`**, in a separate worktree when the main checkout may be in use. Always check `git branch --show-current` before editing. In ampledash, never put "packs" in a worktree directory name (it breaks boot), and since a fresh worktree has no `node_modules`, commit with `--no-verify` when no JS changed.
- **Don't run specs or migrations unless the user asks.** Write or update the specs and the migration file, then stop; CI runs them. Linting is fine (in ampledash: `bin/bundle exec standardrb <files>`).
- **Specs only for observable behaviour.** No specs that pin a lock mode, SQL text or other implementation detail. For small infra fixes, rely on the existing behaviour specs and put the reasoning in the PR body.
- **Code comments: default to none.** No narration, no restating the method name, no description of another class, no explanation of a bug you just fixed. A known limitation goes in the PR body, not the source.
- **Naming:** no `*Service` suffix (use a role noun: `Logger`, `Importer`, `Resolver`). Specific names for new tables and namespaces (`external_dialer_*`, not `dialer_*`). Small pure mappings are a class method on the model, not a new class.

## 2. Branch, commits, title

- **Branch:** `fix/<what-broke>`, `feature/saas-<ticket>-<slug>`, `chore/<slug>`, `refactor/<slug>`. Lowercase, hyphenated, descriptive of the change.
- **Title:** sentence case, imperative, describes the outcome rather than the mechanism ("Stop the CRM deal matcher task lookup from timing out on large domains", "Spread monthly insights emails over three hours"). Prefix `SAAS-1234: ` (or `BE-720: `) when there is a Linear ticket. `fix:` or `refactor(SAAS-3382):` prefixes appear on some, but plain sentences are the norm. No trailing period, no em dash.
- **Commits:** one logical step per commit, imperative subject, ticket prefix when the PR has one, body wrapped at about 72 characters. End with the attribution trailer the session gives you. Do not force push except to rebase (use `--force-with-lease`, and ask if a plain push cannot work).

## 3. The body (ampledash)

Start from `.github/pull_request_template.md`. Real `###` sections, never bold inline labels. Keep the template's `---` and "Relevant docs for reviewer" footer, then the attribution line.

```
### Context
### Solution
### Notes / Caveats
---
### Relevant docs for reviewer   (template boilerplate)

[Slack Thread](...)   (when the work started from one)
Fixes RUBY-RAILS-XXXX (when a Sentry issue closes)

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

Larger or more design-heavy PRs may swap in `## The change` / `## Decisions` / `## Behaviour changes`. Other repos: sherlock uses `## Context` / `## Solution` (older ones `## Why` / `## What`); ampledash-infra uses `## Why` / `## What` / `## Risk` / `## Related`. Match the repo's recent PRs.

### Context
- **Whenever the work has a Linear ticket (from the branch, title prefix, commits or conversation), link it in Context**, even if the title already carries the ID: `[SAAS-3913](https://linear.app/amplemarket/issue/SAAS-3913/<slug>)`. Look the slug up with the Linear MCP (`get_issue`) rather than guessing. For a stacked PR that continues a ticket, still link it, and add a short phrase on which part of the ticket this PR covers.
- Name the trigger first and link it: a Sentry issue as `[RUBY-RAILS-1A1S](https://amplemarket.sentry.io/issues/RUBY-RAILS-1A1S)`, a Linear ticket as `[SAAS-3913](https://linear.app/amplemarket/issue/...)`, an earlier PR as `#40451`, a reviewer comment as a link.
- Include the numbers that show scale (events, rows, seconds, "~720 contacts", "4k events since July") and the actual mechanism, with the concrete thing named first.
- When the cause was non-obvious, say how you verified it (a prod console check, pganalyze, `EXPLAIN` on the replica).
- People first, mechanism second, first person plural ("we", "our"). Warm, longer sentences with subordinate clauses, parenthetical asides with the occasional `:)`, concrete `(e.g. ...)` examples, relaxed capitalisation for familiar things. Matching this voice never relaxes the word cap.

### Solution
- One or two sentences on what changed, then show behaviour, not code:
  - a before/after table (`| Lead | Before | After |`), or a plan/cost table for query fixes,
  - a Mermaid flowchart, only when branching or flow logic changes (about 1 in 10 PRs: a conversion branch, a batched pipeline, a retry or deadlock path). Show a before and after pair when the branches differ,
  - a trimmed before/after SQL sketch only when generated SQL changes (the Ruby diff cannot show it).
- **No diagram** for new classes without callers, renames or moves, config or alert changes, single-query fixes, or anything a table or file tree explains. Do not diagram a flow that does not exist yet; save it for the PR that wires it up.
- Say what was chosen and why, and what was rejected ("We chose the fence because it doesn't depend on row estimates. Plucking IDs into Ruby wasn't enough").
- Never paste a diff or pseudocode of the code change. The PR diff does that.

### Notes / Caveats
- Two to four bullets: behaviour that stays unchanged, merge order against sibling PRs, rollout caveats, which open PRs will need a rebase, the follow-up ticket for a known gap. One line each.

### Hard rules for every body
1. **300 words maximum by default**, counting everything the author writes and excluding the template footer. Count before `gh pr create` or `gh pr edit`. A deeper investigation means harder compression. If compressing to 300 makes the Context, the Solution or the reasoning behind a decision ambiguous, or drops something a reviewer needs, ask the user whether to allow up to 400 words and say briefly what would get lost. Never go past 300 without a yes, and never past 400.
2. **Say each fact once.** No restating Solution in Notes, no prose plus a table for the same thing. No coverage matrices.
3. **Spend length only on** the chosen approach and why, and the exact old vs new semantics of any changed rule or branch.
4. **No wall of text.** Short paragraphs or bullets, one claim per line.
5. **No hard wrapping.** One unwrapped line per paragraph or bullet (GitHub renders single newlines as breaks).
6. **No em dashes anywhere** (body, commits, comments, spec strings). Use a comma, parentheses, a colon or two sentences. Use "none" in empty table cells.
7. **Never mention running specs, or not running them.** Saying what coverage was added is fine ("New specs cover the ordering").
8. **No code diffs** in the body.
9. When editing a body a person wrote or touched, preserve their text byte for byte (the API returns CRLF).
10. Render every Mermaid diagram in both themes before shipping: `npx -y -p @mermaid-js/mermaid-cli mmdc -i d.mmd -o d.png -t dark -b '#0d1117'` and again with `-t default -b '#ffffff'`. Fixed `fill` plus explicit `color`, a few words per node, entry points in their own class.

## 4. Open it

1. Show the user the title, branch and full body in the terminal and wait for approval, even if told to "just open it". If the body needs more than 300 words (hard rule 1), ask for the 400-word allowance in the same message.
2. `gh pr create --draft --repo <owner/name> --base master --head <branch> --title ... --body-file ...`. Always `--draft` (stacked PRs too) and always `--repo`: the shell cwd resets between calls, and a bare `gh` once overwrote an unrelated PR. Echo the resolved URL before any `gh ... edit`.
3. Reply in chat with the link and only what needs a decision. Do not repeat the body.

## 5. After opening: the review loop

- When asked to check comments, first explain each finding and whether it is valid, then fix.
- After fixing, draft a short reply per thread (commit SHA, or a declining rationale citing precedent such as how the CRM dialers do it), show the drafts for approval, post them through `gh api .../comments/<id>/replies`, then re-poll for new comments, including bot reviews like Greptile, until none are unanswered.
- New commits on top, no force push. Reasoning for declined suggestions goes in the thread, not in code comments.

## 6. Pre-flight checklist

- [ ] Draft, correct repo, correct base, correct branch
- [ ] Title sentence case, ticket prefix if any, no em dash
- [ ] Body under 300 words (or 400 if the user approved), each fact once, no wrapping, no diff block, no spec-run mention
- [ ] Context links the Linear ticket (if any) and the Sentry or PR trigger, with real numbers
- [ ] Solution shows behaviour (table, diagram, SQL sketch), and the rejected alternative if there was one
- [ ] Notes name merge order, unchanged behaviour and follow-ups
- [ ] No new code comments, no implementation-pinning specs, no `*Service` class
- [ ] Diagram only if flow or branching changed; if present, rendered in both themes
- [ ] Author approved the draft

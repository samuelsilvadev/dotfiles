---
name: draft-pr
description: Push the current branch, open a draft PR with a written description, and add the disposable label.
argument-hint: "[full] — use the disposable-full label instead of disposable"
disable-model-invocation: true
---

Running this skill is the user's explicit go-ahead to **push** and **open a draft PR** for the current branch. It is not permission to commit: if the working tree has uncommitted changes, list them and ask before doing anything.

Arguments: $ARGUMENTS

## 1. Check the branch

- `git status --short` — if anything is uncommitted, stop and ask whether to commit it first.
- `git branch --show-current` — never push a branch starting with `claude/`. Rename it locally first with `git branch -m <type>/<ticket-lower>-<short-slug>` (`feature/`, `fix/` or `chore/`). If it is already on the remote under the `claude/` name, ask before renaming.
- Resolve the repo once and reuse it everywhere: `REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)`. Pass `--repo "$REPO"` to every `gh pr` command below, because the shell cwd resets between calls and a bare `gh` can touch an unrelated PR.
- Find the Linear ticket ID (e.g. `PRJ-1234`) from the branch name, commit messages, or this conversation. If there is none, ask once; continue without one if the user says so.
- Check whether the branch already has a PR: `gh pr list --repo "$REPO" --head "$(git branch --show-current)" --json number,url`. If one exists, skip `gh pr create` in step 5 and update it with `gh pr edit` instead. Echo its URL before editing.
- Check whether the branch is part of a stack: `gh stack view`. If it is, use the stack flow in step 5.

## 2. Gather what the PR does

- Base branch: the stack's parent if stacked, otherwise `gh repo view --json defaultBranchRef -q .defaultBranchRef.name`.
- `git log --oneline <base>..HEAD` and `git diff <base>...HEAD --stat`, then read the diff and anything from this conversation that explains why the change was made.

## 3. Write the title and description

- Title: `type(TICKET): Summary` — conventional type, ticket in caps, summary starting with a capital letter (e.g. `feat(ENGA-5495): Confirm moving stages with an undo toast`). Without a ticket: `type: Summary`. The summary describes the outcome rather than the mechanism, with no trailing period.
- Read the user's latest PR body for layout: `gh pr list --repo "$REPO" --author @me --state all --limit 1 --json body -q '.[0].body'`. Copy its style: short Context paragraphs (one idea each) opening with the Linear link, Solution bullets with nested sub-bullets explaining both what changed and why, a closing line on user-facing impact.
- Build the body on the repo's `.github/pull_request_template.md`. `--body-file` skips the template, so copy every remaining section in verbatim: the HTML hint comments, `### Notes / Caveats`, `---`, and the "Relevant docs for reviewer" links.
- Never write about the PR's place in the stack (e.g. "First PR of the stack. The frontend PR on top adds..."): GitHub's stack view already shows it.
- No "Generated with Claude Code" footer or any other attribution line.
- Write the body to a temp file: `BODY=$(mktemp -t pr-body).md`.

### Content rules

- **Linear link:** look the ticket up with the Linear MCP (`get_issue`) and use the URL it returns, as `[PRJ-1234](<url>)`. Never guess the slug. For a stacked PR that continues a ticket, still link it and add a short phrase on which part this PR covers.
- **Context:** name the trigger first and link it (ticket, Sentry issue, earlier PR, reviewer comment). Include the numbers that show scale (events, rows, seconds) and the actual mechanism. When the cause was non-obvious, say how it was verified (a prod console check, `EXPLAIN`, a dashboard).
- **Solution:** show behaviour, not code. Use a before/after table when behaviour changes. Use a Mermaid flowchart only when branching or flow logic changes, never for renames, moves, config changes or single-query fixes. Say what was chosen, why, and what was rejected.
- **Notes / Caveats:** two to four one-line bullets: behaviour that stays unchanged, merge order against sibling PRs, rollout caveats, which open PRs need a rebase, the follow-up ticket for a known gap.
- **Hygiene:**
  - Say each fact once. Do not restate Solution in Notes, and do not give prose plus a table for the same thing.
  - No code diffs or pseudocode of the change, since the PR diff already shows it.
  - One unwrapped line per paragraph or bullet.
  - No em dashes in the body.
  - Say what test coverage was added ("New specs cover the ordering"), and never mention running tests or not running them.
  - Keep it short. If a body is heading past about 300 words, compress it, and if that would drop something a reviewer needs, ask the user before going longer.
- When editing a body a person wrote or touched, preserve their text byte for byte (the API returns CRLF).

## 4. Get approval

Before pushing or opening anything, show the user the branch name, base, title, label and full body in the terminal, then stop and wait. This applies even if they said "just open it". Revise and show it again until they approve. Do not push, create or edit the PR before a yes.

## 5. Push and open the draft PR

Label: `disposable-full` if the arguments contain `full`, otherwise `disposable`. Skip it if `gh label list --repo "$REPO" --search <label>` shows it doesn't exist in this repo.

**Not stacked, no PR yet:**

```bash
git push -u origin HEAD
gh pr create --draft --repo "$REPO" --base <base> --title "<title>" --body-file "$BODY" --label <label>
```

**Not stacked, PR already exists:**

```bash
git push
gh pr edit <number> --repo "$REPO" --title "<title>" --body-file "$BODY" --add-label <label>
```

Push normally for new commits. Use `--force-with-lease` only after a rebase, and ask if a plain push cannot work.

**Stacked** (never plain `git push` / `gh pr create` on a stack):

```bash
gh stack submit --auto
```

`--auto` opens new PRs as drafts with generated titles. Then fix up the PR for this branch:

```bash
gh pr edit <number> --repo "$REPO" --title "<title>" --body-file "$BODY" --add-label <label>
```

After a squash-merged bottom PR, restack the next branch with `git rebase --onto origin/<base> <merged-branch> <next-branch>`, then `gh stack submit --auto` again. Run `gh stack view` before calling a commit misplaced.

## 6. Assign and ping Greptile

Assign the PR to the user, then comment `@greptileai` unless a comment with it already exists (re-runs and `gh pr edit` fix-ups must not post it twice):

```bash
gh pr edit <number> --repo "$REPO" --add-assignee @me
gh pr view <number> --repo "$REPO" --json comments -q '.comments[].body' | grep -qF '@greptileai' \
  || gh pr comment <number> --repo "$REPO" --body '@greptileai'
```

## 7. Report

Reply with the PR link and title, plus one line if you renamed the branch or skipped the label. Don't paste the description back; it's on the PR.

## 8. Review loop (only when asked to check comments)

- Fetch all review comments and bot reviews (Greptile included). First explain each finding and whether it is valid, then fix the valid ones.
- Push fixes as new commits, no force push. Reasoning for declined suggestions goes in the thread, not in code comments.
- Draft a short reply per thread (the commit SHA, or a declining rationale citing precedent), show the drafts to the user, and post them only after approval via `gh api repos/$REPO/pulls/<number>/comments/<id>/replies`.
- Re-poll for new comments until none are unanswered.

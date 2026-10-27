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
- Find the Linear ticket ID (e.g. `PRJ-1234`) from the branch name, commit messages, or this conversation. If there is none, ask once; continue without one if the user says so.
- Check whether the branch is part of a stack: `gh stack view`. If it is, use the stack flow in step 4.

## 2. Gather what the PR does

- Base branch: the stack's parent if stacked, otherwise `gh repo view --json defaultBranchRef -q .defaultBranchRef.name`.
- `git log --oneline <base>..HEAD` and `git diff <base>...HEAD --stat`, then read the diff and anything from this conversation that explains why the change was made.

## 3. Write the title and description

- Title: `type(TICKET): Summary` — conventional type, ticket in caps, summary starting with a capital letter (e.g. `feat(ENGA-5495): Confirm moving stages with an undo toast`). Without a ticket: `type: Summary`.
- Read the user's latest PR body for layout: `gh pr list --author @me --state all --limit 1 --json body -q '.[0].body'`. Copy its style: short Context paragraphs (one idea each) opening with the Linear link, Solution bullets with nested sub-bullets explaining both what changed and why, a closing line on user-facing impact.
- Build the body on the repo's `.github/pull_request_template.md`. `--body-file` skips the template, so copy every remaining section in verbatim: the HTML hint comments, `### Notes / Caveats` (stack position goes here when stacked), `---`, and the "Relevant docs for reviewer" links.
- No "Generated with Claude Code" footer or any other attribution line.
- Write the body to a temp file: `BODY=$(mktemp -t pr-body).md`.

## 4. Push and open the draft PR

Label: `disposable-full` if the arguments contain `full`, otherwise `disposable`. Skip it if `gh label list --search <label>` shows it doesn't exist in this repo.

**Not stacked:**

```bash
git push -u origin HEAD
gh pr create --draft --base <base> --title "<title>" --body-file "$BODY" --label <label>
```

**Stacked** (never plain `git push` / `gh pr create` on a stack):

```bash
gh stack submit --auto
```

`--auto` opens new PRs as drafts with generated titles. Then fix up the PR for this branch:

```bash
gh pr edit <number> --title "<title>" --body-file "$BODY" --add-label <label>
```

## 5. Report

Reply with the PR link and title, plus one line if you renamed the branch or skipped the label. Don't paste the description back; it's on the PR.

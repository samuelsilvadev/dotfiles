---
description: Prep notes for reviewing a GitHub PR — orientation, read order, triage, symbol map.
argument-hint: <pr-url>
---

You help me review a GitHub PR faster by making the diff legible. Your role is purely descriptive: you describe what the PR does and how to navigate it. Judgment work — whether code is risky, well-tested, or could be cleaner — is handled separately by AI code review and by me.

PR URL: $ARGUMENTS

## Steps

1. Pull PR metadata:
   `gh pr view $ARGUMENTS --json title,body,files,additions,deletions,labels,baseRefName,headRefName`
2. Pull the diff:
   `gh pr diff $ARGUMENTS`
3. Read files in the repo as needed for context, including unchanged files the diff touches indirectly.
4. For each changed file, compute the GitHub anchor for direct linking:
   `$ARGUMENTS/files#diff-$(printf '%s' '<path>' | shasum -a 256 | awk '{print $1}')`
5. Check labels — include the QA section only when `disposable` is present.

## Output

One combined report, exactly these sections in this order. Write fresh content; assume I've already read the PR title and description.

### TL;DR

One paragraph in plain English describing what the PR does: the entry point and the data flow.

### Read first (context outside the diff)

Files NOT in the diff worth skimming first for context. One line per file on why it helps. Include this section only when such files exist.

### Glossary

New terms, concepts, types, or domain words introduced by the PR, one line each. Include only when new terms exist.

### Reality check

- Files: <count>, +<additions> / -<deletions>
- Mechanical / skim: breakdown by kind — lockfiles, snapshots, generated, renames, moves, etc.
- Real review surface: ~<N> lines across <M> files

### Read order

Numbered list of files in the order to open on GitHub.

For each:
N. `path/to/file.ext` — [label]

- <github anchor link>
- Focus: one line describing what to look at. For mechanical files, point to the lines that aren't mechanical. For renames/moves, mark as "rename only — safe to skim".

Labels: `new logic` / `refactor` / `rename` / `move` / `generated` / `migration` / `test` / `boilerplate` / `mixed`

When two files only make sense read together, say so in the focus line.

### Symbol map

- **New:** ...
- **Changed:** ...
- **Deleted:** ...

Symbols = functions, classes, types, components, exported constants, route handlers, migrations, DB columns.

### Call graph

Text-only flow of the new or changed path:

```
CallerA (path)
  → CalleeB (path)
    → CalleeC (path)
```

Include this section only when the PR introduces or changes a flow.

### QA on disposable

Include only when the PR has the `disposable` label.

- **Pages / screens affected:** URL paths in the app the PR touches.
- **How to reach them:** navigation steps from the app entry point.
- **What to exercise:** concrete user actions that hit the new/changed code — frame as "click X", "enter Y", "observe Z is now different from before".
- **Required setup:** specific data, account state, or feature-flag state needed. Include only when setup is required.

## Style

- Stay in observer mode: name what changed and how to look at it.
- Use exact file paths. Compute GitHub anchor links from the path with shasum.
- Match section length to content — short PRs get short sections.
- Open directly with the TL;DR.

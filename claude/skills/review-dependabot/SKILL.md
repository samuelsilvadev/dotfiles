---
name: review-dependabot
description: |
  Review a Dependabot dependency-bump PR and surface breaking or impactful changes,
  backed by evidence from the published code (not changelogs).
  Use when: (1) Asked to review/analyze a dependabot PR, e.g. "/review-dependabot <PR url or number>",
  (2) Deciding whether dependency-bump PRs are safe to merge alone or must land together,
  (3) Investigating what actually changed between two versions of a dependency.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - WebFetch
  - AskUserQuestion
---

# Review Dependabot PR

Adversarially review a Dependabot PR. The goal is a verdict the team can act on:
**safe to merge alone**, **must land together with sibling PRs**, or **risky — needs investigation**.
Bias toward surfacing risk; never assume a bump is safe because it is patch-level or CI is green.

**Analysis only.** Never merge, approve, comment on, or rebase the PR. Report findings to the user.
Do all scratch work (tarballs, diffs) in a temp directory, never inside the repo.

## Input

The argument is a PR URL or number. If missing, list candidates and ask which one to review:

```bash
gh pr list --author "app/dependabot" --state open --json number,title
```

## Step 1 — Understand the bump

```bash
gh pr view <n> --json title,body,files
gh pr diff <n>
```

Extract: package(s) bumped, old → new versions, ecosystem (`pnpm-lock.yaml` → npm/pnpm;
`Gemfile.lock` → bundler), and which manifests were edited.

## Step 2 — Workspace consistency (npm monorepo)

Check every workspace that declares the dependency (`grep -rl "<pkg>" --include=package.json`,
excluding `node_modules`) against the manifests the PR edits. Dependabot sometimes bumps
workspaces that don't import the package while the **actual consumer stays locked on the old
version** (its lockfile entry is untouched even when its range would allow the new version).
Find the real consumers by grepping imports, and flag mismatches.

## Step 3 — Dependency-graph / lockfile analysis

From the PR's lockfile diff, list resolved package versions **added and removed**. Watch for:

- **New duplicate copies of transitive deps.** Additions without matching removals mean the old
  copy stays because other packages still pin it.
- **Split shared stateful internals.** Some families (notably `@radix-ui/*`) pin internals to
  exact versions, and several internals hold module-global state: `react-dismissable-layer`
  (layer stack, Escape/outside-click, body pointer-events lock), `react-focus-scope`,
  `react-focus-guards`, `react-remove-scroll`, `aria-hidden`. If the bump moves one component
  to a new copy while sibling components stay on the old one, nested-overlay behavior breaks
  (Escape closes too much, outside-click misfires, stuck `pointer-events: none`, focus wars).
  Map who consumes each copy by parsing the lockfile snapshots, and check whether components
  that end up on different copies can nest in this app.
- **Sibling PRs.** Check other open dependabot PRs touching the same family. If merging them
  together re-unifies the internals, report them as a **must-land-together set** (and note that
  sequential merges leave master in the split state between them — batch before a deploy, or
  replace with one manual PR bumping the whole set).

## Step 4 — Ground-truth source diff

Changelogs lie by omission. Diff the published artifacts:

```bash
# npm — note: the tarball filename strips the scope
curl -sL "https://registry.npmjs.org/@scope/name/-/name-<VER>.tgz" -o pkg.tgz
mkdir out && tar -xzf pkg.tgz -C out   # sources in out/package/dist/
diff -u old/package/dist/index.mjs new/package/dist/index.mjs

# ruby
gem fetch <name> -v <VER> && gem unpack <name>-<VER>.gem
```

- Diff the `dependencies` in the two `package.json`s / gemspecs too — added or dropped
  transitive deps are a signal.
- Also diff important transitive bumps (internals the package pins that changed alongside it).
- Classify each hunk: **behavior change**, **bug fix**, **API change** (removed exports,
  removed `displayName` statics, signature changes), **dev-only**, or **build noise**
  (`__name` wrappers, minifier churn — ignore).
- Release notes / GitHub issues are secondary context for *why* a change was made, not
  evidence of *what* changed.

## Step 5 — Map changes to this codebase

For each meaningful change, determine whether this repo actually exercises the affected path:

- Where is the package imported — directly, or only via a wrapper (e.g. `@amplemarket/amplie`)?
- Does the wrapper's usage hit the changed code (controlled vs uncontrolled, forms/hidden
  inputs, CSS animations for presence changes, SSR, event bubbling)?
- Most important: **does any code depend on the OLD behavior?** A fixed bug is a regression
  for code that relied on it. Search for such reliance before calling a change harmless.

## Step 6 — Report

Lead with the verdict, then evidence:

1. **Verdict** — safe to merge alone / must land together with PRs #… / risky.
2. **Meaningful changes**, each with the diff evidence and old vs new behavior spelled out.
3. **Regression surface in this repo** — what was checked and what was found.
4. **Suggested post-merge smoke tests** targeting the changed paths.
5. **What was NOT analyzed** (e.g. changelog-only claims, untested nesting combos). Unverified
   is flagged as unverified, never rounded up to safe.

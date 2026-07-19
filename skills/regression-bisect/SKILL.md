---
name: regression-bisect
description: Find the commit that introduced a regression using git bisect with evidence, not guesswork. Detects the VCS and a reproducing check, then drives an automated bisect to the culprit commit. Use when something worked before and broke, and you don't know which change caused it.
---

# Regression bisect

## Purpose
Find the exact commit that introduced a regression by binary-searching history with `git bisect`, driven by an automated reproducing check rather than manual checkout-and-test. Works across stacks — detect the test/repro command first, then bisect.

## Required inputs
- a symptom that reproduces deterministically now (a failing test, a command that errors, an assertion)
- a known-good reference: a commit, tag, or rough date where the symptom was absent
- the bad reference (defaults to `HEAD`)

> **Project profile:** if a `.codex/essentials-profile.md` file exists in the repo, read it first and trust it for this codebase's stack, commands, layout, and conventions.

## Step 0 — Confirm it's a clean bisect candidate

```bash
git status --porcelain          # must be clean; stash or commit first
git log --oneline -5
```

Bail out early if:
- the working tree is dirty (bisect needs clean checkouts) — tell the user to commit/stash.
- the symptom is **not** reproducible on demand → this is a flaky test, not a regression. Hand off to $flaky-test-investigation instead.
- there's no plausible good commit (it never worked) → this is a feature/bug, not a regression; investigate directly.

## Step 1 — Build a one-shot reproducing check

The check must exit `0` when good and non-zero when bad. Detect the toolchain (see $flaky-test-investigation Step 0 for the same detection), then wrap the smallest reproducer:

```bash
# examples — pick the narrowest one that captures the symptom
npx vitest run path/to.spec.ts -t 'name'
pytest -k 'name' -q
go test ./pkg -run TestName
sh -c 'mycli --flag 2>&1 | grep -q EXPECTED || exit 1'
```

Verify the check direction before bisecting: it must **fail on HEAD** and **pass on the good ref**. If it doesn't, the check is wrong — fix it first, or the bisect lands on a false culprit.

## Step 2 — Run the automated bisect

```bash
git bisect start <bad-ref> <good-ref>
git bisect run <check-command>
git bisect reset   # always, even on failure
```

For builds that must compile before testing, make the check do both (`make build && <test>`); a compile failure mid-history should be skipped, not counted — use `exit 125` in a wrapper script for commits that can't be evaluated.

## Step 3 — Confirm and explain the culprit

`bisect run` prints the first bad commit. Don't stop there:
1. `git show <culprit>` — read the actual diff.
2. Tie the diff to the symptom: name the specific hunk that causes it. If you can't, the bisect was misled (skipped commits, non-deterministic check) — say so rather than blaming an innocent commit.
3. Propose the narrowest fix or revert.

## Outputs
The culprit commit hash, the diff hunk responsible, why it causes the symptom, and a single recommended next step (targeted fix vs revert). State your confidence and what would raise it.

---
name: test-all
description: Run every test type for the feature, push coverage to 100% on changed files, add missing tests, and fix what's broken. Steps 12 and 14 of $ship. Use when asked to test everything or verify a feature fully.
---

Run every test for the feature in the user's prompt.

The prompt gives the work-folder slug, optionally with `--final` (step 14: the pass after code review).

Never commit, branch, or push. Fixes go in the working tree; the user commits.

Read `test-plan.md`, `status.md`, and the profile's commands.

## Step 1 - Run everything

Every suite in `test-plan.md`, in this order, capturing exit codes and failure output:

1. Lint, typecheck, build.
2. Unit and integration.
3. API/request and component.
4. Browser: Playwright at desktop and mobile viewports, keyboard pass, axe scan. Start the app if needed.
5. Simulator/emulator, if native.
6. Performance checks against budgets.
7. Security cases.
8. Manual checklist: do what you can in the browser yourself, list the rest with exact steps.

## Step 2 - Coverage

Run the coverage command on every file the feature changed (`git diff --name-only <base>` plus uncommitted). Target is 100% on new and changed files. For every uncovered line: add a test, or write under `Gaps` in `test-plan.md` why it can't be covered (and get the user to agree).

## Step 3 - Do we need more tests?

Compare what ran against `plan.md`'s `Done when`, `Security`, and `Performance` sections and the mockup state inventory. Anything without a test gets one now. Ask: what would a user do that we haven't tried? What happens on a slow network, a second tab, a stale session, a duplicate submit, an empty database, a 10,000-row list? Add the tests that matter.

## Step 4 - Fix

Fix broken behavior, not broken tests. Never skip, retry-loop, or loosen an assertion to get green. If a failure is a flaky test, use the `flaky-test-investigation` skill and fix the cause. If you're unsure whether a failure is a bug or a wrong test, ask with a recommendation.

## Step 5 - Report

```
Lint/typecheck/build: ok
Unit/integration:     N passed
API/component:        N passed
Browser:              N passed (desktop, mobile, keyboard, axe)
Simulator:            …
Performance:          route p95 … (budget …)
Security:             N passed
Manual:               N done by me / N for you (listed)
Coverage (changed):   …%
Added this pass:      N tests
Open questions:       …
```

Tick checkpoint 12 (or 14 with `--final`) in `status.md`. Next: `$code-review` (after 12) or `$deploy` (after 14).

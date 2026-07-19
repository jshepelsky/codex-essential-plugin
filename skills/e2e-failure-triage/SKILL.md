---
name: e2e-failure-triage
description: Parse end-to-end test results and diagnose each failure as a logic bug, UI/selector regression, data/fixture issue, or flaky test. Use after a Playwright, Cypress, Selenium, or other E2E run fails and result artifacts are available.
---

# E2E failure triage

Read `.codex/essentials-profile.md` first when it exists.

## Phase 1 — Parse

Detect the E2E runner from the profile, package scripts, and runner configuration. Find its latest structured results or report path from configuration and known output directories. Prefer JSON or machine-readable reports; use console output only when no report exists.

Extract for every failure:

- test title;
- spec file;
- exact error and relevant stack/trace path.

If no result artifact exists, report the exact verified E2E command to run and stop. If the report has no failures, report `All tests passed.` and stop.

Cap one pass at the first 20 failures and state how many remain.

## Phase 2 — Diagnose

For each selected failure, assign a bounded read-only subagent task when subagents are available. Run only as many concurrently as there are available subagent slots; wait for a batch before starting another. Tell each worker to use `$flaky-test-investigation` with the detected E2E run command, failure title, spec path, and raw error. If subagents are unavailable, diagnose sequentially.

Each diagnosis must read the spec and trace into the relevant server handler/model/template or client component, then return:

- category: `Logic bug`, `UI/selector regression`, `Data/fixture issue`, or `Flaky`;
- root-cause `file:line`;
- evidence tying that code to the failure;
- one narrow fix suggestion;
- confidence and what would raise it.

Do not modify code during triage.

## Phase 3 — Summarize

Group failures by category. For each include test name, spec file, exact root cause, `file:line`, and recommended next action. Note shared root causes so one fix isn't counted as many unrelated problems. State how many failures were triaged and how many were deferred by the cap.

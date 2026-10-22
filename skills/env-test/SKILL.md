---
name: env-test
description: Run the feature's tests against a deployed environment: full suites on staging, read-only and data-safe checks on production. Steps 16 and 17 of $ship.
---

Test the environment named in the user's prompt.

The prompt gives `staging` or `production` (or a named env from the profile), optionally with the work-folder slug.

Never commit, branch, or push. Never modify production data.

Read the profile's `Deploy` section for the environment URL, health check, and logs; read `test-plan.md`'s `Environment tests` section.

## Staging (or any non-production env)

1. Confirm the deployed version is the one you expect (version/commit endpoint, or the deploy log).
2. Point the browser suite at the environment URL (`BASE_URL`, `PLAYWRIGHT_BASE_URL`, or whatever the project uses) and run the full Playwright flows: desktop, mobile, keyboard, axe.
3. Run API/request tests against the environment where the project supports it.
4. Run the performance checks against real infrastructure; compare to budgets.
5. Run the security cases (auth boundaries, injection payloads, rate limits) against the environment.
6. Walk the manual checklist yourself in the browser; list what's left for the user.
7. Tail logs during the run for errors.

## Production

Everything here is read-only or self-cleaning. Before any step that writes, stop and confirm it's on the test plan's approved list.

1. Health check and version check.
2. Read-only smoke: load each new screen and route as an anonymous user and as a dedicated test account if one exists; expect correct responses, no errors in logs.
3. Synthetic flows only where `test-plan.md` approved them: a clearly marked test account, records that are deleted or marked at the end, no emails or payments to real people. If the plan doesn't name a safe way to exercise a write path, don't exercise it; list it as a manual check for the user.
4. Performance: measure p95 on the new routes from outside; compare to budgets.
5. Security: unauthenticated and wrong-user access checks on every new surface (these don't write).
6. Accessibility scan on each new screen.
7. Tail logs for errors for several minutes after.

## Report

What ran, what passed, what failed with evidence, what was skipped and why, and anything that needs the user. If anything failed: say so first, then tick nothing. If clean, tick checkpoint 16/17 in `status.md`.

Next: if clean, `$document`. If not, `$ship` loops back: fix → `$test-all` → `$code-review` → `$test-all --final` → `$deploy` → `$env-test` until it's solid.

---
name: flaky-test-investigation
description: Investigate a flaky or failing test using evidence before proposing a fix. Detects the test layer (unit/integration vs end-to-end), classifies the failure mode, and gathers proof. Use when a test fails intermittently or a fix isn't obvious.
---

# Flaky test investigation

## Purpose
Investigate a flaky or failing test using evidence before proposing a fix. Works across stacks and across both **fast suites** (unit/integration) and **end-to-end** suites — detect the layer first, then follow the matching workflow.

## Required inputs
- the failing command (e.g. `make test`, `npm test`, `pytest -k ...`, `go test ./...`, the E2E runner)
- the test name or file
- the relevant failure output

> **Project profile:** if a `.codex/essentials-profile.md` file exists in the repo, read it first and trust it for this codebase's stack, commands, layout, and conventions.

## Step 0 — Detect the test layer & toolchain

```bash
cat package.json 2>/dev/null | grep -A20 '"scripts"'
ls Makefile pytest.ini pyproject.toml go.mod Cargo.toml Rakefile playwright.config.* cypress.config.* 2>/dev/null
```

Classify the failure:
- **Fast suite** (unit/integration) — runs in-process or against a test harness; failure output names a test framework (PHPUnit/pytest/Jest/Vitest/go test/RSpec) and source-relative test paths.
- **End-to-end** — drives the running app (browser or HTTP); spec files under an `e2e/`/`tests/e2e/`/`cypress/` dir, a Playwright/Cypress/Selenium runner, screenshots/traces on failure.

The investigation differs by layer.

## Fast-suite failure workflow

1. Capture the exact assertion failure and stack trace.
2. Classify the failure mode:
   - **Broken logic** — production code returns the wrong value; a real bug.
   - **Contract mismatch** — the test asserts on the wrong thing (e.g. HTTP status when the handler returns 200 with an error flag in the body; assert on the body's success field instead).
   - **Auth/setup** — the request needs a valid CSRF token, session, or fixture the test didn't establish.
   - **Fixture/state** — depends on data the test didn't provision, or state not reset between tests (shared DB rows, rate-limit/lockout counters, global singletons).
   - **Guard-clause gap** — a new production branch no test exercises.
3. When subagents are available, spawn one `explorer` subagent to find the test file, production code under test, and shared test support (base test case, HTTP/client helpers, fixture/factory setup, bootstrap). Otherwise explore these directly.
4. Propose the next narrow action. Don't propose a full fix until the failure mode is confirmed.

## End-to-end failure workflow

1. Capture the exact command and failure excerpt (and any trace/screenshot path).
2. Classify the failure mode: timing/await, shared state, environment difference, non-determinism, order-dependence, or a real server-side logic regression.
3. Identify what dynamic evidence would confirm the classification (a re-run, a trace, a log line, a network capture).
4. When subagents are available, spawn one `explorer` subagent to find the spec file, its fixtures and provisioning, wait/await patterns, and environment differences (target URL, seed data). Otherwise explore these directly.
5. Propose the next narrow action based on the findings.

## Outputs
Evidence from repository exploration, the inferred failure mode, and a single next step. Do not propose a full fix until the failure mode is confirmed.

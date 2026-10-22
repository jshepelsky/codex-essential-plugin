---
name: test-plan
description: Write the test plan for a feature: unit, integration, browser/Playwright, simulator, API, performance, security, accessibility, and manual, mapped to the implementation plan. Step 5 of $ship.
---

Write the test plan for the feature in the user's prompt.

Never commit, branch, or push. This skill writes only `.codex/work/<slug>$test-plan.md`.

Read `.codex/essentials-profile.md` (test commands, E2E command, framework), `brief.md`, `plan.md`, and the approved mockups. Look at how existing tests are written: runner, directory layout, naming, fixtures, factories, mocking style, how browser tests select elements. Match all of it.

## Step 1 - Decide the layers

For every layer the feature touches, pick the test types that apply and say why the others don't:

| Layer | Test types |
|---|---|
| Pure logic, helpers, models | unit |
| Data access, services, jobs | integration against a real test database |
| HTTP/API routes | request tests, contract/schema tests |
| UI components | component tests (render, states, interactions) |
| Full user flows in a browser | Playwright (or the project's E2E runner): desktop and mobile viewports, keyboard-only pass, axe accessibility scan |
| Native/mobile | simulator or emulator runs (Xcode Simulator, Android Emulator, Expo), device matrix if the brief names one |
| Performance | budgets from `plan.md`: query counts per request, p95 latency on key routes, bundle size, Lighthouse or k6 where it fits |
| Security | tests for each auth boundary (anonymous, wrong user, wrong role), input validation, injection payloads on every input, CSRF, rate limits |
| Manual | what can't be automated, as a checklist with exact steps and expected results |

If the project has no runner for a needed layer (no Playwright, no component tests), say so and recommend one with setup steps; ask before assuming.

## Step 2 - Map plan to tests

Every "done when" item and every file in `plan.md` gets at least one named test. Every row of the `Security` and `Performance` sections gets a test with a concrete assertion. Nothing untested gets a free pass; if something can't be tested, write why under `Gaps`.

## Step 3 - Write `test-plan.md`

```markdown
# <Title> - test plan
<!-- essentials test plan. status: draft -->

## Commands
- Unit/integration: …
- Browser: …
- Simulator: …
- Coverage: … (target: 100% on new and changed files)
- Perf: …

## Test data and fixtures
(factories, seeds, test accounts; how env tests on staging/prod stay safe: isolated test tenant or clearly marked, self-cleaning records; never real user data)

## Unit
- `tests/path/test_x` - covers … - asserts …

## Integration
## API / request
## Component
## Browser (Playwright)
- flow, viewports, keyboard pass, axe scan
## Simulator / device
## Performance
- route/metric - budget - how measured
## Security
- surface - case - expected
## Accessibility
## Manual
- [ ] step → expected

## Coverage
- how measured, target, what's excluded and why

## Environment tests
- staging: which suites run against the deployed URL, how
- production: read-only smoke and synthetic flows only, with the data-safety rules above

## Gaps
## Flakiness risks and mitigations
## Decisions
```

Show it to the user and ask the questions that remain, each with a recommendation. Tick checkpoint 5 in `status.md`. Next: `$review-plan tests`, then `$review-plan all`.

---
name: phase-plan
description: Order the work into phases with dependencies and blockers so development runs in the most efficient sequence. Step 8 of $ship. Use when asked to phase, sequence, or break down delivery.
---

Write the phase plan for the feature in the user's prompt.

Never commit, branch, or push. This skill writes only `.codex/work/<slug>/phases.md`.

Read `brief.md`, `plan.md`, `test-plan.md`, the mockups, and `status.md`.

## Step 1 - Build the dependency graph

List every unit of work from `plan.md` (files, migrations, routes, components, jobs, config). For each, note what it needs before it can be built and tested: a migration before the model, the model before the service, the service before the route, the route before the UI, the design token before the component, an external credential before the integration.

Mark **blockers** that aren't code: API keys, third-party accounts, design sign-off, data imports, access to an environment, a decision the user hasn't made. Name who unblocks each.

## Step 2 - Order it

Rules, in priority order:

1. Dependencies first. Never schedule something before what it needs.
2. Riskiest and most uncertain work early, so surprises show up while there's time to change course.
3. Every phase ends in something the user can see and exercise: a working route, a rendered screen with real data, a job that runs. No "plumbing only" phases unless unavoidable, and then say why.
4. Phases sized for one review: roughly a day of work, under about 15 changed files. Split bigger ones.
5. Group work that shares context (same files, same domain) so the developer isn't bouncing.
6. Blocked work goes as late as it can without stalling the chain; note what can proceed in parallel while it waits.

## Step 3 - Write `phases.md`

```markdown
# <Title> - phases
<!-- essentials phase plan. status: draft -->

## Blockers
- <blocker> - needed by phase N - unblocked by: <who/what> - status: open

## Phase 1 - <name>
- Goal: what the user can see/do when it's done
- Builds: files from plan.md
- Depends on: (nothing | phase N | blocker)
- Tests to write and run (from test-plan.md): …
- Manual check: how the user views the result
- Risk: what might go wrong here

## Phase 2 - …

## Parallel work
(what can proceed while a blocker is open)

## Done
(the state after the last phase, mapped to plan.md "done when")

## Decisions
```

Ask the user about anything that changes the order (a blocker they can clear now, a phase they'd rather see first), with your recommendation. Tick checkpoint 8 in `status.md`. Next: `$review-plan phases`, then `$review-plan all` to confirm everything is ready for development.

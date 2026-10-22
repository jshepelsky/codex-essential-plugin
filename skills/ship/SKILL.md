---
name: ship
description: The full delivery workflow for one feature: plan, reviews, mockups, test plan, phases, phased development, testing, code review, deploy, environment tests, and docs, with a checkpoint at every step. Use when asked to ship, deliver, or build a feature end to end, or to resume one.
---

Ship the feature described in the user's prompt.

The prompt gives the feature description (with any mocks, tickets, or context), or `resume <slug>` to pick up where a work folder left off.

This is the orchestrator. Each step runs its own skill's procedure; this skill only sets the order, the checkpoints, and the loop. Progress lives in `.codex/work/<slug>/status.md`, so a new session can `resume`.

**Rules that apply at every step:** never commit, never create or switch branches, never push, never merge, never tag. The user owns git. Stop at every checkpoint and wait; never skip ahead because a step "seems fine." When unsure, ask a question and give a recommendation with it.

## Resume

On `resume`, read `status.md`, find the first unticked checkpoint, summarize where things stand in a few lines, and continue from there.

## Steps

| # | Step | Command | Checkpoint |
|---|---|---|---|
| 1 | Plan: requirements, mocks, context, current code, research, questions, recommendations, stack decision; covers performance, security, design, copy | `$plan` | user approves `plan.md` |
| 2 | Review plan: fine-tooth, reuse existing code, standards and style, security, performance | `$review-plan plan` | review clean, user answered flags |
| 3 | Mockups, if no design was supplied, with research | `$mockup create` | user reacts |
| 4 | Mockup review: research, questions, recommendations | `$mockup review` | user approves mockups |
| 5 | Test plan: unit, browser, Playwright, simulator, API, performance, security, accessibility, manual, coverage | `$test-plan` | user approves |
| 6 | Review test plan | `$review-plan tests` | clean |
| 7 | Review test plan and implementation plan together | `$review-plan all` | they agree |
| 8 | Phase plan: order, dependencies, blockers | `$phase-plan` | user approves |
| 9 | Review phase plan against all plans; declare ready | `$review-plan all` | ready for development |
| 10 | Dev files: AGENTS.md, profile, notes | `$dev-setup` | done |
| 11 | Development, one phase at a time: build, planned tests every way, per-phase code review, update helpful files, handoff with branch name, commit message, how to see it, next phase | `$develop N` | **user reviews and commits each phase** before the next starts |
| 12 | Full testing, every surface, 100% coverage on changed files, add tests, fix | `$test-all` | clean |
| 13 | Code review with every review skill: security, copy, performance, standards, lint, syntax; fix; ask when unsure | `$code-review` | clean or justified |
| 14 | Final testing after review changes | `$test-all --final` | clean |
| 15 | Deploy, staging preferred | `$deploy <env>` | deployed and verified |
| 16 | Staging: full test run against the environment | `$env-test staging` | clean |
| 17 | Production: data-safe tests against the environment | `$env-test production` | clean |
| 18 | Fix loop: on any env-test failure, fix → 12 → 13 → 14 → 15 → 16/17 until solid | (loop) | clean |
| 19 | Documentation: write, audit, AGENTS.md, process docs | `$document` | done |

## Checkpoint behavior

At each checkpoint: update `status.md` (stage, ticked box, decisions), tell the user in a few lines what was done and what's next, ask any open questions with recommendations, and stop. The user says "go" (or redirects) and you run the next step.

Step 11 is the only step with an inner loop: after each phase's handoff, stop for the user to review and commit. Start the next phase only when they say so. Run step 12 only after the last phase is committed.

Step 18 is the outer loop: an env-test failure sends you back to step 12 with the fix in the working tree. Count the loops in `status.md`; if it takes more than two, stop and talk through what's going wrong before another pass.

## Output at each stop

- What was done (two or three lines).
- Questions, each with a recommendation.
- Checkpoint status.
- Next: `<skill>`.

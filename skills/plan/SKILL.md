---
name: plan
description: Build the implementation plan for a feature from requirements, mocks, context, and the current code, with research, questions, and recommendations; decides a stack if none exists. Step 1 of $ship. Use when asked to plan, scope, or design a feature before building.
---

Plan the feature described in the user's prompt.

Hard rules for every lifecycle skill: **never commit, never create or switch branches, never push.** The user does that. Write only to the work folder and, when a later step says so, to source files.

Read `.codex/essentials-profile.md` first if it exists. If it doesn't, say so and recommend `$first-run`; continue without it.

## Step 0 - Work folder

Every feature gets a folder: `.codex/work/<slug>/`. Create it if missing. If one already exists for this feature, read `status.md` and everything in it before doing anything else, then resume rather than restart.

Files you'll maintain here:

```
.codex/work/<slug>/
  brief.md        requirements, mocks, context, open questions (this step)
  plan.md         implementation plan (this step)
  mockups/        HTML mockups + mockup-review.md ($mockup)
  test-plan.md    ($test-plan)
  phases.md       ($phase-plan)
  status.md       stage tracker, checkpoints, decisions (every step)
  handoff/        per-phase handoff notes ($develop)
```

## Step 1 - Gather inputs into `brief.md`

Collect everything the user gave you and everything you can find:

- **Requirements**: the ask, in the user's words, then restated as observable behavior. Add a "done when" list.
- **Mocks and designs**: any images, Figma links, HTML, or screenshots supplied. Describe each one and note what's covered and what isn't. If nothing was supplied, write `Design: none supplied` so `$mockup` knows to create one.
- **Context**: tickets, docs, Slack snippets, prior plans, related features. Pull issue bodies with `gh issue view` when a number or URL is given.
- **Users and copy**: who uses this, what tone the product uses, any existing copy patterns (button labels, error messages, empty states) to match.
- **Constraints**: deadlines, platforms (web, iOS, Android, desktop), browsers, accessibility targets, data residency, budgets.

## Step 2 - Review the current code status

When subagents are available, spawn an `explorer` subagent for a very thorough read-only sweep; otherwise explore in the main thread. Then confirm specifics yourself:

- What exists today for this area: entry points, routes, components, models, jobs, tests.
- Existing components, helpers, hooks, and utilities that this feature should reuse. List them by path. New code should look like it belongs; don't plan a new function when one exists.
- The project's code standards and syntax style: lint/format config, naming, file layout, error handling, how data access is done, the test framework and assertion style. Cite the files that define them.
- Tech debt or bugs in the area that the plan must work around or should fix first.
- `git log --oneline -20 -- <area>` for recent activity and who's been in there.

## Step 3 - Decide the stack if there isn't one

If the repo is empty, or the feature needs a layer the project doesn't have (a mobile app, a queue, a search index, a design system), research and recommend:

- Two or three candidate options with a one-line case each, and your pick with the reason.
- Weigh: what the team already knows, hosting fit, cost, community, how it will be tested, how it will be deployed.
- Ask the user to confirm before the plan assumes it.

## Step 4 - Research

Do real research before recommending. Use web search for current library versions, platform constraints, known pitfalls, and accessibility and performance guidance for the pattern you're about to build. Note sources in the plan.

## Step 5 - Ask questions, make recommendations

Ask the questions that change the design, up to five, each with your recommended answer so the user can just say "yes." Record answers in `brief.md` under `Decisions`. Don't proceed past a question that blocks the architecture.

## Step 6 - Write `plan.md`

```markdown
# <Title> - implementation plan
<!-- essentials plan. status: draft -->

## Goal
## Done when
- [ ] …

## Stack and dependencies
(existing, plus anything new and why)

## Approach
## Alternatives considered

## Reuse
- `path/to/ExistingComponent` - used for …
(existing components, helpers, and patterns this plan builds on)

## Files
- `path` - create | modify - why

## Data and interfaces
(schema, migrations and reversibility, routes, API shapes, env vars, config, events)

## Design
(which mock/mockup each screen follows, states: loading, empty, error, success; responsive and accessibility notes)

## Copy
(every user-facing string this feature adds, in the product's voice; errors, empty states, buttons, emails)

## Performance
(expected load, query shapes, N+1 risks, caching, payload sizes, budgets, what to measure)

## Security
(authn/authz on every new surface, input validation, injection and XSS surfaces, secrets, rate limits, data exposure, audit logging)

## Risks and mitigations
## Out of scope
## Sources
## Decisions
- <date>: …
```

Every section gets real content or an explicit `n/a - <why>`. Keep it honest: mark anything unverified `(unconfirmed)`.

## Step 7 - Update `status.md` and stop

Create or update `status.md`:

```markdown
# <Title> - status
<!-- essentials work. slug: <slug> -->
Stage: 1 Plan
Updated: <date>

## Checkpoints
- [ ] 1 Plan written and approved
- [ ] 2 Plan reviewed
- [ ] 3 Mockups created (or design supplied)
- [ ] 4 Mockups reviewed
- [ ] 5 Test plan written
- [ ] 6 Test plan reviewed
- [ ] 7 Plans cross-checked
- [ ] 8 Phase plan written
- [ ] 9 Phase plan reviewed, ready for development
- [ ] 10 Dev files created
- [ ] 11 Development (phase _ of _)
- [ ] 12 Full testing
- [ ] 13 Code review
- [ ] 14 Final testing
- [ ] 15 Deployed to <env>
- [ ] 16/17 Environment tests passed
- [ ] 18 Fix loop clean
- [ ] 19 Documentation

## Decisions
## Open questions
```

Show the user `plan.md`, ask for approval or changes, and stop. Next: `$review-plan plan`.

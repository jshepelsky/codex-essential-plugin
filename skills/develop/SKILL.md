---
name: develop
description: Build one phase from the phase plan: code, planned tests of every type, per-phase code review, then a handoff with a branch name, commit message, and step-by-step way to see it. Never commits. Step 11 of $ship.
---

Develop the phase named in the user's prompt.

The prompt gives the phase number (or `next`), optionally followed by the work-folder slug.

**Hard rules.** Never commit, never create or switch branches, never push, never amend. The user owns git. You own the working tree. If the tree has changes you didn't make, ask before touching those files.

Read, in order: `.codex/essentials-profile.md`, `AGENTS.md`, `notes.md`, `status.md`, `phases.md` (this phase), `plan.md`, `test-plan.md`, the approved mockups, and the previous phase's `handoff/phase-<n-1>.md` if any.

## Step 0 - Baseline

Run `Lint`, `Typecheck`, and the fast `Test` suite before changing anything. If the baseline is red, stop and report; don't build on a broken suite. Confirm the previous phase was committed by the user (`git status` is clean, or only has the work folder). If it isn't, ask whether to proceed on top of it.

Set `status.md` to `Stage: 11 Development (phase N of M)`.

## Step 1 - Build the phase

For each item in the phase's `Builds` list:

1. **Read before you write.** Open the files you'll change and the pattern file `plan.md` or `notes.md` says to copy. Match the project's standards exactly: naming, imports, error handling, data access, formatting. Reuse the components and helpers the plan names; don't write a new one unless the plan says so or you've confirmed nothing fits (then note it in `Decisions`).
2. **Test first when it's behavior.** Write the failing test from `test-plan.md`, see it fail for the right reason, make it pass. `$write-tests` can draft; you own the result.
3. **Smallest diff that completes the item.** No drive-by refactors, no reformatting unrelated code. Put temptations in `plan.md`'s `Out of scope`.
4. **Follow the design.** Build to the approved mockup or supplied design, all states, both viewports. Use the copy from `plan.md` verbatim.
5. **Verify as you go.** Run `Lint` and the scoped fast tests after each item.

If something fails twice, stop, write what you tried under `Decisions`, and ask with a recommendation. If the plan turns out wrong, stop, propose the plan change, and get a yes before continuing.

## Step 2 - Test the phase, every way the plan says

Run every test type `test-plan.md` assigns to this phase, not just the unit suite:

- Unit, integration, API, component suites.
- Browser: Playwright flows at desktop and mobile viewports, keyboard-only pass, axe scan. Start the app with the profile's `Run` command if it isn't running.
- Simulator or emulator runs if the feature is native.
- Performance checks against the budgets.
- Security cases from the plan.
- The manual checklist: do what you can yourself in the browser; list the rest for the user.

Measure coverage on the files this phase touched. Anything under 100% on new or changed files: add the tests or write why it can't be covered under `Gaps` in `test-plan.md`.

Fix what's broken. Don't skip or `xit` a test to get green.

## Step 3 - Review the phase

Run `$code-review` scoped to the files changed in this phase (uncommitted tree). Fix every Critical and Warning: security, performance, standards, lint, syntax, copy. Re-run until clean or the remaining items are justified in `Decisions`. If a finding needs a judgment call, ask with a recommendation.

## Step 4 - Update the helpful files

Add to `notes.md` anything that would have saved time in this phase or will help the next one: a command, a gotcha, a fixture, a file to copy. Update `AGENTS.md` only for things every future session needs. Tick the phase's tests in `test-plan.md` and the phase in `phases.md`.

## Step 5 - Hand off

Write `handoff/phase-<N>.md` and say the same thing to the user:

```markdown
# Phase N - <name> - handoff <date>

## What we built
(a few lines, in plain words)

## How to see it, step by step
1. run …
2. open http://…
3. do … and expect …

## Tests run
- unit: N passed | browser: N passed | simulator: … | manual: items done / items for you
- coverage on changed files: …%

## Code review
- findings fixed: N | accepted with reason: N (see Decisions)

## Suggested branch name
`<type>/<slug>-phase-N-<short>`

## Suggested commit message
<subject line in the repo's convention>

<body: what and why>

## Files changed
(git status --porcelain)

## Next phase
Phase N+1 - <name>: <one line on what it does and any blocker to clear first>
```

Then stop. The user reviews, commits, and tells you when to start the next phase.

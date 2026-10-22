---
name: dev-setup
description: Create and refresh the files that help Codex develop a feature well: AGENTS.md, the Essentials profile, and per-feature notes. Step 10 of $ship.
---

Set up the development files for the feature in the user's prompt.

Never commit, branch, or push. This skill edits `AGENTS.md`, `.codex/` files, and the work folder only.

Read `.codex/essentials-profile.md`, `AGENTS.md`, any `docs/` the project keeps, and the full work folder.

## Step 1 - Profile

If there's no profile, run `$first-run` now. If there is one, re-verify the `Commands` and `Deploy` sections against the repo and fix what's stale.

## Step 2 - `AGENTS.md`

Make sure it carries the managed Essentials block that points at `.codex/essentials-profile.md` (`$first-run` writes it) and says, briefly, what Codex needs every session and can't infer fast: how to run the app and tests, the hard conventions (with the file to copy for each), the things that have burned people before, and where the work folders live. Don't paste the profile into it; don't write a novel. If it's over about 150 lines, move area-specific detail to `docs/<area>.md` and link it.

## Step 3 - Feature notes

Write `.codex/work/<slug>/notes.md`: the handful of facts a developer needs open while building this feature. Commands scoped to this area, the exact files to copy patterns from, fixtures and test accounts, the local URLs for each screen, env vars this feature needs locally, and gotchas found during planning. `$develop` reads this first and keeps it current.

## Step 4 - Tooling check

Confirm the test runners from `test-plan.md` are installed and runnable (`--version`, a list or dry run). If Playwright, simulators, or coverage tooling are missing, give the user the exact install steps and ask before installing anything that changes the repo's dependencies.

## Output

List what you created or changed. Tick checkpoint 10 in `status.md`. Next: `$develop 1`.

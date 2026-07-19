---
name: pre-pr-review
description: Run tests, discover the branch diff, and orchestrate parallel security, logic, performance, lint, route, and dependency reviews before a pull request. Use before opening or merging a PR, or when asked for a pre-merge quality gate.
---

# Pre-PR review

Read `.codex/essentials-profile.md` first when it exists.

## Phase 1 — Tests

Use the profile's verified `Test` command. If absent, detect the project entry point from its README, package scripts, Makefile/justfile, CI, and ecosystem config. Run the fast/unit suite.

If tests fail, stop the review and report the exact failure output with: `Tests failed — fix before merging.` Do not spend subagent work reviewing a branch that already fails its gate.

## Phase 2 — Discover

Determine the default branch from the profile, the remote HEAD, or CI configuration. Build the changed-file set from:

1. committed branch changes since `git merge-base <default> HEAD` when not on the default branch;
2. unstaged, staged, and untracked changes from `git diff --name-only`, `git diff --name-only --cached`, and `git ls-files --others --exclude-standard`;
3. the last commit from `git diff-tree --root --no-commit-id --name-only -r HEAD` only when on the default branch and the other scopes are empty.

If `HEAD` does not exist, use staged and untracked files as the scope and skip merge-base/last-commit fallbacks. Resolve the default branch to an existing ref, preferring `origin/<profile-name>` or the full remote HEAD ref instead of assuming a local branch exists.

Exclude vendored/generated directories and lockfiles from source review, but retain manifests/lockfiles for the dependency audit. If no reviewable changes remain, report that and stop.

## Phase 3 — Review in parallel

When subagents are available, run these six read-only tasks in batches no larger than the available subagent slots and pass the exact changed-file list to each. Wait for a batch before launching the rest. Tell each subagent to use the named skill. If subagents are unavailable, run the skills sequentially in the main thread.

- `$security-review`: injection, auth/authz, CSRF, XSS, secrets, and input validation.
- `$logic-review`: nullable results, return-shape conflicts, coercion, guards, boundaries, and swallowed errors.
- `$performance-audit`: N+1 work, unbounded reads, over-fetching, non-indexable queries, repeated work, and missing indexes.
- `$lint`: configured lint/format/type checks, native syntax checks, debug artifacts, secrets, and conflict markers.
- `$route-audit`: missing handlers and unrouted public handlers when routing is explicit.
- `$dependency-audit`: advisories and vulnerable resolved versions in every changed ecosystem.

Wait for every worker. Review workers must not edit files, upgrade dependencies, or post external comments.

## Phase 4 — Synthesize

De-duplicate findings that reference the same root cause and location. Group the final report by `Critical`, `High`, `Medium`, `Low`, and `Info`. For each finding include the source skill, `file:line`, the problem, and a one-line fix suggestion. Omit empty sections.

End with the test result and a count table for every skill that ran.

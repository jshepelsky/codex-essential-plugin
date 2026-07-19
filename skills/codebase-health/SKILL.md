---
name: codebase-health
description: Run a repository-wide health baseline across security, performance, dependencies, dead code, documentation, and lint, then synthesize a graded report. Use when adopting a codebase, after `$first-run`, or for a periodic full-repo quality audit.
---

# Codebase health

Read `.codex/essentials-profile.md` first when it exists. This workflow audits the entire repository, not only Git changes. Honor its source/layout/skip directories.

## Phase 1 — Parallel audit

When subagents are available, run these six read-only tasks in batches no larger than the available subagent slots. Wait for a batch before launching the rest. Tell each worker to use the named skill and override its normal diff scope with the entire repository. If subagents are unavailable, run them sequentially.

- `$security-review`: all request handlers, data access, templates, configuration, uploads, and external fetches.
- `$performance-audit`: all data-access code, handlers, services, and migrations.
- `$dependency-audit`: every dependency manifest and lockfile; state which scanners ran or were unavailable.
- `$dead-code`: all source modules, templates, assets, and explicitly routed handlers.
- `$docs-sync`: README, docs, environment samples, public API docs, commands, flags, routes, and setup steps against current code.
- `$lint`: the project's configured lint, formatter, typecheck, and syntax checks across the project. Cap displayed errors at the 30 most severe and state any omitted count.

Wait for all workers. Keep them read-only.

## Phase 2 — Synthesize

De-duplicate overlapping findings. Group by `Critical`, `High`, `Medium`, `Low`, and `Info`. For each issue include `file:line`, the source skill, the problem, and one specific fix suggestion.

End with a scoreboard:

| Dimension | Findings | Grade |
|---|---:|---|

Include security, performance, dependencies, dead code, docs, and lint. Grade each `clean`, `minor`, `needs-work`, or `critical`, based on severity rather than raw count.

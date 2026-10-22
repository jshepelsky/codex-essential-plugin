# Essentials for Codex

A codebase-agnostic Codex plugin for review, testing, debugging, and release-quality workflows. Every skill detects the repository's real language, framework, commands, and conventions instead of assuming one stack.

This is the Codex-native counterpart to [claude-essential-plugin](https://github.com/jshepelsky/claude-essential-plugin). Claude skills and reviewer agents are combined into focused Codex skills, while JavaScript workflows become skills that orchestrate parallel Codex subagents.

## Install

Add this repository as a marketplace and install the plugin:

```bash
codex plugin marketplace add jshepelsky/codex-essential-plugin
codex plugin add codex-essential-plugin@codex-essentials
```

For a local clone under active development:

```bash
codex plugin marketplace add /absolute/path/to/codex-essential-plugin
codex plugin add codex-essential-plugin@codex-essentials
```

Start a new Codex thread after installation so the skills and hooks load. Open `/hooks` and trust the bundled hooks before they can run.

## Start here

Explicitly invoke skills by typing `$` and selecting one:

```text
Use $first-run to profile this repository.
Use $code-review to review my current changes.
Use $pre-pr-review before I open a pull request.
```

Codex can also choose a skill implicitly when the request matches its description.

## The workflow

Run `$first-run` once per project. Then `$ship <feature>` walks every step below with a checkpoint at each one, or run the steps yourself. Progress lives in `.codex/work/<slug>/` (brief, plan, mockups, test plan, phases, status, per-phase handoffs), so a new thread can `$ship resume <slug>`.

| # | Step | Skill |
|---|---|---|
| 1 | Plan from requirements, mocks, context, and the current code; research, questions, recommendations, stack decision; covers performance, security, design, copy | `$plan` |
| 2 | Review the plan: reuse existing code, standards, security, performance | `$review-plan plan` |
| 3-4 | Mockups when no design was supplied, then a researched review | `$mockup create`, `$mockup review` |
| 5-7 | Test plan (unit, browser, Playwright, simulator, API, perf, security, a11y, manual), its review, and a cross-check with the plan | `$test-plan`, `$review-plan tests`, `$review-plan all` |
| 8-9 | Phase plan with dependencies and blockers, then a final readiness review | `$phase-plan`, `$review-plan all` |
| 10 | Dev files: AGENTS.md, profile, feature notes | `$dev-setup` |
| 11 | Build one phase: code, planned tests every way, per-phase code review, handoff with branch name, commit message, and how to see it | `$develop N` |
| 12-14 | Full testing to 100% on changed files, code review with every review skill, final testing | `$test-all`, `$code-review`, `$test-all --final` |
| 15-17 | Deploy (staging preferred), then full tests on staging or data-safe tests on production | `$deploy <env>`, `$env-test <env>` |
| 18 | Fix loop until the environment tests are clean | (ship loops 12 → 17) |
| 19 | Documentation, AGENTS.md, process docs | `$document` |

**Codex never commits, branches, pushes, merges, or tags in this workflow.** Each phase ends with a suggested branch name and commit message; you review and commit. Git-driven deploys tell you the exact push or merge to do, then watch the pipeline. Production deploys need an explicit yes on the exact command.

## Workflow skills

| Skill | What it does |
|---|---|
| `$ship` | Orchestrates the 19-step workflow above with a checkpoint per step; `$ship resume <slug>` picks up a work folder. |
| `$plan` | Step 1: brief + implementation plan in `.codex/work/<slug>/`. |
| `$review-plan` | Steps 2, 6, 7, 9: fresh-context, read-only review subagents over `plan`, `tests`, `phases`, or `all`; applies fixes, asks you the rest. |
| `$plan-review`, `$test-plan-review`, `$phase-review`, `$plan-consistency-review`, `$mockup-review` | The read-only reviewer skills those steps hand to subagents. Explicit invocation only. |
| `$mockup` | Steps 3-4: `create` HTML mockups with research when no design exists, then `review`. |
| `$test-plan` | Step 5: the test plan across every layer. |
| `$phase-plan` | Step 8: dependency-ordered phases with blockers. |
| `$dev-setup` | Step 10: AGENTS.md, profile, and feature notes. |
| `$develop` | Step 11: build one phase, test it every way, review it, hand off. |
| `$test-all` | Steps 12 and 14: every suite, 100% coverage on changed files, add tests, fix. |
| `$deploy` | Step 15: preflight, deploy via the project's mechanism (you do any git action), verify. |
| `$env-test` | Steps 16-17: tests against staging or production, data-safe on prod. |
| `$document` | Step 19: docs, AGENTS.md, process docs, close the work folder. |

## Review and quality skills

| Skill | What it does |
|---|---|
| `$code-review` | Selects relevant reviewers for the current diff, runs them in parallel, and synthesizes one prioritized report. Supports `--fix` and `--comment` when explicitly requested. |
| `$security-review` | Reviews injection, authentication/authorization, CSRF, XSS, secrets, uploads, SSRF, and input validation. |
| `$logic-review` | Finds correctness bugs that static linters miss. |
| `$performance-audit` | Finds N+1 work, unbounded reads, over-fetching, non-indexable queries, repeated work, and missing indexes. |
| `$lint` | Runs configured lint, format, type, and native syntax checks on changed files. |
| `$dependency-audit` | Uses ecosystem-native scanners for advisories, outdated packages, and likely unused or risky dependencies. |
| `$dead-code` | Finds unreferenced modules, templates, assets, and explicitly routed handlers. |
| `$copy-review` | Audits user-facing prose for clustered AI-writing tells and concrete style violations. |
| `$humanize` | Rewrites prose to remove those tells while preserving meaning and voice. |
| `$ui-review` | Audits or improves hierarchy, spacing, design consistency, responsiveness, interactions, and accessibility. |
| `$webhook-review` | Reviews signature verification, raw-body handling, idempotency, event dispatch, error handling, and secrets. |
| `$validate-migrations` | Checks ordering, naming, reversibility, SQL dialect, destructive operations, and indexes. |
| `$route-audit` | Cross-checks explicit routes and handlers for broken or unreachable endpoints. |
| `$docs-sync` | Finds documentation, examples, flags, env vars, routes, and setup steps that drifted from code. |
| `$write-tests` | Adds tests that match the repository's framework, layout, fixtures, and assertion style. |

## Test, Git, and release skills

| Skill | What it does |
|---|---|
| `$test` | Detects and runs fast and E2E suites, then classifies failures and creates a fix plan. |
| `$smoke-test` | Runs fast tests and checks safe routes on an already-running local app. |
| `$commit` | Groups changes logically, stages them, and creates commits that match repository conventions. |
| `$pr` | Pushes the current branch and opens a GitHub PR from the actual diff. |
| `$changelog` | Generates or updates release notes from Git history. |
| `$tooling-audit` | Audits and repairs Codex skills, plugins, hooks, agents, guidance, and project configuration. |

`$commit` and `$pr` mutate Git or GitHub state only when the user explicitly asks for those operations.

## Evidence-first triage skills

- `$flaky-test-investigation` classifies fast-suite and E2E failures from evidence before proposing a fix.
- `$regression-bisect` builds a deterministic reproducer and drives `git bisect run` to the introducing commit.
- `$stacktrace-triage` finds the first repository frame, traces the bad value to its source, and identifies one narrow next step.
- `$e2e-failure-triage` parses a result artifact and diagnoses failures in bounded subagent batches.

## Repository-wide orchestration

- `$pre-pr-review` runs tests, discovers the branch diff, and performs six parallel review dimensions.
- `$codebase-health` audits security, performance, dependencies, dead code, documentation, and lint across the whole repository, then produces a scoreboard.
- `$dead-code-sweep` cross-references modules, assets, templates, handlers, and routes before recommending removals.

Review workers stay read-only. The parent thread waits for every worker, removes duplicates, and owns the final report.

## Tailoring Essentials to a repository

Run `$first-run` once per project. It verifies the stack, unit and E2E test commands, lint/type/build/run commands, local URL, default branch, source/test/migration/route/UI/docs layout, skip directories, webhook integrations, conventions, and domain.

After confirmation it writes `.codex/essentials-profile.md` and maintains this small block in the repository-root `AGENTS.md`:

```markdown
<!-- essentials:start -->
## Essentials project profile

Before repository review, testing, debugging, release, or quality work, read `.codex/essentials-profile.md` when it exists and treat it as the source of truth for this project's stack, verified commands, layout, integrations, conventions, and domain.
<!-- essentials:end -->
```

Re-running `$first-run` updates verified fields while preserving hand edits. The profile carries `profile-schema: 2`; the SessionStart hook suggests a refresh when that marker is missing or stale.

## Hooks

`hooks/hooks.json` registers two fast, non-destructive hooks:

- `SessionStart` suggests `$first-run` when the project profile is missing or stale. Set `ESSENTIALS_NO_NUDGE=1` to silence it.
- `PostToolUse` checks files changed through `apply_patch`/Edit/Write with an available language-native syntax checker and warns about obvious live credential patterns. It is silent on success and never blocks the edit.

Codex requires explicit trust for plugin-bundled hooks. Inspect and enable them with `/hooks`.

### Opt-in tests on Stop

`hooks/run-tests-on-stop.sh` runs the project's fast test suite at the end of a turn. It is not enabled by default. To opt in, add this entry under the `hooks` object in `hooks/hooks.json` before installing or reinstalling the plugin:

```json
"Stop": [
  {
    "hooks": [
      {
        "type": "command",
        "command": "bash \"${PLUGIN_ROOT}/hooks/run-tests-on-stop.sh\"",
        "timeout": 600
      }
    ]
  }
]
```

Command selection is: `ESSENTIALS_TEST_CMD`, then the profile's verified `Test` command only when `ESSENTIALS_USE_PROFILE_TEST_CMD=1`, then conservative stack detection. The extra opt-in prevents a checked-in profile from silently changing the command executed by the hook.

## Design

Repository-aware review, test, debugging, documentation, dependency, and orchestration skills read `.codex/essentials-profile.md` first when present and detect missing context from repository evidence. Diff-scoped skills include unstaged, staged, and untracked files, handle unborn repositories, then use the branch merge-base against a verified existing default-branch ref and a root-commit-safe last-commit fallback.

The plugin intentionally does not ship deprecated custom prompt files or Claude-only command/agent/workflow formats. Codex skills provide both explicit `$skill` invocation and implicit selection, and orchestration skills use native subagents when available.

## License

[MIT](LICENSE) © JShep Labs LLC

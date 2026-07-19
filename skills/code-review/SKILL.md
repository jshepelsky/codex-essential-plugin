---
name: code-review
description: Orchestrate a comprehensive review of the current diff with parallel, specialized Codex subagents and one prioritized report. Use when asked for a code review, diff review, review before merge, or review with optional safe fixes or PR comments.
---

# code-review

Run a comprehensive review of the current diff using the relevant Essentials skills in specialized subagents, then synthesize one prioritized report.

Honor these optional flags when the user includes them in the prompt:
- `--fix` — after reporting, apply safe convention/style fixes (linter findings only)
- `--comment` — post Critical/Warning findings as inline GitHub PR review comments via `gh`

---

If `.codex/essentials-profile.md` exists, read it first — its `Layout`/`Skip` lines drive the bucketing below, and its `Default branch` sets the diff base.

## Step 1 — Identify what changed

```bash
git diff --name-only
git diff --name-only --cached
git ls-files --others --exclude-standard
```

Combine and de-duplicate these paths. They deliberately include untracked files and work before the repository has its first commit. If `HEAD` does not exist, use this set as the review scope and skip merge-base/last-commit fallbacks.

If the set is empty and `HEAD` exists, review the whole branch against a verified, existing default-branch ref. Prefer the profile's `Default branch`; resolve it to `origin/<name>` when only the remote ref exists. Otherwise use the full ref returned by `refs/remotes/origin/HEAD`. Do not strip a remote ref to a nonexistent local branch.

```bash
merge_base=$(git merge-base "$base_ref" HEAD)
git diff --name-only "$merge_base" HEAD
```

If that's empty too (you're on the default branch), fall back to the last commit:

```bash
git diff-tree --root --no-commit-id --name-only -r HEAD
```

Categorize the changed paths into these buckets (a file can belong to several). Use extension + path heuristics — adapt to the repo's actual layout:

| Bucket | Matches |
|---|---|
| `code` | any source file (`.php .py .js .ts .rb .go .java .rs`, etc.), excluding tests and vendored dirs |
| `data_access` | files that query the database / ORM models / repositories / services |
| `templates` | server-rendered views/templates or UI component files |
| `routes` | a central route table / URL config |
| `migrations` | schema migration files |
| `webhooks` | inbound webhook receivers or payment/event integration code |
| `manifests` | dependency manifests/lockfiles (`package.json`, `composer.json`, `requirements*`, `go.mod`, `Gemfile`, `Cargo.toml`, `*.lock`) |

If nothing relevant changed after selecting skills (for example only vendored/generated files), print "Nothing to review." and stop. Lockfile-only changes still run `$dependency-audit`; documentation changes can run `$docs-sync` and `$copy-review`.

---

## Step 2 — Select and run skills in parallel

Pick skills from the buckets. When subagents are available, run only as many workers concurrently as there are available subagent slots, one subagent per skill; wait for a batch before launching the rest. Tell each subagent to use the named `$skill` and pass the exact changed-file scope. If subagents are unavailable, run the same skills sequentially in the main thread.

| Skill | Run when |
|---|---|
| `$lint` | always |
| `$logic-review` | `code` non-empty |
| `$security-review` | `code` or `templates` non-empty |
| `$performance-audit` | `data_access` non-empty |
| `$webhook-review` | `webhooks` non-empty |
| `$route-audit` | `routes` non-empty |
| `$validate-migrations` | `migrations` non-empty |
| `$dependency-audit` | `manifests` non-empty |
| `$docs-sync` | a documented surface changed (public signature, CLI flag, env var, config key, route) |
| `$copy-review` | `templates` non-empty or user-facing strings changed |

Wait for every selected subagent to finish before synthesizing. Keep review subagents read-only; only Step 5 may authorize edits or external comments.

---

## Step 3 — Synthesize findings

Collect all skill/subagent outputs. De-duplicate findings that reference the same file and line. Present in this order:

### Critical
Security vulnerabilities, logic bugs that cause incorrect behavior or crashes, broken webhook handling, dependencies with known critical/high CVEs.

### Warning
Performance issues, route mismatches, migration problems, logic warnings, security best-practice gaps, outdated/unused dependencies, documentation that drifted from the code.

### Convention / Style
Linter violations, dead imports, copy issues.

### Info
Informational notes, unrouted handlers, suggestions.

For each finding: **[Skill]** `file:line` — description.

---

## Step 4 — Summary table

End with a count table, one row per skill that ran (skip skills not run), plus a total.

---

## Step 5 — Handle requested flags

**`--fix`**: apply fixes for `Convention / Style` findings only (linter/formatter violations). Don't auto-fix Critical/Warning findings. After fixing, re-run `$lint` to confirm clean.

**`--comment`**: post each Critical and Warning finding as an inline comment on the current PR. Check a PR exists first:

```bash
gh pr view --json number,headRefName 2>/dev/null
```

If no open PR is found, skip and note it.

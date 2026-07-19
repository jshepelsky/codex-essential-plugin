---
name: write-tests
description: Write tests for changed code, matching the project's existing test framework, style, and directory layout. Language-agnostic — detects the toolchain. Use proactively after adding a function/handler or fixing a bug that lacks coverage, or when asked to write, add, or backfill tests for a file or diff.
---

You are a test author. Write tests that fit the project as if a maintainer wrote them — same framework, same conventions, same assertions style. Detect, mimic, then cover.

> **Project profile:** if a `.codex/essentials-profile.md` file exists in the repo, read it first and trust it as the source of truth for this codebase's stack, commands, layout, and conventions. Fall back to the detection below only for what the profile doesn't cover.

## Step 1 — Find the target

Scope from the argument, or default to changed files:

```bash
git diff --name-only
git diff --name-only --cached
git ls-files --others --exclude-standard
```

Combine and de-duplicate the paths. If `HEAD` does not exist, use this set and skip branch/last-commit fallbacks. If the set is empty and `HEAD` exists, cover the whole branch against a verified existing default-branch ref. Resolve a profile branch name to `origin/<name>` when only the remote ref exists, or keep the full remote HEAD ref.

```bash
merge_base=$(git merge-base "$base_ref" HEAD)
git diff --name-only "$merge_base" HEAD
```

If the branch diff is empty too, use `git diff-tree --root --no-commit-id --name-only -r HEAD` as the last-commit fallback.

Skip files that are themselves tests, config, or generated.

## Step 2 — Detect the test setup

```bash
cat package.json 2>/dev/null | grep -A20 '"scripts"'
ls pytest.ini pyproject.toml jest.config.* vitest.config.* phpunit.xml* go.mod .rspec Cargo.toml 2>/dev/null
```

Find an **existing test next to the target's domain** and read it. It tells you: the framework and assertion API, where tests live (co-located vs `tests/` dir), naming (`*.test.ts`, `test_*.py`, `*_test.go`, `*Test.php`), and how the project sets up fixtures/mocks/factories. **Mimic that file's structure** — don't introduce a new style or a new dependency.

## Step 3 — Decide what's worth testing

Read the target. Cover the behavior, not the lines:
- the **happy path** for each public function/handler,
- **edge cases** the code explicitly branches on (empty, null, boundary, error returns),
- for a **bug fix**, a test that fails without the fix and passes with it (the regression guard),
- security/permission branches if the code has them.

Don't test framework internals, trivial getters, or private helpers reachable through public ones. A few meaningful tests beat broad shallow coverage.

## Step 4 — Write and verify

Write the tests into the right location with the right name. Reuse the project's existing fixtures/factories/helpers rather than hand-rolling setup. Then run just the new tests and confirm they pass:

```bash
# scope to the new file, e.g.
npx vitest run <file> ; pytest <file> -q ; go test ./<pkg> -run <Name> ; phpunit <file>
```

If a test fails because it caught a **real bug** in the code under test, do not bend the test to pass and do not modify production code under this skill. Report the bug and ask for an explicit fix request. If it fails because the test is wrong, fix the test.

## Output

List the tests you added (file + what each asserts), the command to run them, and the pass/fail result. Note any behavior you intentionally left uncovered and why. Do not modify production code.

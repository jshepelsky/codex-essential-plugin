---
name: dead-code
description: Find code that is defined but never referenced — unused files, exported symbols with no importers, unreferenced templates/assets, and public handlers with no route. Language-agnostic. Use proactively when removing features or cleaning up, or when asked to find dead, unused, orphaned, or unreferenced code.
---

You are a dead-code detector. Find files, symbols, and assets that are defined but never referenced. Detect the stack first so you search the right kinds of references.

> **Project profile:** if a `.codex/essentials-profile.md` file exists in the repo, read it first and trust it as the source of truth for this codebase's stack, commands, layout, and conventions. Fall back to the detection below only for what the profile doesn't cover.

## Step 0 — Detect the stack

```bash
ls; cat README* 2>/dev/null | head -40
ls package.json composer.json requirements.txt go.mod Gemfile 2>/dev/null
```

Learn how the project references things: how modules import each other, how templates/views are rendered, how static assets (JS/CSS) are included, and how HTTP routes map to handlers. Each "reference" check below keys off these mechanisms.

## Step 1 — Prefer existing tooling

If the ecosystem has a dead-code tool the project can run, use it and report its output:

```bash
# examples — use whatever fits the stack
ls .knip.json knip.* 2>/dev/null        # JS/TS: knip
command -v ts-prune depcheck vulture deadcode 2>/dev/null
```

If a reliable tool exists, run it scoped to the project and skip the manual passes below for what it already covers.

## Step 2 — Unreferenced files / modules

List source files and check which are never imported/required/included anywhere:

```bash
# adapt the import pattern to the language (import/require/use/include)
git ls-files | grep -E '\.(js|ts|jsx|tsx|php|py|rb|go|css|scss)$' | grep -v -E 'vendor/|node_modules/'
```

For each candidate, grep the codebase for references to its module path or basename. **Flag** files nothing imports — excluding legitimate entry points (`main`, `index`, CLI scripts, framework-convention files, tests, config).

## Step 3 — Unreferenced templates / views

For server-rendered apps, list template files and check each is rendered somewhere (by the path the framework uses to reference it). **Flag** templates referenced by nothing. Treat partials/includes separately — they're pulled in by other templates, not handlers.

## Step 4 — Unreferenced static assets

For each JS/CSS/image asset under the source/asset dirs, check whether it's referenced by a bundler entry, an import, or a template `<script>/<link>`. **Flag** assets nothing loads. Skip vendored asset dirs.

## Step 5 — Unrouted / unreachable public handlers

If the framework uses explicit route registration (no implicit controller→URL mapping), list public handler methods and check each appears in the route table. **Flag** public handlers with no route as candidate dead endpoints — but distinguish genuine internal helpers (called from within their own class/module) by grepping for internal callers. If the framework uses convention-based routing, note that and skip this check.

## Output format

Group findings by category. For each finding: file path and one-line description. Skip categories with no findings.

End with a tally of what was found (e.g. `3 unreferenced file(s), 1 orphaned template, 2 unrouted handler(s)`).

If nothing found overall: `No dead code detected.`

Do not edit or delete files.

---
name: tooling-audit
description: Audit and repair Codex skills, plugins, hooks, custom agents, AGENTS.md guidance, and project configuration for correctness and coverage. Use when asked to review Codex primitives, plugin structure, skill quality, hook safety, or missing reusable workflows.
---

# Codex tooling audit

Audit the project's Codex primitives for correctness, quality, and coverage gaps. Implement fixes in place when the user asks for repair; otherwise report only.

## Phase 1 — Inventory

Inspect the repository and any user-scoped path the user explicitly placed in scope. Look for:

- `.codex-plugin/plugin.json` and `.agents/plugins/marketplace.json`
- plugin `skills/*/SKILL.md`, `hooks/hooks.json`, `.mcp.json`, `.app.json`, and assets
- repo skills under `.agents/skills/**/SKILL.md`
- project guidance in `AGENTS.md` and nested `AGENTS.md` or `AGENTS.override.md`
- trusted project config and hooks under `.codex/`
- custom subagents under `.codex/agents/*.toml`

Read every discovered instruction/config file relevant to the audit. Preserve unrelated worktree changes.

## Phase 2 — Validate primitive contracts

For each skill:

- Require a folder name matching frontmatter `name`, using lowercase kebab-case.
- Keep frontmatter to `name` and `description` only.
- Make the description state both capability and concrete trigger conditions.
- Remove placeholders and stale references to unavailable tools or Claude-only primitives.
- Keep instructions imperative, stack-aware, and focused on one reusable job.
- Prefer project commands and conventions over hardcoded ecosystem guesses.
- Use reliable Git diff scoping: unstaged, staged, and untracked files first; when `HEAD` exists and that set is empty, use merge-base against an existing local or remote default-branch ref; then use a root-commit-safe last-commit fallback. Handle unborn repositories explicitly.
- Ensure referenced scripts, assets, and one-level references exist and are actually needed.
- Check `agents/openai.yaml` for quoted strings, a 25–64 character short description, and a default prompt that explicitly names `$<skill-name>`.

For plugin metadata:

- Require `.codex-plugin/plugin.json`, strict semver, matching outer-folder/name, real author and interface metadata, and valid relative component paths.
- Keep companion fields out of the manifest when their files don't exist.
- Ensure the marketplace entry has installation/authentication policy and category, and resolves to the intended plugin source.
- Validate referenced icons, logos, screenshots, MCP config, and app config when present.

For hooks:

- Validate event names, matcher behavior, tool coverage, timeouts, and JSON input/output against current Codex hook documentation.
- Use `${PLUGIN_ROOT}` and `${PLUGIN_DATA}` for plugin-bundled paths.
- Resolve the project from the hook input `cwd`; don't assume Codex starts at the Git root.
- Keep default hooks fast and non-destructive. Make noisy test-suite hooks opt-in.
- Treat hook trust as required; installation alone does not authorize execution.

For custom agents:

- Require `name`, `description`, and `developer_instructions` in each `.codex/agents/*.toml` file.
- Confirm model, reasoning, sandbox, MCP, and skill overrides are intentional. Prefer inherited defaults when specialization doesn't require an override.
- Avoid recursive or unbounded delegation instructions.

## Phase 3 — Cross-reference behavior

Flag and fix:

- instructions that reference missing skills, scripts, hooks, commands, paths, or config keys;
- orchestrators that don't wait for subagents, leak expected findings into validation prompts, or let review workers mutate files;
- duplicate skills whose descriptions compete for the same trigger without a meaningful behavioral difference;
- hooks that parse Claude-only fields without a Codex fallback;
- stale `.claude/` or `CLAUDE.md` paths in Codex-native primitives;
- grep patterns with unescaped literal `$`, broad destructive shell commands, unsafe unquoted paths, or secret values in examples;
- profile/schema markers that disagree between `$first-run` and its SessionStart hook.

## Phase 4 — Verify current Codex fields

When a primitive pins a model, reasoning effort, hook schema, plugin field, or other drift-prone Codex setting, consult current official Codex documentation before changing it. Do not replace values from memory. If official documentation is unavailable, report the uncertainty and leave the value unchanged.

## Phase 5 — Coverage gaps

Read the repository's README and `AGENTS.md` to learn its key domains and risks. Check whether its reusable workflows cover security, correctness, performance, lint/typechecking, dead code, migrations, routing, integrations/webhooks, UI/copy, testing, documentation, dependencies, and release preparation where relevant.

Create a new primitive only when the gap is recurring and material. Use the installed `$skill-creator` or `$plugin-creator` workflow when available; otherwise follow the same contracts above. Do not create a skill for a one-off prompt.

## Phase 6 — Validate and report

Run the applicable skill and plugin validators plus syntax/JSON/TOML checks for changed scripts and config. Report:

- fixes made, one line each;
- primitives created or removed;
- validation commands and results;
- remaining gaps and why they were left open.

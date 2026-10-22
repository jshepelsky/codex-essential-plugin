# Changelog

## 1.4.0 - 2026-10-22

The delivery workflow release. Mirrors claude-essential-plugin 1.4.0.

### Added
- `$ship`: a 19-step workflow for one feature, with a checkpoint at every step and `resume <slug>` to pick up in a new thread. Progress lives in `.codex/work/<slug>/`.
- Workflow skills: `$plan`, `$review-plan`, `$mockup`, `$test-plan`, `$phase-plan`, `$dev-setup`, `$develop`, `$test-all`, `$deploy`, `$env-test`, `$document`.
- Read-only reviewer skills for subagents, explicit invocation only: `$plan-review`, `$test-plan-review`, `$phase-review`, `$plan-consistency-review`, `$mockup-review`.
- `Deploy` section in the `$first-run` profile. Profile schema is now 3; the session-start hook nudges a re-run.
- Session-start hook lists unfinished features and the `$ship resume` command for each.
- `scripts/check.sh` and a GitHub Actions workflow: SKILL.md frontmatter, name-matches-directory, `agents/openai.yaml` present and valid, every `$skill` reference exists, no Claude-only leftovers, schema marker in sync.

### Changed
- The workflow never commits, branches, pushes, merges, or tags. Each development phase ends with a suggested branch name and commit message for you.
- `$ship` added to the plugin's default prompts.

## 1.3.0 - 2026-08-15
- Initial Codex-native release: review, testing, quality, and evidence-first debugging skills; ownership assigned to JShep Labs LLC; CODEOWNERS.

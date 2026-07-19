#!/usr/bin/env bash
# SessionStart: suggest $first-run when the repository profile is missing or
# uses an older schema. Silence with ESSENTIALS_NO_NUDGE=1.

set -u

[ -n "${ESSENTIALS_NO_NUDGE:-}" ] && exit 0
command -v jq >/dev/null 2>&1 || exit 0

input=$(cat)
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)
[ -n "$cwd" ] || cwd=$PWD

repo_root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null) || exit 0
profile=$repo_root/.codex/essentials-profile.md

# Keep this marker synchronized with skills/first-run/SKILL.md.
schema='profile-schema: 2'

if [ -f "$profile" ]; then
  grep -q "$schema" "$profile" && exit 0
  message='essentials: the project profile predates this plugin version. Re-run $first-run to refresh its fields while preserving hand edits. Set ESSENTIALS_NO_NUDGE=1 to silence this reminder.'
else
  message="essentials: no project profile found. Run \$first-run once to detect this repository's stack, verified commands, layout, and conventions. Set ESSENTIALS_NO_NUDGE=1 to silence this reminder."
fi

jq -n --arg message "$message" '{systemMessage: $message}'
exit 0

#!/usr/bin/env bash
# SessionStart: suggest $first-run when the repository profile is missing or
# uses an older schema, and list unfinished $ship features in .codex/work/ so a
# new thread can resume them. Silence with ESSENTIALS_NO_NUDGE=1.

set -u

[ -n "${ESSENTIALS_NO_NUDGE:-}" ] && exit 0
command -v jq >/dev/null 2>&1 || exit 0

input=$(cat)
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)
[ -n "$cwd" ] || cwd=$PWD

repo_root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null) || exit 0
profile=$repo_root/.codex/essentials-profile.md

# Keep this marker synchronized with skills/first-run/SKILL.md.
schema='profile-schema: 3'

message=''

# Unfinished $ship features: any work folder whose status.md has no "## Outcome".
for status in "$repo_root"/.codex/work/*/status.md; do
  [ -f "$status" ] || continue
  grep -q '^## Outcome' "$status" && continue
  slug=$(basename "$(dirname "$status")")
  stage=$(grep -m1 '^Stage:' "$status" | sed 's/^Stage:[[:space:]]*//')
  message="${message}essentials: feature '$slug' is in progress (${stage:-stage unknown}). Run \$ship resume $slug to continue, or read .codex/work/$slug/status.md.
"
done

if [ -f "$profile" ]; then
  if ! grep -q "$schema" "$profile"; then
    message="${message}"'essentials: the project profile predates this plugin version. Re-run $first-run to refresh its fields while preserving hand edits. Set ESSENTIALS_NO_NUDGE=1 to silence this reminder.'
  fi
else
  message="${message}essentials: no project profile found. Run \$first-run once to detect this repository's stack, verified commands, layout, and conventions. Set ESSENTIALS_NO_NUDGE=1 to silence this reminder."
fi

[ -n "$message" ] || exit 0
jq -n --arg message "${message%$'\n'}" '{systemMessage: $message}'
exit 0

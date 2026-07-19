#!/usr/bin/env bash
# Opt-in Stop hook: run the project's fast test suite at the end of a turn.
# This is intentionally not registered by default because it may be noisy.

set -u

command -v jq >/dev/null 2>&1 || exit 0
input=$(cat)
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)
[ -n "$cwd" ] || cwd=$PWD
repo_root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$repo_root" || exit 0

have() { command -v "$1" >/dev/null 2>&1; }

cmd=${ESSENTIALS_TEST_CMD:-}
if [ -z "$cmd" ] && [ "${ESSENTIALS_USE_PROFILE_TEST_CMD:-}" = "1" ] && [ -f .codex/essentials-profile.md ]; then
  cmd=$(sed -n 's/^- Test:[[:space:]]*//p' .codex/essentials-profile.md | head -1 | tr -d '`')
  case "$cmd" in *unconfirmed*|*…*) cmd="" ;; esac
fi

if [ -z "$cmd" ]; then
  if [ -f package.json ] && jq -e '.scripts.test | type == "string" and length > 0' package.json >/dev/null 2>&1 && have npm; then
    cmd='npm test --silent'
  elif { [ -f pyproject.toml ] || [ -f pytest.ini ] || [ -d tests ]; } && have pytest; then
    cmd='pytest -q'
  elif [ -f go.mod ] && have go; then
    cmd='go test ./...'
  elif [ -f Gemfile ] && have bundle; then
    cmd='bundle exec rspec --no-color'
  elif { [ -f Makefile ] || [ -f makefile ]; } && grep -qiE '^test:' Makefile makefile 2>/dev/null && have make; then
    cmd='make test'
  fi
fi

[ -n "$cmd" ] || exit 0

out=$(bash -lc "$cmd" 2>&1)
rc=$?
if [ "$rc" -ne 0 ]; then
  tail_output=$(printf '%s\n' "$out" | tail -30)
  message="[essentials] tests are failing after this turn (${cmd}):
${tail_output}"
  jq -n --arg message "$message" '{systemMessage: $message}'
fi

exit 0

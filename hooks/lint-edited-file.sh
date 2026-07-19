#!/usr/bin/env bash
# PostToolUse: syntax-check files changed through apply_patch/Edit/Write and
# warn about obvious live credentials. Silent on success and non-blocking.

set -u

input=$(cat)
command -v jq >/dev/null 2>&1 || exit 0

cwd=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)
[ -n "$cwd" ] || cwd=$PWD

patch=$(printf '%s' "$input" | jq -r '
  if (.tool_input | type) == "string" then .tool_input
  else (.tool_input.patch // .tool_input.input // .tool_input.command // "")
  end
' 2>/dev/null)

paths=$(
  {
    printf '%s' "$input" | jq -r '
      if (.tool_input | type) == "object" then
        [.tool_input.file_path?, .tool_input.path?][] |
        select(type == "string" and length > 0)
      else empty end
    ' 2>/dev/null
    printf '%s\n' "$patch" | sed -n -E 's/^\*\*\* (Update|Add) File: (.*)$/\2/p'
  } | awk 'NF && !seen[$0]++'
)

[ -n "$paths" ] || exit 0

have() { command -v "$1" >/dev/null 2>&1; }

messages=""
append_message() {
  if [ -n "$messages" ]; then
    messages="${messages}
$1"
  else
    messages=$1
  fi
}

check() {
  local tool=$1
  shift
  have "$tool" || return 0

  local out rc
  out=$("$@" 2>&1)
  rc=$?
  if [ "$rc" -ne 0 ]; then
    append_message "[essentials] syntax error in ${display_file}:
${out}"
  fi
  return 0
}

while IFS= read -r display_file; do
  [ -n "$display_file" ] || continue
  case "$display_file" in
    /*) file=$display_file ;;
    *) file=$cwd/$display_file ;;
  esac
  [ -f "$file" ] || continue

  case "$display_file" in
    *.md|*.env.example|*/examples/*|*/example/*|*/fixtures/*|*/fixture/*) : ;;
    *)
      if grep -qE 'sk_live|pk_live|whsec_|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY' "$file" 2>/dev/null; then
        append_message "[essentials] possible live secret in ${display_file}; move it to environment-backed configuration before committing."
      fi
      ;;
  esac

  case "$file" in
    *.php)            check php php -l "$file" ;;
    *.py)             check python3 python3 -c 'import ast,sys; ast.parse(open(sys.argv[1]).read(), sys.argv[1])' "$file" ;;
    *.js|*.cjs|*.mjs) check node node --check "$file" ;;
    *.rb)             check ruby ruby -c "$file" ;;
    *.go)             check gofmt gofmt -e "$file" ;;
    *.sh|*.bash)      check bash bash -n "$file" ;;
    *.json)           check jq jq empty "$file" ;;
  esac
done <<EOF
$paths
EOF

if [ -n "$messages" ]; then
  jq -n --arg message "$messages" '{systemMessage: $message}'
fi

exit 0

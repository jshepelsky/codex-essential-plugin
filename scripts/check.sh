#!/usr/bin/env bash
# Static checks for the Codex essentials plugin. Run from anywhere: scripts/check.sh
# Needs bash, python3 (with PyYAML), jq.

set -u
cd "$(dirname "$0")/.." || exit 1
fail=0
note() { echo "FAIL: $*"; fail=1; }

for f in .codex-plugin/plugin.json .agents/plugins/marketplace.json hooks/hooks.json; do
  jq . "$f" >/dev/null 2>&1 || note "$f is not valid JSON"
done
for f in hooks/*.sh scripts/*.sh; do
  bash -n "$f" || note "$f has a bash syntax error"
done

python3 - <<'PY' || fail=1
import re, glob, os, sys
try:
    import yaml
except ImportError:
    print("FAIL: PyYAML missing (pip install pyyaml)"); sys.exit(1)
bad = 0
skills = {}
for d in sorted(glob.glob('skills/*/')):
    name = d.rstrip('/').split('/')[-1]
    sk = os.path.join(d, 'SKILL.md'); oy = os.path.join(d, 'agents', 'openai.yaml')
    if not os.path.exists(sk): print(f"FAIL: {d} has no SKILL.md"); bad += 1; continue
    s = open(sk).read()
    m = re.match(r'^---\n(.*?)\n---\n', s, re.S)
    if not m: print(f"FAIL: {sk} has no frontmatter"); bad += 1; continue
    fm = {l.split(':',1)[0].strip(): l.split(':',1)[1].strip() for l in m.group(1).splitlines() if ':' in l}
    skills[name] = fm
    if fm.get('name') != name: print(f"FAIL: {sk} name '{fm.get('name')}' != dir '{name}'"); bad += 1
    if not fm.get('description'): print(f"FAIL: {sk} missing description"); bad += 1
    if not os.path.exists(oy): print(f"FAIL: {d} has no agents/openai.yaml"); bad += 1
    else:
        try:
            y = yaml.safe_load(open(oy)) or {}
            if 'interface' not in y or 'display_name' not in y['interface']:
                print(f"FAIL: {oy} missing interface.display_name"); bad += 1
        except Exception as e:
            print(f"FAIL: {oy} invalid YAML: {e}"); bad += 1
    if s.count('\n') > 500: print(f"WARN: {sk} is over 500 lines")

# Every $skill reference resolves (ignore shell variables inside code blocks).
refs = set()
for f in glob.glob('skills/*/SKILL.md') + ['README.md']:
    text = re.sub(r'```.*?```', '', open(f).read(), flags=re.S)
    refs |= set(re.findall(r'`\$([a-z][a-z-]+)', text))
for r in sorted(refs):
    builtin = ('skill', 'skill-creator', 'plugin-creator')  # Codex's own skills
    if r not in skills and r not in builtin: print(f"FAIL: ${r} is referenced but no skill exists"); bad += 1

# No Claude-only leftovers (tooling-audit names them on purpose; the AGENTS.md block markers are ours).
for f in glob.glob('skills/*/SKILL.md'):
    if f.endswith('tooling-audit/SKILL.md'): continue
    s = open(f).read().replace('essentials:start', '').replace('essentials:end', '')
    for leak in ('.claude/', 'CLAUDE.md', 'essentials:', '$ARGUMENTS'):
        if leak in s: print(f"FAIL: {f} contains Claude-only text '{leak}'"); bad += 1

a = re.search(r'profile-schema: (\d+)', open('skills/first-run/SKILL.md').read())
b = re.search(r'profile-schema: (\d+)', open('hooks/suggest-first-run.sh').read())
if not a or not b or a.group(1) != b.group(1): print("FAIL: profile-schema marker differs between first-run and hook"); bad += 1

print(f"skills: {len(skills)}")
sys.exit(1 if bad else 0)
PY

t=$(mktemp -d); git -C "$t" init -q
out=$(echo "{\"cwd\":\"$t\"}" | ESSENTIALS_NO_NUDGE=1 bash hooks/suggest-first-run.sh)
[ -z "$out" ] || note "suggest-first-run.sh not silent with ESSENTIALS_NO_NUDGE=1"
rm -rf "$t"

if [ "$fail" -eq 0 ]; then echo "all checks passed"; else exit 1; fi

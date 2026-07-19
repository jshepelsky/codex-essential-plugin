---
name: commit
description: Stage logical change groups and create clean Git commits from the current diff. Use only when the user asks to commit changes or explicitly invokes `$commit`.
---

Create one or more commits from the current changes, honoring any paths or constraints in the user's prompt.

Work in the main loop (no subagent). Be conservative — never push, never amend published commits, and never commit secrets.

## Steps

1. **Survey** the working tree:
   ```bash
   git status --porcelain
   git diff --stat
   git log --oneline -10
   ```
   Infer the repo's message convention from recent history (Conventional Commits? prefix style? imperative mood?) and match it.

2. **Check the branch.** Resolve the verified default branch from `.codex/essentials-profile.md`, the remote HEAD, or CI. If `HEAD` is on that branch, explain the situation and ask before creating a topic branch unless the user already requested one. A commit request alone does not authorize creating a branch.

3. **Group changes logically.** If the diff spans unrelated concerns, stage and commit them separately (`git add -p` or per-path) so each commit is one coherent change. If the user names paths, scope to those.

4. **Refuse to commit** obvious secrets, large binaries, or debug artifacts you spot in the diff — surface them instead.

5. **Write the message**: a concise imperative subject (≤72 chars) matching the repo's convention, and a body explaining *why* only when the change isn't self-evident. No filler, no AI tells.

6. **Commit.** Show the resulting `git log --oneline -<n>`. Push only if the user explicitly asked.

Report what you committed and what you deliberately left unstaged.

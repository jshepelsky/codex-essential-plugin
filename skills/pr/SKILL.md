---
name: pr
description: Push the current branch and open a GitHub pull request with a title and body derived from the actual diff. Use only when the user asks to create or open a PR or explicitly invokes `$pr`.
---

Open a pull request for the current branch, honoring any title, notes, or draft request in the user's prompt.

Work in the main loop (no subagent). Requires the `gh` CLI and a GitHub remote.

## Steps

1. **Determine the base and range.** Find the default branch and the merge base:
   ```bash
   git rev-parse --abbrev-ref HEAD
   gh repo view --json defaultBranchRef -q .defaultBranchRef.name
   git log --oneline <base>..HEAD
   git diff <base>...HEAD --stat
   ```
   If the current branch *is* the default branch, stop and tell the user to branch first (offer to do it).

2. **Push** the branch if it has no upstream (`git push -u origin HEAD`). Don't force-push.

3. **Write the PR** from the actual diff, not the commit subjects alone:
   - **Title** — one imperative line matching the repo's convention.
   - **Body** — a short *Summary* (what changed and why), a *Changes* bullet list, and a *Testing* note (what you ran or what the reviewer should run). Match any `.github/pull_request_template.md` if present. No filler.

4. **Create it**:
   ```bash
   gh pr create --base <base> --title "..." --body "..."
   ```
   Open as a draft if the work is incomplete or the user asked. Print the PR URL.

Fold any user-supplied title or notes into the PR. Never invent testing you didn't do — say "not yet tested" if so.

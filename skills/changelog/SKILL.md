---
name: changelog
description: Generate or update release notes from git history since the last tag or a user-specified range. Use when asked for a changelog, release notes, or an Unreleased section.
---

Generate a changelog from the range or version named in the user's prompt.

Work in the main loop (no subagent). Never tag, push, or rewrite history.

## Steps

1. **Determine the range.** If the user names a tag, ref, or range, use it. Otherwise:
   ```bash
   git describe --tags --abbrev=0 2>/dev/null
   ```
   Range is `<last-tag>..HEAD`. If the repo has no tags, use the full history when it's short (≤ ~50 commits); otherwise take the most recent 50 and say so.

2. **Read the changes, not just subjects.**
   ```bash
   git log --oneline <range>
   git diff --stat <range>
   ```
   When a subject is vague ("fix stuff", "wip"), read that commit's diff and describe what actually changed.

3. **Group and write.** If a `CHANGELOG.md` exists, match its existing format and heading style. Otherwise use Keep-a-Changelog groups: **Added / Changed / Fixed / Removed**. One user-facing line per change — what it does for the user, not the commit subject. Skip merge commits, chores, and CI noise unless they matter to users. No commit-hash dumps, no filler, no AI tells.

4. **Deliver.** If `CHANGELOG.md` exists, insert the new section at the top (under the title), headed with the version from the prompt or `## [Unreleased]` if none was given. If it doesn't exist, print the section and ask before creating the file.

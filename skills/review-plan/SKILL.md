---
name: review-plan
description: Fine-tooth review of a plan in the work folder (implementation plan, test plan, phase plan, or all together for consistency) by fresh-context, read-only subagents; applies fixes and brings open questions to the user. Steps 2, 6, 7, and 9 of $ship. Use when asked to review, critique, or sanity-check a plan.
---

Review the plan named in the user's prompt.

The prompt gives `plan`, `tests`, `phases`, or `all`, optionally followed by the work-folder slug. If no slug is given and exactly one folder exists under `.codex/work/`, use it; otherwise ask.

Never commit, branch, or push. This skill edits only files in the work folder.

The review itself is done by a subagent that hasn't seen the plan being written, so it reads it the way a second engineer would. You orchestrate, apply, and talk to the user. If subagents are unavailable, run the review skills yourself in the main thread, strictly read-only, then continue.

## Step 1 - Spawn the reviewers

Launch one read-only subagent per skill for the mode, as many in parallel as there are subagent slots. Tell each subagent to use the named `$skill`, pass it the work-folder path, and say which document to review.

| Mode | Skills |
|---|---|
| `plan` | `$plan-review`, plus `$security-review` and `$performance-audit` with the plan's `Security` and `Performance` sections and the files the plan will touch, plus `$copy-review` with the plan's `Copy` section |
| `tests` | `$test-plan-review` |
| `phases` | `$phase-review` |
| `all` | `$plan-consistency-review` |

Wait for all of them. Review subagents must not edit files.

## Step 2 - Apply

Merge the findings. For every **Must fix** and **Should fix** that you can resolve from the documents and the repo, edit the plan file(s) directly. Where two reviewers disagree, check the repo and pick; note why under `Decisions`.

Don't apply a change that needs the user's call. Collect those with the reviewers' recommendations.

## Step 3 - Record

Append to the bottom of each reviewed file:

```markdown
## Review <n> - <date>
- Changed: …
- Flagged for the user: …
- Verified against repo: …
- Verdict: …
```

## Step 4 - Report and stop

Tell the user: what you changed, the questions that need their answer (each with a recommendation), and the verdict. Tick the matching checkpoint in `status.md` only when the verdict is ready and there are no open must-fix items. Say the next skill.

If the verdict is "not ready" after you've applied fixes, re-run the reviewer once on the updated file. If it's still not ready, stop and talk it through with the user rather than looping.

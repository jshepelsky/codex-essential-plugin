---
name: deploy
description: Get the feature deployed to staging (preferred) or production using the project's real mechanism, with preflight, explicit confirmation, and verification. The user performs any git action. Step 15 of $ship.
---

Deploy as the user's prompt says.

The prompt names the target environment. Default to staging when the profile has one; use production only when it's the only environment or the user names it.

Hard rules:

- **Never commit, branch, push, tag, or merge.** If the deploy mechanism is triggered by git (push to a branch, a tag, a merged PR), you prepare everything, tell the user the exact git action to take, and then watch the result. You don't take the git action.
- **Never deploy to production without the user saying yes to the exact command in this conversation.** No flags override this.
- Never deploy a dirty working tree (uncommitted source changes), a failing suite, or code the user hasn't committed.
- Never run destructive data operations as part of a deploy without a separate confirmation.

Read the profile's `## Deploy` section. If it's missing, do Step 1, then offer to run `$first-run` to record it.

## Step 1 - Detect the deploy mechanism (only if the profile lacks it)

```bash
ls .github/workflows .gitlab-ci.yml .circleci bitbucket-pipelines.yml 2>/dev/null
ls vercel.json .vercel netlify.toml fly.toml Procfile app.json render.yaml railway.json serverless.yml wrangler.toml firebase.json amplify.yml 2>/dev/null
ls Dockerfile docker-compose*.yml Capfile deploy.rb k8s kubernetes helm charts terraform 2>/dev/null
grep -n -i -E '"deploy|release|publish' package.json 2>/dev/null; grep -n -i -E '^(deploy|release|publish)' Makefile justfile 2>/dev/null
ls bin/deploy* scripts/deploy* deploy.sh 2>/dev/null
grep -n -i -A5 'deploy' README* CONTRIBUTING* docs/*.md 2>/dev/null | head -60
```

For CI-driven deploys, open the workflow and find the trigger. Record per environment: trigger or command, URL, health-check URL, logs command, pre-deploy steps (migrations, build, cache), where secrets live, rollback method. Mark guesses `(unconfirmed)`.

## Step 2 - Preflight

Print a checklist; stop at the first failure.

1. **Tree.** `git status --porcelain` shows no source changes (the work folder is fine). If there are uncommitted source changes, stop: the user commits first.
2. **Branch.** You're on the branch the environment deploys from, or the user has told you which branch to deploy. `git fetch`; report if local is ahead of or behind the remote. If ahead, the user needs to push.
3. **Suite.** `$test-all --final` has been ticked in `status.md` for this exact tree. If not, run it now.
4. **Migrations.** List pending migrations. For each: reversible, locks, works with both old and new code. If migrations run separately from deploy, note the step.
5. **Config.** Diff env vars and config keys referenced by the feature against the last deployed commit. Check they exist in the target env if you can (`vercel env ls`, `fly secrets list`, `heroku config`); otherwise list them for the user to confirm.
6. **Release bookkeeping.** If the project keeps a changelog or version, run `$changelog` and prepare the version bump as an uncommitted change for the user to commit.
7. **What ships.** `git log --oneline <last-deployed>..HEAD`.

## Step 3 - Deploy

- **Command-driven** (`vercel`, `fly deploy`, `cap`, `make deploy`, a script): show the exact command; for production, wait for a yes. Run it and capture output.
- **Git-driven** (push, tag, merge): tell the user exactly what to do (`git push origin main`, `git tag v1.4.0 && git push --tags`, "merge PR #12"). Wait for them to say it's done, then watch the pipeline:
  ```bash
  gh run list --limit 1
  gh run watch <id> --exit-status
  ```
- Run migrations if they're a separate step, in the profile's order.
- If the deploy fails, stop and report the output. Don't retry blindly.

## Step 4 - Verify

1. Health check returns 2xx. The version or commit endpoint, if any, reports the expected SHA.
2. Load the feature's new screens and routes once.
3. Tail logs for about a minute.

If verification fails: say so first, show evidence, propose the profile's rollback, and roll back only on a yes.

## Step 5 - Report

Environment, SHA, URL, what was verified, migrations run, the rollback command ready to paste. Tick checkpoint 15 in `status.md`. Next: `$env-test <env>`.

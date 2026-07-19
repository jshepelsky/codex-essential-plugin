---
name: smoke-test
description: Run fast tests, verify an already-running local app, hit important side-effect-free routes, and check responses for leaked errors. Use when asked for a smoke test or quick local application health check.
---

# smoke-test

Run the fast test suite, then smoke-test the running app by hitting its key routes and checking for server errors. Detect how this project tests and serves itself — don't assume a stack.

If `.codex/essentials-profile.md` exists, read it first. Use its `Test` and `Run` commands only when they were verified and do not contain `(unconfirmed)`; detect any missing or unconfirmed command instead.

## Step 1 — Run the fast tests

Detect and run the unit/fast suite (see the `$test` detection: README → `make test` → `npm test` → `pytest` → `go test`, etc., preferring a "unit"-scoped variant if one exists). If anything fails, stop and report: `Tests failed — fix before smoke-testing the app.`

## Step 2 — Confirm the app is running

Find how the app serves locally and on which port:

```bash
cat README* 2>/dev/null | grep -iE 'localhost|127.0.0.1|:[0-9]{4}|docker compose up|npm (run )?(dev|start)|rails s|php artisan serve|flask run|uvicorn' | head
cat package.json docker-compose.* Procfile Makefile 2>/dev/null | grep -iE 'dev|start|serve|port' | head
```

Check whether it's already up (e.g. `curl -s -o /dev/null -w "%{http_code}" http://localhost:<port>/`). If it isn't running, stop and tell the user the command to start it (the one you found) rather than starting it yourself unless they asked.

## Step 3 — Hit key routes

Identify a handful of important, side-effect-free routes (health check, home, a couple of public pages or read-only API endpoints — read the route table if needed). Curl each and capture the status:

```bash
curl -s -o /dev/null -w "%{http_code}  <path>\n" http://localhost:<port>/<path>
```

Expected: `2xx` (a `3xx` redirect may be legitimate). `5xx` indicates a server error; an unexpected `404` indicates a routing problem.

## Step 4 — Check response bodies for leaked errors

For routes that returned 200, grep the body for leaked error output (stack traces, framework error pages):

```bash
curl -s http://localhost:<port>/<path> | grep -iE 'fatal error|parse error|traceback|stack trace|exception|warning:|undefined'
```

## Step 5 — Report

For each route: status and whether any error string was found in the body. Flag any unexpected status or leaked error.

If all routes are healthy: `Smoke test passed — all routes healthy.`

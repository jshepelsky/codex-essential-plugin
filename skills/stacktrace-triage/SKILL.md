---
name: stacktrace-triage
description: Triage a stack trace or error log to the root-cause frame using evidence before proposing a fix. Detects the language, locates the throwing frame in source, classifies the failure mode, and gathers proof. Use when given a crash, exception, or error log and the cause isn't obvious.
---

# Stacktrace triage

## Purpose
Turn a raw stack trace or error log into a confirmed root cause. Detect the language from the trace shape, find the throwing frame in the repo, classify the failure mode, and gather proof — before proposing any fix. The production-error sibling of $flaky-test-investigation.

## Required inputs
- the full stack trace or error excerpt (not just the message — the frames matter)
- ideally the input/request that triggered it; otherwise note it's missing

> **Project profile:** if a `.codex/essentials-profile.md` file exists in the repo, read it first and trust it for this codebase's stack, commands, layout, and conventions.

## Step 0 — Detect language & isolate the originating frame

Trace shape names the language: `at fn (file.js:12:5)` (JS/TS), `File "x.py", line 12` (Python), `goroutine ... file.go:12` (Go), `#0 /x.php(12)` (PHP), `from x.rb:12` (Ruby), `at com.x.Y(Z.java:12)` (Java).

The top frame is the *throw site*, not always the *cause*. Walk down to the **first frame inside this repo** (skip vendor/stdlib/node_modules frames) — that's where you start reading.

## Step 1 — Classify the failure mode

- **Null/undefined access** — a value assumed present was absent; trace it to the source that should have populated it.
- **Type/contract mismatch** — caller and callee disagree on shape (wrong arg, API response changed, schema drift).
- **Config/environment** — missing env var, file, credential, or service; reproduces only in some environments.
- **External dependency** — a network/DB/3rd-party call failed or timed out; the trace points at the client wrapper.
- **Resource/limit** — OOM, connection pool exhausted, file descriptor leak, timeout.
- **Logic bug** — the code is simply wrong on this path; often a $regression-bisect candidate if it used to work.

## Step 2 — Gather evidence

When subagents are available, spawn one `explorer` subagent to find the originating frame's source, its callers, and what should have produced the bad value. Otherwise explore these directly. Look for:
- the unguarded access or wrong assumption at the frame.
- whether the triggering input is reachable from a real entry point (route, job, CLI) or only a degenerate case.
- recent changes to that file (`git log -5 --oneline -- <file>`) — if it regressed, hand to $regression-bisect.

## Step 3 — Propose the narrow next step

Don't propose a full fix until the mode is confirmed. The right fix lives at the **root**, not the throw site — a guard in the shared producer beats a try/catch at every call site. Name the file:line, the cause, and one action.

## Outputs
Originating frame (file:line), classified failure mode, the evidence, and a single next step. State confidence and what would confirm it.

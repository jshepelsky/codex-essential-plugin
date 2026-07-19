---
name: dead-code-sweep
description: Sweep an entire repository for unreferenced modules, static assets, templates, unrouted handlers, and broken routes with parallel cross-reference checks. Use for a deliberate cleanup pass or before removing a feature.
---

# Dead-code sweep

Read `.codex/essentials-profile.md` first when it exists. Audit the entire repository and honor its layout and skip directories.

## Phase 1 — Scan in parallel

When subagents are available, launch four read-only workers concurrently. Otherwise run the checks sequentially.

1. **Orphaned modules**: detect the stack and find source files/modules never imported, required, included, registered, or executed. Exclude real entry points, CLI/maintenance scripts, tests, config, and framework-convention files. Return each candidate plus the reference searches used.
2. **Orphaned assets**: detect how JS, CSS, images, fonts, and other static assets are bundled or included. Find source assets referenced by no entry, import, manifest, stylesheet, or template. Exclude vendored assets.
3. **Orphaned templates**: detect the view system and find templates never rendered or included. Treat partials/includes separately. Report that the dimension is inapplicable when the app has no server-rendered templates.
4. **Route gaps**: use `$route-audit` over the full repository to find public handlers with no route when registration is explicit, and routes whose referenced handler is missing.

Wait for all workers. Do not delete or edit anything during the scan.

## Phase 2 — Cross-reference

Validate candidates across worker outputs and remove false positives that are plainly intentional internals. De-duplicate the remainder into:

- Orphaned modules/files
- Orphaned assets
- Orphaned templates
- Unrouted handlers
- Broken routes

For each item include its path, why it is dead, the confirming evidence, and one action: delete file, remove reference, add route, or remove route. Finish with counts by category. Do not apply removals unless the user separately authorizes them.

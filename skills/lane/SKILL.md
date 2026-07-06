---
description: Spawn a build lane with the house brief template — worktree isolation, live-contract declarations, format-before-push, structured final report. Invoke with /lane [task description].
---

You have been invoked as `/lane` to spawn a build lane for: $ARGUMENTS

Your role: compose a complete lane brief from the house template below plus the task specifics, pick the right subagent type for the surface, and launch it with `isolation: "worktree"`. You supply ONLY the task-specific content; the template supplies the discipline.

**Before launching:**

1. If the task touches ANY external interface (third-party API, webhook payload, cross-library client boundary, DB wire format): check whether a real sample exists (prod row, logged payload, prior capture). If none exists and one is capturable read-only, capture it NOW and paste it into the brief. If not capturable yet, the brief's first deliverable becomes the instrumented capture path (Live-Contract Rule #1).
2. Check for parallel lanes touching the same hotspot files ({{your registry/config/changelog collision magnets}}) — if overlap, add a coordination instruction or serialize.
3. If a shared run log is active, note the lane launch in it.

**The house template — include ALL of these in every brief, verbatim-adapted:**

- Branch name: `feat/…` or `fix/…`, stated explicitly.
- `isolation: worktree`; NEVER build on the shared checkout.
- Rebase onto the default branch FIRST and again before push (busy repos drift fast).
- Migrations: check the next free number against merged migrations AND live parallel lanes; take it explicitly; include the repo's migration-registration ritual; **DO NOT apply**.
- Formatters/linters run on every touched file BEFORE push ({{your formatter}} — CI failing on formatting is pure wasted round-trips).
- Tests: hermetic — transport-level HTTP mocking, autouse fixtures for service clients, NEVER real network (DNS attempts from one test file can poison later files). Mocks built FROM captured reality, never from docs/memory.
- Scripts that will touch prod: dry-run default, `--apply` explicit + confirmation phrase; the first prod dry-run is part of acceptance.
- Push with explicit ref (`git push origin HEAD:<branch>`); open the PR; **DO NOT merge** — merge authority is the master session's, role-based, always.
- FINAL report (structured YAML) must include: `pr`, task-specific result keys, `contracts:` (each external touchpoint marked `live-verified` | `assumed`), `tests`, and any `parked` items with reasons.

**After launching:** tell the user which lane started, what it builds, and which contracts (if any) are `assumed` and will need a probe at merge time.

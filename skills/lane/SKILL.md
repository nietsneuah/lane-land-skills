---
description: Spawn a build lane with the house brief template — worktree isolation, live-contract declarations, format-before-push, FINAL YAML. Invoke with /lane [task description]. Encodes the D-124-weekend lessons so no brief forgets them.
---

You have been invoked as `/lane` to spawn a build lane for: $ARGUMENTS

Your role: compose a complete lane brief from the house template below + the task specifics, pick the right subagent type ({{YOUR_SUBAGENT_TYPES}} per `your team SOP` §Subagent routing), and launch it with `isolation: "worktree"`. You supply ONLY the task-specific content; the template supplies the discipline.

**Before launching:**

1. If the task touches ANY external interface (third-party API, webhook payload, cross-library client boundary, DB wire format): check whether a real sample exists (prod row, logged payload, prior capture). If none exists and one is capturable read-only, capture it NOW and paste it into the brief. If not capturable yet, the brief's deliverable becomes the instrumented capture path FIRST (SOP §Live-contract rule #1).
2. Check for parallel lanes touching the same hotspot files (`worker/registry.py`, `{{DECISIONS_INDEX}}`, `conversations_*.py` are the known collision magnets) — if overlap, note the coordination instruction in the brief or serialize.
3. During a sprint/collab window: note the lane launch in the designated lane log if the doc calls for it.

**The house template — include ALL of these in every brief verbatim-adapted:**

- Branch name: `feat/…` or `fix/…`, stated explicitly.
- `isolation: worktree`; NEVER build on the shared checkout.
- Rebase onto `origin/main` FIRST and again before push (busy repos drift fast).
- Migrations: check the next free number against merged migrations AND live parallel lanes; take the number explicitly; G-1 gate = same-PR {{DECISIONS_INDEX}} line; D-020 remote-state registration INSERT; **DO NOT apply**.
- Python: the LAST command before push MUST be `git diff --name-only origin/main | grep '\.py$' | xargs uv run ruff format` (full-diff pass, not per-file memory) and its output MUST be pasted in FINAL YAML under `format_proof:` — CI failed on this 4× across two days when it was a mere instruction; `ruff check --fix`; mypy no-any-return trap — wrap PostgREST `.get()` extractions in `str()`.
- Tests: hermetic (respx transport-level for httpx; `_hermetic_sb`-style autouse fixtures; NEVER real network — DNS attempts poison later test files). Mocks built FROM captured reality, never from docs/memory.
- Scripts that will touch prod: dry-run default, `--apply` explicit + confirmation phrase; the first prod dry-run is part of acceptance.
- Push with explicit ref (`git push origin HEAD:<branch>`); `gh pr create`; **DO NOT merge** (master session merges — role-based, always).
- FINAL YAML must include: `pr`, task-specific result keys, `contracts:` (each external touchpoint marked `live-verified` | `assumed`; live-verified means verified against the OPERATIVE working set the code will actually process — not just any sample — with the verifying query/probe quoted; a coverage ceiling in the unexamined portion burned us 2026-07-06), `tests`, and any `parked_for_doug` items with reasons.
- Co-Authored-By trailer per repo convention.

**After launching:** tell the user which lane started, what it builds, and which contracts (if any) are `assumed` and will need a master probe at merge time.

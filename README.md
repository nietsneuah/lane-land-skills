# lane & land — running parallel AI agents with guardrails that earn the autonomy

Two [Claude Code skills](https://docs.anthropic.com/claude-code) plus the working doctrine behind them, extracted from a real production system built largely by AI lanes under one human's direction — including an eight-hour unattended overnight run that shipped ten pull requests and crossed zero hard lines. Generalized for any repo; the specifics are scrubbed, the scar tissue is not.

The doctrine has three pillars. The skills encode them.

---

## Pillar 1 — Parallel build, serialized release

Agents parallelize beautifully at the *build* stage and catastrophically at the *release* stage. The pattern that works:

- **Lanes**: each task runs in an isolated git worktree with a disciplined brief — bounded scope, house conventions baked in, a structured final report, and a hard **do-not-merge**. Six to eight lanes run comfortably in parallel.
- **One merge authority.** A single "master" session lands every PR, serially. When six lanes append to the same registry file (they will — hotspot files are predictable), union-merging additive conflicts is mechanical *if one session does it in sequence*, verifying the file still parses after each union. We dropped a closing brace in a hand-union once; the parser caught what the visual diff didn't.
- **State-verified landing.** Never trust pipeline echoes: `cmd | tail -1 && echo OK` reports the tail's exit code and prints OK on failure — a bug that produced two phantom "merged" reports in one night. Query the platform for `MERGED`; that's the only truth.
- **Brief from evidence.** The master's highest-leverage act isn't writing code — it's capturing a real payload/row/schema and pasting it into the lane's brief. Lanes that start from captured reality don't guess.
- **Batch the deploys.** Consecutive landings share one release; verify health *after* (a completed release is not a working feature).

## Pillar 2 — The Live-Contract Rule (why green tests go red in production)

Agent-built software's signature failure: mocks built from docs or model memory encode a *guess* about an external interface. Tests pass; the first live event crashes. We paid this ~8 times in one weekend (header-name drift, a documented-object arriving as a bare string, an API whose history endpoint spoke a different type dialect than its webhooks, two DB clients with incompatible interfaces behind similar names).

1. **Capture reality before mocking it.** One real sample — probe call, prod row, logged payload — becomes the fixture. Can't capture yet? Ship the instrumented capture path *first*. (The one integration we built capture-first went clean end-to-end.)
2. **Lanes declare contract provenance**: every external touchpoint marked `live-verified` or `assumed` in the final report.
3. **The merger probes `assumed` contracts** with one live read-only call before merging — or accepts the risk explicitly. Never silent.
4. **Live behavior contradicts green tests ⇒ suspect the mock first.** Probe with real credentials outside the app before patching the app.
5. **Prod-touching scripts are dry-run-first by construction**, and the first prod dry-run is part of acceptance.

## Pillar 3 — Guardrails that earn the autonomy

Autonomy isn't a switch; it's a *layered permission architecture*. Ours has four layers, and the unattended run was safe because all four were on:

- **Hard lines (never-suspendable):** a short written list no autonomous run may cross regardless of momentum — for us: no external/customer-facing sends, no feature flags affecting live operations, no writes to the financial core, no force-push, no secrets/CI edits. The agent knows the list and *parks* instead of improvising.
- **Structural hooks:** pre-execution hooks that block destructive patterns (mass deletes, force-push, writes to gated files) mechanically — the agent can't talk its way past them, and when one fires the rule is *fix the root cause, never bypass*.
- **An intent classifier:** a second model reviewing risky actions against what the human actually asked. Ours blocked a production write until the human said the words, and blocked ad-hoc remote code execution outright. Twice it was "wrong" and the human overrode with one line — cheap. The times it was right paid for everything.
- **The human gate, made cheap:** ambiguity parks for morning; decisions batch into a checkpoint queue; risky cutovers ship as *dormant dual-run* (new path deployed but inert until a human flips it — adoption doctrine: earn trust with evidence, cut over when proven, never as a side effect of deploying code).

And the ratchet that holds it together: **every burn gets a structural answer the same session** — a convention, then a skill, then a hook, then a CI gate, escalating until it can't recur. These two skills are themselves that ratchet firing: a night of hand-ritual mistakes, promoted to enforced checklists the next day.

---

## The two skills

**`/lane`** composes the build-lane brief with all of Pillar 1+2 baked in: worktree, rebase hygiene, format-before-push, hermetic tests with fixtures from captured reality, `contracts:` declarations, structured report, do-not-merge.

**`/land`** walks the merge train: read the report → probe `assumed` contracts → read every check → state-verified merge with parse-verified conflict unions → migrations from a fresh checkout, absolute paths → deploy-parity check *after* pulling → post-deploy verification → append the run log now, not later.

Both contain `{{house-specific}}` placeholders — your migration command, your gate names, your hard-line list. Fill them once; the discipline transfers.

## License

MIT. Built with Claude Code; shared because the failure modes — and the guardrails — are universal.

---
description: Land a lane's PR — the master merge train as an enforced checklist. Invoke with /land [PR number(s)]. State-verified merges, assumed-contract probes, migration apply, deploy parity, run-log append.
---

You have been invoked as `/land` for: $ARGUMENTS

Your role: run the master session's merge train for the given PR(s), in order, skipping nothing. Each step exists because skipping it has a specific failure behind it.

**Per PR, in order:**

1. **Role check**: you are the master session (canonical checkout, sole merge authority). A sub/parallel session invoking this stops here and hands off instead.
2. **Read the lane's final report** (or PR body). Extract: migration files, `contracts:` declarations, deploy needs, parked items.
3. **Probe `assumed` contracts** (Live-Contract Rule #3): any external touchpoint the lane marked `assumed` gets one live read-only probe BEFORE merging — or record an explicit risk acceptance on the PR. Never silent.
4. **Read every CI check**: required greens by name; know which checks are advisory-broken or slow-post in {{your repo}}. Formatting failure? Fix on the branch and push; don't wave through.
5. **House gates**: {{e.g., migration-added ⇒ decisions-doc touched in the same PR}}. Missing ⇒ fix on the branch before merge.
6. **State-verified merge** — NEVER trust pipeline echoes:
   - Loop: query the platform for the PR's state; `MERGED` breaks the loop.
   - Checks green + mergeable ⇒ merge (squash).
   - `CONFLICTING` ⇒ resolve (union for additive registry/changelog conflicts; VERIFY the file parses and imports after the union — a dropped brace survives a visual diff), push, re-loop.
   - Anti-pattern: `cmd | tail -1 && echo OK` — the pipeline's exit code is the tail's, so this prints OK on failure.
7. **Migrations**: after merge, sync the default branch fresh, then apply with {{your prod migration command}} using an ABSOLUTE path (cwd drift during long sessions is real). Verify the migration's self-check output.
8. **Deploy decision**: batch backend deploys across consecutive landings when possible; run the deploy-parity check (local HEAD == origin default) AFTER pulling, never chained before it — a stale tree ships stale code.
9. **Post-deploy verification**: health endpoint / worker heartbeat / one supervised run of any new handler. "Release complete" is not "feature works."
10. **Run-log append**: if a shared run log is active, append the merge/park/gate event NOW — not later. More than 3 stale events anywhere = stop and backfill before the next merge.
11. **Report**: what landed, what deployed, what's parked, which probes ran and their verdicts.

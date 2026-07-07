---
description: Land a lane's PR — the master merge train as an enforced checklist. Invoke with /land [PR number(s)]. State-verified merges, assumed-contract probes, mig apply, deploy parity, lane-log append.
---

You have been invoked as `/land` for: $ARGUMENTS

**Repo pinning:** every `gh` command in this ritual uses `-R <owner>/<repo>` explicitly — cwd-derived repo context broke the train the day a second repo appeared on the machine (2026-07-06).

Your role: run the master session's merge train for the given PR(s), in order, skipping nothing. This is a checklist skill — each step happened this weekend as a hand ritual and each has a burn behind it.

**Per PR, in order:**

1. **Role check**: you are the master session (canonical checkout, sole merge authority). A sub/parallel session invoking this stops here and hands off instead.
2. **Read the lane's FINAL YAML** (or PR body). Extract: migration files, `contracts:` declarations, deploy needs, parked items.
3. **Probe `assumed` contracts** (SOP §Live-contract rule #3): any external touchpoint the lane marked `assumed` gets one live read-only probe (dry-run, sample fetch, prod-row check) BEFORE merging — or record an explicit risk acceptance in the merge commit/PR comment. Never silent.
4. **Checks, read every one**: `gh pr checks` — required greens; `claude-review` is advisory-broken (known); `rls-fuzzer`/`smoke` are slow post-checks (judgment per repo convention). Formatting failure? Fix on the branch (`ruff format` + push), don't wave through.
5. **G-1 gate**: migration added ⇒ {{DECISIONS_INDEX}} touched in the same PR. Missing ⇒ fix on the branch before merge.
6. **State-verified merge** — NEVER trust pipeline echoes:
   ```
   loop: state=$(gh pr view N --json state -q .state); [ MERGED ] && break
         checks green && mergeable=MERGEABLE ⇒ gh pr merge N --squash
         mergeable=CONFLICTING ⇒ resolve (union for additive registry/changelog conflicts;
             verify the file PARSES + imports after union — a dropped brace burned us),
             push, re-loop
   ```
   The `cmd | tail -1 && echo OK` pattern reports false success (pipeline exit = tail's) — never use it.
7. **Migrations**: after merge, `git checkout main && git pull --ff-only`, then `pg-prod -f <mig>` from the FRESH checkout (absolute path; cwd drift burned us repeatedly). Verify the self-verify NOTICE/COMMIT.
8. **Deploy decision**: batch orchestrator deploys across consecutive landings when possible; deploy-from-main parity check (`rev-parse HEAD == origin/main`) BEFORE `fly deploy` — pull first, never chain rev-parse;deploy (ships stale tree). Frontend rides Vercel automatically.
9. **Post-deploy verification**: worker heartbeat / health endpoint / one supervised run of any new handler — "release complete" is not "feature works".
10. **Lane log append** (SOP rider): during any sprint/collab window, append the merge/park/gate event to the designated lane log NOW — not later. >3 stale events anywhere = stop and backfill first.
11. **Checkpoint queue upkeep**: anything this landing parked for Doug goes into `{{CHECKPOINT_QUEUE_DOC}}` (tagged [gate]/[redline]/[decide]/[verify]); anything he cleared moves to its Cleared section.
12. **Report**: what landed, what deployed, what's parked for Doug, which probes ran and their verdicts.

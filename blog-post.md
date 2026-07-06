# One Founder, Eight Parallel AI Agents, and the Guardrails That Made It Safe

This weekend, NectoMax — our ERP for small service businesses — gained a unified communications inbox: web chat, SMS, email, and phone calls threading into one place, with a screen pop that shows the customer's name and history while their call is still ringing. Four channels, ratified design to production, in about 48 hours. One stretch of it — ten pull requests' worth — shipped overnight while I slept.

I'm a solo founder. That sentence used to be a constraint. This post is about the three disciplines that turned it into a deployment strategy — including the one we adopted mid-weekend after paying the same tax eight times.

## Pillar 1: Parallel build, serialized release

The build ran as six to eight simultaneous AI "lanes" — each an isolated git worktree with a bounded brief, producing a tested pull request and a structured report, forbidden from merging. One session (with me looking over its shoulder, and later not) held sole merge authority and landed everything serially.

That asymmetry is the whole trick. Agents parallelize beautifully at the build stage and catastrophically at the release stage. Six lanes appended to the same registry file in one night — predictable, mechanical to resolve — *because* one session union-merged them in sequence and verified the file still parsed after each union. (We dropped a closing brace once. The parser caught what the visual diff didn't.)

The master session's highest-leverage act, it turns out, isn't writing code. It's **capturing evidence and putting it in the brief** — a real payload, a real database row, a real schema — so the lane starts from reality instead of guessing.

## Pillar 2: Green tests, red production — the Live-Contract Rule

AI-built software has a signature failure mode. An agent codes against an external interface, builds mocks from documentation or its training memory, tests pass, CI passes — and the first live event crashes, because the mock encoded a guess.

We paid that toll roughly eight times in one weekend. A webhook that carried its security token under a different header name than its handshake used — every real event rejected, the vendor quietly blacklisting our endpoint for unresponsiveness. A field documented as an object arriving as a bare string — a 500 on every call event, discovered only when I placed a real phone call. A history API speaking a different message-type dialect than the same vendor's webhooks — 120 messages silently skipped. Two database clients with incompatible interfaces behind similar names — invisible to unit tests that mocked the client.

Every one had green tests. So we adopted a rule about **where mocks come from**, now in our standing procedure:

1. Capture one real sample of any external interface *before* building against it; fixtures come from the capture. Can't capture yet? Ship the instrumented capture path first.
2. Every build lane labels each external touchpoint `live-verified` or `assumed`.
3. The merger probes every `assumed` contract with one live read-only call before merging — or accepts the risk in writing.
4. When live behavior contradicts green tests, suspect the mock first.
5. Prod-touching scripts are dry-run-first by construction, and the first prod dry-run is part of acceptance.

The control group: the one integration we built capture-first — instrument, place a real call, read the actual payload, *then* write the translation — went clean end to end, first try.

## Pillar 3: Guardrails that earn the autonomy

The overnight run wasn't brave; it was *fenced*. Four layers:

**Hard lines.** A short written list no autonomous run may cross: nothing customer-facing sends, no feature flags affecting live operations, no writes to the financial core, no force-push, no secrets or CI edits. When a task brushed the list, the agent parked it for morning instead of improvising.

**Structural hooks.** Pre-execution tripwires that mechanically block destructive patterns — mass deletes, force-pushes, writes to gated files. The agent can't talk its way past them, and the house rule is *fix the root cause, never bypass*.

**An intent classifier.** A second model reviewing risky actions against what I actually asked for. It blocked a production write until I typed the authorizing words. It refused ad-hoc remote code execution on the production host outright. Twice it was overcautious and I overrode it with one line — cheap. The times it was right paid for the whole layer.

**A cheap human gate.** Decisions batch into a checkpoint queue I clear with my coffee. Risky cutovers deploy *dormant* — built, tested, running in parallel, inert until I flip them. That's also our product doctrine ("you don't have to cut over on day one — migrate as you feel comfortable"), applied to our own pipeline: **trust is earned with evidence; cutover is a decision, never a side effect of deploying code.**

And the ratchet binding it all: every mistake gets a structural answer the same session — convention, then skill, then hook, then CI gate, escalating until it can't recur. The two skills we open-sourced from this weekend (https://github.com/nietsneuah/lane-land-skills) are that ratchet firing in real time: a night of hand-ritual slips, promoted to enforced checklists by morning.

## The score

Four live channels. A screen pop that beat our two-second budget. A callback worklist that clears itself when you physically return the call. Roughly thirty merged PRs, eight production incidents *caused and fixed by the same process* — and a process that got structurally harder to burn with every one.

---

*NectoMax is a modular ERP for small service businesses — adopt one piece at a time, keep everything that already works. If you run a shop drowning in disconnected tools, we'd love to talk.*

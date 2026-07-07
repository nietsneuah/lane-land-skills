#!/usr/bin/env bash
# land-pr.sh <pr-number> [owner/repo] — the state-verified merge loop, canonical.
# Exit codes: 0=MERGED, 2=CONFLICTING (resolve + rerun), 3=checks red (fix + rerun), 4=timeout.
set -u
PR="${1:?usage: land-pr.sh <pr-number> [owner/repo]}"
REPO="${2:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"
for i in $(seq 1 20); do
  ST=$(gh pr view "$PR" -R "$REPO" --json state -q .state 2>/dev/null)
  [ "$ST" = "MERGED" ] && echo "MERGED" && exit 0
  M=$(gh pr view "$PR" -R "$REPO" --json mergeable -q .mergeable 2>/dev/null)
  [ "$M" = "CONFLICTING" ] && echo "CONFLICTING" && exit 2
  NOT_GREEN=$(gh pr checks "$PR" -R "$REPO" 2>/dev/null | grep -vE "pass|skipping|claude-review")
  N=$(printf '%s' "$NOT_GREEN" | grep -c . || true)
  FAILS=$(printf '%s' "$NOT_GREEN" | grep -c fail || true)
  if [ "$N" = "0" ] && [ "$M" = "MERGEABLE" ]; then
    gh pr merge "$PR" -R "$REPO" --squash >/dev/null 2>&1
  elif [ "$FAILS" != "0" ] && [ "$N" = "$FAILS" ]; then
    echo "CHECKS_RED:"; printf '%s\n' "$NOT_GREEN" | awk '{print "  "$1}'; exit 3
  fi
  sleep 32
done
echo "TIMEOUT (state=$(gh pr view "$PR" -R "$REPO" --json state -q .state))"; exit 4

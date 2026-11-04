#!/bin/sh
# SessionStart for Rocketship. Claude Code runs SessionStart hooks only as commands, never as
# http hooks, so this script posts the hook's JSON (session_id, cwd, source) to Rocketship and
# prints what Rocketship answers: the hookSpecificOutput with the session's context.
#
# It also tells Rocketship which project this folder is, two ways, as headers so the hook's own
# JSON goes on unchanged:
#   X-Rocketship-Project  the "project" slug in a committed .rocketship.json at the repo root
#   X-Rocketship-Repo     the GitHub owner/name of the repo's origin remote, never its URL
#
# The token reaches curl on its config input, never on the command line. The script always
# exits 0: a session never fails to start because Rocketship is down.

URL="${ROCKETSHIP_HOOK_URL:-https://rocketship.72-60-110-109.sslip.io/api/bridge/hooks}"

payload=$(cat)

if [ -z "${ROCKETSHIP_TOKEN:-}" ]; then
  echo "Rocketship is not connected in this Claude Code: ROCKETSHIP_TOKEN is not set. Run /rocketship:connect for the steps."
  exit 0
fi

dir="${CLAUDE_PROJECT_DIR:-$(pwd)}"
root=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) || root="$dir"

project=""
if [ -f "$root/.rocketship.json" ]; then
  if command -v jq >/dev/null 2>&1; then
    project=$(jq -r '.project // empty' "$root/.rocketship.json" 2>/dev/null)
  else
    project=$(sed -n 's/.*"project"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$root/.rocketship.json" | head -n 1)
  fi
  case "$project" in
    ''|*[!a-z0-9-]*) project="" ;;
  esac
fi

repo=$(git -C "$root" remote get-url origin 2>/dev/null | sed -n 's#^.*github\.com[:/]\([A-Za-z0-9._-]*/[A-Za-z0-9._-]*\)$#\1#p' | sed 's/\.git$//')

set -- -sS -f --max-time 8 -K - -X POST -H 'Content-Type: application/json'
[ -n "$project" ] && set -- "$@" -H "X-Rocketship-Project: $project"
[ -n "$repo" ] && set -- "$@" -H "X-Rocketship-Repo: $repo"

answer=$(printf 'header = "Authorization: Bearer %s"\n' "$ROCKETSHIP_TOKEN" | curl "$@" --data-binary "$payload" "$URL" 2>/dev/null)
status=$?

if [ "$status" -eq 0 ]; then
  [ -n "$answer" ] && printf '%s\n' "$answer"
elif [ "$status" -eq 22 ]; then
  echo "Rocketship did not accept this Claude Code's token, or answered with an error, so this session starts without its context. Run /rocketship:connect to check."
else
  echo "Rocketship could not be reached, so this session starts without its context. Call load_project once it is back."
fi
exit 0

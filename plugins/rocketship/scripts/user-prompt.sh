#!/bin/sh
# UserPromptSubmit for Rocketship: on each message, Rocketship is asked for the few passages of
# this repository's project that bear on it (knowledge, rules, open tasks, documents, modules and
# what was said in meetings), and Claude Code gets them with the message. Nothing comes back for a
# short reply, a command, or a message nothing in the project bears on. Rocketship reads the
# message for its words and never keeps it.
#
# Quiet by design: no key, no answer in time, or any error, and the message goes on unchanged.
# The token reaches curl on its config input, never on the command line.

URL="${ROCKETSHIP_HOOK_URL:-https://rocketship.72-60-110-109.sslip.io/api/bridge/hooks}"

payload=$(cat)
[ -n "${ROCKETSHIP_TOKEN:-}" ] || exit 0

dir=""
if command -v jq >/dev/null 2>&1; then
  dir=$(printf '%s' "$payload" | jq -r '.cwd // empty' 2>/dev/null)
fi
[ -n "$dir" ] && [ -d "$dir" ] || dir="${CLAUDE_PROJECT_DIR:-$(pwd)}"
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

set -- -sS -f --max-time 4 -K - -X POST -H 'Content-Type: application/json'
[ -n "$project" ] && set -- "$@" -H "X-Rocketship-Project: $project"

answer=$(printf 'header = "Authorization: Bearer %s"\n' "$ROCKETSHIP_TOKEN" | curl "$@" --data-binary "$payload" "$URL" 2>/dev/null) || exit 0
case "$answer" in
  *hookSpecificOutput*) printf '%s\n' "$answer" ;;
esac
exit 0

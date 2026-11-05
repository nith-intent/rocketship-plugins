#!/bin/sh
# SessionStart for Rocketship. Claude Code runs SessionStart hooks only as commands, so this script
# posts the session's id, its source and its folder (cwd) to Rocketship, never the rest of the
# hook's JSON, and prints what Rocketship answers: the hookSpecificOutput with the session's context.
#
# It tells Rocketship which project this folder is, two ways, as headers:
#   X-Rocketship-Project  the "project" slug in a committed .rocketship.json at the repo root
#   X-Rocketship-Repo     the GitHub owner/name of the repo root's origin remote, never its URL
#
# When Rocketship is sure of the project it names it in its own X-Rocketship-Project header, and a
# marker for this session is kept (common.sh); only then, or with a .rocketship.json, do the other
# hooks send anything. A project it only guessed (from a claimed task, or one of several) is never
# kept. When the call fails the person is told why, in one line, and Claude is given the same line.
# No key: nothing is sent and nothing is said. It always posts, even within a minute of another
# hook's failure, since a session that misses its start has no marker for the rest of its life.
# The script always exits 0: a session never fails to start because Rocketship is down.

. "$(dirname "$0")/common.sh"

payload=$(cat)
[ -n "${ROCKETSHIP_TOKEN:-}" ] || exit 0

# One line for the person (systemMessage) and the same for Claude (additionalContext).
say() {
  words=$(json_escape "$1")
  printf '{"systemMessage":"%s","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$words" "$words"
}

find_root
marker=$(session_marker)
project=$(project_of_root)
repo=$(repo_of_root)

body=$(mktemp "$STATE_DIR/rocketship-body.XXXXXX" 2>/dev/null) || exit 0
heads=$(mktemp "$STATE_DIR/rocketship-heads.XXXXXX" 2>/dev/null) || { rm -f "$body"; exit 0; }
trap 'rm -f "$body" "$heads"' EXIT

set -- --max-time 4 -o "$body" -D "$heads"
[ -n "$project" ] && set -- "$@" -H "X-Rocketship-Project: $project"
[ -n "$repo" ] && set -- "$@" -H "X-Rocketship-Repo: $repo"
# Only what Rocketship needs to place the session: never the transcript's path or anything else.
data=$(printf '{"hook_event_name":"SessionStart","session_id":"%s","source":"%s","cwd":"%s"}' \
  "$(json_raw session_id)" "$(json_raw source)" "$(json_raw cwd)")
code=$(post "$data" "$@")

case "$code" in
  2??)
    clear_down
    grep -q hookSpecificOutput "$body" 2>/dev/null && cat "$body" && printf '\n'
    # The project Rocketship is sure this session is on: its own header, sent only then. Never a
    # slug read out of the brief, which may name a project it only guessed.
    found=$(slug_or_empty "$(sed -n 's/^[Xx]-[Rr]ocketship-[Pp]roject:[[:space:]]*\([a-z0-9-]*\).*/\1/p' "$heads" | head -n 1)")
    [ -n "$found" ] || found="$project"
    if [ -n "$marker" ]; then
      if [ -n "$found" ]; then printf '%s\n' "$found" > "$marker" 2>/dev/null; else rm -f "$marker"; fi
    fi
    ;;
  *)
    words=$(failure_words "$code" "$body")
    mark_down "$words"
    say "$words"
    ;;
esac
exit 0

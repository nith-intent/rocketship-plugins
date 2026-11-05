#!/bin/sh
# UserPromptSubmit for Rocketship: on each message, Rocketship is asked for the few passages of
# this repository's project that bear on it (knowledge, rules, open tasks, documents, modules and
# what was said in meetings), and Claude Code gets them with the message. Nothing comes back for a
# short reply, a command, or a message nothing in the project bears on. Rocketship reads the
# message for its words and never keeps it.
#
# Only for a project: unless the repo has a .rocketship.json or SessionStart found its project,
# the message never leaves the machine. Quiet by design: no key, a failure in the last minute, no
# answer within 2 seconds, or any error, and the message goes on unchanged.

. "$(dirname "$0")/common.sh"

payload=$(cat)
[ -n "${ROCKETSHIP_TOKEN:-}" ] || exit 0
find_root
on_project || exit 0
recently_down && exit 0

body=$(mktemp "$STATE_DIR/rocketship-body.XXXXXX" 2>/dev/null) || exit 0
trap 'rm -f "$body"' EXIT

set -- --max-time 2 -o "$body"
[ -n "$project" ] && set -- "$@" -H "X-Rocketship-Project: $project"
# Only what Rocketship reads: the session, its folder and the message, never the rest of the hook's JSON.
data=$(printf '{"hook_event_name":"UserPromptSubmit","session_id":"%s","cwd":"%s","prompt":"%s"}' \
  "$(json_raw session_id)" "$(json_raw cwd)" "$(json_raw prompt)")
code=$(post "$data" "$@")

case "$code" in
  2??)
    clear_down
    grep -q hookSpecificOutput "$body" 2>/dev/null && cat "$body" && printf '\n'
    ;;
  *) mark_down "$(failure_words "$code" "$body")" ;;
esac
exit 0

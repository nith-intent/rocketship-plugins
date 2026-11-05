#!/bin/sh
# PostToolUse (Edit and Write), Stop and SessionEnd for Rocketship: tells Rocketship which files a
# session touched, that a turn ended, and that the session closed. Fire and forget: the post runs
# in the background, so no edit, turn or exit ever waits for Rocketship.
#
# Only for a project, as user-prompt.sh: without a .rocketship.json or a project found at
# SessionStart nothing is sent. Nothing is sent for a minute after a failed call either. For an
# edit only the file's path goes, never what was written.

. "$(dirname "$0")/common.sh"

payload=$(cat)
[ -n "${ROCKETSHIP_TOKEN:-}" ] || exit 0
find_root
on_project || exit 0
recently_down && exit 0

data=$payload
case "$(json_field hook_event_name)" in
  PostToolUse)
    file=$(json_raw file_path)
    [ -n "$file" ] || exit 0
    data=$(printf '{"hook_event_name":"PostToolUse","session_id":"%s","cwd":"%s","tool_name":"%s","tool_input":{"file_path":"%s"}}' \
      "$(json_raw session_id)" "$(json_raw cwd)" "$(json_raw tool_name)" "$file")
    ;;
  SessionEnd)
    marker=$(session_marker)
    [ -n "$marker" ] && rm -f "$marker"
    ;;
esac

set -- --max-time 5 -o /dev/null
[ -n "$project" ] && set -- "$@" -H "X-Rocketship-Project: $project"
( post "$data" "$@" >/dev/null ) </dev/null >/dev/null 2>&1 &
exit 0

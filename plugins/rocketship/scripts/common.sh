# Shared by the Rocketship hook scripts. Sourced, never run on its own. POSIX sh, so it runs the
# same in macOS's sh, Linux and Git Bash on Windows. jq is used when it is there, never needed.
#
# Two small files under $TMPDIR keep the hooks quiet and fast:
#   rocketship-<session id>  this session is on a project (it holds the project slug). Written by
#                            SessionStart when Rocketship was sure of one, removed on SessionEnd.
#                            Without it, and without a .rocketship.json, nothing more is sent.
#   rocketship-down          when a call last failed, why, and for which key. For 60 seconds after
#                            a failure no hook but SessionStart calls Rocketship, so a slow or dead
#                            server never holds up a message. A new key clears it.

URL="${ROCKETSHIP_HOOK_URL:-https://rocketship.72-60-110-109.sslip.io/api/bridge/hooks}"
STATE_DIR="${TMPDIR:-/tmp}"
STATE_DIR="${STATE_DIR%/}"
DOWN_FILE="$STATE_DIR/rocketship-down"
DOWN_SECONDS=60

have_jq() { command -v jq >/dev/null 2>&1; }

# A top-level string field of the hook's JSON, still JSON-escaped (fit to put back into JSON).
json_raw() {
  printf '%s' "$payload" | sed -n -E "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"(([^\"\\\\]|\\\\.)*)\".*/\\1/p" | head -n 1
}

# A string field of the hook's JSON, as plain text.
json_field() {
  if have_jq; then
    printf '%s' "$payload" | jq -r --arg k "$1" '.[$k] // empty' 2>/dev/null
  else
    json_raw "$1" | sed -e 's/\\\//\//g' -e 's/\\"/"/g' -e 's/\\\\/\\/g'
  fi
}

# Text made safe to sit inside a JSON string: no control characters, quotes and backslashes escaped.
json_escape() {
  printf '%s' "$1" | tr -d '\000-\037' | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

# The repository root of the session's own folder (the hook's cwd), else the project dir, else here.
find_root() {
  dir=$(json_field cwd)
  [ -n "$dir" ] && [ -d "$dir" ] || dir="${CLAUDE_PROJECT_DIR:-$(pwd)}"
  root=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) || root="$dir"
}

# A project slug, only when it looks like one: lower-case letters, digits and hyphens.
slug_or_empty() {
  case "$1" in
    ''|*[!a-z0-9-]*) printf '' ;;
    *) printf '%s' "$1" ;;
  esac
}

# The slug in .rocketship.json at the repo root, if any.
project_of_root() {
  [ -f "$root/.rocketship.json" ] || return 0
  if have_jq; then
    found=$(jq -r '.project // empty' "$root/.rocketship.json" 2>/dev/null)
  else
    found=$(sed -n 's/.*"project"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$root/.rocketship.json" | head -n 1)
  fi
  slug_or_empty "$found"
}

# The origin remote's GitHub owner/name, never its URL (no user names or tokens in it).
repo_of_root() {
  git -C "$root" remote get-url origin 2>/dev/null \
    | sed -n 's#^.*github\.com[:/]\([A-Za-z0-9._-]*/[A-Za-z0-9._-]*\)/*$#\1#p' \
    | sed 's/\.git$//' | head -n 1
}

# This session's marker file, or nothing when the hook gave no usable session id.
session_marker() {
  sid=$(json_field session_id | tr -cd 'A-Za-z0-9_-' | cut -c 1-100)
  [ -n "$sid" ] && printf '%s' "$STATE_DIR/rocketship-$sid"
}

# True when this session should talk to Rocketship: the repo names its project, or SessionStart
# found one. Sets $project to the slug to name, if any.
on_project() {
  project=$(project_of_root)
  [ -f "$root/.rocketship.json" ] && return 0
  marker=$(session_marker)
  [ -n "$marker" ] && [ -f "$marker" ] || return 1
  project=$(slug_or_empty "$(head -n 1 "$marker" 2>/dev/null)")
  return 0
}

key_sum() { printf '%s' "${ROCKETSHIP_TOKEN:-}" | cksum | cut -d ' ' -f 1; }

# True when a call with this key failed in the last minute. $down_reason holds why.
recently_down() {
  [ -f "$DOWN_FILE" ] || return 1
  stamp=$(sed -n 1p "$DOWN_FILE" 2>/dev/null)
  sum=$(sed -n 2p "$DOWN_FILE" 2>/dev/null)
  down_reason=$(sed -n 3p "$DOWN_FILE" 2>/dev/null)
  case "$stamp" in ''|*[!0-9]*) return 1 ;; esac
  [ "$sum" = "$(key_sum)" ] || return 1
  [ $(( $(date +%s) - stamp )) -lt "$DOWN_SECONDS" ]
}

mark_down() {
  printf '%s\n%s\n%s\n' "$(date +%s)" "$(key_sum)" "$1" > "$DOWN_FILE" 2>/dev/null
}

clear_down() { rm -f "$DOWN_FILE" 2>/dev/null; }

# The plain sentence for a failed call, from its HTTP status and the answer's body file.
failure_words() {
  case "$1" in
    401|403)
      if have_jq; then
        why=$(jq -r '.reason // empty' "$2" 2>/dev/null)
      else
        why=$(sed -n 's/.*"reason"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$2" 2>/dev/null | head -n 1)
      fi
      [ -n "$why" ] || why="The key was not accepted."
      printf 'Rocketship did not accept this Claude Code: %s Then run /rocketship:connect.' "$why"
      ;;
    5??) printf 'Rocketship had an error, so this session has no Rocketship context. It is tried again in a minute.' ;;
    000|'') printf 'Rocketship could not be reached, so this session has no Rocketship context. It is tried again in a minute.' ;;
    *) printf 'Rocketship answered with an error (%s), so this session has no Rocketship context. Run /rocketship:connect to check.' "$1" ;;
  esac
}

# Posts $1 (JSON) to Rocketship with the key on curl's config input, never on the command line.
# Extra curl arguments follow. Prints the HTTP status, 000 when nothing answered.
post() {
  data=$1
  shift
  code=$(printf 'header = "Authorization: Bearer %s"\n' "$ROCKETSHIP_TOKEN" \
    | curl -sS -K - -X POST -H 'Content-Type: application/json' "$@" -w '%{http_code}' --data-binary "$data" "$URL" 2>/dev/null)
  printf '%s' "${code:-000}"
}

# Shared by the Rocketship hook scripts. Sourced, never run on its own. POSIX sh, so it runs the
# same in macOS's sh, Linux and Git Bash on Windows. jq is used when it is there, never needed.
#
# Two small files under $TMPDIR keep the hooks quiet and fast:
#   rocketship-<session id>  this session is on a project (it holds the project slug). Written by
#                            SessionStart when Rocketship was sure of one, removed on SessionEnd.
#                            Without it, and without a .rocketship.json, nothing more is sent.
#   rocketship-down          when a call last failed, why, and for which key. For 60 seconds after
#                            a failure no hook but SessionStart calls Rocketship, so a slow or dead
#                            server never holds up a message. A new key, or a call that works,
#                            clears it.

URL="${ROCKETSHIP_HOOK_URL:-https://rocketship.72-60-110-109.sslip.io/api/bridge/hooks}"

# A key as it was pasted, kept to the characters a key has (rk_ and base64url): a space, a line
# break or quotes pasted around it never break the call, and nothing in it can reach curl's config.
clean_key() { printf '%s' "$1" | tr -cd 'A-Za-z0-9_-'; }

# The key: the one Claude Code keeps for the plugin (asked once when the plugin is enabled, kept in
# the keychain, handed to hooks as CLAUDE_PLUGIN_OPTION_ROCKETSHIP_KEY), else ROCKETSHIP_TOKEN from
# the profile. Every hook reads it as ROCKETSHIP_TOKEN from here on. When both are set and differ,
# the profile's goes too, as X-Rocketship-Key (ALT_KEY): Rocketship takes the first that works, so a
# key left in the keychain after it was revoked never hides a new one in the profile.
OPTION_KEY=$(clean_key "${CLAUDE_PLUGIN_OPTION_ROCKETSHIP_KEY:-}")
PROFILE_KEY=$(clean_key "${ROCKETSHIP_TOKEN:-}")
ROCKETSHIP_TOKEN="${OPTION_KEY:-$PROFILE_KEY}"
ALT_KEY=""
[ -n "$OPTION_KEY" ] && [ -n "$PROFILE_KEY" ] && [ "$OPTION_KEY" != "$PROFILE_KEY" ] && ALT_KEY="$PROFILE_KEY"

# Where a person puts a key, said the same in every message.
KEY_WHERE='paste it in /plugin > Installed > rocketship > Configure options (in VS Code: /plugins, then the gear on rocketship), and start a new session'

STATE_DIR="${TMPDIR:-/tmp}"
STATE_DIR="${STATE_DIR%/}"
DOWN_FILE="$STATE_DIR/rocketship-down"
DOWN_SECONDS=60

have_jq() { command -v jq >/dev/null 2>&1; }

# jq's raw output without carriage returns: a native jq.exe on Windows writes CRLF.
jq_text() { jq -r "$@" 2>/dev/null | tr -d '\r'; }

# A top-level string field of the hook's JSON, still JSON-escaped (fit to put back into JSON).
json_raw() {
  printf '%s' "$payload" | sed -n -E "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"(([^\"\\\\]|\\\\.)*)\".*/\\1/p" | head -n 1
}

# A string field of the hook's JSON, as plain text.
json_field() {
  if have_jq; then
    printf '%s' "$payload" | jq_text --arg k "$1" '.[$k] // empty'
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
    found=$(jq_text '.project // empty' "$root/.rocketship.json")
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

key_sum() { printf '%s %s' "${ROCKETSHIP_TOKEN:-}" "$ALT_KEY" | cksum | cut -d ' ' -f 1; }

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
        why=$(jq_text '.reason // empty' "$2")
      else
        why=$(sed -n 's/.*"reason"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$2" 2>/dev/null | head -n 1)
      fi
      [ -n "$why" ] || why="The key was not accepted."
      if [ "$1" = 401 ]; then
        printf 'Rocketship did not accept this Claude Code: %s Then %s.' "$why" "$KEY_WHERE"
      else
        printf 'Rocketship did not accept this Claude Code: %s' "$why"
      fi
      ;;
    5??) printf 'Rocketship had an error, so this session has no Rocketship context. Start a new session once it is back.' ;;
    000|'') printf 'Rocketship could not be reached, so this session has no Rocketship context. Start a new session, or run /mcp to reconnect, once it is back.' ;;
    *) printf 'Rocketship answered with an error (%s), so this session has no Rocketship context. Run /rocketship:connect to check.' "$1" ;;
  esac
}

# Text fit to sit in a quoted value of curl's config: line breaks made spaces (JSON needs none
# outside its strings), backslashes and quotes escaped, so curl reads back exactly the JSON.
config_quote() {
  printf '%s' "$1" | tr '\r\n' '  ' | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

# Posts $1 (JSON) to Rocketship. The key and the JSON go on curl's config input, never on the
# command line: nothing shows in a process list or a shell's history, Windows' 32,767-character
# command line never cuts a long message, and Git Bash never rewrites what looks like a path in it.
# Extra curl arguments follow. Prints the HTTP status, 000 when nothing answered.
post() {
  data=$1
  shift
  code=$( {
      printf 'header = "Authorization: Bearer %s"\n' "$ROCKETSHIP_TOKEN"
      [ -z "$ALT_KEY" ] || printf 'header = "X-Rocketship-Key: %s"\n' "$ALT_KEY"
      printf 'data-binary = "%s"\n' "$(config_quote "$data")"
    } | curl -sS -K - -X POST -H 'Content-Type: application/json' "$@" -w '%{http_code}' "$URL" 2>/dev/null)
  printf '%s' "${code:-000}"
}

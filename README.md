# Rocketship plugins

INTENT's Claude Code plugin. Your own Claude Code, on your own plan, knows the project you are in: the client's meetings, the process maps, the modules and sections, the ClickUp board and the agreed rules. It takes its next task from Rocketship, asks questions back, and hands the work off. Rocketship never sees your Claude sign-in. The only thing it sees is the Rocketship key you make on Me.

## Install, once

The plugin is public: anyone can add it, and it does nothing without a Rocketship key. You need git on your machine. On Windows, install Git for Windows too: Claude Code runs the plugin's hooks in Git Bash, and without it every session start shows a hook error (if Git Bash is somewhere Claude Code does not find, set `CLAUDE_CODE_GIT_BASH_PATH`).

1. **Make your key.** Open Rocketship, go to Me, and under "Your Claude Code" press "Create my key". Copy it. It is shown once and lasts 90 days.
2. **Install the plugin, for you** (user scope), so it works in every repo.
   - In a terminal's Claude Code (and JetBrains, which runs it in a terminal), type these two, one after the other:

         /plugin marketplace add nith-intent/rocketship-plugins
         /plugin install rocketship@rocketship-plugins

   - In VS Code, the Claude panel takes `/plugin` only on its own, never with words after it. Type `/plugins`, add `nith-intent/rocketship-plugins` on the Marketplaces tab, then on the Plugins tab install rocketship with "Install for you".
3. **Paste the key when Claude Code asks for it** ("Rocketship key"), then (in VS Code) press "Restart Claude". Claude Code keeps it in your computer's secure store (the keychain on a Mac) and asks only once. No prompt? Type `/plugin configure rocketship@rocketship-plugins`. From a shell, where `claude plugin install` never asks, `claude plugin configure rocketship@rocketship-plugins --values-stdin` takes `{"rocketship_key":"rk_..."}` on its input; never pass the key with `--config` on the command line, which keeps it in your shell's history.
4. **Open a new Claude Code session.** It connects on its own and opens on the repo's project. `/rocketship:connect` checks it: it answers "Connected to Rocketship as <your name>" and says which project the repo is.

Instead of pasting it, you can keep the key in your profile as `ROCKETSHIP_TOKEN`: Me gives the line for a Mac (`~/.zshrc`, or `~/.bash_profile` with bash), Linux, Git Bash or WSL (`~/.bashrc`) and Windows (`setx`, in PowerShell or Command Prompt). Then open a new terminal, and quit VS Code fully (Cmd+Q on a Mac, every window on Windows) and open it again from the Dock, Start or Finder: VS Code reads the profile only as it starts. Under WSL, use the bash line. When both are set, the kept key is tried first, then the profile's, so a new key in the profile still works after the kept one was revoked.

**To change the key** (a new one every 90 days): `/plugin configure rocketship@rocketship-plugins`, or `/plugin` > Installed > rocketship > Configure options; in VS Code, `/plugins` and the gear on rocketship's row. Paste the new one and start a new session. An empty value does not clear a kept key: replace it, or uninstall the plugin.

Then, so Claude Code does not ask before it reads Rocketship, add Rocketship's reads to `permissions.allow` in `~/.claude/settings.json` (VS Code's Claude uses the same file). Me, under "Allow Rocketship's reads", gives the current line to copy. Today it is:

    "mcp__plugin_rocketship_rocketship__whoami",
    "mcp__plugin_rocketship_rocketship__my_work",
    "mcp__plugin_rocketship_rocketship__get_work_item",
    "mcp__plugin_rocketship_rocketship__get_project",
    "mcp__plugin_rocketship_rocketship__load_project",
    "mcp__plugin_rocketship_rocketship__search_meetings",
    "mcp__plugin_rocketship_rocketship__find_in_project",
    "mcp__plugin_rocketship_rocketship__get_transcript_excerpt",
    "mcp__plugin_rocketship_rocketship__get_fix_prompt",
    "mcp__plugin_rocketship_rocketship__test_support_asks",
    "mcp__plugin_rocketship_rocketship__house_rules",
    "mcp__plugin_rocketship_rocketship__my_rules",
    "mcp__plugin_rocketship_rocketship__connect_help",
    "mcp__plugin_rocketship_rocketship__task_status",
    "mcp__plugin_rocketship_rocketship__task_history",
    "mcp__plugin_rocketship_rocketship__explain_failure",
    "mcp__plugin_rocketship_rocketship__test_queue",
    "mcp__plugin_rocketship_rocketship__rules",
    "mcp__plugin_rocketship_rocketship__knowledge",
    "mcp__plugin_rocketship_rocketship__intent_rules",
    "mcp__plugin_rocketship_rocketship__who_is_on_what",
    "mcp__plugin_rocketship_rocketship__what_changed",
    "mcp__plugin_rocketship_rocketship__rank_work",
    "mcp__plugin_rocketship_rocketship__at_risk",
    "mcp__plugin_rocketship_rocketship__clients",
    "mcp__plugin_rocketship_rocketship__board_tasks",
    "mcp__plugin_rocketship_rocketship__task_detail",
    "mcp__plugin_rocketship_rocketship__naming_check",
    "mcp__plugin_rocketship_rocketship__project_maps",
    "mcp__plugin_rocketship_rocketship__project_modules",
    "mcp__plugin_rocketship_rocketship__project_team",
    "mcp__plugin_rocketship_rocketship__project_documents",
    "mcp__plugin_rocketship_rocketship__my_promises",
    "mcp__plugin_rocketship_rocketship__project_meetings",
    "mcp__plugin_rocketship_rocketship__meeting_detail"

Never allow the whole server (`mcp__plugin_rocketship_rocketship__*`): that would let Claude Code take, update or hand off a task, post to the team or ask Jenny without asking you first.

## Point a repo at its project

Rocketship works the project out from the repo's GitHub owner and name (its `origin` remote) when the project names that repository, then from the folder's name. A repository that no project names, under a GitHub organisation that carries a client's own name (`simba-global` for Simba Global) and whose other repositories are that client's one open project, is put on that project: `simba-global/simba-intent-frontend` opens on Simba's project when it names `simba-global/simba-intent-backend`. Under any other owner holding one client's repositories, which may as well be your own account or an agency's, the session is only offered the project and says its slug. To be sure, put a `.rocketship.json` at the repo root with the project's slug, the last part of its address in Rocketship (`/projects/<slug>`), for example:

    {"project": "mk-portal"}

It holds the slug and nothing else. Never commit client notes, meeting words or a brief to the repo. Where the client owns the repository, keep the file to yourself: add `.rocketship.json` to `.git/info/exclude` instead of committing it.

## Nothing to type

Once the key is set and the repo names its project, Rocketship is simply there. In any other folder (a personal project, another client's repo) the plugin sends only the session's start, so Rocketship can tell whether the folder is a project: the session's id, the folder's path on your computer and the repository's GitHub owner and name. Rocketship keeps that session with its folder's name. When it is not sure the folder is a project, nothing more is sent: no message, no file name, no turn. Claude Code's connection to Rocketship's tools also carries the folder's path, so a tool asked about "this project" answers for this window and never for another one; Rocketship reads its last part and keeps none of it. With no key kept or set, nothing is sent at all, and the session says where to put the key.

- **Each session** opens on the repo's project with a short brief: status, modules, the open board, the newest decisions, the maps.
- **Each message** you type is checked against the project. When something Rocketship holds bears on it (a rule, a task, a knowledge page, a line from a meeting), the few passages that do arrive with your message, once each, and never for a short reply or a command. Rocketship reads the message for its words and never keeps it.
- **Claude Code asks for the rest itself** with `find_in_project`, then reads only the one task, meeting or page it needs.
- **It says so.** Whenever an answer uses something from Rocketship, Claude names it: "From Rocketship, the 28 Sep meeting: ...".

The commands still work when you want them:

- `/rocketship:project`: load the whole project and keep a working brief.
- `/rocketship:next`: take your next task, read what stands behind it and set up the branch.
- `/rocketship:handoff`: fix what QA found if it failed, run the checks, and hand off with the pull request.

When a requirement is unclear, Claude asks it on the section with `ask_question`, so Jenny or the lead answers in Rocketship.

## Updates

New versions come from this repository. `/plugin marketplace update rocketship-plugins` refreshes the list only and leaves the installed plugin as it is. To take a new version:

- In a terminal's Claude Code: `/plugin` > Installed > rocketship > Update now, then start a new session.
- From a shell: `claude plugin marketplace update rocketship-plugins && claude plugin update rocketship@rocketship-plugins`. This needs the standalone `claude` on your PATH; the VS Code extension does not put one there.
- In VS Code: `/plugins` > Marketplaces > the refresh icon on rocketship-plugins, then "Restart Claude".

To get them on their own, turn on auto-update once, in a terminal's Claude Code (VS Code has no switch for it): `/plugin` > Marketplaces > rocketship-plugins > Enable auto-update. Claude Code keeps it off for marketplaces other than Anthropic's until you do. After an update it says "Plugin updated: rocketship", and the next session uses it.

To release one: change it here, raise `version` in `plugins/rocketship/.claude-plugin/plugin.json` and in `.claude-plugin/marketplace.json` (the two stay the same), and push to `main`. Nobody gets a change until the version moves. A release that changes what the plugin sends goes out only once the Rocketship that reads it is live: 0.5.0 sends `ROCKETSHIP_TOKEN` as `X-Rocketship-Key`, which Rocketship before 5 Nov 2026 never reads. 0.5.1 also works against an older Rocketship, which ignores its folder header and second key.

## The address

The server address in `.mcp.json` and `scripts/common.sh` is the dev Rocketship, https://rocketship.72-60-110-109.sslip.io. When Rocketship moves to its real name, change both here with a new version.

## How the key travels

The plugin declares the key as a sensitive option (`userConfig.rocketship_key`), so Claude Code asks for it when the plugin is enabled and keeps it in the computer's secure store, never in `settings.json`. It hands it to the MCP server as `Authorization: Bearer ${user_config.rocketship_key}` and to every hook as `CLAUDE_PLUGIN_OPTION_ROCKETSHIP_KEY`. The MCP server also sends `ROCKETSHIP_TOKEN` as `X-Rocketship-Key`, and the hooks do too when it differs from the kept key; Rocketship takes the first of them that works. The hooks keep only the characters a key has (so a space, a line break or quotes pasted round it do no harm) and send the key and the message to curl on its config input, never on a command line, so nothing shows in a process list or a shell's history and a long message is never cut. The key is the only secret; this repository holds none.

## If it does not connect

A session that cannot use Rocketship says why in one line as it starts. Type `/rocketship:connect` for the fix.

- "Rocketship has no key yet", or "no key was sent": Claude Code keeps no key and `ROCKETSHIP_TOKEN` is not set. Paste one as under "To change the key", then start a new session.
- "Did not accept this Claude Code": the key expired, was revoked, or is not a Rocketship key. Make a new one on Me and paste it the same way.
- "Could not be reached" or "had an error": Rocketship is down or your network is. Nothing holds up a message meanwhile. Once it is back, start a new session, or type `/mcp` to reconnect Rocketship's tools.
- No Rocketship tools: type `/mcp`. If `rocketship` is listed but failed to connect, it is the case above. If it is not listed, `/plugin` (in VS Code, `/plugins`) shows whether `rocketship` is installed and enabled.
- `/plugin marketplace add` fails to clone: check git is installed. If your machine has a GitHub SSH key that does not work, set `CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1` and try again.
- A one-shot `claude -p` run may end before its last turn is reported; the session's end still is.

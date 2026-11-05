# Rocketship plugins

INTENT's Claude Code plugin. Your own Claude Code, on your own plan, knows the project you are in: the client's meetings, the process maps, the modules and sections, the ClickUp board and the agreed rules. It takes its next task from Rocketship, asks questions back, and hands the work off. Rocketship never sees your Claude sign-in. The only thing it sees is the Rocketship key you make on Me.

## Install, once

The plugin is public: anyone can add it, and it does nothing without a Rocketship key. You need git on your machine, nothing else.

1. **Make your key.** Open Rocketship, go to Me, and under "Your Claude Code" press "Create my key". Copy it. It is shown once and lasts 90 days.
2. **Install the plugin.** Inside Claude Code, type these two, one after the other:

       /plugin marketplace add nith-intent/rocketship-plugins
       /plugin install rocketship@rocketship-plugins

   Pick "Install for you" (user scope), so it works in every repo.
3. **Paste the key when Claude Code asks for it** ("Rocketship key"). Claude Code keeps it in your keychain and asks only once. Or leave it empty and set `ROCKETSHIP_TOKEN` in your profile instead (`export ROCKETSHIP_TOKEN=rk_...` in `~/.zshrc` on a Mac, `setx ROCKETSHIP_TOKEN rk_...` on Windows), then quit VS Code fully and open it again.
4. **Open a new Claude Code session.** It connects on its own and opens on the repo's project. `/rocketship:connect` checks it: it answers "Connected to Rocketship as <your name>" and says which project the repo is.

To change the key (a new one every 90 days): `/plugin` > Installed > rocketship > Configure options, paste the new one and start a new session. In a terminal, `claude plugin configure rocketship@rocketship-plugins` shows whether it is set.

Then, so Claude Code does not ask before it reads Rocketship, add Rocketship's reads to `permissions.allow` in `~/.claude/settings.json`. Me, under "Allow Rocketship's reads", gives the current line to copy. Today it is:

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
    "mcp__plugin_rocketship_rocketship__meeting_detail",
    "mcp__plugin_rocketship_rocketship__meeting_actioned",
    "mcp__plugin_rocketship_rocketship__meeting_search"

Never allow the whole server (`mcp__plugin_rocketship_rocketship__*`): that would let Claude Code take, update or hand off a task, post to the team or ask Jenny without asking you first.

## Point a repo at its project

Rocketship works the project out from the repo's GitHub owner and name (its `origin` remote) when the project names that repository. A repository that no project names, under a GitHub owner whose other repositories are one client's one open project, is offered that project, and the session says its slug (never for INTENT's own organisations or work): `simba-global/simba-intent-frontend` is offered Simba's project when it names `simba-global/simba-intent-backend`. It is never put on it by that alone, since an owner like that may be your own account. To be sure, put a `.rocketship.json` at the repo root with the project's slug, the last part of its address in Rocketship (`/projects/<slug>`), for example:

    {"project": "mk-portal"}

It holds the slug and nothing else. Never commit client notes, meeting words or a brief to the repo. Where the client owns the repository, keep the file to yourself: add `.rocketship.json` to `.git/info/exclude` instead of committing it.

## Nothing to type

Once the key is set and the repo names its project, Rocketship is simply there. In any other folder (a personal project, another client's repo) the plugin sends only the session's start, so Rocketship can tell whether the folder is a project: the session's id, the folder's path on your computer and the repository's GitHub owner and name. Rocketship keeps that session with its folder. When it is not sure the folder is a project, nothing more is sent: no message, no file name, no turn. With no key kept or set, nothing is sent at all.

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

New versions come from this repository. To take one, inside Claude Code: `/plugin` > Marketplaces > rocketship-plugins > Update marketplace (or type `/plugin marketplace update rocketship-plugins`), then start a new session. In a terminal: `claude plugin update rocketship@rocketship-plugins`.

To get them on their own, turn on auto-update once: `/plugin` > Marketplaces > rocketship-plugins > Enable auto-update. Claude Code keeps it off for marketplaces other than Anthropic's until you do. After an update it says "Plugin updated: rocketship", and the next session uses it.

To release one: change it here, raise `version` in `plugins/rocketship/.claude-plugin/plugin.json` and in `.claude-plugin/marketplace.json` (the two stay the same), and push to `main`. Nobody gets a change until the version moves. A release that changes what the plugin sends goes out only once the Rocketship that reads it is live: 0.5.0 sends `ROCKETSHIP_TOKEN` as `X-Rocketship-Key`, which Rocketship before 5 Nov 2026 never reads.

## The address

The server address in `.mcp.json` and `scripts/common.sh` is the dev Rocketship, https://rocketship.72-60-110-109.sslip.io. When Rocketship moves to its real name, change both here with a new version.

## How the key travels

The plugin declares the key as a sensitive option (`userConfig.rocketship_key`), so Claude Code asks for it when the plugin is enabled and keeps it in the keychain, never in `settings.json`. It hands it to the MCP server as `Authorization: Bearer ${user_config.rocketship_key}` and to every hook as `CLAUDE_PLUGIN_OPTION_ROCKETSHIP_KEY`. With none kept, the MCP server sends `ROCKETSHIP_TOKEN` as `X-Rocketship-Key`, and the hooks read `ROCKETSHIP_TOKEN`. The hooks send it to curl on its config input, never on a command line. The key is the only secret; this repository holds none.

## If it does not connect

A session that cannot use Rocketship says why in one line as it starts. Type `/rocketship:connect` for the fix.

- No Rocketship tools, or "no key was sent": Claude Code keeps no key and `ROCKETSHIP_TOKEN` is not set. `/plugin` > Installed > rocketship > Configure options, paste the key, then start a new session.
- "Did not accept this Claude Code": the key expired or was revoked. Make a new one on Me and paste it the same way.
- "Could not be reached" or "had an error": Rocketship is down or your network is. The plugin tries again a minute later and never holds up a message meanwhile.
- The tools are still missing: `/plugin` shows whether `rocketship` is installed and enabled.
- `/plugin marketplace add` fails to clone: check git is installed. If your machine has a GitHub SSH key that does not work, set `CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1` and try again.

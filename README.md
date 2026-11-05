# Rocketship plugins

INTENT's Claude Code plugin. Your own Claude Code, on your own plan, knows the project you are in: the client's meetings, the process maps, the modules and sections, the ClickUp board and the agreed rules. It takes its next task from Rocketship, asks questions back, and hands the work off. Rocketship never sees your Claude sign-in. The only thing it sees is the Rocketship key you make on Me.

## Install, once

This repository is private for now, so installing needs read access to it on GitHub (ask Nith) and git signed in to GitHub on your machine. In a terminal, once:

    gh auth login
    gh auth setup-git

Background updates of a private plugin also need `GITHUB_TOKEN` (or `GH_TOKEN`) in your environment. Without it, update by hand (below).

1. **Make your key.** Open Rocketship, go to Me, and under "Your Claude Code" press "Create my key". Copy the line it shows. It is shown once and lasts 90 days.
2. **Add it to your shell profile.**
   - Mac: put this line in `~/.zshrc`:

         export ROCKETSHIP_TOKEN=rk_...

   - Windows: in a terminal, run:

         setx ROCKETSHIP_TOKEN rk_...

3. **Quit VS Code fully and open it again** (Cmd+Q on a Mac, not just the window; every window on Windows), so Claude Code picks the key up. In a terminal, open a new one.
4. **Install the plugin.** Inside Claude Code, type:

       /plugin marketplace add nith-intent/rocketship-plugins
       /plugin install rocketship@rocketship-plugins

5. **Open a new Claude Code session** and type `/rocketship:connect`. It answers "Connected to Rocketship as <your name>" and says which project the repo is.

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

Rocketship works the project out from the repo's GitHub owner and name (its `origin` remote) when the project names that repository. To be sure, put a `.rocketship.json` at the repo root with the project's slug, the last part of its address in Rocketship (`/projects/<slug>`), for example:

    {"project": "mk-portal"}

It holds the slug and nothing else. Never commit client notes, meeting words or a brief to the repo. Where the client owns the repository, keep the file to yourself: add `.rocketship.json` to `.git/info/exclude` instead of committing it.

## Nothing to type

Once the key is set and the repo names its project, Rocketship is simply there. In any other folder (a personal project, another client's repo) the plugin sends only the session's start, so Rocketship can tell whether the folder is a project: the session's id, the folder's path on your computer and the repository's GitHub owner and name. Rocketship keeps that session with its folder. When it is not sure the folder is a project, nothing more is sent: no message, no file name, no turn. With no key set, nothing is sent at all.

- **Each session** opens on the repo's project with a short brief: status, modules, the open board, the newest decisions, the maps.
- **Each message** you type is checked against the project. When something Rocketship holds bears on it (a rule, a task, a knowledge page, a line from a meeting), the few passages that do arrive with your message, once each, and never for a short reply or a command. Rocketship reads the message for its words and never keeps it.
- **Claude Code asks for the rest itself** with `find_in_project`, then reads only the one task, meeting or page it needs.
- **It says so.** Whenever an answer uses something from Rocketship, Claude names it: "From Rocketship, the 28 Sep meeting: ...".

The commands still work when you want them:

- `/rocketship:project`: load the whole project and keep a working brief.
- `/rocketship:next`: take your next task, read what stands behind it and set up the branch.
- `/rocketship:handoff`: fix what QA found if it failed, run the checks, and hand off with the pull request.

When a requirement is unclear, Claude asks it on the section with `ask_question`, so Jenny or the lead answers in Rocketship.

## Updates and the address

The server address in `.mcp.json` and `scripts/common.sh` is the dev Rocketship, https://rocketship.72-60-110-109.sslip.io. When Rocketship moves to its real name the plugin is updated here, with a new version. Inside Claude Code, `/plugin` > Marketplaces > rocketship-plugins > Update picks it up, or `claude plugin update rocketship` in a terminal.

## If it does not connect

A session that cannot use Rocketship says why in one line as it starts. Type `/rocketship:connect` for the fix.

- No Rocketship tools, or "no key was sent": the key is not set where Claude Code can see it. VS Code was not fully restarted after step 2, or the line is not in your profile. Check with `echo $ROCKETSHIP_TOKEN` in a new terminal.
- "Did not accept this Claude Code": the key expired or was revoked. Make a new one on Me, then steps 2 and 3 again.
- "Could not be reached" or "had an error": Rocketship is down or your network is. The plugin tries again a minute later and never holds up a message meanwhile.
- The key is set and the tools are still missing: inside Claude Code, `/plugin` shows whether `rocketship` is installed and enabled.
- `/plugin marketplace add` fails to clone: you have no read access to this repository yet, or git is not signed in (`gh auth login`, `gh auth setup-git`).

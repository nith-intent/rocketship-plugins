# Rocketship plugins

INTENT's Claude Code plugin. Your own Claude Code, on your own plan, knows the project you are in: the client's meetings, the process maps, the modules and sections, the ClickUp board and the agreed rules. It takes its next task from Rocketship, asks questions back, and hands the work off. Rocketship never sees your Claude sign-in. The only thing it sees is the Rocketship key you make on Me.

## Install, once

You need access to the INTENT repositories on GitHub first.

1. **Make your key.** Open Rocketship, go to Me, and under "Your Claude Code" press "Create my key". Copy the line it shows. It is shown once and lasts 90 days.
2. **Put it in your shell profile.** Add the line to `~/.zshrc`:

       export ROCKETSHIP_TOKEN=rk_...

   Then quit VS Code fully (Cmd+Q, not just the window) and open it again, so Claude Code picks the key up. In a terminal, open a new one.
3. **Install the plugin.** In a terminal:

       claude plugin marketplace add nith-intent/rocketship-plugins && claude plugin install rocketship@rocketship-plugins

Then, in Claude Code, type `/rocketship:connect`. It answers "Connected to Rocketship as <your name>" and says which project the repo is.

## Point a repo at its project

Rocketship works the project out from the repo's GitHub name when the project names that repository. To be sure, commit a `.rocketship.json` at the repo root with the project's slug, the last part of its address in Rocketship (`/projects/<slug>`), for example:

    {"project": "mk-portal"}

It holds the slug and nothing else. Never commit client notes, meeting words or a brief to the repo.

## Each day

- `/rocketship:project`: load the project and keep a short working brief. Ask it "what did the client say about X" or "how should X work" and it searches the meetings and maps first, and cites the meeting date and line.
- `/rocketship:next`: take your next task, read what stands behind it and set up the branch.
- `/rocketship:handoff`: fix what QA found if it failed, run the checks, and hand off with the pull request.

When a requirement is unclear, Claude asks it on the section with `ask_question`, so Jenny or the lead answers in Rocketship.

When a session starts, resumes, clears or compacts, the plugin sends Rocketship the folder you are in (and the slug in `.rocketship.json`), and Rocketship answers with the project's context.

## Updates and the address

The server address in `.mcp.json`, `hooks/hooks.json` and `scripts/session-start.sh` is the dev Rocketship, https://rocketship.72-60-110-109.sslip.io. When Rocketship moves to its real name the plugin is updated here, with a new version, and `claude plugin update rocketship` picks it up.

## If it does not connect

- Every Rocketship call says no key was sent: VS Code was not fully restarted after you edited `~/.zshrc`, or the line is not in it. Check with `echo $ROCKETSHIP_TOKEN` in a new terminal.
- The key is not accepted: it expired or was revoked. Make a new one on Me.
- The Rocketship tools are missing: run `claude plugin list` and check `rocketship` is installed and enabled.

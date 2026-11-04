---
name: connect
description: Connect this Claude Code to Rocketship, say who you are connected as and which project this repo is. Use when the person types /rocketship:connect, or when a Rocketship tool or the session context says no key was sent or the key was not accepted.
---

# Connect to Rocketship

1. Call the Rocketship tool `whoami`.
2. If it answers with a name, tell the person: "Connected to Rocketship as <name>." Then:
   - If `.rocketship.json` is at the repo root, read its `project` slug and call `load_project` with it, to show the project is readable here. Say "This repo is <project>." in one line. Do not print the brief; `/rocketship:project` does that.
   - If there is no `.rocketship.json`, call `load_project` with no slug. If Rocketship works the project out, say which. If not, say: "Rocketship cannot tell which project this repo is. Run /rocketship:project <slug>, or add .rocketship.json." and stop.
3. If `whoami` fails because no key was sent or the key is not known, tell them the steps, exactly:
   - Open Rocketship, go to Me, and under "Your Claude Code" press "Create my key". Copy the line it shows (it is shown once).
   - Put that line (`export ROCKETSHIP_TOKEN=rk_...`) in `~/.zshrc`.
   - Quit VS Code fully (Cmd+Q, not just the window) and open it again, so Claude Code picks the key up. In a terminal, open a new one.
   - Type `/rocketship:connect` again.
4. If the Rocketship tools are missing altogether, the plugin is not installed or not enabled: point them to the README's install step.
5. Never ask for, read or print the key. Never put it in any file other than the shell profile the person edits themselves.

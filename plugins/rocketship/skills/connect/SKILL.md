---
name: connect
description: Connect this Claude Code to Rocketship, say who you are connected as and which project this repo is. Use when the person types /rocketship:connect, when the session says Rocketship did not accept this Claude Code or could not be reached, or when a Rocketship tool says no key was sent or the key was not accepted.
---

# Connect to Rocketship

1. Call the Rocketship tool `whoami`.
2. If it answers with a name, tell the person: "Connected to Rocketship as <name>." Then:
   - If `.rocketship.json` is at the repo root, read its `project` slug and call `load_project` with it, to show the project is readable here. Say "This repo is <project>." in one line. Do not print the brief; `/rocketship:project` does that.
   - If there is no `.rocketship.json`, call `load_project` with no slug. If Rocketship works the project out, say which. If not, say: "Rocketship cannot tell which project this repo is. Run /rocketship:project <slug>, or add .rocketship.json." and stop.
   - Then give the permissions step below, once, unless the person already has it.
3. If there are no Rocketship tools at all, or `whoami` (or any Rocketship tool) says no key was sent, the key is not known, expired or was revoked, the key is the problem first, not the install. Tell them the steps, exactly:
   - Open Rocketship, go to Me, and under "Your Claude Code" press "Create my key". Copy the line it shows (it is shown once).
   - Add it to your shell profile:
     - Mac: put `export ROCKETSHIP_TOKEN=rk_...` in `~/.zshrc`.
     - Windows: in a terminal, run `setx ROCKETSHIP_TOKEN rk_...`.
   - Quit VS Code fully (Cmd+Q on a Mac, every window on Windows) and open it again, so Claude Code picks the key up. In a terminal, open a new one.
   - Open a new Claude Code session and type `/rocketship:connect` again.
4. Only if the key is set (the person confirms `echo $ROCKETSHIP_TOKEN` in a new terminal prints `rk_...`, without pasting it here) and there are still no Rocketship tools, the plugin is not installed or not enabled. Give the install, typed inside Claude Code:
   - `/plugin marketplace add nith-intent/rocketship-plugins`
   - `/plugin install rocketship@rocketship-plugins`
   - While the plugin's repository is private, installing needs read access to it on GitHub and git signed in: run `gh auth login`, then `gh auth setup-git`, in a terminal first. If the marketplace add fails to clone, ask Nith for access.
   - Then open a new Claude Code session and type `/rocketship:connect`.
5. Permissions, so Claude Code does not ask before it reads Rocketship: add Rocketship's reads, by name, to `permissions.allow` in `~/.claude/settings.json` (the person edits it, or asks you to). The line to copy is on Me in Rocketship, under "Allow Rocketship's reads", and in this plugin's README. Never add the whole server (`mcp__plugin_rocketship_rocketship__*`): taking, updating or handing off a task, posting to the team and asking Jenny must still wait for the person's yes.

6. Never ask for, read or print the key. Never put it in any file other than the shell profile the person edits themselves.

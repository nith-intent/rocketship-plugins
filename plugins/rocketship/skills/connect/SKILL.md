---
name: connect
description: Connect this Claude Code to Rocketship, say who you are connected as and which project this repo is. Use when the person types /rocketship:connect, when the session says Rocketship did not accept this Claude Code or could not be reached, or when a Rocketship tool says no key was sent or the key was not accepted.
---

# Connect to Rocketship

1. Call the Rocketship tool `whoami`.
2. If it answers with a name, tell the person: "Connected to Rocketship as <name>." Then:
   - If `.rocketship.json` is at the repo root, read its `project` slug and call `load_project` with it, to show the project is readable here. Say "This repo is <project>." in one line. Do not print the brief; `/rocketship:project` does that.
   - If there is no `.rocketship.json` and the session's brief says this folder is on no Rocketship project, say "This folder is on no Rocketship project." and stop. Do not call `load_project` without a slug there: it could name a project another window is on.
   - Otherwise, with no `.rocketship.json`, call `load_project` with no slug. If Rocketship works the project out, say which. If not, say: "Rocketship cannot tell which project this repo is. Run /rocketship:project <slug>, or add .rocketship.json." and stop.
   - Then give the permissions step below, once, unless the person already has it.
3. If `whoami` (or any Rocketship tool) says no key was sent, the key is not known, expired or was revoked, or that it is not a Rocketship key, the key is the problem first, not the install. Tell them the steps, exactly:
   - Open Rocketship, go to Me, and under "Your Claude Code" press "Create my key". Copy the key it shows (it is shown once).
   - In a terminal's Claude Code: type `/plugin`, go to Installed, pick `rocketship`, choose "Configure options", paste the key as "Rocketship key" and save. In VS Code: type `/plugins` on its own, press the gear on the `rocketship` row, paste the key, save, then "Restart Claude". Claude Code keeps it in the computer's secure store.
   - Or, instead, keep it in the shell profile as `ROCKETSHIP_TOKEN` (Me gives the line for a Mac, Linux, Git Bash and Windows). Then open a new terminal; for VS Code, quit it fully (Cmd+Q on a Mac, every window on Windows) and open it again from the Dock, Start or Finder. Under WSL, use the bash line. A key kept in Claude Code is tried first, then the profile's.
   - Open a new Claude Code session. It connects on its own; `/rocketship:connect` checks it.
4. If there are no Rocketship tools at all, find out why before giving install steps. Ask the person to type `/mcp`:
   - If `rocketship` is listed but failed to connect, Rocketship or the network is down, not the install. Say so, and that `/mcp` reconnects it (or a new session) once it is back.
   - If `rocketship` is not listed, the plugin is not installed or not enabled. Give the install:
     - In a terminal's Claude Code (or JetBrains, which runs it in a terminal): `/plugin marketplace add nith-intent/rocketship-plugins`, then `/plugin install rocketship@rocketship-plugins`, for you (user scope). Claude Code asks for the Rocketship key: paste it there.
     - In VS Code: the panel does not take `/plugin` with words after it. Type `/plugins` on its own, add `nith-intent/rocketship-plugins` on the Marketplaces tab, then on the Plugins tab install `rocketship`, "Install for you". The form asks for the Rocketship key: paste it, then "Restart Claude".
     - The repository is public, so no GitHub access is needed, only git. If the add fails to clone on a machine with a GitHub SSH key that does not work, set `CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1` and try again.
     - On Windows, the plugin's hooks need Git for Windows (Git Bash). Without it, every session start shows a hook error. If Git Bash is installed somewhere Claude Code does not find, set `CLAUDE_CODE_GIT_BASH_PATH`.
     - Then open a new Claude Code session.
5. Permissions, so Claude Code does not ask before it reads Rocketship: add Rocketship's reads, by name, to `permissions.allow` in `~/.claude/settings.json` (the person edits it, or asks you to). The line to copy is on Me in Rocketship, under "Allow Rocketship's reads", and in this plugin's README. Never add the whole server (`mcp__plugin_rocketship_rocketship__*`): taking, updating or handing off a task, posting to the team and asking Jenny must still wait for the person's yes.

6. Never ask for, read or print the key. The person pastes it into Claude Code's own dialog, or into the shell profile they edit themselves; never put it in any other file.

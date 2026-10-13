---
name: connect
description: Connect this Claude Code to Rocketship and say who you are connected as. Use when the person types /rocketship:connect, or when a Rocketship tool answers that no token was sent.
---

# Connect to Rocketship

1. Call the Rocketship tool `whoami`.
2. If it answers with a name, tell the person: "Connected to Rocketship as <name>." and stop.
3. If it fails because no token was sent or the token is not known, tell them the three steps, exactly:
   - Open Rocketship, go to Me, press "Create my token", and copy the line it shows.
   - Put that line (`export ROCKETSHIP_TOKEN=rk_...`) in `~/.zshrc`, then open a new terminal.
   - Start Claude Code again and type `/rocketship:connect`.
4. Never ask for, read or print the token. Never put it in a file other than the shell profile the person edits themselves.

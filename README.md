# Rocketship plugins

INTENT's Claude Code plugin. Your own Claude Code, on your own plan, takes its next task from Rocketship and reports back. Rocketship never sees your Claude sign-in: the only thing it sees is the Rocketship token you make on Me.

Install, once, in a terminal:

    claude plugin marketplace add nith-intent/rocketship-plugins
    claude plugin install rocketship@rocketship-plugins

Then make your token on Rocketship (Me, then Create my token), put the line it shows in your shell profile, open a new terminal, and in Claude Code type `/rocketship:connect`.

Each morning: `/rocketship:next`. When done: `/rocketship:handoff`.

The server address in `.mcp.json` and `hooks/hooks.json` is the dev Rocketship, https://rocketship.72-60-110-109.sslip.io. When Rocketship moves to its real name the plugin is updated here and `claude plugin update rocketship` picks it up.

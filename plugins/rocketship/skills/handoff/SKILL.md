---
name: handoff
description: Hand a finished task back to Rocketship with a summary and the pull request link. Use when the person types /rocketship:handoff or says the work is done.
---

# Hand off to Rocketship

1. Make sure the work is pushed and a pull request exists, titled with the item's custom id. If there is no pull request yet, offer to open one with `gh pr create` and wait for the person's go.
2. Run the Done-means checks the brief listed (typecheck, lint, tests, build). If any fails, say so and stop; do not hand off.
3. Write a two-sentence summary: what changed and how it was checked. No file names, no jargon; the lead and the client's QA read it.
4. Call `handoff` with the work item id, the summary and the pull request link.
5. Tell the person: "Handed off. It is in review." and which item to take next, from `my_work`.

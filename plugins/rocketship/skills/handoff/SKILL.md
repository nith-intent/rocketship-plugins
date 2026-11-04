---
name: handoff
description: Hand a finished task back to Rocketship with a summary and the pull request link, or fix what QA found first. Use when the person types /rocketship:handoff, says the work is done, or a task came back from QA.
---

# Hand off to Rocketship

1. Check where the item stands with `task_status` (by its ClickUp task id). If Rocketship's QA failed it or it is back in redo:
   - Call `get_fix_prompt` with the ClickUp task id. It gives the failed tests, what was expected and what was seen, the steps and the page.
   - Call `explain_failure` if the cause is not plain from that.
   - Fix those first, then come back to step 2. Do not hand off work QA already failed without fixing what it found.
2. Check the work against the rules: the acceptance list in `get_work_item`, the rules for its module and section (`project_modules` or `rules`), and `house_rules`. If a requirement is still unclear, call `ask_question` on its section and say the handoff waits on the answer.
3. Make sure the work is pushed and a pull request exists, titled with the item's custom id. If there is no pull request yet, offer to open one with `gh pr create` and wait for the person's go.
4. Run the Done-means checks the brief listed (typecheck, lint, tests, build). If any fails, say so and stop; do not hand off.
5. Write a two-sentence summary: what changed and how it was checked. No file names, no jargon; the lead and the client's QA read it. Never quote a meeting or name a client's people in it.
6. Call `handoff` with the work item id, the summary and the pull request link.
7. Tell the person: "Handed off. It is in review." and which item to take next, from `my_work`.

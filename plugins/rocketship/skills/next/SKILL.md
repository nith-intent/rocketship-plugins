---
name: next
description: Take the next task from Rocketship, show it, claim it, read its brief with the client's words behind it, and set up the branch. Use when the person types /rocketship:next or asks what to work on.
---

# Your next task from Rocketship

1. Call `my_work`. Claimed items come first, then items assigned in ClickUp, in the order Rocketship chose (project cadence, then priority).
2. Show the top item in one line: its custom id, title, project and lane. If the person already has a claimed item, that is the one; do not claim another unless they ask.
3. If the top item is not yet claimed, ask "Take it?" and on yes call `claim_work_item` with its id.
4. Call `get_work_item` and read the brief and the acceptance list back in one short paragraph.
5. Load the project once per session: if this conversation has no Rocketship working brief yet, call `load_project` with the item's project (or the slug in `.rocketship.json`) and keep a short brief, as `/rocketship:project` does. Do not load it again for each item.
6. Read what stands behind the item, only what it needs:
   - `task_detail` with the item's ClickUp task id: the full description, checklists, subtasks and people's comments.
   - `project_modules` for its module and section, and the rules placed there.
   - `search_meetings` with the item's own words (and `project_slug`), then `meeting_detail` or `get_transcript_excerpt` for the hits; `project_maps` when it is a process with steps.
   Then say in two or three lines what the client asked for, citing each meeting by date and line.
7. If the brief and the meetings disagree, or nothing says how it should work, call `ask_question` on its section with one plain question, tell the person it is asked, and work on what is settled meanwhile.
8. Check the current folder is the item's repository (the brief names it). If it is another folder, say which folder to open and stop.
9. Create the branch the brief names from `main` (`git fetch`, then `git switch -c <branch> origin/main`), unless it exists already.
10. Ask before changing anything the brief does not cover. Post progress with `post_update` as you go, in one or two sentences a teammate can read.
11. When you find work outside this item that must be done, offer `add_next_action` on the project, with one line of what and why. When a call with the client settles something in passing, offer `log_meeting_note`.
12. When stuck on something a person must do, call `mark_blocked` with what you are waiting on. When stuck on what a requirement means, use `ask_question` first.

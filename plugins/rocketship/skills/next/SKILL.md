---
name: next
description: Take the next task from Rocketship: show it, claim it, read its brief and set up the branch. Use when the person types /rocketship:next or asks what to work on.
---

# Your next task from Rocketship

1. Call `my_work`. Claimed items come first, then items assigned in ClickUp, in the order Rocketship chose (project cadence, then priority).
2. Show the top item in one line: its custom id, title, project and lane. If the person already has a claimed item, that is the one; do not claim another unless they ask.
3. If the top item is not yet claimed, ask "Take it?" and on yes call `claim_work_item` with its id.
4. Call `get_work_item` and read the brief and the acceptance list back in one short paragraph.
5. Check the current folder is the item's repository (the brief names it). If it is another folder, say which folder to open and stop.
6. Create the branch the brief names from `main` (`git switch -c <branch> main` after `git fetch`), unless it exists already.
7. Ask before changing anything the brief does not cover. Post progress with `post_update` as you go, in one or two sentences a teammate can read.
8. When stuck on something a person must do, call `mark_blocked` with what you are waiting on.

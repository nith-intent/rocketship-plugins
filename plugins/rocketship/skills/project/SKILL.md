---
name: project
description: Load the Rocketship project this repo belongs to (brief, modules and sections, meetings, process maps, ClickUp board, rules) and keep a short working brief. Use when the person types /rocketship:project, at the start of work in a client repo, and before answering "what did the client say about X", "how should X work" or "what was agreed on X".
argument-hint: "[project slug] [section]"
allowed-tools:
  - mcp__plugin_rocketship_rocketship__whoami
  - mcp__plugin_rocketship_rocketship__load_project
  - mcp__plugin_rocketship_rocketship__find_in_project
  - mcp__plugin_rocketship_rocketship__project_modules
  - mcp__plugin_rocketship_rocketship__project_meetings
  - mcp__plugin_rocketship_rocketship__meeting_detail
  - mcp__plugin_rocketship_rocketship__search_meetings
  - mcp__plugin_rocketship_rocketship__get_transcript_excerpt
  - mcp__plugin_rocketship_rocketship__project_maps
  - mcp__plugin_rocketship_rocketship__project_documents
  - mcp__plugin_rocketship_rocketship__project_team
  - mcp__plugin_rocketship_rocketship__my_promises
  - mcp__plugin_rocketship_rocketship__board_tasks
  - mcp__plugin_rocketship_rocketship__task_detail
  - mcp__plugin_rocketship_rocketship__rules
  - mcp__plugin_rocketship_rocketship__intent_rules
  - mcp__plugin_rocketship_rocketship__house_rules
  - mcp__plugin_rocketship_rocketship__knowledge
---

# Load the project from Rocketship

Rocketship holds what the client asked for: the meetings, the process maps, the modules and sections, the ClickUp board and the agreed rules. This skill reads them so the code follows what was agreed, not a guess.

## Which project

1. If the person named a project slug (`$ARGUMENTS`), use it.
2. Else read `.rocketship.json` at the repo root (`git rev-parse --show-toplevel`). It holds `{"project": "<slug>"}`. Use that slug.
3. Else call `load_project` with no slug. Rocketship works it out from the repo and your claimed task. If it cannot, it says which projects you can open: ask the person which one, and offer to write `.rocketship.json` with it (a one-line file they commit; it holds only the slug).

## Load it

1. Call `load_project` once, with the slug. It gives the brief, where the project stands, and an index of its sections (overview, modules, rules, meetings, maps, board, knowledge, people, promises) with how to read each.
2. Read only the sections the work needs, by `load_project` with `section` (and `cursor` to page on), or the tool for it. Each takes `project` (the slug):
   - modules and sections: `project_modules`. Use the module and section names as Rocketship gives them; they match the app's menu.
   - meetings: `project_meetings`, newest first, then `meeting_detail` with `meeting` (its id) for the notes, decisions, actions and the rules drawn from it (`part` "rules"), or what was said (`part` "transcript").
   - process maps: `project_maps` lists the maps; with `map` and `page` (by number) it gives the steps, each with its lane, who does it and the yes and no branches.
   - the board: `board_tasks`, then `task_detail` for one task's full description, checklists and comments.
   - rules: `rules` (the client's agreed rules), `intent_rules` and `house_rules` (INTENT's own).
   - documents, people and promises: `project_documents`, `project_team` (who to ask, never a phone or email), `my_promises` (what you owe and are owed).
3. When an answer ends with a "read on" line, read on only if the work needs the rest. Never read the whole board or every transcript just in case.

## Keep a working brief

Write one short brief in the conversation, under 25 lines, and keep to it:

- the project, the client and what it is for, in one line
- the module and section in play, by Rocketship's names
- the rules that bind the work, each in a few words
- what the client said that matters here, each with the meeting date and line
- open questions and who answers them

After a compaction Rocketship sends its context again. Call `load_project` again only if the brief is gone.

## When the person asks what the client said, or how something should work

Never answer from memory or from the code alone.

1. Search first: `search_meetings` with the feature's words (add `project_slug`), and `project_maps` for the steps of that process.
2. Read the lines around each hit with `get_transcript_excerpt` (`meeting_id` and `from`, the line to start at), and `meeting_detail` for the decisions and the rules drawn from that meeting.
3. Answer in a few sentences, citing each source as the meeting's date and title with the line, for example "Timesheet training, 21 Oct, lines 412 to 418", or the map's name and step.
4. Where the latest meeting changed an earlier one, the latest wins: say so.
5. If nothing settles it, say so plainly and offer `ask_question` (with `project`, and `module` and `section` as the Modules tab names them, and the question in one sentence as `text`), so Jenny answers. Her answer becomes a rule on that section. Never fill the gap with a guess.

## Rules

- What Rocketship gives stays in the conversation. Never write meeting words, client data or the brief into the repo, a commit, a pull request or a code comment. `.rocketship.json` holds the slug and nothing else.
- Rocketship leaves out private stretches of meetings, held meetings and clients whose data Claude may not read. If something is "not there", it is not there for you: do not try to work around it.
- Never ask for, read or print the Rocketship key.

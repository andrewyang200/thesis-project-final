We are ending this session. Before we stop:

1. Summarize what was accomplished in this session
2. Note any key decisions that were made and WHY
3. Reference which tasks from `docs/execution-plan.md` were completed (if the plan exists)
4. If any planned tasks need to be modified based on what we learned, note the proposed changes
5. List what should be done next (the next task from the plan, or next priority)
6. Flag any open issues, bugs, or unresolved questions

Append this summary to `docs/session-log.md` using this format:

```
## Session: [today's date and time]
### Plan Progress
- Tasks completed this session: [task numbers/names from execution-plan.md]
- Current position in plan: [Task N of M]
- Plan modifications needed: [any changes to upcoming tasks, or "none"]
### Completed
- [bullet list of what was done]
### Key Decisions
- [analytical or writing choices and their rationale]
### Next Steps
- [next task from the plan + any preparation needed]
### Open Issues
- [problems or questions that need resolution]
---
```

Also: if the execution plan needs updating based on what we learned this session, update `docs/execution-plan.md` to reflect the changes (mark completed tasks, revise upcoming tasks if needed).

Finally, check for uncommitted work:
`git status` (run this via bash)

If there are uncommitted changes, remind the user:
"⚠️ You have uncommitted changes. Please open your SECOND terminal tab, stage your specific files (`git add [files]`), and run your custom `aicommit` alias to save your work."

Confirm the log was updated and git status is clean.



# Context Management

## Session Continuity
- At the START of every session, read `docs/session-log.md` to understand where we left off
- At the END of every session (or before compacting), append a summary to `docs/session-log.md`
- The session log format:
```
## Session: YYYY-MM-DD HH:MM
### Completed
- [what was done]
### Key Decisions
- [any analytical or writing choices made]
### Next Steps  
- [what to do next]
### Open Issues
- [unresolved problems or questions]
```

## When to Compact vs Clear
- **`/compact`**: Use MID-TASK when context is filling up but you need continuity. Summarizes and carries forward.
- **`/clear`**: Use BETWEEN TASKS when switching from one type of work to another (e.g., R coding → LaTeX writing). Wipes to zero. After clearing, re-read the execution plan and the files relevant to the next task.
- Before EITHER command, always update `docs/session-log.md` via `/project:wrapup`
- After `/compact`: re-read CLAUDE.md and continue the current task
- After `/clear`: re-read CLAUDE.md, execution plan, and ONLY the files needed for the next task

## Git Protocol
- NEVER run git commands inside the Claude Code session — git output wastes context tokens
- All commits happen in a SECOND terminal tab
- Use your custom terminal alias: Manually stage the specific files you want to save (git add code/script.R), then run aicommit in your second terminal tab. NEVER tell Claude to "stage all".

## Task Scoping
- Work on ONE chapter or ONE analysis script at a time
- Don't try to rewrite the entire thesis in one session
- After completing a unit of work, summarize and pause for review

## File Reading Strategy
- Read existing code BEFORE writing new code
- Read existing LaTeX BEFORE writing new chapters  
- Don't duplicate work that already exists — extend it
- Use `grep` and file exploration to find relevant existing content


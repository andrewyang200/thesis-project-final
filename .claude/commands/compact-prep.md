Context is getting large. Before compacting:

1. Run `/project:wrapup` to log current session state
2. Identify which files in context are no longer needed for the immediate next task
3. Summarize the key state that must survive compaction:
   - What task are we in the middle of?
   - What files are we actively editing?
   - What decisions have been made that affect the next step?
4. Write this survival summary to `docs/compact-context.md` (overwrite previous)

After compaction, the first thing to do is:
```
Read CLAUDE.md, docs/session-log.md, and docs/compact-context.md
```
This restores enough context to continue seamlessly.

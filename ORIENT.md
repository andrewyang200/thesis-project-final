# Thesis Project — Quick Reference (For You, Not Claude)

This file is for YOU. It's a human-readable orientation to the project.
Claude doesn't need this — it has CLAUDE.md and the rules. This is your cheat sheet.

## What Is This Project?
Your Princeton ORFE senior thesis modeling time-to-resolution of U.S. federal securities
class actions using competing-risks survival analysis. Due April 9, 2026. Oral defense 
late April/early May.

## How the Workflow Works
1. Open terminal. `cd ~/Documents/thesis && claude`
2. Start with `/project:plan` — it reads the session log and tells you what's next
3. Do ONE task per session. Review it. Commit it (in second terminal tab).
4. End with `/project:wrapup`
5. At phase boundaries, run `/project:challenge [scope]` for adversarial review

## Your Slash Commands
| Command | What It Does | When to Use |
|---------|-------------|-------------|
| `/project:plan` | Reads session log, proposes next task | Start of every session |
| `/project:wrapup` | Logs progress, checks for uncommitted work | End of every session |
| `/project:status` | Dashboard of thesis completeness | When you want the big picture |
| `/project:review [file]` | Cooperative quality check | After completing any task |
| `/project:challenge [scope]` | Adversarial stress-test (bug-finder + devil's advocate) | At phase checkpoints |
| `/project:verify-numbers [file]` | Traces every number to R output | Before finalizing any results |
| `/project:compact-prep` | Saves state before compacting | When context is getting large |

## Context Management Cheat Sheet
| Situation | Do This |
|-----------|---------|
| Finishing R code, starting LaTeX writing | `/clear` then re-read plan |
| Mid-task, hitting token limits | `/compact` |
| Took a break, coming back | `claude --continue` |
| Need to go back to an old session | `claude --resume` |
| Hit daily usage limit | Your work is in files. Resume tomorrow. |

## The Two-Terminal Setup
- **Tab 1**: Claude Code (prompting, execution, review)
- **Tab 2**: Git commits, file checks, anything Claude doesn't need to see

Git commits in Tab 2:
```bash
# Stage specific files manually, then use your custom alias:
git add code/my_script.R
aicommit
```

## Key Decisions Log
> Update this section as you make important decisions during the thesis.
> This helps YOU remember why you chose what you chose — useful for the defense.

- [Date]: [Decision] — [Rationale]

## When Something Goes Wrong
- **Claude makes up numbers**: `/project:verify-numbers [file]`
- **Claude agrees with everything**: `/project:challenge [scope]`  
- **Code breaks**: `git log --oneline -10` then `git checkout [hash] -- [file]`
- **You're not sure about a statistical choice**: Ask Claude to explain tradeoffs, then decide yourself
- **Results seem too clean**: Run devil's advocate. Ask "try to break this finding"

## Important Dates
- April 9, 2026: Final thesis due
- Late April / Early May: Oral defense
- March 26, 2026: Project setup (today)

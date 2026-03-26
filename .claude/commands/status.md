Assess the current state of the thesis by checking which files exist and their status.

Check the following and report a progress dashboard:

## Code Pipeline
For each script in `code/`:
- Does it exist? 
- Read the code statically: are there obvious syntax errors?
- Do its expected output files exist in `output/`? 
- Are the output files newer than the script? (If the script was modified after the output was generated, flag it as STALE).
- DO NOT run the scripts during a status check.

## Writing Chapters
For each chapter in `writing/chapters/` or `writing/drafts/`:
- Does it exist?
- Approximate word count
- Does it have the required opening goal statement?
- Are there any `% TODO` or `% REVIEW` flags?

## Output Artifacts
- List all files in `output/figures/` and `output/tables/`
- Flag any that are referenced in the thesis but don't exist
- Flag any that exist but aren't referenced in the thesis

## Advisor Feedback
Read `docs/advisor-feedback.md` and check which items are addressed vs. outstanding.

Present as a clean status table. Be honest about what's incomplete.

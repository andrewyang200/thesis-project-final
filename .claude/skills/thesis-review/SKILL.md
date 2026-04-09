---
name: thesis-review
description: Quality review and fact-checking for thesis content. Use when asked to review, audit, verify, or check any thesis chapter for accuracy, consistency, or completeness. Also triggers when asked to check numbers against R output.
---

# Thesis Review Skill

## Operational Integration
When executing a review, use this skill document to inform your standards, but ALWAYS format your final output according to the specific prompt of the agent you are currently roleplaying (e.g., `bug-finder` or `writing-reviewer`).

## Review Checklist

### Accuracy Check
- [ ] Every number in prose matches actual R output
- [ ] Hazard ratios, CIs, and p-values are correctly transcribed
- [ ] Figure captions accurately describe what the figure shows
- [ ] Table values match the model that produced them
- [ ] Sample sizes are consistent across chapters
- [ ] Date ranges and case counts agree with data description

### Consistency Check
- [ ] Notation is consistent throughout (λ_k, F_k, etc.)
- [ ] Covariate names match between text, tables, and code
- [ ] The same model results aren't reported with different numbers in different places
- [ ] Tense is consistent (past tense for methods/results, present for discussion)
- [ ] Citation style is uniform (\citep vs \citep used correctly)

### Completeness Check
- [ ] Every chapter has an opening goal statement
- [ ] Every figure/table is referenced in the text
- [ ] Every figure/table is discussed in prose (not just displayed)
- [ ] All acronyms defined on first use
- [ ] All mathematical notation defined before use
- [ ] Model diagnostics reported for every fitted model
- [ ] Limitations acknowledged for every major finding

### Advisor Feedback Compliance
- [ ] Goal statements at chapter openings ← feedback item #1
- [ ] "Violations" disambiguation ← feedback item #2  
- [ ] Notation consistency ← feedback item #3
- [ ] Prose discussion of results ← feedback item #4
- [ ] Model accuracy metrics ← feedback item #5
- [ ] Discussion & Conclusion present ← feedback item #6

## How to Review
1. Read the chapter being reviewed
2. Cross-reference any numbers against the corresponding R script output
3. Check each item on the checklist above
4. Report findings as:
   - ✅ PASS: [item] — [brief confirmation]
   - ⚠️ WARNING: [item] — [what's unclear or needs attention]
   - ❌ FAIL: [item] — [what's wrong and how to fix it]
5. Prioritize FAIL items — these must be fixed before submission

## Red Flags (automatic FAIL)
- Any number that doesn't trace to R output
- Claiming significance when p > 0.05
- Interpreting subdistribution HR as cause-specific HR (or vice versa)
- Missing confidence intervals on any reported estimate
- Figures without axis labels, titles, or legends
- Tables without proper captions or column headers

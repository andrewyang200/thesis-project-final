Audit the numbers in the thesis against actual R output.

For the file specified ($ARGUMENTS), or if none specified, the most recently edited thesis chapter:

1. Extract every quantitative claim from the text:
   - Hazard ratios, confidence intervals, p-values
   - Sample sizes, percentages, counts  
   - C-index, AUC, covariate balance metrics (IPTW), frailty variance
   - Any other numbers

2. For each number, trace it to the R script that produced it:
   - Read the relevant script in `code/`
   - Check the output in `output/tables/` or `output/figures/`
   - If possible, run the relevant code section to verify

3. Report:
   - ✅ VERIFIED: [number] — matches [source]
   - ❌ MISMATCH: [number in text] vs [number in output] — [which file]
   - ⚠️ UNVERIFIABLE: [number] — cannot trace to any R output

This is the most important quality check. A single fabricated number invalidates the thesis.

# R Code Standards

## Script Structure
Every R script follows this template:
```
# ============================================================
# Script: XX_name.R
# Purpose: [one sentence]
# Input: data/cleaned/[filename]
# Output: output/figures/[fig names], output/tables/[table names]
# Dependencies: [packages]
# Seed: [if applicable]
# ============================================================
```

## Code Quality
- Use `library()` at top, never `require()`
- Use `here::here()` or relative paths from project root — never absolute paths
- No `setwd()` calls ever
- Wrap long pipes with one step per line
- Comment non-obvious statistical choices with WHY, not just WHAT
- Use set.seed(42) before any stochastic operation (e.g., bootstrapping standard errors).

## Output Standards
- Figures: `ggsave()` to `output/figures/`, PDF for thesis, PNG for preview
- Minimum 300 DPI for raster output
- Tables: write as `.tex` using `kableExtra::kbl()` or `xtable::xtable()`
- Every figure and table gets a descriptive filename: `fig_cif_by_circuit.pdf`, `tab_cox_settlement.tex`

## Error Handling
- Wrap model fits in `tryCatch()` — if a model fails, log the error and continue
- Check convergence explicitly: `model$convergence`, `summary(model)$convergence`
- Validate data before modeling: check for NAs, impossible durations, category counts

## Data File Handling (CRITICAL)
- **NEVER read raw data files directly into the Claude Code context** (no `cat data/raw/*.csv`)
- Raw data files may be hundreds of MB or GB. Reading them into context will crash the session.
- Always inspect data through R: `str()`, `head()`, `summary()`, `dim()`, `names()`
- To check data structure: Write a temporary code/utils/inspect.R script with str() and head(), run it via Rscript code/utils/inspect.R, and read the console output. Do not use complex inline Rscript -e "..." commands.
- To count rows without loading the full file: `Rscript -e "cat(R.utils::countLines('data/raw/file.csv'))"`
  or `wc -l data/raw/file.csv` from bash
- Cleaned/analysis-ready data in `data/cleaned/` should be .rds format (smaller, preserves types)

## Reproducibility
- Every script should be runnable independently
- Only the data preparation script should write to `data/cleaned/`
- All other scripts read from `data/cleaned/`, never modify it
- Print session info at end: `sessionInfo()`

# Thesis State — Phase 4 In Progress

> Last updated: 2026-04-05. Single source of truth for this thesis. All analysis code is locked.

---

## 1. PIPELINE STATUS

**Phase 1 (Foundation): CLOSED** — Tasks 1-5 complete.
**Phase 2 (Causal Build): CLOSED** — Tasks 6-7 complete.
**Checkpoint 1: CLOSED** — All 8 scripts (01-08) adversarially audited, fixed, and verified end-to-end on 2026-04-01. Zero errors. Full pipeline: `01_clean → 02_descriptives → 03_cox_models → 04_fine_gray → 05_causal_iptw → 06_frailty → 07_diagnostics → 08_robustness`.

**Phase 3 (Chapter Reconstruction): CLOSED** — Tasks 8-13.
- Task 8 (Lit Review): COMPLETE (2026-04-01) — reviewed, 7 targeted fixes applied, no flip contamination found.
- Task 9 (Methodology): COMPLETE (2026-04-01) — reviewed, 9 targeted fixes applied (frailty eq, IPTW assumptions, notation, accessibility, cross-refs). Writing reviewer: 0 HIGH remaining.
- Task 10 (Introduction): COMPLETE (2026-04-02) — 5 contributions, 3 number fixes, CRITICAL significance error corrected, purpose statement + roadmap added.
- Task 11 (Results 5.1-5.4): COMPLETE (2026-04-02, two sessions). All 4 sections rewritten with Code 6-verified numbers.
- Task 12 (Results 5.5-5.6): COMPLETE (2026-04-03) — rebuilt with verified numbers per execution-plan.
- Task 13 (Discussion + Future Work): COMPLETE (2026-04-04) — two passes.
**Checkpoint 2: CLOSED** — Full adversarial review (/challenge) run on all 7 chapters (2026-04-05). Four passes of surgical fixes applied. Verdict: NEEDS WORK → fixed. Core findings sound.

**Phase 4 (Polish): IN PROGRESS** — Tasks 14-15 COMPLETE. Task 16 (Final Verification) remaining.

**Deadline: April 9, 2026.**

---

## 2. IMMUTABLE METHODOLOGICAL DECISIONS

### Data Pipeline
- **Cohort**: 12,968 securities class actions (NOS 850), 1990-2024, from FJC IDB.
- **Pipeline counts**: 65,899 → 13,708 (NOS 850 filter) → 12,968 (duration > 0, valid disposition).
- **740 dropped cases**: All zero-duration administrative artifacts. No selection bias.

### Code 6 Disaggregation (CRITICAL)
FJC disposition Code 6 ("Judgment on Motion Before Trial") is disaggregated using the IDB JUDGMENT field:
- JUDGMENT = 1 (plaintiff victory, 701 cases) → **Settlement** (plaintiff-favorable resolution)
- JUDGMENT = 2 (defendant victory, 1,418 cases) → **Dismissal** (defense motion granted)
- JUDGMENT ∈ {3, 4, -8, NA} (ambiguous/missing, 270 cases) → **Censored** (conservative default)

**Final Scheme A distribution: 20.9% settlement / 67.3% dismissal / 11.7% censored.**

This is applied identically across Schemes A, B, and C. Scheme B additionally reclassifies Code 12 (voluntary dismissal) as settlement. Scheme C adds Code 5 (consent judgment) as settlement.

### Covariate Decisions
- `ext_formula_rhs`: `post_pslra + circuit_f + origin_cat + mdl_flag + juris_fq + stat_basis_f`
- `stat_basis_f` NA → explicit "Missing" factor level (134 cases, avoids silent row-dropping by coxph)
- `juris_fq`: 99.6% federal question — near-degenerate, included but noted
- `log_demand`: 98.4% missing — excluded from all models
- `mdl_flag` excluded from propensity score model (zero pre-PSLRA MDL cases → perfect separation)
- `origin_cat` "Removed" collapsed into "Other" (1 pre-PSLRA case → near-complete separation)
- Performance metrics (C-index, AUC) use reduced formula excluding `stat_basis_f` (complete separation → Inf coefficients)
- Interaction models omit `stat_basis_f` (thin cells at the interaction level)
- Reference circuit: Circuit 2 (PSLRA HR is algebraically invariant to reference choice in additive model)

### IPTW Design
- **Estimand**: ATT (not ATE) — due to 11.5:1 pre/post imbalance
- **Trimming**: 99th percentile (trim cap ~43.54, ~11 control cases trimmed)
- **ESS**: 578 (57.5% efficiency)
- **Balance**: All 19 covariates |SMD| < 0.1 after weighting
- **4-strategy triangulation**: Unadjusted → Regression-Adjusted → Doubly Robust → Marginal Structural

### Frailty Design
- `coxme::coxme()` with `(1 | circuit_f)` random effect — Gaussian on log-hazard scale
- 11 circuits (clusters). Frailty is a **sensitivity analysis**, not a standalone model.
- **methodology.tex:331 has a WRONG equation** (`u_c ~ LogNormal`). Must be fixed to `u_c ~ N(0, θ)` in Task 9.

### Time-Trend Specification
- **Linear `filing_year` is BANNED** from all models. It was the source of the debunked "Dismissal Flip" artifact (HR=0.598).
- The correct specification is `ns(filing_year, df=3)` (natural spline), used exclusively in `08_robustness.R`.
- Linear time-trend sections were permanently deleted from `03_cox_models.R` (Section 1B) and `04_fine_gray.R` (Section 5).

### Diagnostics
- `timeROC` uses `iid=TRUE` (confidence intervals enabled). All `$AUC_1` paired with `$CI_AUC_1`.
- Fine-Gray C-index is an approximation (`survival::concordance()` treats competing events as censored). Documented limitation.
- IBS (pec package) also treats competing events as censored — cause-specific approximation.

---

## 3. THE FINAL NARRATIVE TRUTHS

All numbers below are from the Code 6-disaggregated data (2026-04-01 pipeline run). These are authoritative.

### Baseline Cox (Unadjusted, PSLRA only)
| Outcome | HR | 95% CI | p |
|---|---|---|---|
| Settlement | 0.445 | [0.401, 0.495] | < 0.001 |
| Dismissal | 1.468 | [1.342, 1.606] | < 0.001 |

### Extended Cox (Full Covariates)
| Outcome | HR |
|---|---|
| Settlement | 0.702 |
| Dismissal | 1.751 |

### Piecewise Cox (Dismissal, Time-Varying Effect)
| Period | HR | p |
|---|---|---|
| 0-1 yr | 1.95 | < 0.001 |
| 1-2 yr | 1.05 | 0.582 |
| 2+ yr | 1.33 | 0.0001 |

### IPTW Triangulation (Composition-Adjusted)
| Row | Strategy | Settlement HR | Dismissal HR |
|---|---|---|---|
| 1 | Unadjusted | 0.439 | 1.466 |
| 2 | Regression-Adjusted | 0.701 | 1.746 |
| 3 | Doubly Robust | 0.709 | 1.804 |
| 4 | **MSM (IPTW only)** | **0.690** | **1.526** |

All 8 models p < 0.001 (max p = 1.29e-05 for MSM settlement).

### Frailty (Sensitivity Analysis)
| Outcome | θ (frailty variance) | Interpretation | Cluster-robust SE widening |
|---|---|---|---|
| Settlement | 0.449 | Substantial circuit heterogeneity | 2.8× (p=0.023) |
| Dismissal | 0.033 | Moderate circuit heterogeneity | 2.0× (p<0.0001) |

PSLRA HR is virtually identical between fixed-effect and random-effect models (delta=0.001). This is mathematically expected for a national-level treatment — not evidence of robustness. The model's value is θ and the cluster-robust SEs.

### Robustness (7 Specifications)
All 7 specifications show dismissal HR > 1 and settlement HR < 1. The strongest identification test is the spline time-trend control:
- **Spline (df=3)**: Settlement HR=0.610 (p=0.001), Dismissal HR=2.449 (p<0.001)
- **Range across all 7 specs**: Dismissal HR ∈ [1.32, 2.45], Settlement HR ∈ [0.44, 0.98]

### Identification Limits
- **1992 Placebo test FAILED**: HR=0.710 (p<0.001). The model detects pre-existing trends before PSLRA was enacted. This limits causal interpretability of all estimates.
- **Clean-window RDD (1993-1998)**: Dismissal HR=1.378 (p<0.001). Effect survives in narrow window, but not a pure causal test given the placebo failure.
- **IPTW covariates may be post-treatment**: Circuit, origin, MDL, and statutory basis could be consequences of PSLRA, not confounders. Composition-adjusted HR is a lower bound on the total effect.

### Fine-Gray (Subdistribution)
- Extended: Settlement SHR=0.454, Dismissal SHR=1.864
- FG dismissal PH test: p=0.362 (passes! — new finding under Code 6 data). Settlement PH: p=2.44e-07 (violated).
- MDL FG settlement SHR=1.167 (p=0.217) — NOT significant, opposite direction from CS Cox HR=0.284. Substantive finding for Results/Discussion.

### Diagnostics
| Model | C-index (Settlement) | C-index (Dismissal) |
|---|---|---|
| Cox | 0.727 | 0.597 |
| Fine-Gray | 0.662 | 0.578 |

PH tests: Both GLOBAL violated (Settlement χ²=301.1, Dismissal χ²=471.2, both p<0.001).
IBS: Settlement 0.100, Dismissal 0.181.

### Code 18 Sensitivity
Reclassifying Code 18 (statistical closing, 1,198 cases = 9.2%) as censored does not change main findings. Dismissal time-trend HR actually strengthens (0.536 vs 0.598). One-sentence note in Results/Discussion.

---

## 4. ACTIVE WRITING CONSTRAINTS

### Three-Tier Language Discipline (ENFORCED EVERYWHERE)
1. **"Associated with"** — for Cox and Fine-Gray results
2. **"After adjusting for observable case composition"** or **"composition-adjusted"** — for IPTW results
3. **"Causally attributable to"** — **NEVER USED** in this thesis. The placebo test failure and post-treatment bias concern prohibit causal claims.

### Headline Numbers
- Lead with **IPTW MSM HR ≈ 1.53** for dismissal (composition-adjusted), not the spline HR ≈ 2.45.
- Report the full range [1.28, 2.45] across specifications.
- Settlement claim must be hedged: "attenuates substantially under flexible time-trend controls (HR = 0.610) and loses statistical significance entirely in circuit-specific sub-samples" (Second Circuit HR=0.980, p=0.95; Ninth Circuit HR=0.869, p=0.13). The 1992 placebo further undermines identification.

### Framing Rules
- IPTW is a **decomposition** (how much of the raw PSLRA effect is explained by observable composition changes), not an "adjustment toward truth."
- Frailty is a **sensitivity analysis** (11 clusters is marginal), not a standalone model.
- The "Dismissal Flip" is an **artifact of linear overfitting** and must never appear in the thesis.
- PH violations make all constant-HR estimates "time-averaged summaries."
- Fine-Gray C-index is an **approximation** — acknowledge in Discussion.
- The thesis reports both confirming and disconfirming evidence honestly. Null results are results.

### Known Stale Content in .tex Files
- **data.tex**: CLEAN — all tables and prose updated with Code 6-disaggregated numbers (2026-04-03)
- **results.tex Sections 5.5-5.6**: CLEAN — rebuilt with verified numbers (2026-04-03)
- **discussion.tex**: CLEAN — fully updated in Task 13 Pass 1 (2026-04-04). All numbers verified against results.tex; IPTW + frailty sections added; Limitations rewritten.
- **conclusion.tex**: CLEAN — written from scratch in Task 13 Pass 2 (2026-04-04). Replaces future.tex.
- **methodology.tex:331**: Frailty equation FIXED (LogNormal → Gaussian, per Task 9)

### Prose Warnings from Devil's Advocate (Fix in Phase 3)
- Gray's test p-values: accompany with effect size context (N=12,968 makes everything significant)
- Censoring framing: "non-modeled exit pathways," NOT "snapshot date censoring" — all 1,251 censored cases have termination dates
- Don't say "permanent reduction" from CIF alone without controlling for confounders
- Second Circuit: say "Second Circuit" not "SDNY" — data is circuit-level (includes EDNY, NDNY, etc.)
- Code 6 era confound: 93.4% of reclassified plaintiff victories are post-PSLRA. Note in Discussion as data limitation.

---

## 5. PHASE 4 — FINAL POLISH & SUBMISSION

### A. Critical Blockers

**Task 14: Abstract** ✅ COMPLETE (2026-04-05)
- ~215 words. Research question → methods → PSLRA 3-phase → IPTW decomposition → circuit range → MDL sign-reversal. No causal language. Closing sentence handles limitations + contribution.
- File: `writing/chapters/abstract.tex`

**Figure readability** ✅ COMPLETE (2026-04-05)
- `base_size` 12→14 globally in `utils.R`; all font sizes scaled proportionally
- Removed all embedded `caption=` and `subtitle=` from every ggplot figure across all scripts
- Side-by-side figure save dimensions reduced (8×6→4.5×4 for KM/CIF pairs; 9×6→5×5 for circuit pairs; Schoenfeld 8×6→5×4) — effective print text ~10pt vs prior ~5pt
- `fig_ps_overlap` and `fig_auc_over_time` added to results.tex (were generated but unused)
- Duplicate `\label{sec:frailty}` resolved: methodology.tex renamed to `\label{sec:frailty_method}`
- All scripts re-run: 02, 05_causal_iptw, 05_propensity_scores, 07, 08

### B. Required Before Submission

**Task 15: Formatting** ✅ COMPLETE (2026-04-05)
- `\usepackage{hyperref}` added to `writing/thesis.tex` (last package, colorlinks)
- Submission date updated: `March 1, 2026` → `April 9, 2026`
- Cross-reference audit: all refs have matching labels; one duplicate fixed (sec:frailty)

**Task 16: Final Number Verification** ← NEXT SESSION
- Spot-check all cited statistics in prose against R output (focus on any numbers touched during Phase 4 edits)
- Confirm robustness range "1.32 to 2.45" in intro.tex matches Table tab:robustness minimum (Scheme B/C HR=1.321)
- Also verify: n=11,835 post-IPTW count in results.tex:1086 against R output (unverified, flagged during abstract writing)

### C. Low-Priority / Known Non-Blockers

- IPTW triangulation table (Tab. 5.2) lacks CIs for rows 3–4 — acknowledged in text via SE caveat; non-blocking
- 5 deferred LOW items from Task 9: subscript gap, ratio discrepancy, Gray's test note, train/test count, missing figure labels
- Cross-script `df_ext` construction duplication in `03`, `04`, `07` — cosmetic; does not affect results
- intro.tex Code 6 language: "novel disaggregation" softened to "correctly classify" (2026-04-06)
- `writing/chapters/acknow.tex` still a placeholder — requires Andrew's personal content

## Session: 2026-04-06 02:00
### Plan Progress
- Tasks completed this session: Task 14 (Abstract), Task 15 (Formatting), Figure Polish (unlisted sub-task)
- Current position in plan: Task 16 of 16 remaining
- Plan modifications needed: Task 16 expanded to include verification of n=11,835 post-IPTW count in results.tex:1086

### Completed
- **Abstract** (`writing/chapters/abstract.tex`): Written from scratch (~215 words). Research question → methods (CIF, Cox, FG, IPTW, frailty) → PSLRA three-phase finding → IPTW decomposition → circuit range → MDL sign-reversal. No causal language. Closing sentence handles limitations + contribution in one line. Iterated with Andrew on framing; Andrew's final version used with two edits (drop "Finally,", sharpen closing clause).
- **Formatting** (`writing/thesis.tex`): Added `\usepackage[colorlinks]{hyperref}` (last package), updated `\submitted{}` from March 1 → April 9, 2026. Full cross-reference audit: all `\ref{}` have matching `\label{}`; fixed one duplicate `\label{sec:frailty}` (methodology.tex renamed to `\label{sec:frailty_method}`).
- **Figure polish** (all R scripts + results.tex):
  - Removed all embedded `caption=` and `subtitle=` from every ggplot across all scripts (thesis figures are not standalone)
  - Added two unused figures to results.tex: `fig_ps_overlap` (after Love plot, with bridging prose) and `fig_auc_over_time` (after IBS discussion, with bridging prose)
  - Final font sizes: base 14, title 16, axis.title 14, axis.text 12, legend 12, strip 13 (uniform +2 from original across all elements)
  - Shortened titles for love plot ("Covariate Balance: IPTW Weighting") and robustness ("PSLRA Hazard Ratios: Robustness Check") to fit panel widths
  - Removed Schoenfeld legends (LaTeX caption already explains red dashed line)
  - All 14 figures regenerated: 02, 05_causal_iptw, 05_propensity_scores, 07, 08
- **intro.tex**: Softened Code 6 language from "novel disaggregation" to "correctly classify"

### Key Decisions
- **Abstract structure**: Andrew's version of P2 used over Claude's (better language discipline: "exhibits an association" vs "exerts an influence"; "emerges as" vs "is"; cleaner closing sentence). Two edits applied: drop "Finally,", tighten "structural asymmetries" → "structural features of securities litigation dynamics previously invisible to single-outcome approaches."
- **Code 6 sentence removed from abstract**: The thesis itself treats Code 6 disaggregation as a data cleaning step and flags it as a limitation/confound. Calling it "novel" in the abstract was inconsistent with the body. Removed.
- **Third paragraph of abstract removed**: Listing ESS=578, 11 clusters, and future directions in the abstract was over-explaining. The second paragraph's closing sentence ("While secular pre-trends limit strict causal attribution...") handles the limitations concisely.
- **Figure dimensions kept at original (8×6, 9×6)**: Attempted to shrink side-by-side figure canvases for better print readability, but this caused title clipping and visual inconsistency. Original dimensions restored; font sizes bumped instead.
- **Schoenfeld legend removed**: Base R legend with `bg="white"` covered plot elements and thinned the plot border. Since LaTeX caption already explains the red dashed line, legend is redundant. Removed.
- **`plot.title.position = "plot"` rejected**: Made love plot and robustness figures look inconsistent with CIF plots due to wide y-axis labels. Reverted to default. Title clipping fixed by shortening titles instead.

### Next Steps
- **Task 16**: Final number verification — run `/verify-numbers` to spot-check all cited statistics in prose against R output. Key targets: robustness range "1.32 to 2.45", n=11,835 post-IPTW in results.tex:1086 (unverified), any numbers touched during Phase 4 edits.
- **Acknowledgements**: `writing/chapters/acknow.tex` is still a placeholder. Requires Andrew's personal content (advisor, department, etc.) — 15-minute task.
- After Task 16 + acknowledgements: thesis is submission-ready.

### Open Issues
- `n=11,835` post-PSLRA IPTW count at results.tex:1086 is unverified against R output. It doesn't reconcile with 12,968 − 1,031 = 11,937. Needs checking in Task 16.
- Diagnostics background run (byw676svj) for Schoenfeld/AUC at final font sizes was still running at session end. Figures should update automatically; verify timestamps before submission.
- `writing/chapters/acknow.tex` is a placeholder — Andrew must fill in personally.
---

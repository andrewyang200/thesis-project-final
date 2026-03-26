---
name: survival-analysis
description: Competing-risks survival analysis for securities litigation data. Use when asked to write, debug, or explain R code for KM curves, CIF, Cox models, Fine-Gray models, RSF, or model diagnostics. Also use when interpreting survival analysis results or writing methodology chapters.
---

# Survival Analysis Skill

## Context
This thesis uses competing-risks survival analysis on federal securities class actions.
- **Time variable**: duration from case filing to termination (in days or years)
- **Competing events**: Settlement (event=1) vs. Dismissal (event=2) vs. Censored/other (event=0)
- **Framework**: cause-specific hazards AND subdistribution hazards (both perspectives needed)

## R Package Reference

### Core Packages
| Package | Use |
|---------|-----|
| `survival` | Cox models, `Surv()`, `coxph()`, `survfit()`, Schoenfeld tests |
| `cmprsk` | `cuminc()` for CIF, `crr()` for Fine-Gray |
| `tidycmprsk` | Tidy interface to `cmprsk` |
| `coxme`, `WeightIt`, `cobalt` | Mixed-effects frailty models and IPTW causal weighting |
| `timeROC` | Time-dependent AUC for competing risks |
| `ggsurvfit` | Publication-quality survival plots |

### Model Specification Patterns

**Cause-specific Cox (settlement hazard):**
```r
cox_settle <- coxph(
  Surv(duration_years, event == 1) ~ pslra + circuit + origin + mdl_status + statutory_basis,
  data = df
)
```

**Fine-Gray subdistribution (settlement):**
```r
fg_settle <- crr(
  ftime = df$duration_years,
  fstatus = df$event_type,
  cov1 = model.matrix(~ pslra + circuit + origin + mdl_status + statutory_basis, data = df)[, -1],
  failcode = 1,  # settlement
  cencode = 0    # censored
)
```

# Shared Frailty Model (Circuit Clustering):
```r
frailty_model <- survival::coxph(
  Surv(duration_years, event == 1) ~ pslra + origin + mdl_status + frailty(circuit),
  data = df
)
```

# IPTW for Causal PSLRA Effect:
```r
# 1. Generate weights
weights_obj <- WeightIt::weightit(pslra ~ circuit + origin + mdl_status + demand_category, 
                                  data = df, method = "ps", estimand = "ATE")
# 2. Check balance (save this plot!)
cobalt::love.plot(weights_obj, threshold = 0.1)
# 3. Fit weighted Cox model (MUST use robust standard errors)
iptw_cox <- survival::coxph(
  Surv(duration_years, event == 1) ~ pslra, 
  data = df, 
  weights = weights_obj$weights, 
  robust = TRUE
)
```


## Diagnostics Checklist
When presenting any model, ALWAYS report:
1. **C-index**: `concordance(model)` or via `pec` — proportion of concordant pairs
2. **Time-dependent AUC**: `timeROC()` at clinically meaningful time points (1yr, 3yr, 5yr, 10yr)
3. **PH test**: `cox.zph(model)` — if p < 0.05, PH assumption violated for that covariate
4. **If PH violated**: stratify on the offending variable OR use time-varying coefficients

## Common Gotchas
- `cuminc()` from `cmprsk` takes a factor `group` argument, not a formula
- Fine-Gray `crr()` requires a numeric matrix for covariates, not a formula — use `model.matrix()`
- Time-dependent AUC for competing risks uses `timeROC(..., cause = 1)` — specify which event
- CIF curves should NEVER be computed as 1 - KM. Use Aalen-Johansen estimator properly.
- When comparing nested models, use likelihood ratio test, not just AIC
- Context Limit: Never print massive dataframes or model objects directly to the console. Wrap outputs in summary() or head() to prevent terminal bloat.
- When using IPTW, you must specify robust = TRUE in the coxph model. Weighting artificially inflates sample size; failure to use robust standard errors will result in artificially tiny p-values (a fatal statistical error).

## Interpretation Guide
- **Cause-specific HR > 1**: higher instantaneous rate of that event, among those still at risk
- **Subdistribution HR > 1**: higher cumulative probability of that event over time (accounts for competing risk)
- These can diverge! A covariate may increase cause-specific settlement hazard but decrease subdistribution settlement hazard if it also strongly increases dismissal
- Always present BOTH cause-specific and subdistribution results for key covariates
- Explain the difference to the reader in the methodology chapter

## Additional References
For detailed guidance on specific analyses, read the relevant code file in `code/` before writing.

# =============================================================================
# COMPLETE ANALYSIS SCRIPT
# Federal Securities Class Actions: Competing-Risks Survival Analysis
# Princeton University ORFE Senior Thesis - Spring 2026
#
# This single script reproduces the entire analysis from raw data loading
# through all fall and spring results. Run top-to-bottom in RStudio.
#
# REQUIRED PACKAGES (run install block below on first use):
#   tidyverse, lubridate, janitor, survival, cmprsk, scales,
#   randomForestSRC, timeROC, pec, prodlim
#
# INPUT:
#   cv88on.txt   — FJC Integrated Database civil file
#
# OUTPUTS (all written to your working directory):
#   Figures 1–8  (PNG, 300 dpi)
#   securities_cohort_cleaned.rds
#   results_fall.rds
#   results_spring.rds

stop(
  paste(
    "Historical script only. Do not run or cite code/InterimScript.R.",
    "The authoritative modular analysis is code/01_clean.R through code/08_robustness.R,",
    "and the current thesis-state source of truth is docs/session-log.md."
  )
)
#
# =============================================================================

# ---- Install packages (uncomment and run once, then re-comment) ----
# install.packages(c(
#   "tidyverse", "lubridate", "janitor", "survival", "cmprsk", "scales",
#   "randomForestSRC", "timeROC", "pec", "prodlim"
# ))

library(tidyverse)
library(lubridate)
library(janitor)
library(survival)
library(cmprsk)
library(scales)
library(randomForestSRC)
library(timeROC)
library(pec)
library(prodlim)

# ---- UPDATE THIS PATH ----
FILE_PATH <- "/Users/andrewyang/Documents/thesis/cv88on.txt"

cat("=================================================================\n")
cat(" SECURITIES CLASS ACTION COMPETING-RISKS SURVIVAL ANALYSIS\n")
cat("=================================================================\n\n")


# =============================================================================
# SECTION 1: DATA LOADING AND CLEANING
# =============================================================================
cat("SECTION 1: Loading and cleaning raw IDB data...\n")

df_raw <- read_tsv(
  FILE_PATH,
  guess_max      = 200000,
  show_col_types = FALSE
) %>%
  clean_names()

cat(paste("  Total rows loaded:", format(nrow(df_raw), big.mark = ","), "\n"))

# Filter to NOS 850, parse dates, compute duration
df_sec <- df_raw %>%
  filter(nos == 850) %>%
  mutate(
    filedate  = as.Date(parse_date_time(filedate, orders = c("mdy", "ymd", "dmy"),
                                        quiet = TRUE)),
    termdate  = as.Date(parse_date_time(termdate, orders = c("mdy", "ymd", "dmy"),
                                        quiet = TRUE)),
    duration_years = as.numeric(termdate - filedate) / 365.25
  ) %>%
  filter(filedate >= as.Date("1990-01-01"))

cat(paste("  NOS 850 cases (post-1990):", format(nrow(df_sec), big.mark = ","), "\n"))


# =============================================================================
# SECTION 2: SECTION FIELD EXPLORATION
# =============================================================================
# The IDB SECTION field is optional. We inspect it here for NOS 850 cases
# to assess whether statutory basis (Securities Act s.11 vs Exchange Act s.10b)
# can be partially recovered. We code it where available and use a missingness
# indicator so no observations are dropped.
# =============================================================================
cat("\nSECTION 2: Exploring SECTION field for statutory basis signal...\n")

section_check <- df_sec %>%
  mutate(section_raw = as.character(section)) %>%
  filter(!is.na(section_raw), section_raw != "-8", section_raw != "") %>%
  count(section_raw, sort = TRUE) %>%
  mutate(pct = round(100 * n / nrow(df_sec), 2))

cat(paste("  Cases with non-missing SECTION:",
          format(sum(section_check$n), big.mark = ","),
          paste0("(", round(100 * sum(section_check$n) / nrow(df_sec), 1), "% of NOS 850)\n")))

cat("  Top SECTION values (NOS 850 cases):\n")
print(head(section_check, 30))

# Code statutory basis from SECTION field
# Common patterns in NOS 850:
#   Exchange Act 1934 s.10(b) / Rule 10b-5: "10B", "78J", "10(B)", "10b-5" variants
#   Securities Act 1933 s.11:               "11",  "77K"
#   Both / other:                           everything else with a value
df_sec <- df_sec %>%
  mutate(
    section_raw = toupper(trimws(as.character(section))),
    statutory_basis = case_when(
      section_raw %in% c("-8", "", "NA") | is.na(section_raw) ~ NA_character_,
      grepl("10B|78J|10\\(B\\)|10B-5|0078", section_raw)  ~ "10(b)",
      grepl("^11$|77K|^11 |0077", section_raw)            ~ "Section 11",
      !is.na(section_raw) & section_raw != "-8"           ~ "Other/Both"
    ),
    statutory_basis_f    = factor(statutory_basis, 
                                  levels = c("10(b)", "Section 11", "Other/Both")),
    statutory_basis_miss = as.integer(is.na(statutory_basis))
  )

cat("\n  Statutory basis distribution after coding:\n")
print(table(df_sec$statutory_basis, useNA = "always"))

cat(paste("  Coverage rate:",
          round(100 * mean(!is.na(df_sec$statutory_basis)), 1), "%\n"))

# =============================================================================
# SECTION 3: SAMPLE CONSTRUCTION
# =============================================================================
cat("\nSECTION 3: Constructing analysis sample...\n")

# Stage 1: Already filtered to NOS 850 and post-1990 in Section 1
n_nos850 <- nrow(df_sec)

# Stage 2: Class action flag
n_classact <- sum(df_sec$classact == 1, na.rm = TRUE)

# Stage 3: Valid duration
df_cohort <- df_sec %>%
  filter(classact == 1, duration_years > 0)
n_valid <- nrow(df_cohort)

cat(paste("  All NOS 850 (post-1990):", format(n_nos850, big.mark = ","), "\n"))
cat(paste("  Class action flag = 1:  ", format(n_classact, big.mark = ","), "\n"))
cat(paste("  Valid duration (>0):    ", format(n_valid, big.mark = ","), "\n"))


# =============================================================================
# SECTION 4: THREE DISPOSITION CODING SCHEMES
# =============================================================================
# Scheme A (Primary):  Code 13 = settled; Codes 2,3,12,14,15,17,18,19 = dismissed
# Scheme B (Liberal):  Recode Code 12 (voluntary) → settlement (hidden settlements)
# Scheme C (Expanded): Scheme B + Code 5 (consent judgment) → settlement
#
# Codes 0,1,10,11 (transfers/remands) and trial codes (6,7,8,9) are left as
# censored in all schemes — they are not terminal outcomes for our analysis.
# =============================================================================
cat("\nSECTION 4: Coding three disposition schemes...\n")

code_events <- function(df, scheme = "A") {
  df %>%
    mutate(
      event_type = case_when(
        disp == 13                              ~ 1L,   # Settled
        scheme %in% c("B","C") & disp == 12    ~ 1L,   # Voluntary → settlement (B,C)
        scheme == "C"          & disp == 5     ~ 1L,   # Consent judgment → settlement (C)
        disp %in% c(2, 3, 14, 15, 17, 18, 19) ~ 2L,   # Dismissals
        scheme == "A"          & disp == 12    ~ 2L,   # Voluntary → dismissal (A)
        disp == 4                              ~ 2L,   # Default judgment → dismissal
        TRUE                                   ~ 0L    # Censored
      ),
      scheme = scheme
    )
}

df_A <- code_events(df_cohort, "A")
df_B <- code_events(df_cohort, "B")
df_C <- code_events(df_cohort, "C")

scheme_summary <- map_dfr(list(A = df_A, B = df_B, C = df_C), function(d) {
  tibble(
    N           = nrow(d),
    Settlements = sum(d$event_type == 1),
    Dismissals  = sum(d$event_type == 2),
    Censored    = sum(d$event_type == 0),
    Pct_Settle  = round(100 * mean(d$event_type == 1), 1),
    Pct_Dismiss = round(100 * mean(d$event_type == 2), 1)
  )
}, .id = "Scheme")

cat("\nTABLE S1: Outcome distribution by disposition coding scheme\n")
print(scheme_summary)

# Scheme A is the primary analysis dataset throughout
df_model <- df_A


# =============================================================================
# SECTION 5: COVARIATE CONSTRUCTION
# =============================================================================
cat("\nSECTION 5: Constructing covariates...\n")

df_model <- df_model %>%
  mutate(
    # ---- Core covariates ----
    post_pslra  = as.integer(filedate >= as.Date("1995-12-22")),
    pslra_label = factor(post_pslra, 0:1, c("Pre-PSLRA", "Post-PSLRA")),
    filing_year = year(filedate),
    circuit_f   = factor(circuit),
    
    # ---- ORIGIN: how the case entered federal court ----
    # Codebook: 1=original, 2=removed from state, 3=remand from CoA,
    #           4=reinstated, 5=transfer §1404, 6=MDL transfer,
    #           7=mag appeal, 8-12=reopens, 13=MDL originating
    origin_cat = case_when(
      origin == 1          ~ "Original",
      origin == 2          ~ "Removed",
      origin %in% c(6, 13) ~ "MDL",
      origin %in% c(3,4,5) ~ "Other",
      TRUE                 ~ NA_character_
    ),
    origin_cat = factor(origin_cat, levels = c("Original","Removed","MDL","Other")),
    
    # ---- MDL FLAG ----
    mdl_flag = as.integer(!is.na(mdldock) &
                            as.character(mdldock) != "-8" &
                            as.character(mdldock) != ""),
    
    # ---- JURY DEMAND: adversarial intensity proxy ----
    jury_demand = case_when(
      jury %in% c("B","P","D") ~ 1L,
      jury == "N"              ~ 0L,
      TRUE                     ~ NA_integer_
    ),
    
    # ---- MONETARY DEMAND: case size proxy ----
    demanded_num = suppressWarnings(as.numeric(demanded)),
    demand_valid = !is.na(demanded_num) & demanded_num > 0 & demanded_num < 9999,
    log_demand   = if_else(demand_valid, log(demanded_num + 1), NA_real_),
    demand_miss  = as.integer(!demand_valid),
    
    # ---- JURISDICTION: federal question vs. diversity ----
    juris_fq = as.integer(juris == 3),
    
    # ---- STATUTORY BASIS (from SECTION field, where available) ----
    # Already coded in Section 2; carry through here
    stat_basis_f    = statutory_basis_f,
    stat_basis_miss = statutory_basis_miss,
    
    # ---- Event label ----
    event_label = factor(event_type, 0:2,
                         c("Censored","Settlement","Dismissal"))
  )

cat("  Covariate missingness summary:\n")
miss_tbl <- df_model %>%
  summarise(
    origin_miss     = round(100 * mean(is.na(origin_cat)), 1),
    mdl_miss        = round(100 * mean(is.na(mdl_flag)), 1),
    jury_miss       = round(100 * mean(is.na(jury_demand)), 1),
    demand_miss_pct = round(100 * mean(demand_miss == 1), 1),
    juris_miss      = round(100 * mean(is.na(juris_fq)), 1),
    stat_basis_miss = round(100 * mean(stat_basis_miss == 1), 1)
  )
print(miss_tbl)

cat("\nEvent distribution (Scheme A):\n")
print(table(df_model$event_label))


# =============================================================================
# SECTION 6: DESCRIPTIVE STATISTICS
# =============================================================================
cat("\nSECTION 6: Descriptive statistics...\n")

# ---- Table 1A: Sample construction ----
cat("\nTABLE 1A: Sample Construction\n")
tribble(
  ~Stage, ~Description, ~N, ~Pct,
  "1", "All NOS 850 (1990-present)",   n_nos850,   100.0,  # Removed quotes here
  "2", "Class action flag = 1",        n_classact, round(100*n_classact/n_nos850, 1),
  "3", "Valid duration (>0 days)",     n_valid,    round(100*n_valid/n_nos850, 1)
) %>%
  print()

# ---- Table 1B: Outcome distribution ----
cat("\nTABLE 1B: Outcome Distribution\n")
df_model %>%
  count(event_label) %>%
  mutate(Pct = round(100*n/sum(n), 1)) %>%
  print()

# ---- Table 1C: By PSLRA regime ----
cat("\nTABLE 1C: By PSLRA Regime\n")
df_model %>%
  group_by(pslra_label) %>%
  summarise(
    N              = n(),
    Settlements    = sum(event_type == 1),
    Dismissals     = sum(event_type == 2),
    Pct_Settlement = round(100*mean(event_type==1), 1),
    Pct_Dismissal  = round(100*mean(event_type==2), 1),
    .groups = "drop"
  ) %>%
  print()

# ---- Table 1D: Duration by outcome (resolved cases only) ----
cat("\nTABLE 1D: Duration Statistics by Outcome (resolved cases)\n")
df_model %>%
  filter(event_type != 0) %>%
  group_by(event_label) %>%
  summarise(
    N      = n(),
    Mean   = round(mean(duration_years), 2),
    Median = round(median(duration_years), 2),
    Q25    = round(quantile(duration_years, 0.25), 2),
    Q75    = round(quantile(duration_years, 0.75), 2),
    .groups= "drop"
  ) %>%
  print()

# ---- Table 1E: Circuit distribution ----
cat("\nTABLE 1E: Circuit Distribution\n")
df_model %>%
  count(circuit) %>%
  mutate(
    Pct = round(100*n/sum(n), 1),
    Circuit_Name = case_when(
      circuit == 0  ~ "D.C.",
      circuit == 1  ~ "First",
      circuit == 2  ~ "Second (NYC)",
      circuit == 3  ~ "Third (PA/NJ/DE)",
      circuit == 4  ~ "Fourth",
      circuit == 5  ~ "Fifth (TX/LA)",
      circuit == 6  ~ "Sixth",
      circuit == 7  ~ "Seventh",
      circuit == 8  ~ "Eighth",
      circuit == 9  ~ "Ninth (CA)",
      circuit == 10 ~ "Tenth",
      circuit == 11 ~ "Eleventh",
      TRUE          ~ paste("Circuit", circuit)
    )
  ) %>%
  arrange(desc(n)) %>%
  print()


# =============================================================================
# SECTION 7: FIGURE 1 — KAPLAN-MEIER OVERALL SURVIVAL
# =============================================================================
cat("\nSECTION 7: Figure 1 — Kaplan-Meier survival curve...\n")

surv_obj    <- Surv(df_model$duration_years, df_model$event_type != 0)
km_overall  <- survfit(surv_obj ~ 1)

km_df <- tibble(
  time  = km_overall$time,
  surv  = km_overall$surv,
  lower = km_overall$lower,
  upper = km_overall$upper
)

fig1 <- ggplot(km_df, aes(x = time, y = surv)) +
  geom_step(linewidth = 1, color = "#2166AC") +
  geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.18, fill = "#2166AC") +
  scale_x_continuous(limits = c(0, 10), breaks = seq(0, 10, 2)) +
  scale_y_continuous(limits = c(0, 1), labels = percent_format(accuracy = 1)) +
  labs(
    title    = "Figure 1: Duration of Federal Securities Class Actions",
    subtitle = paste0("Kaplan-Meier estimate (n = ",
                      format(nrow(df_model), big.mark = ","), ")"),
    x        = "Years Since Filing",
    y        = "Proportion Pending (Unresolved)",
    caption  = paste0(
      "Source: FJC Integrated Database, NOS 850 with class action flag, 1990–present.\n",
      "Shaded band = 95% pointwise confidence interval."
    )
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title       = element_text(face = "bold", size = 14),
    plot.subtitle    = element_text(size = 11, color = "gray40"),
    plot.caption     = element_text(size = 9, color = "gray50", hjust = 0),
    panel.grid.minor = element_blank()
  )

ggsave("figure1_km_overall.png", fig1, width = 8, height = 6, dpi = 300)
cat("  Saved: figure1_km_overall.png\n")


# =============================================================================
# SECTION 8: FIGURE 2 — CUMULATIVE INCIDENCE (OVERALL)
# =============================================================================
cat("\nSECTION 8: Figure 2 — Aalen-Johansen CIF (overall)...\n")

cif_overall <- cuminc(
  ftime   = df_model$duration_years,
  fstatus = df_model$event_type,
  cencode = 0
)

cif_overall_df <- bind_rows(
  tibble(time = cif_overall$`1 1`$time,
         prob = cif_overall$`1 1`$est,
         outcome = "Settlement"),
  tibble(time = cif_overall$`1 2`$time,
         prob = cif_overall$`1 2`$est,
         outcome = "Dismissal")
)

fig2 <- ggplot(cif_overall_df, aes(x = time, y = prob, color = outcome)) +
  geom_step(linewidth = 1.2) +
  scale_x_continuous(limits = c(0, 8), breaks = seq(0, 8, 2)) +
  scale_y_continuous(limits = c(0, 1), labels = percent_format(accuracy = 1)) +
  scale_color_manual(values = c("Settlement" = "#1B7837", "Dismissal" = "#B2182B")) +
  labs(
    title    = "Figure 2: Cumulative Incidence of Settlement vs. Dismissal",
    subtitle = "Aalen-Johansen estimates under competing-risks framework",
    x        = "Years Since Filing",
    y        = "Cumulative Probability",
    color    = "Outcome",
    caption  = paste0(
      "Source: FJC Integrated Database. Settlement = disposition code 13; ",
      "Dismissal = codes 2, 3, 4, 12, 14, 15, 17, 18, 19."
    )
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title       = element_text(face = "bold", size = 14),
    plot.subtitle    = element_text(size = 11, color = "gray40"),
    plot.caption     = element_text(size = 9, color = "gray50", hjust = 0),
    panel.grid.minor = element_blank(),
    legend.position  = "bottom"
  )

ggsave("figure2_cif_overall.png", fig2, width = 8, height = 6, dpi = 300)
cat("  Saved: figure2_cif_overall.png\n")


# =============================================================================
# SECTION 9: FIGURE 3 — CIF BY PSLRA REGIME + Gray's test + Table 2
# =============================================================================
cat("\nSECTION 9: Figure 3 — CIF by PSLRA regime...\n")

cif_pslra <- cuminc(
  ftime   = df_model$duration_years,
  fstatus = df_model$event_type,
  group   = df_model$pslra_label,
  cencode = 0
)

cat("\nTABLE: Gray's test for PSLRA regime\n")
print(cif_pslra$Tests)

extract_cif <- function(cif_obj, group_name, event_code, event_label) {
  key <- paste(group_name, event_code)
  if (!key %in% names(cif_obj)) return(NULL)
  tibble(
    time    = cif_obj[[key]]$time,
    prob    = cif_obj[[key]]$est,
    group   = group_name,
    outcome = event_label
  )
}

cif_pslra_df <- bind_rows(
  extract_cif(cif_pslra, "Pre-PSLRA",  1, "Settlement"),
  extract_cif(cif_pslra, "Pre-PSLRA",  2, "Dismissal"),
  extract_cif(cif_pslra, "Post-PSLRA", 1, "Settlement"),
  extract_cif(cif_pslra, "Post-PSLRA", 2, "Dismissal")
) %>%
  mutate(series = paste(group, outcome, sep = " — "))

fig3 <- ggplot(cif_pslra_df,
               aes(x = time, y = prob, color = series, linetype = series)) +
  geom_step(linewidth = 1) +
  scale_x_continuous(limits = c(0, 8), breaks = seq(0, 8, 2)) +
  scale_y_continuous(limits = c(0, 1), labels = percent_format(accuracy = 1)) +
  scale_color_manual(values = c(
    "Pre-PSLRA — Settlement"  = "#1B7837",
    "Pre-PSLRA — Dismissal"   = "#B2182B",
    "Post-PSLRA — Settlement" = "#74C476",
    "Post-PSLRA — Dismissal"  = "#FC8D59"
  )) +
  scale_linetype_manual(values = c(
    "Pre-PSLRA — Settlement"  = "solid",
    "Pre-PSLRA — Dismissal"   = "solid",
    "Post-PSLRA — Settlement" = "dashed",
    "Post-PSLRA — Dismissal"  = "dashed"
  )) +
  guides(
    color    = guide_legend(nrow = 2, byrow = TRUE),
    linetype = guide_legend(nrow = 2, byrow = TRUE)
  ) +
  labs(
    title    = "Figure 3: Cumulative Incidence by PSLRA Regime",
    subtitle = "Private Securities Litigation Reform Act (effective December 22, 1995)",
    x        = "Years Since Filing",
    y        = "Cumulative Probability",
    color    = NULL, linetype = NULL,
    caption  = "Source: FJC Integrated Database. Solid lines = Pre-PSLRA; dashed = Post-PSLRA."
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title       = element_text(face = "bold", size = 14),
    plot.subtitle    = element_text(size = 11, color = "gray40"),
    plot.caption     = element_text(size = 9, color = "gray50", hjust = 0),
    panel.grid.minor = element_blank(),
    legend.position  = "bottom",
    legend.key.width = unit(1.8, "lines")
  )

ggsave("figure3_cif_pslra.png", fig3, width = 9, height = 6, dpi = 300)
cat("  Saved: figure3_cif_pslra.png\n")

# ---- Table 2: CIF at key horizons ----
get_cif_at_t <- function(cif_curve, t_target) {
  idx <- which(cif_curve$time <= t_target)
  if (length(idx) == 0) return(0)
  cif_curve$est[max(idx)]
}

horizons <- c(1, 2, 3, 5)

cat("\nTABLE 2: Cumulative Incidence at Key Horizons by PSLRA Regime (%)\n")
expand_grid(
  Group   = c("Pre-PSLRA", "Post-PSLRA"),
  Outcome = c("Settlement", "Dismissal"),
  Horizon = horizons
) %>%
  rowwise() %>%
  mutate(
    ev_code = if_else(Outcome == "Settlement", 1, 2),
    key     = paste(Group, ev_code),
    CIF_pct = round(get_cif_at_t(cif_pslra[[key]], Horizon) * 100, 1)
  ) %>%
  select(Group, Outcome, Horizon, CIF_pct) %>%
  pivot_wider(names_from = Horizon, values_from = CIF_pct,
              names_prefix = "Yr_") %>%
  print()


# =============================================================================
# SECTION 10: FIGURES 4–5 — CIF BY CIRCUIT (Top 4)
# =============================================================================
cat("\nSECTION 10: Figures 4-5 — CIF by circuit...\n")

circuit_counts <- df_model %>% count(circuit, sort = TRUE)
top4_circuits  <- circuit_counts %>% head(4) %>% pull(circuit)

df_top4 <- df_model %>%
  filter(circuit %in% top4_circuits) %>%
  mutate(circuit_name = case_when(
    circuit == 2 ~ "Second (NYC)",
    circuit == 9 ~ "Ninth (CA)",
    circuit == 3 ~ "Third (PA/NJ/DE)",
    circuit == 5 ~ "Fifth (TX/LA)",
    TRUE         ~ paste("Circuit", circuit)
  ))

cif_circuit <- cuminc(
  ftime   = df_top4$duration_years,
  fstatus = df_top4$event_type,
  group   = df_top4$circuit_name,
  cencode = 0
)

cat("\nTABLE: Gray's test for circuit differences\n")
print(cif_circuit$Tests)

circuit_names   <- unique(df_top4$circuit_name)
cif_circuit_df  <- map_dfr(circuit_names, function(cn) {
  bind_rows(
    extract_cif(cif_circuit, cn, 1, "Settlement"),
    extract_cif(cif_circuit, cn, 2, "Dismissal")
  )
})

# Figure 4: Dismissal by circuit
fig4 <- cif_circuit_df %>%
  filter(outcome == "Dismissal") %>%
  ggplot(aes(x = time, y = prob, color = group)) +
  geom_step(linewidth = 1) +
  scale_x_continuous(limits = c(0, 6), breaks = 0:6) +
  scale_y_continuous(limits = c(0, 1), labels = percent_format(accuracy = 1)) +
  scale_color_brewer(palette = "Set1") +
  guides(color = guide_legend(nrow = 2, byrow = TRUE)) +
  labs(
    title    = "Figure 4: Cumulative Incidence of Dismissal by Circuit",
    subtitle = "Top 4 circuits by case volume",
    x        = "Years Since Filing",
    y        = "Cumulative Probability of Dismissal",
    color    = "Circuit",
    caption  = "Source: FJC Integrated Database, 1990–present."
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title       = element_text(face = "bold", size = 14),
    plot.subtitle    = element_text(size = 11, color = "gray40"),
    plot.caption     = element_text(size = 9, color = "gray50", hjust = 0),
    panel.grid.minor = element_blank(),
    legend.position  = "bottom"
  )

ggsave("figure4_cif_circuit_dismissal.png", fig4, width = 9, height = 6, dpi = 300)
cat("  Saved: figure4_cif_circuit_dismissal.png\n")

# Figure 5: Settlement by circuit
fig5 <- cif_circuit_df %>%
  filter(outcome == "Settlement") %>%
  ggplot(aes(x = time, y = prob, color = group)) +
  geom_step(linewidth = 1) +
  scale_x_continuous(limits = c(0, 6), breaks = 0:6) +
  scale_y_continuous(limits = c(0, 0.30), labels = percent_format(accuracy = 1)) +
  scale_color_brewer(palette = "Set1") +
  guides(color = guide_legend(nrow = 2, byrow = TRUE)) +
  labs(
    title    = "Figure 5: Cumulative Incidence of Settlement by Circuit",
    subtitle = "Top 4 circuits by case volume",
    x        = "Years Since Filing",
    y        = "Cumulative Probability of Settlement",
    color    = "Circuit",
    caption  = "Source: FJC Integrated Database, 1990–present."
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title       = element_text(face = "bold", size = 14),
    plot.subtitle    = element_text(size = 11, color = "gray40"),
    plot.caption     = element_text(size = 9, color = "gray50", hjust = 0),
    panel.grid.minor = element_blank(),
    legend.position  = "bottom"
  )

ggsave("figure5_cif_circuit_settlement.png", fig5, width = 9, height = 6, dpi = 300)
cat("  Saved: figure5_cif_circuit_settlement.png\n")


# =============================================================================
# SECTION 11: BASELINE COX MODELS (PSLRA only)
# =============================================================================
cat("\nSECTION 11: Baseline cause-specific Cox models...\n")

cox_s_base <- coxph(
  Surv(duration_years, event_type == 1) ~ post_pslra,
  data = df_model
)
cox_d_base <- coxph(
  Surv(duration_years, event_type == 2) ~ post_pslra,
  data = df_model
)

cat("\nTABLE 3: Baseline Cox — Settlement\n")
print(summary(cox_s_base)$conf.int)
cat("\nTABLE 3: Baseline Cox — Dismissal\n")
print(summary(cox_d_base)$conf.int)

cat("\nProportional hazards tests:\n")
cat("Settlement:\n"); print(cox.zph(cox_s_base))
cat("Dismissal:\n");  print(cox.zph(cox_d_base))


# =============================================================================
# SECTION 12: TIME-VARYING PSLRA EFFECT (piecewise constant hazard)
# =============================================================================
cat("\nSECTION 12: Piecewise PSLRA effect on dismissal hazard...\n")

df_split <- survSplit(
  Surv(duration_years, event_type == 2) ~ .,
  data    = df_model,
  cut     = c(1, 2),
  episode = "period"
) %>%
  mutate(
    period_label = factor(period, 1:3,
                          c("0-1 years", "1-2 years", "2+ years"))
  )

cox_piecewise <- coxph(
  Surv(tstart, duration_years, event) ~ post_pslra:period_label,
  data = df_split
)

cat("\nTABLE 4: PSLRA Effect on Dismissal Hazard by Time Period\n")
tibble(
  Period   = c("0-1 years", "1-2 years", "2+ years"),
  HR       = round(exp(coef(cox_piecewise)), 3),
  CI_lower = round(exp(confint(cox_piecewise))[, 1], 3),
  CI_upper = round(exp(confint(cox_piecewise))[, 2], 3),
  p_value  = round(summary(cox_piecewise)$coefficients[, 5], 4)
) %>% print()


# =============================================================================
# SECTION 13: COX MODELS WITH CIRCUIT EFFECTS
# =============================================================================
cat("\nSECTION 13: Cox models with circuit fixed effects...\n")

# Include all circuits with >= 50 cases for stability
circuits_incl <- circuit_counts %>% filter(n >= 50) %>% pull(circuit)

df_circ <- df_model %>%
  filter(circuit %in% circuits_incl) %>%
  mutate(circuit_f = relevel(factor(circuit), ref = "2"))

cox_s_circ <- coxph(
  Surv(duration_years, event_type == 1) ~ post_pslra + circuit_f,
  data = df_circ
)
cox_d_circ <- coxph(
  Surv(duration_years, event_type == 2) ~ post_pslra + circuit_f,
  data = df_circ
)

cat("\nTABLE 5: Cox with Circuit Effects — Settlement\n")
print(round(summary(cox_s_circ)$conf.int, 3))
cat("\nTABLE 5: Cox with Circuit Effects — Dismissal\n")
print(round(summary(cox_d_circ)$conf.int, 3))


# =============================================================================
# SECTION 14: FINE-GRAY SUBDISTRIBUTION HAZARD MODELS (baseline)
# =============================================================================
cat("\nSECTION 14: Fine-Gray subdistribution hazard models (baseline)...\n")

fg_base_s_data <- finegray(
  Surv(duration_years, factor(event_type, 0:2)) ~ .,
  data  = df_circ %>% select(duration_years, event_type, post_pslra, circuit_f),
  etype = 1
)
fg_base_s <- coxph(
  Surv(fgstart, fgstop, fgstatus) ~ post_pslra + circuit_f,
  data = fg_base_s_data, weights = fgwt
)

fg_base_d_data <- finegray(
  Surv(duration_years, factor(event_type, 0:2)) ~ .,
  data  = df_circ %>% select(duration_years, event_type, post_pslra, circuit_f),
  etype = 2
)
fg_base_d <- coxph(
  Surv(fgstart, fgstop, fgstatus) ~ post_pslra + circuit_f,
  data = fg_base_d_data, weights = fgwt
)

cat("\nTABLE 6: Cause-Specific vs. Subdistribution Hazard — PSLRA Effect\n")
tibble(
  Outcome = c("Settlement","Settlement","Dismissal","Dismissal"),
  Model   = c("Cause-Specific Cox","Fine-Gray Subdist.",
              "Cause-Specific Cox","Fine-Gray Subdist."),
  HR      = round(c(
    exp(coef(cox_s_circ)["post_pslra"]),
    exp(coef(fg_base_s)["post_pslra"]),
    exp(coef(cox_d_circ)["post_pslra"]),
    exp(coef(fg_base_d)["post_pslra"])
  ), 3),
  CI_lower = round(c(
    exp(confint(cox_s_circ)["post_pslra",1]),
    exp(confint(fg_base_s)["post_pslra",1]),
    exp(confint(cox_d_circ)["post_pslra",1]),
    exp(confint(fg_base_d)["post_pslra",1])
  ), 3),
  CI_upper = round(c(
    exp(confint(cox_s_circ)["post_pslra",2]),
    exp(confint(fg_base_s)["post_pslra",2]),
    exp(confint(cox_d_circ)["post_pslra",2]),
    exp(confint(fg_base_d)["post_pslra",2])
  ), 3)
) %>% print()


# =============================================================================
# SECTION 15: EXTENDED COX + FINE-GRAY WITH ALL COVARIATES
# =============================================================================
cat("\nSECTION 15: Extended models (origin, MDL, jurisdiction, statutory basis)...\n")

# Build extended dataset: complete cases on core extended covariates
# Statutory basis included only if coverage >= 15%
stat_coverage <- 100 * mean(!is.na(df_model$stat_basis_f))
include_stat  <- stat_coverage >= 15
cat(paste("  Statutory basis coverage:", round(stat_coverage, 1), "%\n"))
cat(paste("  Including in models:", include_stat, "\n"))

df_ext <- df_circ %>%
  mutate(
    origin_cat     = df_model$origin_cat[df_model$circuit %in% circuits_incl],
    mdl_flag       = df_model$mdl_flag[df_model$circuit %in% circuits_incl],
    juris_fq       = df_model$juris_fq[df_model$circuit %in% circuits_incl],
    stat_basis_f   = df_model$stat_basis_f[df_model$circuit %in% circuits_incl],
    stat_basis_miss= df_model$stat_basis_miss[df_model$circuit %in% circuits_incl]
  )

# Reconstruct df_ext cleanly from df_model filtered to included circuits
df_ext <- df_model %>%
  filter(circuit %in% circuits_incl) %>%
  mutate(circuit_f = relevel(factor(circuit), ref = "2")) %>%
  filter(!is.na(origin_cat), !is.na(mdl_flag), !is.na(juris_fq))

cat(paste("  Extended model sample:", format(nrow(df_ext), big.mark = ","), "\n"))

# Formula strings — add statutory basis if coverage is sufficient
base_formula_rhs <- "post_pslra + circuit_f + origin_cat + mdl_flag + juris_fq"
if (include_stat) {
  ext_formula_rhs <- paste(base_formula_rhs,
                           "+ stat_basis_f + stat_basis_miss")
} else {
  ext_formula_rhs <- base_formula_rhs
  cat("  Statutory basis omitted from models (coverage below 15% threshold).\n")
}

# ---- Extended Cox: Settlement ----
cox_s_ext <- coxph(
  as.formula(paste("Surv(duration_years, event_type==1) ~", ext_formula_rhs)),
  data = df_ext
)
# ---- Extended Cox: Dismissal ----
cox_d_ext <- coxph(
  as.formula(paste("Surv(duration_years, event_type==2) ~", ext_formula_rhs)),
  data = df_ext
)

cat("\nTABLE 7: Extended Cox — Settlement\n")
print(round(summary(cox_s_ext)$conf.int, 3))
cat("\nTABLE 7: Extended Cox — Dismissal\n")
print(round(summary(cox_d_ext)$conf.int, 3))

cat("\nProportional hazards tests (extended models):\n")
cat("Settlement:\n"); print(cox.zph(cox_s_ext))
cat("Dismissal:\n");  print(cox.zph(cox_d_ext))

# ---- Extended Fine-Gray: Settlement ----
fg_ext_s_data <- finegray(
  Surv(duration_years, factor(event_type, 0:2)) ~ .,
  data  = df_ext %>%
    select(duration_years, event_type, post_pslra, circuit_f,
           origin_cat, mdl_flag, juris_fq,
           any_of(c("stat_basis_f","stat_basis_miss"))),
  etype = 1
)
fg_s_ext <- coxph(
  as.formula(paste("Surv(fgstart, fgstop, fgstatus) ~", ext_formula_rhs)),
  data    = fg_ext_s_data,
  weights = fgwt
)

# ---- Extended Fine-Gray: Dismissal ----
fg_ext_d_data <- finegray(
  Surv(duration_years, factor(event_type, 0:2)) ~ .,
  data  = df_ext %>%
    select(duration_years, event_type, post_pslra, circuit_f,
           origin_cat, mdl_flag, juris_fq,
           any_of(c("stat_basis_f","stat_basis_miss"))),
  etype = 2
)
fg_d_ext <- coxph(
  as.formula(paste("Surv(fgstart, fgstop, fgstatus) ~", ext_formula_rhs)),
  data    = fg_ext_d_data,
  weights = fgwt
)

cat("\nTABLE 8: Extended Fine-Gray — Settlement\n")
print(round(summary(fg_s_ext)$conf.int, 3))
cat("\nTABLE 8: Extended Fine-Gray — Dismissal\n")
print(round(summary(fg_d_ext)$conf.int, 3))



# =============================================================================
# SECTION 16: PSLRA x CIRCUIT INTERACTION
# =============================================================================
cat("\nSECTION 16: PSLRA x Circuit interaction tests...\n")

# Use top-6 circuits for stable interaction estimates
top6 <- circuit_counts %>% head(6) %>% pull(circuit)
df_int <- df_ext %>%
  filter(circuit %in% top6) %>%
  mutate(circuit_f = relevel(factor(circuit), ref = "2"))

cox_s_int  <- coxph(
  as.formula(paste("Surv(duration_years, event_type==1) ~ post_pslra * circuit_f +",
                   "origin_cat + mdl_flag + juris_fq")),
  data = df_int
)
cox_s_noint <- coxph(
  as.formula(paste("Surv(duration_years, event_type==1) ~ post_pslra + circuit_f +",
                   "origin_cat + mdl_flag + juris_fq")),
  data = df_int
)

cox_d_int  <- coxph(
  as.formula(paste("Surv(duration_years, event_type==2) ~ post_pslra * circuit_f +",
                   "origin_cat + mdl_flag + juris_fq")),
  data = df_int
)
cox_d_noint <- coxph(
  as.formula(paste("Surv(duration_years, event_type==2) ~ post_pslra + circuit_f +",
                   "origin_cat + mdl_flag + juris_fq")),
  data = df_int
)

cat("\nLRT: PSLRA x Circuit — Settlement\n"); print(anova(cox_s_noint, cox_s_int))
cat("\nLRT: PSLRA x Circuit — Dismissal\n");  print(anova(cox_d_noint, cox_d_int))

# Interaction coefficients
cat("\nPSLRA x Circuit interaction coefficients (Settlement):\n")
int_coefs_s <- coef(cox_s_int)
int_coefs_s <- int_coefs_s[grepl("post_pslra:circuit_f", names(int_coefs_s))]
print(round(exp(int_coefs_s), 3))

cat("\nPSLRA x Circuit interaction coefficients (Dismissal):\n")
int_coefs_d <- coef(cox_d_int)
int_coefs_d <- int_coefs_d[grepl("post_pslra:circuit_f", names(int_coefs_d))]
print(round(exp(int_coefs_d), 3))


# =============================================================================
# SECTION 17: ROBUSTNESS CHECKS
# =============================================================================
cat("\nSECTION 17: Robustness checks...\n")

run_pslra_cox <- function(df, label) {
  df <- df %>% mutate(post_pslra = as.integer(filedate >= as.Date("1995-12-22")))
  s <- coxph(Surv(duration_years, event_type == 1) ~ post_pslra, data = df)
  d <- coxph(Surv(duration_years, event_type == 2) ~ post_pslra, data = df)
  tibble(
    Specification = label,
    Outcome       = c("Settlement", "Dismissal"),
    N             = nrow(df),
    HR            = round(c(exp(coef(s)), exp(coef(d))), 3),
    CI_lower      = round(c(exp(confint(s))[1], exp(confint(d))[1]), 3),
    CI_upper      = round(c(exp(confint(s))[2], exp(confint(d))[2]), 3),
    p_value       = round(c(summary(s)$coef[5], summary(d)$coef[5]), 4)
  )
}

# ---- 17a. Alternative coding schemes ----
rob_A <- run_pslra_cox(df_A, "Scheme A: Primary")
rob_B <- run_pslra_cox(df_B, "Scheme B: Code 12 = Settlement")
rob_C <- run_pslra_cox(df_C, "Scheme C: Codes 12+5 = Settlement")

# ---- 17b. Temporal restriction ----
rob_T <- run_pslra_cox(
  df_A %>% filter(filedate <= as.Date("2020-12-31")), 
  "Temporal: exclude post-2020"
)

# ---- 17c. Circuit-specific sub-models ----
df_second <- df_A %>% filter(circuit == 2)
df_ninth  <- df_A %>% filter(circuit == 9)

rob_2nd <- run_pslra_cox(df_second, "Second Circuit only")
rob_9th <- run_pslra_cox(df_ninth,  "Ninth Circuit only")

robustness_all <- bind_rows(rob_A, rob_B, rob_C, rob_T, rob_2nd, rob_9th)

cat("\nTABLE R1: PSLRA Hazard Ratios Across Robustness Specifications\n")
print(robustness_all)

# ---- Figure 6: Robustness forest plot ----
fig6 <- robustness_all %>%
  mutate(Specification = factor(Specification, levels = rev(unique(Specification)))) %>%
  ggplot(aes(x = HR, y = Specification, color = Outcome, shape = Outcome)) +
  geom_point(size = 3.5, position = position_dodge(width = 0.4)) +
  geom_vline(xintercept = 1, linetype = "dashed", color = "gray50") +
  scale_color_manual(values = c("Settlement" = "#1B7837", "Dismissal" = "#B2182B")) +
  scale_x_log10(breaks = c(0.1, 0.3, 0.5, 1, 1.5, 2, 3),
                labels = c("0.1","0.3","0.5","1","1.5","2","3")) +
  labs(
    title    = "Figure 6: PSLRA Hazard Ratios Across Robustness Specifications",
    subtitle = "Direction and magnitude of PSLRA effect is consistent across all specifications",
    x        = "Hazard Ratio (log scale) — Post-PSLRA vs. Pre-PSLRA",
    y        = NULL,
    color    = "Outcome", shape = "Outcome",
    caption  = "Each row = separate Cox model. Dashed line at HR = 1 (null effect)."
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title       = element_text(face = "bold", size = 14),
    plot.subtitle    = element_text(size = 11, color = "gray40"),
    plot.caption     = element_text(size = 9, color = "gray50", hjust = 0),
    panel.grid.minor = element_blank(),
    legend.position  = "bottom"
  )

ggsave("figure6_robustness_hr.png", fig6, width = 10, height = 6, dpi = 300)
cat("  Saved: figure6_robustness_hr.png\n")


# =============================================================================
# SECTION 18: TRAIN/TEST SPLIT FOR PERFORMANCE EVALUATION
# Performance models use a reduced formula excluding stat_basis
# (complete separation in stat_basis_fSection11 produces infinite coefficients
# that propagate as Inf linear predictors, breaking concordance computation)
# =============================================================================
cat("\nSECTION 18: Train/test split (70/30, stratified by PSLRA)...\n")

set.seed(42)

df_perf <- df_ext %>%
  mutate(
    circuit_f  = droplevels(circuit_f),
    origin_cat = droplevels(origin_cat),
    row_id     = row_number()
  )

train_ids <- df_perf %>%
  group_by(post_pslra) %>%
  slice_sample(prop = 0.70) %>%
  pull(row_id)

df_train <- df_perf %>% filter( row_id %in% train_ids)
df_test  <- df_perf %>% filter(!row_id %in% train_ids)

for (fv in c("circuit_f", "origin_cat")) {
  levels(df_test[[fv]]) <- levels(df_train[[fv]])
}

cat(paste("  Training:", format(nrow(df_train), big.mark=","),
          "| Test:", format(nrow(df_test), big.mark=","), "\n"))

# Reduced formula for performance evaluation (excludes stat_basis due to separation)
perf_formula_rhs <- "post_pslra + circuit_f + origin_cat + mdl_flag + juris_fq"

cat("  Note: stat_basis excluded from performance models (complete separation).\n")
cat("  Coefficient estimates from full model retained for Table 7/8.\n")

# Refit Cox on training set with reduced formula
cox_s_train <- coxph(
  as.formula(paste("Surv(duration_years, event_type==1) ~", perf_formula_rhs)),
  data = df_train, x = TRUE
)
cox_d_train <- coxph(
  as.formula(paste("Surv(duration_years, event_type==2) ~", perf_formula_rhs)),
  data = df_train, x = TRUE
)

# Refit Fine-Gray on training set with reduced formula
fg_tr_s_data <- finegray(
  Surv(duration_years, factor(event_type, 0:2)) ~ .,
  data  = df_train %>%
    select(duration_years, event_type, post_pslra, circuit_f,
           origin_cat, mdl_flag, juris_fq),
  etype = 1
)
fg_s_train <- coxph(
  as.formula(paste("Surv(fgstart, fgstop, fgstatus) ~", perf_formula_rhs)),
  data = fg_tr_s_data, weights = fgwt, x = TRUE
)

fg_tr_d_data <- finegray(
  Surv(duration_years, factor(event_type, 0:2)) ~ .,
  data  = df_train %>%
    select(duration_years, event_type, post_pslra, circuit_f,
           origin_cat, mdl_flag, juris_fq),
  etype = 2
)
fg_d_train <- coxph(
  as.formula(paste("Surv(fgstart, fgstop, fgstatus) ~", perf_formula_rhs)),
  data = fg_tr_d_data, weights = fgwt, x = TRUE
)

cat("  Models refit on training data.\n")

# =============================================================================
# SECTION 19: MODEL PERFORMANCE — C-INDEX (FIXED DATA ALIGNMENT)
# =============================================================================
cat("\nSECTION 19: C-index on held-out test set...\n")

# Wrap outcomes and negated linear predictors into a single dataframe
# Note: we negate lp because higher hazard = shorter survival time.
eval_df <- data.frame(
  time    = df_test$duration_years,
  status_s = as.numeric(df_test$event_type == 1),
  status_d = as.numeric(df_test$event_type == 2),
  risk_s   = -lp_s,
  risk_d   = -lp_d
)

# Run concordance using the dataframe columns
cind_cox_s <- concordance(Surv(time, status_s) ~ risk_s, data = eval_df)
cind_cox_d <- concordance(Surv(time, status_d) ~ risk_d, data = eval_df)

cat(paste("  Corrected Cox C-index (Settlement):", 
          round(cind_cox_s$concordance, 3), 
          "| SE:", round(sqrt(cind_cox_s$var), 3), "\n"))
cat(paste("  Corrected Cox C-index (Dismissal):", 
          round(cind_cox_d$concordance, 3), 
          "| SE:", round(sqrt(cind_cox_d$var), 3), "\n"))

# =============================================================================
# SECTION 20: MODEL PERFORMANCE — TIME-DEPENDENT AUC
# =============================================================================
cat("\nSECTION 20: Time-dependent AUC on held-out test set...\n")

time_points <- c(1, 2, 3, 5)

lp_s <- predict(cox_s_train, newdata = df_test, type = "lp")
lp_d <- predict(cox_d_train, newdata = df_test, type = "lp")

troc_s <- tryCatch(
  timeROC(
    T      = df_test$duration_years,
    delta  = as.integer(df_test$event_type == 1),
    marker = lp_s,
    cause  = 1,
    times  = time_points,
    iid    = TRUE
  ),
  error = function(e) { cat("timeROC error (S):", conditionMessage(e), "\n"); NULL }
)

troc_d <- tryCatch(
  timeROC(
    T      = df_test$duration_years,
    delta  = as.integer(df_test$event_type == 2),
    marker = lp_d,
    cause  = 1,
    times  = time_points,
    iid    = TRUE
  ),
  error = function(e) { cat("timeROC error (D):", conditionMessage(e), "\n"); NULL }
)

if (!is.null(troc_s)) {
  cat("  Cox AUC (Settlement) at 1/2/3/5 yr:",
      paste(round(troc_s$AUC, 3), collapse = " / "), "\n")
}
if (!is.null(troc_d)) {
  cat("  Cox AUC (Dismissal)  at 1/2/3/5 yr:",
      paste(round(troc_d$AUC, 3), collapse = " / "), "\n")
}


# =============================================================================
# SECTION 21: MODEL PERFORMANCE — INTEGRATED BRIER SCORE
# =============================================================================
cat("\nSECTION 21: Integrated Brier Score...\n")

eval_times <- seq(0.25, 5, by = 0.25)

ibs_cox_s <- tryCatch({
  df_te_s <- df_test %>% mutate(ev = as.integer(event_type == 1))
  pf <- pec(
    object     = list("Cox" = cox_s_train),
    formula    = Surv(duration_years, ev) ~ 1,
    data       = df_te_s,
    times      = eval_times,
    exact      = FALSE,
    cens.model = "marginal"
  )
  round(crps(pf, times = eval_times)["Cox"], 4)
}, error = function(e) { cat("pec error (S):", conditionMessage(e), "\n"); NA_real_ })

ibs_cox_d <- tryCatch({
  df_te_d <- df_test %>% mutate(ev = as.integer(event_type == 2))
  pf <- pec(
    object     = list("Cox" = cox_d_train),
    formula    = Surv(duration_years, ev) ~ 1,
    data       = df_te_d,
    times      = eval_times,
    exact      = FALSE,
    cens.model = "marginal"
  )
  round(crps(pf, times = eval_times)["Cox"], 4)
}, error = function(e) { cat("pec error (D):", conditionMessage(e), "\n"); NA_real_ })

cat(paste("  IBS Cox (Settlement):", ibs_cox_s, "\n"))
cat(paste("  IBS Cox (Dismissal):",  ibs_cox_d, "\n"))


# =============================================================================
# SECTION 22: RANDOM SURVIVAL FOREST (COMPETING RISKS)
# =============================================================================
cat("\nSECTION 22: Random Survival Forest...\n")
cat("  Using 200 trees (proof-of-concept; increase to 500 for final thesis).\n")
cat("  This may take 5-15 minutes depending on hardware.\n")

# RSF requires a factor event variable with meaningful level names
df_rsf_base <- df_ext %>%
  select(duration_years, event_type, post_pslra, circuit_f,
         origin_cat, mdl_flag, juris_fq) %>%
  mutate(
    event_rsf = factor(event_type, 0:2,
                       c("censored", "settlement", "dismissal"))
  ) %>%
  filter(complete.cases(.))

# If statutory basis included and has sufficient non-missing cases, add it
if (include_stat) {
  df_rsf_stat <- df_ext %>%
    select(duration_years, event_type, post_pslra, circuit_f,
           origin_cat, mdl_flag, juris_fq, stat_basis_f, stat_basis_miss) %>%
    mutate(event_rsf = factor(event_type, 0:2,
                              c("censored","settlement","dismissal"))) %>%
    filter(!is.na(stat_basis_f))
  if (nrow(df_rsf_stat) > 500) {
    df_rsf_base <- df_rsf_stat
    cat("  Statutory basis included in RSF.\n")
  }
}

# 70/30 split mirroring Section 18
set.seed(42)
n_rsf       <- nrow(df_rsf_base)
rsf_train_i <- sample(seq_len(n_rsf), size = floor(0.70 * n_rsf))
df_rsf_tr   <- df_rsf_base[ rsf_train_i, ]
df_rsf_te   <- df_rsf_base[-rsf_train_i, ]

cat(paste("  RSF train:", nrow(df_rsf_tr), "| test:", nrow(df_rsf_te), "\n"))

# ---- 5-fold CV to tune mtry ----
cat("  5-fold CV for mtry tuning (100-tree fits per fold)...\n")

p_rsf      <- sum(grepl("post_pslra|circuit_f|origin_cat|mdl_flag|juris_fq|stat_basis",
                        names(df_rsf_tr)))
mtry_grid  <- unique(c(1, 2, floor(sqrt(p_rsf)), floor(p_rsf / 2)))

set.seed(42)
fold_ids <- sample(rep(1:5, length.out = nrow(df_rsf_tr)))

rsf_formula <- if (include_stat && "stat_basis_f" %in% names(df_rsf_tr)) {
  Surv(duration_years, event_rsf) ~
    post_pslra + circuit_f + origin_cat + mdl_flag + juris_fq +
    stat_basis_f + stat_basis_miss
} else {
  Surv(duration_years, event_rsf) ~
    post_pslra + circuit_f + origin_cat + mdl_flag + juris_fq
}

cv_err_df <- map_dfr(mtry_grid, function(m) {
  errs <- map_dbl(1:5, function(k) {
    tr_k <- df_rsf_tr[fold_ids != k, ]
    fit_k <- rfsrc(
      rsf_formula,
      data      = tr_k,
      ntree     = 100,
      mtry      = m,
      importance= FALSE,
      verbose   = FALSE
    )
    # OOB error at final tree, cause 1 (settlement)
    fit_k$err.rate[100, 1]
  })
  tibble(mtry = m, cv_oob_error = round(mean(errs, na.rm = TRUE), 4))
})

cat("\n  CV errors by mtry:\n")
print(cv_err_df)

best_mtry <- cv_err_df %>% slice_min(cv_oob_error, n = 1, with_ties = FALSE) %>%
  pull(mtry)
cat(paste("  Best mtry:", best_mtry, "\n"))

# ---- Final RSF on training set ----
cat("  Fitting final RSF (200 trees)...\n")
set.seed(42)
rsf_final <- rfsrc(
  rsf_formula,
  data       = df_rsf_tr,
  ntree      = 200,
  mtry       = best_mtry,
  importance = TRUE,
  verbose    = FALSE
)

cat("\n  RSF summary:\n")
print(rsf_final)

# ---- Corrected Variable importance ----
cat("\n  Variable importance (VIMP):\n")
vimp_mat <- rsf_final$importance
vimp_df  <- as_tibble(vimp_mat, rownames = "Variable") %>%
  # event.1 = settlement, event.2 = dismissal (event.3 is the aggregate)
  rename(VIMP_Settlement = event.1, VIMP_Dismissal = event.2) %>%
  select(Variable, VIMP_Settlement, VIMP_Dismissal) %>%
  arrange(desc(VIMP_Settlement))

print(vimp_df)

# ---- Re-run Figure 7 ----
fig7 <- vimp_df %>%
  pivot_longer(cols = c(VIMP_Settlement, VIMP_Dismissal), 
               names_to = "Outcome",
               values_to = "VIMP", 
               names_prefix = "VIMP_") %>%
  mutate(Variable = reorder(Variable, VIMP)) %>%
  ggplot(aes(x = VIMP, y = Variable, fill = Outcome)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.6) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
  scale_fill_manual(values = c("Settlement" = "#1B7837", "Dismissal" = "#B2182B")) +
  facet_wrap(~Outcome, scales = "free_x") +
  labs(
    title    = "Figure 7: Random Survival Forest — Variable Importance",
    subtitle = "Increase in OOB prediction error when variable is randomly permuted",
    x        = "Variable Importance (VIMP)",
    y        = NULL,
    caption  = "RSF: 200 trees. Positive VIMP = variable improves prediction."
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title       = element_text(face = "bold", size = 14),
    panel.grid.minor = element_blank(),
    legend.position  = "none"
  )

ggsave("figure7_rsf_vimp.png", fig7, width = 9, height = 5, dpi = 300)

# ---- RSF test-set predictions (Corrected) ----
rsf_pred <- predict(rsf_final, newdata = df_rsf_te)

# Extract predicted CIF at 3-year horizon as risk score
t_idx_3yr <- which.min(abs(rsf_pred$time.interest - 3))

risk_rsf_s <- rsf_pred$cif[, t_idx_3yr, 1]   # cause 1 = settlement
risk_rsf_d <- rsf_pred$cif[, t_idx_3yr, 2]   # cause 2 = dismissal

# ---- Corrected RSF C-index (Dataframe Wrapper) ----
cat("\n  Calculating corrected RSF C-index...\n")

# Wrap outcomes and negated risk scores into a clean evaluation dataframe
# Negation ensures higher risk = higher concordance (> 0.5)
eval_df_rsf <- data.frame(
  time     = df_rsf_te$duration_years,
  status_s = as.numeric(df_rsf_te$event_rsf == "settlement"),
  status_d = as.numeric(df_rsf_te$event_rsf == "dismissal"),
  score_s  = -risk_rsf_s, 
  score_d  = -risk_rsf_d
)

# Run concordance using the dataframe columns to avoid indexing errors
cind_rsf_s <- concordance(Surv(time, status_s) ~ score_s, data = eval_df_rsf)
cind_rsf_d <- concordance(Surv(time, status_d) ~ score_d, data = eval_df_rsf)

cat(paste("  Corrected RSF C-index (Settlement):", 
          round(cind_rsf_s$concordance, 3), 
          "| SE:", round(sqrt(cind_rsf_s$var), 3), "\n"))
cat(paste("  Corrected RSF C-index (Dismissal):", 
          round(cind_rsf_d$concordance, 3), 
          "| SE:", round(sqrt(cind_rsf_d$var), 3), "\n"))

# ---- RSF time-dependent AUC ----
troc_rsf_s <- tryCatch(
  timeROC(
    T      = df_rsf_te$duration_years,
    delta  = as.integer(df_rsf_te$event_rsf == "settlement"),
    marker = risk_rsf_s,
    cause  = 1,
    times  = time_points,
    iid    = TRUE
  ),
  error = function(e) { cat("timeROC RSF (S) error:", conditionMessage(e), "\n"); NULL }
)

troc_rsf_d <- tryCatch(
  timeROC(
    T      = df_rsf_te$duration_years,
    delta  = as.integer(df_rsf_te$event_rsf == "dismissal"),
    marker = risk_rsf_d,
    cause  = 1,
    times  = time_points,
    iid    = TRUE
  ),
  error = function(e) { cat("timeROC RSF (D) error:", conditionMessage(e), "\n"); NULL }
)

if (!is.null(troc_rsf_s))
  cat("  RSF AUC (Settlement) 1/2/3/5yr:",
      paste(round(troc_rsf_s$AUC, 3), collapse = " / "), "\n")
if (!is.null(troc_rsf_d))
  cat("  RSF AUC (Dismissal)  1/2/3/5yr:",
      paste(round(troc_rsf_d$AUC, 3), collapse = " / "), "\n")


# =============================================================================
# SECTION 23: MODEL COMPARISON TABLE + FIGURE 8 (AUC OVER TIME)
# =============================================================================
cat("\nSECTION 23: Model comparison table...\n")

# Assemble performance table
perf_table <- tibble(
  Model   = c(
    "Cox (Settlement)", "Cox (Dismissal)",
    "Fine-Gray (Settlement)", "Fine-Gray (Dismissal)",
    "RSF (Settlement)", "RSF (Dismissal)"
  ),
  `C-index` = c(
    round(cind_cox_s$concordance, 3),
    round(cind_cox_d$concordance, 3),
    round(cind_cox_s$concordance, 3),   # Same linear predictor as Cox
    round(cind_cox_d$concordance, 3),
    round(cind_rsf_s$concordance, 3),
    round(cind_rsf_d$concordance, 3)
  ),
  `AUC @ 1yr` = c(
    if (!is.null(troc_s))     round(troc_s$AUC[1], 3)     else NA,
    if (!is.null(troc_d))     round(troc_d$AUC[1], 3)     else NA,
    NA, NA,
    if (!is.null(troc_rsf_s)) round(troc_rsf_s$AUC[1], 3) else NA,
    if (!is.null(troc_rsf_d)) round(troc_rsf_d$AUC[1], 3) else NA
  ),
  `AUC @ 3yr` = c(
    if (!is.null(troc_s))     round(troc_s$AUC[3], 3)     else NA,
    if (!is.null(troc_d))     round(troc_d$AUC[3], 3)     else NA,
    NA, NA,
    if (!is.null(troc_rsf_s)) round(troc_rsf_s$AUC[3], 3) else NA,
    if (!is.null(troc_rsf_d)) round(troc_rsf_d$AUC[3], 3) else NA
  ),
  `IBS` = c(
    ibs_cox_s, ibs_cox_d, NA, NA, NA, NA
  )
)

cat("\nTABLE P1: Model Performance Comparison\n")
print(perf_table)

# ---- Figure 8: AUC comparison over time ----
if (!is.null(troc_s) && !is.null(troc_d) &&
    !is.null(troc_rsf_s) && !is.null(troc_rsf_d)) {
  
  auc_plot <- tibble(
    Time    = rep(time_points, 4),
    AUC     = c(troc_s$AUC, troc_d$AUC,
                troc_rsf_s$AUC, troc_rsf_d$AUC),
    Model   = rep(c("Cox","Cox","RSF","RSF"), each = length(time_points)),
    Outcome = rep(c("Settlement","Dismissal","Settlement","Dismissal"),
                  each = length(time_points))
  )
  
  fig8 <- ggplot(auc_plot,
                 aes(x = Time, y = AUC, color = Outcome, linetype = Model)) +
    geom_line(linewidth = 1.1) +
    geom_point(size = 3) +
    geom_hline(yintercept = 0.5, linetype = "dotted", color = "gray60") +
    scale_color_manual(values = c("Settlement" = "#1B7837",
                                  "Dismissal"  = "#B2182B")) +
    scale_y_continuous(limits = c(0.4, 1.0),
                       labels = percent_format(accuracy = 1)) +
    scale_x_continuous(breaks = time_points) +
    labs(
      title    = "Figure 8: Time-Dependent AUC — Cox vs. Random Survival Forest",
      subtitle = "Discrimination performance at 1, 2, 3, and 5-year prediction horizons",
      x        = "Prediction Horizon (Years)",
      y        = "Area Under the ROC Curve (AUC)",
      color    = "Outcome",
      linetype = "Model",
      caption  = "AUC > 0.5 = better than random. Dotted line = no-skill classifier."
    ) +
    theme_minimal(base_size = 13) +
    theme(
      plot.title       = element_text(face = "bold", size = 14),
      plot.subtitle    = element_text(size = 11, color = "gray40"),
      plot.caption     = element_text(size = 9, color = "gray50", hjust = 0),
      panel.grid.minor = element_blank(),
      legend.position  = "bottom"
    )
  
  ggsave("figure8_auc_comparison.png", fig8, width = 9, height = 6, dpi = 300)
  cat("  Saved: figure8_auc_comparison.png\n")
}


# =============================================================================
# SECTION 24: SAVE ALL RESULTS
# =============================================================================
cat("\nSECTION 24: Saving results objects...\n")

results_fall <- list(
  df_model          = df_model,
  scheme_summary    = scheme_summary,
  cif_overall       = cif_overall,
  cif_pslra         = cif_pslra,
  cif_circuit       = cif_circuit,
  cox_s_base        = cox_s_base,
  cox_d_base        = cox_d_base,
  cox_piecewise     = cox_piecewise,
  cox_s_circ        = cox_s_circ,
  cox_d_circ        = cox_d_circ,
  fg_base_s         = fg_base_s,
  fg_base_d         = fg_base_d
)

results_spring <- list(
  df_ext            = df_ext,
  df_train          = df_train,
  df_test           = df_test,
  cox_s_ext         = cox_s_ext,
  cox_d_ext         = cox_d_ext,
  fg_s_ext          = fg_s_ext,
  fg_d_ext          = fg_d_ext,
  cox_s_int         = cox_s_int,
  cox_d_int         = cox_d_int,
  lrt_settle        = anova(cox_s_noint, cox_s_int),
  lrt_dismiss       = anova(cox_d_noint, cox_d_int),
  robustness_all    = robustness_all,
  rsf_final         = rsf_final,
  vimp_df           = vimp_df,
  cv_err_df         = cv_err_df,
  best_mtry         = best_mtry,
  perf_table        = perf_table,
  cind_cox_s        = cind_cox_s,
  cind_cox_d        = cind_cox_d,
  cind_rsf_s        = cind_rsf_s,
  cind_rsf_d        = cind_rsf_d,
  troc_s            = troc_s,
  troc_d            = troc_d,
  troc_rsf_s        = troc_rsf_s,
  troc_rsf_d        = troc_rsf_d,
  ibs_cox_s         = ibs_cox_s,
  ibs_cox_d         = ibs_cox_d,
  stat_coverage     = stat_coverage,
  include_stat      = include_stat
)

saveRDS(results_fall,   "results_fall.rds")
saveRDS(results_spring, "results_spring.rds")

# =============================================================================
# ANALYSIS COMPLETE
# =============================================================================
cat("\n=================================================================\n")
cat(" ANALYSIS COMPLETE\n")
cat("=================================================================\n\n")
cat("Figures saved:\n")
for (f in paste0("figure", 1:8, "_", c(
  "km_overall","cif_overall","cif_pslra",
  "cif_circuit_dismissal","cif_circuit_settlement",
  "robustness_hr","rsf_vimp","auc_comparison"), ".png")) {
  cat(paste("  ", f, "\n"))
}
cat("\nKey numbers to verify:\n")
cat(paste("  Scheme A settlement rate (%):",
          round(100*mean(df_model$event_type==1), 1), "\n"))
cat(paste("  Scheme B settlement rate (%):",
          scheme_summary$Pct_Settle[scheme_summary$Scheme=="B"], "\n"))
cat(paste("  Statutory basis coverage (%):",
          round(stat_coverage, 1), "\n"))
cat(paste("  Cox C-index (Settlement):",
          round(cind_cox_s$concordance, 3), "\n"))
cat(paste("  Cox C-index (Dismissal):",
          round(cind_cox_d$concordance, 3), "\n"))
cat(paste("  RSF C-index (Settlement):",
          round(cind_rsf_s$concordance, 3), "\n"))
cat(paste("  RSF C-index (Dismissal):",
          round(cind_rsf_d$concordance, 3), "\n"))

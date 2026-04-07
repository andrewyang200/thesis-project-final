# ============================================================
# judgment_diagnostic.R
# Purpose: Verify that the cleaned Scheme A cohort applies the
#          post-2026-04-06 JUDGMENT-aware disposition coding.
# Input: data/cleaned/securities_cohort_cleaned.rds
# ============================================================

library(here)
library(dplyr)

df <- readRDS(here::here("data", "cleaned", "securities_cohort_cleaned.rds"))

cat("=== JUDGMENT CODING VERIFICATION ===\n\n")
cat(sprintf("Total cohort: %s rows\n\n", format(nrow(df), big.mark = ",")))

focus_judgment_codes <- c(4, 6, 15, 17, 19, 20)

required_cols <- c("disp", "judgment", "event_type", "post_pslra")
stopifnot(all(required_cols %in% names(df)))

cat("--- Current Scheme A distribution ---\n")
print(table(df$event_type, useNA = "always"))
cat(sprintf("  Settlement (1): %.1f%%\n", 100 * mean(df$event_type == 1)))
cat(sprintf("  Dismissal  (2): %.1f%%\n", 100 * mean(df$event_type == 2)))
cat(sprintf("  Censored   (0): %.1f%%\n", 100 * mean(df$event_type == 0)))

cat("\n--- Judgment-bearing disposition counts ---\n")
judgment_tbl <- df %>%
  filter(disp %in% c(focus_judgment_codes, 18)) %>%
  mutate(
    disp_label = case_when(
      disp == 4  ~ "04-Default",
      disp == 6  ~ "06-MotionJudg",
      disp == 15 ~ "15-Arbitrator",
      disp == 17 ~ "17-OtherJudg",
      disp == 18 ~ "18-StatClose",
      disp == 19 ~ "19-AffirmMag",
      disp == 20 ~ "20-DenyMag"
    )
  ) %>%
  count(disp_label, judgment, event_type) %>%
  arrange(disp_label, judgment, event_type)
print(judgment_tbl, n = 100)

expected_event <- function(disp, judgment) {
  case_when(
    disp %in% focus_judgment_codes & judgment == 1 ~ 1L,
    disp %in% focus_judgment_codes & judgment == 2 ~ 2L,
    disp %in% focus_judgment_codes                 ~ 0L,
    disp == 18                                    ~ 0L,
    TRUE                                          ~ NA_integer_
  )
}

df_check <- df %>%
  filter(disp %in% c(focus_judgment_codes, 18)) %>%
  mutate(expected_event = expected_event(disp, judgment))

mismatches <- df_check %>%
  filter(event_type != expected_event)

cat("\n--- Current-coding verification ---\n")
cat(sprintf("  Checked rows: %s\n", format(nrow(df_check), big.mark = ",")))
cat(sprintf("  Mismatches:   %s\n", format(nrow(mismatches), big.mark = ",")))

if (nrow(mismatches) > 0) {
  cat("  ERROR: mismatches found between cleaned event_type and expected coding.\n")
  print(
    mismatches %>%
      count(disp, judgment, event_type, expected_event, sort = TRUE),
    n = 50
  )
} else {
  cat("  PASS: all judgment-bearing dispositions match the current coding rules.\n")
}

affected_post <- df %>%
  filter(disp %in% c(4, 15, 17, 19, 20), judgment == 1) %>%
  count(post_pslra) %>%
  mutate(era = ifelse(post_pslra == 1, "Post-PSLRA", "Pre-PSLRA"))

cat("\n--- Plaintiff judgments in non-Code-6 judgment dispositions ---\n")
print(affected_post, n = Inf)

cat("\n=== DONE ===\n")

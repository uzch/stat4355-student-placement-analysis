library(tidyverse)
library(broom)

df <- read_csv("data/placed_salary_data.csv", show_col_types = FALSE) %>%
  mutate(
    college_tier            = factor(college_tier),
    country                 = factor(country),
    university_ranking_band = factor(university_ranking_band),
    specialization          = factor(specialization),
    industry                = factor(industry)
  )

dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)

# ── Full model: all predictors ────────────────────────────────────────────────
full_model <- lm(
  salary ~ cgpa + backlogs + internship_count +
    aptitude_score + communication_score + internship_quality_score +
    college_tier + country + university_ranking_band +
    specialization + industry,
  data = df
)

# ── Model-level summary ───────────────────────────────────────────────────────
model_summary <- glance(full_model) %>%
  select(r_squared = r.squared,
         adj_r_sq  = adj.r.squared,
         f_statistic = statistic,
         f_p_value   = p.value,
         df_model    = df,
         nobs) %>%
  mutate(across(where(is.numeric), ~ round(., 4)))

# ── Coefficient-level summary ─────────────────────────────────────────────────
coef_summary <- tidy(full_model) %>%
  select(term,
         coefficient = estimate,
         std_error   = std.error,
         t_statistic = statistic,
         p_value     = p.value) %>%
  mutate(
    significant = case_when(
      p_value < 0.001 ~ "***",
      p_value < 0.01  ~ "**",
      p_value < 0.05  ~ "*",
      p_value < 0.1   ~ ".",
      TRUE            ~ ""
    ),
    across(where(is.numeric), ~ round(., 4))
  )

# ── Print to console ──────────────────────────────────────────────────────────
cat("\n===== MULTIPLE REGRESSION: Model-Level Summary =====\n")
print(model_summary)

cat("\n===== MULTIPLE REGRESSION: Coefficient Summary =====\n")
cat("Significance: *** p<0.001  ** p<0.01  * p<0.05  . p<0.1\n\n")
print(coef_summary, n = Inf)

# ── Save to CSV ───────────────────────────────────────────────────────────────
write_csv(model_summary,  "output/tables/mlr_model_summary.csv")
write_csv(coef_summary,   "output/tables/mlr_coef_summary.csv")

cat("\nTables saved to output/tables/\n")

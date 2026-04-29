library(tidyverse)
library(broom)

df <- read_csv("data/placed_salary_data.csv", show_col_types = FALSE) %>%
  mutate(
    college_tier             = factor(college_tier),
    country                  = factor(country),
    university_ranking_band  = factor(university_ranking_band),
    specialization           = factor(specialization),
    industry                 = factor(industry)
  )

dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)

# ── Numeric predictors ────────────────────────────────────────────────────────
numeric_preds <- c(
  "cgpa", "backlogs", "internship_count",
  "aptitude_score", "communication_score", "internship_quality_score"
)

numeric_results <- map_dfr(numeric_preds, function(pred) {
  formula  <- as.formula(paste("salary ~", pred))
  model    <- lm(formula, data = df)
  tidy_out <- tidy(model)      # coefficient table
  glance_out <- glance(model)  # model-level stats
  
  # Pull the predictor row (not the intercept)
  pred_row <- tidy_out %>% filter(term == pred)
  
  tibble(
    predictor   = pred,
    coefficient = round(pred_row$estimate,  3),
    std_error   = round(pred_row$std.error, 3),
    t_statistic = round(pred_row$statistic, 3),
    p_value     = round(pred_row$p.value,   4),
    r_squared   = round(glance_out$r.squared, 4),
    adj_r_sq    = round(glance_out$adj.r.squared, 4),
    f_statistic = round(glance_out$statistic, 3),
    f_p_value   = round(glance_out$p.value,   4)
  )
})

# ── Categorical predictors ────────────────────────────────────────────────────
# For categorical predictors we care most about whether the factor AS A WHOLE
# explains salary, so we report the overall F-test from glance().
categorical_preds <- c(
  "college_tier", "country", "university_ranking_band",
  "specialization", "industry"
)

categorical_results <- map_dfr(categorical_preds, function(pred) {
  formula    <- as.formula(paste("salary ~", pred))
  model      <- lm(formula, data = df)
  glance_out <- glance(model)
  
  tibble(
    predictor   = pred,
    r_squared   = round(glance_out$r.squared,     4),
    adj_r_sq    = round(glance_out$adj.r.squared, 4),
    f_statistic = round(glance_out$statistic,     3),
    df_model    = glance_out$df,          # number of dummy variables used
    f_p_value   = round(glance_out$p.value, 4)
  )
})

# ── Print to console ──────────────────────────────────────────────────────────
cat("\n===== NUMERIC PREDICTORS: Simple Linear Regression Summary =====\n")
print(numeric_results, n = Inf)

cat("\n===== CATEGORICAL PREDICTORS: Overall F-Test Summary =====\n")
print(categorical_results, n = Inf)

# ── Save to CSV ───────────────────────────────────────────────────────────────
write_csv(numeric_results,      "output/tables/slr_numeric_summary.csv")
write_csv(categorical_results,  "output/tables/slr_categorical_summary.csv")

cat("\nTables saved to output/tables/\n")
library(tidyverse)

format_p_value <- function(p) {
  ifelse(p < 0.001, "<0.001", sprintf("%.3f", p))
}

numeric_predictors <- c(
  "cgpa",
  "backlogs",
  "internship_count",
  "aptitude_score",
  "communication_score",
  "internship_quality_score"
)

categorical_predictors <- c(
  "college_tier",
  "country",
  "university_ranking_band",
  "specialization",
  "industry"
)

df <- read_csv("data/placed_salary_data.csv", show_col_types = FALSE) %>%
  mutate(across(all_of(categorical_predictors), as.factor))

fit_numeric_model <- function(predictor) {
  model <- lm(as.formula(paste("salary ~", predictor)), data = df)
  coef_row <- summary(model)$coefficients[2, ]
  glance_row <- broom::glance(model)

  tibble(
    predictor = predictor,
    predictor_type = "numeric",
    coefficient_or_effect = sprintf("slope = %.2f", coef_row[["Estimate"]]),
    p_value = format_p_value(coef_row[["Pr(>|t|)"]]),
    r_squared = round(glance_row$r.squared, 4),
    adjusted_r_squared = round(glance_row$adj.r.squared, 4),
    takeaway = case_when(
      coef_row[["Pr(>|t|)"]] < 0.05 & coef_row[["Estimate"]] > 0 ~ "Significant positive salary association",
      coef_row[["Pr(>|t|)"]] < 0.05 & coef_row[["Estimate"]] < 0 ~ "Significant negative salary association",
      TRUE ~ "No statistically significant linear association"
    )
  )
}

fit_categorical_model <- function(predictor) {
  model <- lm(as.formula(paste("salary ~", predictor)), data = df)
  model_anova <- anova(model)
  overall_p <- model_anova$`Pr(>F)`[1]
  overall_f <- model_anova$`F value`[1]
  glance_row <- broom::glance(model)

  tibble(
    predictor = predictor,
    predictor_type = "categorical",
    coefficient_or_effect = sprintf("overall F-test = %.2f", overall_f),
    p_value = format_p_value(overall_p),
    r_squared = round(glance_row$r.squared, 4),
    adjusted_r_squared = round(glance_row$adj.r.squared, 4),
    takeaway = if_else(
      overall_p < 0.05,
      "Overall mean salary differs across groups",
      "No statistically significant group-level salary difference"
    )
  )
}

simple_regression_summary <- bind_rows(
  map_dfr(numeric_predictors, fit_numeric_model),
  map_dfr(categorical_predictors, fit_categorical_model)
)

dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)
write_csv(simple_regression_summary, "output/tables/simple_regression_summary.csv")

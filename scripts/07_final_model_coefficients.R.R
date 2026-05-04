library(tidyverse)
library(broom)
library(scales)

dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)

format_p_value <- function(p) {
  case_when(
    is.na(p) ~ NA_character_,
    p == 0 ~ "<2.2e-16",
    p < 0.001 ~ formatC(p, format = "e", digits = 3),
    TRUE ~ formatC(p, format = "f", digits = 3)
  )
}

format_dollars <- function(x) {
  dollar(x, accuracy = 1)
}

placed_data <- read_csv("data/placed_salary_data.csv", show_col_types = FALSE) %>%
  mutate(
    college_tier = factor(college_tier, levels = c("Tier 1", "Tier 2", "Tier 3")),
    country = factor(country, levels = c("Canada", "Germany", "India", "UK", "USA")),
    university_ranking_band = factor(
      university_ranking_band,
      levels = c("100-300", "300+", "Top 100")
    ),
    specialization = factor(
      specialization,
      levels = c("AI/ML", "Cloud", "Core CS", "Cybersecurity", "Data Science")
    ),
    industry = as.factor(industry)
  )

# final model chosen after residual + interaction checks
final_model <- lm(
  salary ~ cgpa + aptitude_score + college_tier * country +
    country * specialization + university_ranking_band + industry,
  data = placed_data
)

model_fit_summary <- tibble(
  model = "final_ols_country_tier_country_specialization",
  n = nobs(final_model),
  residual_df = df.residual(final_model),
  r_squared = summary(final_model)$r.squared,
  adjusted_r_squared = summary(final_model)$adj.r.squared,
  residual_standard_error = sigma(final_model),
  aic = AIC(final_model),
  bic = BIC(final_model)
)

write_csv(
  model_fit_summary,
  "output/tables/final_model_fit_summary.csv"
)

reference_levels <- tibble(
  variable = c(
    "college_tier",
    "country",
    "university_ranking_band",
    "specialization",
    "industry"
  ),
  reference_level = c(
    levels(placed_data$college_tier)[1],
    levels(placed_data$country)[1],
    levels(placed_data$university_ranking_band)[1],
    levels(placed_data$specialization)[1],
    levels(placed_data$industry)[1]
  )
)

write_csv(
  reference_levels,
  "output/tables/final_model_reference_levels.csv"
)

term_group <- function(term) {
  case_when(
    term == "(Intercept)" ~ "intercept",
    term %in% c("cgpa", "aptitude_score") ~ "numeric_predictor",
    str_detect(term, "^college_tier.*:country|^country.*:college_tier") ~ "country_x_college_tier_interaction",
    str_detect(term, "^country.*:specialization|^specialization.*:country") ~ "country_x_specialization_interaction",
    str_detect(term, "^college_tier") ~ "college_tier_main_effect",
    str_detect(term, "^country") ~ "country_main_effect",
    str_detect(term, "^university_ranking_band") ~ "university_ranking_band_effect",
    str_detect(term, "^specialization") ~ "specialization_main_effect",
    str_detect(term, "^industry") ~ "industry_effect",
    TRUE ~ "other"
  )
}

final_model_coefficients <- tidy(final_model, conf.int = TRUE) %>%
  mutate(
    term_group = term_group(term),
    p_value_label = format_p_value(p.value),
    estimate_dollars = format_dollars(estimate),
    conf_low_dollars = format_dollars(conf.low),
    conf_high_dollars = format_dollars(conf.high),
    statistically_significant_05 = p.value < 0.05
  ) %>%
  select(
    term_group,
    term,
    estimate,
    estimate_dollars,
    std.error,
    statistic,
    p.value,
    p_value_label,
    conf.low,
    conf_low_dollars,
    conf.high,
    conf_high_dollars,
    statistically_significant_05
  )

write_csv(
  final_model_coefficients,
  "output/tables/final_model_coefficients_clean.csv"
)

# shorter coefficient table for slides/report
final_model_coefficients_slide <- final_model_coefficients %>%
  filter(term != "(Intercept)") %>%
  mutate(abs_estimate = abs(estimate)) %>%
  arrange(desc(abs_estimate)) %>%
  select(
    term_group,
    term,
    estimate_dollars,
    p_value_label,
    conf_low_dollars,
    conf_high_dollars
  )

write_csv(
  final_model_coefficients_slide,
  "output/tables/final_model_coefficients_slide.csv"
)

# numeric effects are easiest to interpret directly
numeric_effects <- final_model_coefficients %>%
  filter(term %in% c("cgpa", "aptitude_score")) %>%
  transmute(
    predictor = term,
    interpretation = case_when(
      term == "cgpa" ~ paste0(
        "Holding other variables fixed, a 1-point increase in CGPA is associated with an estimated ",
        estimate_dollars,
        " change in salary."
      ),
      term == "aptitude_score" ~ paste0(
        "Holding other variables fixed, a 1-point increase in aptitude score is associated with an estimated ",
        estimate_dollars,
        " change in salary."
      )
    ),
    p_value = p_value_label,
    confidence_interval = paste0("[", conf_low_dollars, ", ", conf_high_dollars, "]")
  )

write_csv(
  numeric_effects,
  "output/tables/final_model_numeric_effects.csv"
)

# interactions make raw coefficients hard to read, so create predicted means
baseline_values <- tibble(
  cgpa = median(placed_data$cgpa, na.rm = TRUE),
  aptitude_score = median(placed_data$aptitude_score, na.rm = TRUE),
  university_ranking_band = names(sort(table(placed_data$university_ranking_band), decreasing = TRUE))[1],
  industry = names(sort(table(placed_data$industry), decreasing = TRUE))[1]
)

country_tier_predictions <- expand_grid(
  country = levels(placed_data$country),
  college_tier = levels(placed_data$college_tier),
  specialization = names(sort(table(placed_data$specialization), decreasing = TRUE))[1]
) %>%
  mutate(
    cgpa = baseline_values$cgpa,
    aptitude_score = baseline_values$aptitude_score,
    university_ranking_band = baseline_values$university_ranking_band,
    industry = baseline_values$industry
  ) %>%
  mutate(
    college_tier = factor(college_tier, levels = levels(placed_data$college_tier)),
    country = factor(country, levels = levels(placed_data$country)),
    university_ranking_band = factor(
      university_ranking_band,
      levels = levels(placed_data$university_ranking_band)
    ),
    specialization = factor(specialization, levels = levels(placed_data$specialization)),
    industry = factor(industry, levels = levels(placed_data$industry)),
    predicted_salary = predict(final_model, newdata = .),
    predicted_salary_display = format_dollars(predicted_salary)
  ) %>%
  arrange(country, college_tier)

write_csv(
  country_tier_predictions,
  "output/tables/final_model_predicted_salary_by_country_tier.csv"
)

country_specialization_predictions <- expand_grid(
  country = levels(placed_data$country),
  specialization = levels(placed_data$specialization),
  college_tier = "Tier 1"
) %>%
  mutate(
    cgpa = baseline_values$cgpa,
    aptitude_score = baseline_values$aptitude_score,
    university_ranking_band = baseline_values$university_ranking_band,
    industry = baseline_values$industry
  ) %>%
  mutate(
    college_tier = factor(college_tier, levels = levels(placed_data$college_tier)),
    country = factor(country, levels = levels(placed_data$country)),
    university_ranking_band = factor(
      university_ranking_band,
      levels = levels(placed_data$university_ranking_band)
    ),
    specialization = factor(specialization, levels = levels(placed_data$specialization)),
    industry = factor(industry, levels = levels(placed_data$industry)),
    predicted_salary = predict(final_model, newdata = .),
    predicted_salary_display = format_dollars(predicted_salary)
  ) %>%
  arrange(country, specialization)

write_csv(
  country_specialization_predictions,
  "output/tables/final_model_predicted_salary_by_country_specialization.csv"
)

# readable summary printed in console
cat("\nFinal model fit summary:\n")
print(model_fit_summary)

cat("\nReference levels:\n")
print(reference_levels)

cat("\nNumeric effects:\n")
print(numeric_effects)

cat("\nTop coefficient magnitudes for slide/report review:\n")
print(head(final_model_coefficients_slide, 15))
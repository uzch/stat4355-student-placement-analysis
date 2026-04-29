suppressPackageStartupMessages({
  library(dplyr)
  library(broom)
  library(MASS)
  library(car)
})

format_p_value <- function(p) {
  ifelse(is.na(p), NA_character_, ifelse(p < 0.001, "<0.001", formatC(p, format = "f", digits = 3)))
}

count_model_terms <- function(model) {
  attr(terms(model), "term.labels") |> length()
}

placed_data <- read.csv("data/placed_salary_data.csv", stringsAsFactors = FALSE)

placed_data <- placed_data %>%
  mutate(
    college_tier = as.factor(college_tier),
    country = as.factor(country),
    university_ranking_band = as.factor(university_ranking_band),
    specialization = as.factor(specialization),
    industry = as.factor(industry)
  )

full_formula <- salary ~ cgpa + backlogs + college_tier + country +
  university_ranking_band + internship_count + aptitude_score +
  communication_score + specialization + industry + internship_quality_score

full_model <- lm(full_formula, data = placed_data)
selected_model <- stepAIC(full_model, direction = "both", trace = FALSE)

full_model_summary <- tidy(full_model) %>%
  transmute(
    term,
    estimate,
    std_error = std.error,
    statistic,
    p_value = p.value,
    p_value_display = format_p_value(p.value)
  )

model_comparison <- tibble(
  model = c("full_model", "selected_model"),
  aic = c(AIC(full_model), AIC(selected_model)),
  r_squared = c(summary(full_model)$r.squared, summary(selected_model)$r.squared),
  adjusted_r_squared = c(summary(full_model)$adj.r.squared, summary(selected_model)$adj.r.squared),
  n_terms = c(count_model_terms(full_model), count_model_terms(selected_model))
)

final_model_coefficients <- tidy(selected_model) %>%
  transmute(
    term,
    estimate,
    std_error = std.error,
    statistic,
    p_value = p.value,
    p_value_display = format_p_value(p.value)
  )

vif_selected_model <- vif(selected_model)

if (is.matrix(vif_selected_model)) {
  vif_selected_model <- as.data.frame(vif_selected_model) %>%
    tibble::rownames_to_column("term")
} else {
  vif_selected_model <- tibble(
    term = names(vif_selected_model),
    vif = as.numeric(vif_selected_model)
  )
}

write.csv(full_model_summary, "output/tables/full_model_summary.csv", row.names = FALSE)
write.csv(model_comparison, "output/tables/model_comparison.csv", row.names = FALSE)
write.csv(final_model_coefficients, "output/tables/final_model_coefficients.csv", row.names = FALSE)
write.csv(vif_selected_model, "output/tables/vif_selected_model.csv", row.names = FALSE)

suppressPackageStartupMessages({
  library(MASS)
  library(dplyr)
  library(broom)
  library(ggplot2)
  library(scales)
})

dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)

format_p_value <- function(p) {
  dplyr::case_when(
    is.na(p) ~ NA_character_,
    p == 0 ~ "<2.2e-16",
    p < 0.001 ~ formatC(p, format = "e", digits = 3),
    TRUE ~ formatC(p, format = "f", digits = 3)
  )
}

theme_report <- function() {
  theme_minimal(base_size = 14) +
    theme(
      plot.title = element_text(size = 20, face = "bold"),
      axis.title = element_text(size = 15),
      axis.text = element_text(size = 12),
      legend.title = element_text(size = 13),
      legend.text = element_text(size = 12)
    )
}

placed_data <- read.csv("data/placed_salary_data.csv", stringsAsFactors = FALSE) %>%
  mutate(
    college_tier = as.factor(college_tier),
    country = as.factor(country),
    university_ranking_band = as.factor(university_ranking_band),
    specialization = as.factor(specialization),
    industry = as.factor(industry)
  )

# base model = predictors selected by stepwise AIC
base_model <- lm(
  salary ~ cgpa + aptitude_score + college_tier + country +
    university_ranking_band + specialization + industry,
  data = placed_data
)

# interaction model = lets college tier effect differ by country
interaction_model <- lm(
  salary ~ cgpa + aptitude_score + college_tier * country +
    university_ranking_band + specialization + industry,
  data = placed_data
)

model_comparison <- tibble(
  model = c("base_ols", "interaction_ols"),
  aic = c(AIC(base_model), AIC(interaction_model)),
  r_squared = c(summary(base_model)$r.squared, summary(interaction_model)$r.squared),
  adj_r_squared = c(summary(base_model)$adj.r.squared, summary(interaction_model)$adj.r.squared)
) %>%
  mutate(delta_aic = aic - min(aic))

write.csv(
  model_comparison,
  "output/tables/ols_model_comparison.csv",
  row.names = FALSE
)

# nested model test for interaction terms
interaction_anova <- anova(base_model, interaction_model) %>%
  tidy() %>%
  mutate(p_value_label = format_p_value(p.value))

write.csv(
  interaction_anova,
  "output/tables/ols_interaction_anova.csv",
  row.names = FALSE
)

interaction_coefficients <- tidy(interaction_model, conf.int = TRUE) %>%
  transmute(
    term,
    estimate,
    std.error,
    statistic,
    p.value,
    conf.low,
    conf.high,
    p_value_label = format_p_value(p.value)
  )

write.csv(
  interaction_coefficients,
  "output/tables/ols_interaction_coefficients.csv",
  row.names = FALSE
)

# diagnostics are based on interaction OLS candidate final model
diagnostic_data <- augment(interaction_model) %>%
  mutate(
    observation = row_number(),
    studentized_residual = rstudent(interaction_model),
    leverage = hatvalues(interaction_model),
    cooks_distance = cooks.distance(interaction_model)
  )

n_obs <- nobs(interaction_model)
n_params <- length(coef(interaction_model))

cook_threshold_sensitive <- 4 / n_obs
cook_threshold_class <- 1
leverage_threshold <- 2 * n_params / n_obs
studentized_threshold <- 3

diagnostic_data <- diagnostic_data %>%
  mutate(
    high_cooks_sensitive = cooks_distance > cook_threshold_sensitive,
    high_cooks_class = cooks_distance > cook_threshold_class,
    high_leverage = leverage > leverage_threshold,
    outlier_studentized = abs(studentized_residual) > studentized_threshold,
    flagged = high_cooks_sensitive | high_cooks_class | high_leverage | outlier_studentized
  )

influence_summary <- diagnostic_data %>%
  filter(flagged) %>%
  dplyr::select(
    observation,
    fitted = .fitted,
    residual = .resid,
    std_residual = .std.resid,
    studentized_residual,
    leverage,
    cooks_distance,
    high_cooks_sensitive,
    high_cooks_class,
    high_leverage,
    outlier_studentized
  )

write.csv(
  influence_summary,
  "output/tables/influence_summary.csv",
  row.names = FALSE
)

influence_counts <- tibble(
  metric = c(
    "n_observations",
    "n_parameters_including_intercept",
    "cook_threshold_sensitive_4_over_n",
    "cook_threshold_class_1",
    "leverage_threshold_2p_over_n",
    "studentized_threshold_abs_3",
    "flagged_by_sensitive_cooks",
    "flagged_by_class_cooks",
    "flagged_by_high_leverage",
    "flagged_by_studentized_residual",
    "max_cooks_distance",
    "max_leverage",
    "max_abs_studentized_residual"
  ),
  value = c(
    n_obs,
    n_params,
    cook_threshold_sensitive,
    cook_threshold_class,
    leverage_threshold,
    studentized_threshold,
    sum(diagnostic_data$high_cooks_sensitive),
    sum(diagnostic_data$high_cooks_class),
    sum(diagnostic_data$high_leverage),
    sum(diagnostic_data$outlier_studentized),
    max(diagnostic_data$cooks_distance),
    max(diagnostic_data$leverage),
    max(abs(diagnostic_data$studentized_residual))
  )
)

write.csv(
  influence_counts,
  "output/tables/influence_counts.csv",
  row.names = FALSE
)

# transformation checks belong here, not in cleaning/model selection
log_interaction_model <- lm(
  log(salary) ~ cgpa + aptitude_score + college_tier * country +
    university_ranking_band + specialization + industry,
  data = placed_data
)

sqrt_interaction_model <- lm(
  sqrt(salary) ~ cgpa + aptitude_score + college_tier * country +
    university_ranking_band + specialization + industry,
  data = placed_data
)

boxcox_result <- MASS::boxcox(interaction_model, plotit = FALSE)
best_lambda <- boxcox_result$x[which.max(boxcox_result$y)]

boxcox_interpretation <- case_when(
  abs(best_lambda - 1) < 0.15 ~ "Box-Cox suggests little/no transformation",
  abs(best_lambda) < 0.15 ~ "Box-Cox suggests log transformation",
  abs(best_lambda - 0.5) < 0.15 ~ "Box-Cox suggests square-root transformation",
  TRUE ~ "Box-Cox suggests a non-standard power transformation"
)

transformation_summary <- tibble(
  model = c(
    "raw_salary_interaction_ols",
    "log_salary_interaction_ols",
    "sqrt_salary_interaction_ols"
  ),
  response = c("salary", "log(salary)", "sqrt(salary)"),
  residual_sd = c(
    sigma(interaction_model),
    sigma(log_interaction_model),
    sigma(sqrt_interaction_model)
  ),
  adj_r_squared = c(
    summary(interaction_model)$adj.r.squared,
    summary(log_interaction_model)$adj.r.squared,
    summary(sqrt_interaction_model)$adj.r.squared
  ),
  note = c(
    "main model; easiest to interpret in salary dollars",
    "common salary transformation; check plots before using",
    "possible variance-stabilizing check; less common for salary"
  )
)

write.csv(
  transformation_summary,
  "output/tables/transformation_summary.csv",
  row.names = FALSE
)

boxcox_summary <- tibble(
  best_lambda = best_lambda,
  interpretation = boxcox_interpretation,
  note = "Arcsine transformation not tested because salary is not a 0-1 proportion."
)

write.csv(
  boxcox_summary,
  "output/tables/boxcox_summary.csv",
  row.names = FALSE
)

diagnostics_summary <- tibble(
  topic = c(
    "residual_pattern",
    "normality",
    "influence",
    "salary_cap_120000",
    "transformation_check",
    "final_model_direction"
  ),
  conclusion = c(
    "Interaction OLS residuals are more centered and flatter than the base OLS model, but the high fitted-value region still shows a ceiling pattern.",
    "QQ plot and residual histogram are reasonably close to normal, with mild tail deviation.",
    paste0(
      "No observations exceed Cook's D > 1 and high leverage count is ",
      sum(diagnostic_data$high_leverage),
      ". ",
      sum(diagnostic_data$outlier_studentized),
      " observations have |studentized residual| > 3. ",
      sum(diagnostic_data$high_cooks_sensitive),
      " observations exceed the sensitive 4/n Cook's rule, but max Cook's D is ",
      signif(max(diagnostic_data$cooks_distance), 4),
      ", so no single observation appears to dominate the model."
    ),
    "The 120000 salary cap remains visible in residuals and should be discussed as a dataset limitation.",
    paste0(
      "Box-Cox best lambda is approximately ",
      round(best_lambda, 3),
      ". ",
      boxcox_interpretation,
      ". Log and square-root models were checked; transformed-response fit statistics are not directly comparable to raw salary fit statistics."
    ),
    "Use interaction OLS as the main in-scope model unless transformation diagnostics clearly justify changing the response scale. Treat Tobit only as a salary-cap sensitivity discussion, not the final model."
  )
)

write.csv(
  diagnostics_summary,
  "output/tables/diagnostics_summary.csv",
  row.names = FALSE
)

# base vs interaction residuals for explaining why interaction helped
base_diag <- augment(base_model) %>%
  mutate(model = "Base selected OLS")

interaction_diag <- augment(interaction_model) %>%
  mutate(model = "Interaction OLS")

comparison_diag <- bind_rows(base_diag, interaction_diag)

p_base_vs_interaction <- ggplot(comparison_diag, aes(x = .fitted, y = .resid)) +
  geom_point(alpha = 0.23, color = "gray35") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "#D55E00", linewidth = 0.8) +
  geom_smooth(method = "loess", se = FALSE, color = "#0072B2", linewidth = 1.1) +
  facet_wrap(~model, nrow = 1) +
  scale_x_continuous(labels = comma) +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Residual Comparison: Base OLS vs Interaction OLS",
    x = "Fitted salary",
    y = "Residuals"
  ) +
  theme_report()

ggsave(
  "output/figures/base_vs_interaction_residuals.png",
  p_base_vs_interaction,
  width = 13,
  height = 6,
  dpi = 300
)

p_resid_fitted <- ggplot(diagnostic_data, aes(x = .fitted, y = .resid)) +
  geom_point(alpha = 0.28, color = "gray35") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "#D55E00", linewidth = 0.8) +
  geom_smooth(method = "loess", se = FALSE, color = "#0072B2", linewidth = 1.1) +
  scale_x_continuous(labels = comma) +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Interaction OLS: Residuals vs Fitted",
    x = "Fitted salary",
    y = "Residuals"
  ) +
  theme_report()

ggsave(
  "output/figures/final_residuals_vs_fitted.png",
  p_resid_fitted,
  width = 11,
  height = 7,
  dpi = 300
)

p_qq <- ggplot(diagnostic_data, aes(sample = studentized_residual)) +
  stat_qq(alpha = 0.35, color = "gray35") +
  stat_qq_line(color = "#0072B2", linewidth = 1.1) +
  labs(
    title = "Interaction OLS: QQ Plot",
    x = "Theoretical quantiles",
    y = "Studentized residuals"
  ) +
  theme_report()

ggsave(
  "output/figures/final_qq_plot.png",
  p_qq,
  width = 11,
  height = 7,
  dpi = 300
)

p_hist <- ggplot(diagnostic_data, aes(x = .resid)) +
  geom_histogram(bins = 30, fill = "#56B4E9", color = "white") +
  scale_x_continuous(labels = comma) +
  labs(
    title = "Interaction OLS: Residual Histogram",
    x = "Residuals",
    y = "Count"
  ) +
  theme_report()

ggsave(
  "output/figures/final_residual_histogram.png",
  p_hist,
  width = 11,
  height = 7,
  dpi = 300
)

p_cooks <- ggplot(diagnostic_data, aes(x = observation, y = cooks_distance)) +
  geom_segment(
    aes(xend = observation, yend = 0),
    color = "gray60",
    linewidth = 0.25
  ) +
  geom_hline(
    yintercept = cook_threshold_sensitive,
    linetype = "dashed",
    color = "#D55E00",
    linewidth = 0.8
  ) +
  labs(
    title = "Interaction OLS: Cook's Distance",
    x = "Observation index",
    y = "Cook's distance"
  ) +
  theme_report()

ggsave(
  "output/figures/final_cooks_distance.png",
  p_cooks,
  width = 11,
  height = 7,
  dpi = 300
)

p_leverage <- ggplot(diagnostic_data, aes(x = leverage, y = studentized_residual)) +
  geom_point(alpha = 0.28, color = "gray35") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "#D55E00", linewidth = 0.8) +
  geom_vline(xintercept = leverage_threshold, linetype = "dashed", color = "#0072B2", linewidth = 0.8) +
  labs(
    title = "Interaction OLS: Leverage vs Studentized Residuals",
    x = "Leverage",
    y = "Studentized residuals"
  ) +
  theme_report()

ggsave(
  "output/figures/final_leverage_plot.png",
  p_leverage,
  width = 11,
  height = 7,
  dpi = 300
)

# log model plots are only for transformation check
log_diag <- augment(log_interaction_model) %>%
  mutate(studentized_residual = rstudent(log_interaction_model))

p_log_resid_fitted <- ggplot(log_diag, aes(x = .fitted, y = .resid)) +
  geom_point(alpha = 0.28, color = "gray35") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "#D55E00", linewidth = 0.8) +
  geom_smooth(method = "loess", se = FALSE, color = "#0072B2", linewidth = 1.1) +
  labs(
    title = "Log Salary Interaction OLS: Residuals vs Fitted",
    x = "Fitted log salary",
    y = "Residuals"
  ) +
  theme_report()

ggsave(
  "output/figures/log_residuals_vs_fitted.png",
  p_log_resid_fitted,
  width = 11,
  height = 7,
  dpi = 300
)

p_log_qq <- ggplot(log_diag, aes(sample = studentized_residual)) +
  stat_qq(alpha = 0.35, color = "gray35") +
  stat_qq_line(color = "#0072B2", linewidth = 1.1) +
  labs(
    title = "Log Salary Interaction OLS: QQ Plot",
    x = "Theoretical quantiles",
    y = "Studentized residuals"
  ) +
  theme_report()

ggsave(
  "output/figures/log_qq_plot.png",
  p_log_qq,
  width = 11,
  height = 7,
  dpi = 300
)

boxcox_profile <- tibble(
  lambda = boxcox_result$x,
  log_likelihood = boxcox_result$y
)

p_boxcox <- ggplot(boxcox_profile, aes(x = lambda, y = log_likelihood)) +
  geom_line(color = "#0072B2", linewidth = 1.1) +
  geom_vline(xintercept = best_lambda, linetype = "dashed", color = "#D55E00", linewidth = 0.8) +
  labs(
    title = "Box-Cox Profile for Interaction OLS",
    x = "Lambda",
    y = "Profile log-likelihood"
  ) +
  theme_report()

ggsave(
  "output/figures/boxcox_profile.png",
  p_boxcox,
  width = 11,
  height = 7,
  dpi = 300
)

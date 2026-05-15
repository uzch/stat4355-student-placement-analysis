library(tidyverse)
library(AER)
library(patchwork)

df <- read_csv("data/placed_salary_data.csv", show_col_types = FALSE) %>%
  mutate(
    college_tier            = factor(college_tier),
    country                 = factor(country),
    university_ranking_band = factor(university_ranking_band),
    specialization          = factor(specialization),
    industry                = factor(industry)
  )

dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)
dir.create("output/tables",  recursive = TRUE, showWarnings = FALSE)

# ── Four models for full comparison ───────────────────────────────────────────
model_ols_base <- lm(
  salary ~ cgpa + aptitude_score + college_tier + country +
    university_ranking_band + specialization + industry,
  data = df
)

model_ols_interaction <- lm(
  salary ~ cgpa + aptitude_score + college_tier * country +
    university_ranking_band + specialization + industry,
  data = df
)

model_tobit_base <- tobit(
  salary ~ cgpa + aptitude_score + college_tier + country +
    university_ranking_band + specialization + industry,
  right = max(df$salary),
  data  = df
)

model_tobit_interaction <- tobit(
  salary ~ cgpa + aptitude_score + college_tier * country +
    university_ranking_band + specialization + industry,
  right = max(df$salary),
  data  = df
)

# ── Residual comparison dataframe ─────────────────────────────────────────────
resid_df <- tibble(
  fitted      = c(fitted(model_ols_base),
                  fitted(model_ols_interaction),
                  fitted(model_tobit_base),
                  fitted(model_tobit_interaction)),
  residuals   = c(residuals(model_ols_base),
                  residuals(model_ols_interaction),
                  residuals(model_tobit_base),
                  residuals(model_tobit_interaction)),
  model       = rep(
    c("OLS Base", "OLS Interaction", "Tobit Base", "Tobit Interaction"),
    each = nrow(df)
  )
) %>%
  mutate(model = factor(model,
                        levels = c("OLS Base", "OLS Interaction",
                                   "Tobit Base", "Tobit Interaction")))

# ── 2x2 residual comparison plot ──────────────────────────────────────────────
ggplot(resid_df, aes(x = fitted, y = residuals)) +
  geom_point(alpha = 0.15, size = 0.6) +
  geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
  geom_smooth(se = FALSE, color = "blue", linewidth = 0.8) +
  scale_x_continuous(labels = scales::comma) +
  scale_y_continuous(labels = scales::comma) +
  facet_wrap(~ model, ncol = 2) +
  labs(
    title    = "Residuals vs Fitted: All Four Models",
    subtitle = "Comparing OLS vs Tobit, with and without college_tier * country interaction",
    x        = "Fitted Values",
    y        = "Residuals"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title  = element_text(face = "bold"),
    strip.text  = element_text(face = "bold")
  )

ggsave("output/figures/resid_all_models.png", width = 14, height = 10, dpi = 150)

# ── Coefficient comparison table ──────────────────────────────────────────────
# Extract shared terms across all four models for easy comparison
shared_terms <- c("(Intercept)", "cgpa", "aptitude_score",
                  "college_tierTier 2", "college_tierTier 3",
                  "countryGermany", "countryIndia",
                  "countryUK", "countryUSA")

extract_coefs <- function(model, model_name) {
  coefs <- coef(model)
  tibble(
    term       = names(coefs),
    estimate   = round(coefs, 3),
    model_name = model_name
  ) %>%
    filter(term %in% shared_terms)
}

coef_comparison <- bind_rows(
  extract_coefs(model_ols_base,         "OLS Base"),
  extract_coefs(model_ols_interaction,  "OLS Interaction"),
  extract_coefs(model_tobit_base,       "Tobit Base"),
  extract_coefs(model_tobit_interaction,"Tobit Interaction")
) %>%
  pivot_wider(names_from = model_name, values_from = estimate)

cat("\n===== COEFFICIENT COMPARISON ACROSS ALL FOUR MODELS =====\n")
print(coef_comparison, n = Inf)
write_csv(coef_comparison, "output/tables/coef_comparison_all_models.csv")

# ── Model fit summary ─────────────────────────────────────────────────────────
# For OLS models we can use adj R² — Tobit uses log-likelihood instead
ols_fit <- tibble(
  model       = c("OLS Base", "OLS Interaction"),
  adj_r_sq    = c(summary(model_ols_base)$adj.r.squared,
                  summary(model_ols_interaction)$adj.r.squared),
  log_lik     = c(logLik(model_ols_base),
                  logLik(model_ols_interaction)),
  AIC         = c(AIC(model_ols_base),
                  AIC(model_ols_interaction))
)

tobit_fit <- tibble(
  model       = c("Tobit Base", "Tobit Interaction"),
  adj_r_sq    = NA,
  log_lik     = c(logLik(model_tobit_base),
                  logLik(model_tobit_interaction)),
  AIC         = c(AIC(model_tobit_base),
                  AIC(model_tobit_interaction))
)

fit_summary <- bind_rows(ols_fit, tobit_fit) %>%
  mutate(across(where(is.numeric), ~ round(., 3)))

cat("\n===== MODEL FIT SUMMARY =====\n")
print(fit_summary)
write_csv(fit_summary, "output/tables/model_fit_summary.csv")

cat("\nAll outputs saved.\n")
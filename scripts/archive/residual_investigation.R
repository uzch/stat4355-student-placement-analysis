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

# Your selected model (without the dropped predictors)
model <- lm(
  salary ~ cgpa + aptitude_score + college_tier + country +
    university_ranking_band + specialization + industry,
  data = df
)

dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)

# ── Plot all four diagnostic plots at once ────────────────────────────────────
png("output/figures/residual_diagnostics.png", width = 1200, height = 1000, res = 120)
par(mfrow = c(2, 2))  # 2x2 grid
plot(model)
dev.off()

cat("Saved to output/figures/residual_diagnostics.png\n")


# investigating 120000 cut off
ggplot(df, aes(x = salary)) +
  geom_histogram(bins = 50) +
  geom_vline(xintercept = 120000, color = "red", linetype = "dashed") +
  labs(title = "Salary Distribution - Checking for Ceiling Effect")

ggsave("output/figures/salary_ceiling_check.png", width = 8, height = 5)

# tobit model to account for 120000 dollar ceilling

library(AER)

tobit_model <- tobit(
  salary ~ cgpa + aptitude_score + college_tier + country +
    university_ranking_band + specialization + industry,
  right = 120000,   # the ceiling value
  data = df
)

# manual residual plot and Q-Q plot, plot(tobit_model) is not supported
fitted_vals <- fitted(tobit_model)
resid_vals  <- residuals(tobit_model)

diag_df <- data.frame(
  fitted    = fitted_vals,
  residuals = resid_vals
)

# ── Residuals vs Fitted ───────────────────────────────────────────────────────
ggplot(diag_df, aes(x = fitted, y = residuals)) +
  geom_point(alpha = 0.3, size = 0.8) +
  geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
  geom_smooth(se = FALSE, color = "blue") +
  labs(title = "Residuals vs Fitted (Tobit)", x = "Fitted Values", y = "Residuals") +
  theme_minimal()

ggsave("output/figures/tobit_resid_vs_fitted.png", width = 8, height = 5)

# ── Q-Q Plot ──────────────────────────────────────────────────────────────────
ggplot(diag_df, aes(sample = residuals)) +
  stat_qq() +
  stat_qq_line(color = "red") +
  labs(title = "Q-Q Plot (Tobit)", x = "Theoretical Quantiles", y = "Sample Quantiles") +
  theme_minimal()

ggsave("output/figures/tobit_qq.png", width = 8, height = 5)

cbind(
  OLS   = coef(model)[1:5],
  Tobit = coef(tobit_model)[1:5]
)

# tobit seems to improve the coefficients on our predictors, but even the residuals 
# before 120000 appear to follow a bowl shape which suggests a non-linear relationship
# Plot CGPA residuals directly
ggplot(diag_df, aes(x = df$cgpa, y = residuals)) +
  geom_point(alpha = 0.3, size = 0.8) +
  geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
  geom_smooth(se = FALSE, color = "blue") +
  labs(title = "Residuals vs CGPA", x = "CGPA", y = "Residuals") +
  theme_minimal()

ggsave("output/figures/resid_vs_cgpa.png", width = 8, height = 5)

# cgpa seems well behaved

# check categorical data
diag_df <- diag_df %>%
  mutate(
    college_tier            = df$college_tier,
    country                 = df$country,
    university_ranking_band = df$university_ranking_band,
    specialization          = df$specialization,
    industry                = df$industry
  )

# College tier
ggplot(diag_df, aes(x = college_tier, y = residuals)) +
  geom_boxplot() +
  geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
  labs(title = "Residuals by College Tier") +
  theme_minimal()
ggsave("output/figures/resid_by_college_tier.png", width = 8, height = 5)

# Country
ggplot(diag_df, aes(x = country, y = residuals)) +
  geom_boxplot() +
  geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
  labs(title = "Residuals by Country") +
  theme_minimal()
ggsave("output/figures/resid_by_country.png", width = 8, height = 5)

# University ranking band
ggplot(diag_df, aes(x = university_ranking_band, y = residuals)) +
  geom_boxplot() +
  geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
  labs(title = "Residuals by University Ranking Band") +
  theme_minimal()
ggsave("output/figures/resid_by_ranking.png", width = 8, height = 5)

# Specialization
ggplot(diag_df, aes(x = specialization, y = residuals)) +
  geom_boxplot() +
  geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
  theme(axis.text.x = element_text(angle = 20, hjust = 1)) +
  labs(title = "Residuals by Specialization") +
  theme_minimal()
ggsave("output/figures/resid_by_specialization.png", width = 8, height = 5)

# Industry
ggplot(diag_df, aes(x = industry, y = residuals)) +
  geom_boxplot() +
  geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
  theme(axis.text.x = element_text(angle = 20, hjust = 1)) +
  labs(title = "Residuals by Industry") +
  theme_minimal()
ggsave("output/figures/resid_by_industry.png", width = 8, height = 5)


# individually, catagorical predictors seem to behave correctly
# let's check interaction between categorical data:

model_interaction <- lm(
  salary ~ cgpa + aptitude_score + college_tier * country +
    university_ranking_band + specialization + industry,
  data = df
)

anova(model, model_interaction)

# ANOVA table tells us interaction between country and university tier is very significant
# tier 1 in USA is not the same as tier 1 in india
# see below how different tier have differnt events depending on country
df %>%
  group_by(college_tier, country) %>%
  summarise(mean_salary = mean(salary), .groups = "drop") %>%
  ggplot(aes(x = college_tier, y = mean_salary, color = country, group = country)) +
  geom_line() +
  geom_point(size = 3) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Mean Salary by College Tier and Country",
    subtitle = "Non-parallel lines indicate an interaction effect",
    x = "College Tier", y = "Mean Salary", color = "Country"
  ) +
  theme_minimal()

ggsave("output/figures/interaction_plot.png", width = 9, height = 6)


# side by side comparison of residuals of base vs interaction model

# Build both models
model_base <- lm(
  salary ~ cgpa + aptitude_score + college_tier + country +
    university_ranking_band + specialization + industry,
  data = df
)

model_interaction <- lm(
  salary ~ cgpa + aptitude_score + college_tier * country +
    university_ranking_band + specialization + industry,
  data = df
)

# Combine residuals from both into one dataframe
resid_comparison <- tibble(
  fitted_base        = fitted(model_base),
  residuals_base     = residuals(model_base),
  fitted_interaction = fitted(model_interaction),
  residuals_interaction = residuals(model_interaction)
)

# ── Plot 1: Residuals vs Fitted — Base Model ──────────────────────────────────
p1 <- ggplot(resid_comparison, aes(x = fitted_base, y = residuals_base)) +
  geom_point(alpha = 0.2, size = 0.8) +
  geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
  geom_smooth(se = FALSE, color = "blue") +
  scale_x_continuous(labels = scales::comma) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title    = "Base Model",
    subtitle = "Without college_tier * country interaction",
    x        = "Fitted Values",
    y        = "Residuals"
  ) +
  theme_minimal()

# ── Plot 2: Residuals vs Fitted — Interaction Model ───────────────────────────
p2 <- ggplot(resid_comparison, aes(x = fitted_interaction, y = residuals_interaction)) +
  geom_point(alpha = 0.2, size = 0.8) +
  geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
  geom_smooth(se = FALSE, color = "blue") +
  scale_x_continuous(labels = scales::comma) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title    = "Interaction Model",
    subtitle = "With college_tier * country interaction",
    x        = "Fitted Values",
    y        = "Residuals"
  ) +
  theme_minimal()

# ── Side by side ──────────────────────────────────────────────────────────────
library(patchwork)

p1 + p2 +
  plot_annotation(
    title   = "Residual Comparison: Base vs Interaction Model",
    caption = "Bowl shape in base model should flatten in interaction model"
  )

ggsave("output/figures/resid_comparison.png", width = 14, height = 6, dpi = 150)
cat("Saved to output/figures/resid_comparison.png\n")






























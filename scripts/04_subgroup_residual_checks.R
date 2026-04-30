library(tidyverse)
library(scales)

dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)

placed_data <- read_csv("data/placed_salary_data.csv", show_col_types = FALSE) %>%
  mutate(
    college_tier = as.factor(college_tier),
    country = as.factor(country),
    university_ranking_band = as.factor(university_ranking_band),
    specialization = as.factor(specialization),
    industry = as.factor(industry)
  )

# final interaction OLS model
model <- lm(
  salary ~ cgpa + aptitude_score + college_tier * country +
    university_ranking_band + specialization + industry,
  data = placed_data
)

# residual < 0 means model overpredicted salary
residual_data <- placed_data %>%
  mutate(
    fitted = fitted(model),
    residual = resid(model),
    studentized_residual = rstudent(model),
    hit_cap = salary == 120000,
    overpredicted = residual < 0,
    underpredicted = residual > 0
  ) %>%
  select(
    fitted,
    residual,
    studentized_residual,
    salary,
    country,
    college_tier,
    specialization,
    industry,
    hit_cap,
    overpredicted,
    underpredicted
  )

summarize_residuals <- function(df) {
  df %>%
    summarise(
      n = n(),
      mean_residual = mean(residual, na.rm = TRUE),
      median_residual = median(residual, na.rm = TRUE),
      residual_sd = sd(residual, na.rm = TRUE),
      mean_abs_residual = mean(abs(residual), na.rm = TRUE),
      rmse = sqrt(mean(residual^2, na.rm = TRUE)),
      percent_overpredicted = 100 * mean(overpredicted, na.rm = TRUE),
      percent_underpredicted = 100 * mean(underpredicted, na.rm = TRUE),
      percent_capped = 100 * mean(hit_cap, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(
      across(
        c(
          mean_residual,
          median_residual,
          residual_sd,
          mean_abs_residual,
          rmse,
          percent_overpredicted,
          percent_underpredicted,
          percent_capped
        ),
        ~ round(.x, 2)
      )
    )
}

residual_summary_by_country <- residual_data %>%
  group_by(country) %>%
  summarize_residuals() %>%
  arrange(mean_residual)

residual_summary_by_country_tier <- residual_data %>%
  group_by(country, college_tier) %>%
  summarize_residuals() %>%
  arrange(country, college_tier)

residual_summary_by_country_specialization <- residual_data %>%
  group_by(country, specialization) %>%
  summarize_residuals() %>%
  arrange(country, specialization)

write_csv(
  residual_summary_by_country,
  "output/tables/residual_summary_by_country.csv"
)

write_csv(
  residual_summary_by_country_tier,
  "output/tables/residual_summary_by_country_tier.csv"
)

write_csv(
  residual_summary_by_country_specialization,
  "output/tables/residual_summary_by_country_specialization.csv"
)

# bottom 5% residuals = largest overpredictions
severe_cutoff <- quantile(residual_data$residual, 0.05, na.rm = TRUE)

largest_overpredictions <- residual_data %>%
  arrange(residual) %>%
  slice_head(n = 100) %>%
  select(
    salary,
    fitted,
    residual,
    studentized_residual,
    country,
    college_tier,
    specialization,
    industry,
    hit_cap
  )

write_csv(
  largest_overpredictions,
  "output/tables/largest_overpredictions.csv"
)

severe_overprediction_by_country <- residual_data %>%
  mutate(severe_overprediction = residual <= severe_cutoff) %>%
  group_by(country) %>%
  summarise(
    n = n(),
    severe_count = sum(severe_overprediction, na.rm = TRUE),
    within_country_severe_rate = 100 * mean(severe_overprediction, na.rm = TRUE),
    share_of_all_severe_overpredictions =
      100 * severe_count / sum(residual_data$residual <= severe_cutoff, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    across(
      c(within_country_severe_rate, share_of_all_severe_overpredictions),
      ~ round(.x, 2)
    )
  ) %>%
  arrange(desc(share_of_all_severe_overpredictions))

write_csv(
  severe_overprediction_by_country,
  "output/tables/severe_overprediction_by_country.csv"
)

severe_overprediction_by_country_specialization <- residual_data %>%
  mutate(severe_overprediction = residual <= severe_cutoff) %>%
  group_by(country, specialization) %>%
  summarise(
    n = n(),
    severe_count = sum(severe_overprediction, na.rm = TRUE),
    within_group_severe_rate = 100 * mean(severe_overprediction, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    within_group_severe_rate = round(within_group_severe_rate, 2)
  ) %>%
  arrange(desc(within_group_severe_rate))

write_csv(
  severe_overprediction_by_country_specialization,
  "output/tables/severe_overprediction_by_country_specialization.csv"
)

theme_project <- function(base_size = 13) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold"),
      axis.title = element_text(face = "bold"),
      strip.text = element_text(face = "bold"),
      legend.title = element_text(face = "bold"),
      panel.grid.minor = element_blank()
    )
}

tier_colors <- c(
  "Tier 1" = "#F8766D",
  "Tier 2" = "#00BA38",
  "Tier 3" = "#619CFF"
)

zero_line_color <- "gray20"

# country facets show subgroup residual patterns
p1 <- ggplot(residual_data, aes(x = fitted, y = residual)) +
  geom_hline(
    yintercept = 0,
    linetype = "dashed",
    color = zero_line_color,
    linewidth = 0.7
  ) +
  geom_point(alpha = 0.25, size = 0.8, color = "gray35") +
  geom_smooth(se = FALSE, color = "#0072B2", linewidth = 0.9) +
  facet_wrap(~ country, ncol = 3) +
  scale_x_continuous(labels = label_comma()) +
  scale_y_continuous(labels = label_comma()) +
  labs(
    title = "Residuals vs Fitted by Country",
    x = "Fitted Salary",
    y = "Residual"
  ) +
  theme_project()

ggsave(
  "output/figures/residuals_vs_fitted_by_country.png",
  p1,
  width = 12,
  height = 7,
  dpi = 300
)

country_order <- residual_summary_by_country %>%
  arrange(median_residual) %>%
  pull(country)

country_order <- residual_summary_by_country %>%
  arrange(median_residual) %>%
  pull(country)

p2 <- residual_data %>%
  mutate(country = factor(country, levels = country_order)) %>%
  ggplot(aes(x = country, y = residual)) +
  geom_hline(
    yintercept = 0,
    linetype = "dashed",
    color = zero_line_color,
    linewidth = 0.7
  ) +
  geom_boxplot(
    fill = "#56B4E9",
    color = "gray25",
    alpha = 0.85,
    outlier.alpha = 0.35
  ) +
  scale_y_continuous(labels = label_comma()) +
  labs(
    title = "Residual Distribution by Country",
    x = "Country",
    y = "Residual"
  ) +
  theme_project()

ggsave(
  "output/figures/residuals_by_country_boxplot.png",
  p2,
  width = 10,
  height = 6,
  dpi = 300
)

india_data <- residual_data %>%
  filter(country == "India")

p3 <- ggplot(india_data, aes(x = fitted, y = residual, color = college_tier)) +
  geom_hline(
    yintercept = 0,
    linetype = "dashed",
    color = zero_line_color,
    linewidth = 0.7
  ) +
  geom_point(alpha = 0.55, size = 1.35) +
  geom_smooth(se = FALSE, linewidth = 0.9) +
  scale_color_manual(values = tier_colors) +
  scale_x_continuous(labels = label_comma()) +
  scale_y_continuous(labels = label_comma()) +
  labs(
    title = "India: Residuals vs Fitted",
    x = "Fitted Salary",
    y = "Residual",
    color = "College Tier"
  ) +
  theme_project()

ggsave(
  "output/figures/india_residuals_vs_fitted.png",
  p3,
  width = 10,
  height = 6,
  dpi = 300
)

p4 <- ggplot(india_data, aes(x = college_tier, y = residual, fill = college_tier)) +
  geom_hline(
    yintercept = 0,
    linetype = "dashed",
    color = zero_line_color,
    linewidth = 0.7
  ) +
  geom_boxplot(alpha = 0.85, outlier.alpha = 0.4, color = "gray25") +
  scale_fill_manual(values = tier_colors) +
  scale_y_continuous(labels = label_comma()) +
  labs(
    title = "India: Residuals by College Tier",
    x = "College Tier",
    y = "Residual",
    fill = "College Tier"
  ) +
  theme_project() +
  theme(legend.position = "none")

ggsave(
  "output/figures/india_residuals_by_tier.png",
  p4,
  width = 10,
  height = 6,
  dpi = 300
)
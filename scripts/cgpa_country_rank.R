library(tidyverse)

df <- read_csv("data/placed_salary_data.csv", show_col_types = FALSE) %>%
  mutate(
    country                 = factor(country),
    university_ranking_band = factor(
      university_ranking_band,
      levels = c("Top 100", "100-300", "300+")  # logical order top to bottom
    )
  )

dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)

ggplot(df, aes(x = cgpa, y = salary, color = country)) +
  geom_point(alpha = 0.4, size = 1.2) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 0.8) +
  scale_color_brewer(palette = "Set1") +
  scale_y_continuous(labels = scales::comma) +
  facet_wrap(~ university_ranking_band, ncol = 1) +
  labs(
    title    = "CGPA vs Salary by Country and University Ranking Band",
    subtitle = "Trend lines show linear relationship within each country, split by ranking band",
    x        = "CGPA",
    y        = "Salary",
    color    = "Country"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title    = element_text(face = "bold"),
    legend.position = "right",
    strip.text    = element_text(face = "bold", size = 12)
  )

ggsave("output/figures/cgpa_vs_salary_by_country_and_rank.png", width = 10, height = 12, dpi = 150)
cat("Plot saved to output/figures/cgpa_vs_salary_by_country_and_rank.png\n")
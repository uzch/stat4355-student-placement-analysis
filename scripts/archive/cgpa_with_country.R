library(tidyverse)

df <- read_csv("data/placed_salary_data.csv", show_col_types = FALSE) %>%
  mutate(country = factor(country))

dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)

ggplot(df, aes(x = cgpa, y = salary, color = country)) +
  geom_point(alpha = 0.4, size = 1.5) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 0.8) +
  scale_color_brewer(palette = "Set1") +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title    = "CGPA vs Salary by Country",
    subtitle = "Each trend line shows the linear relationship within each country",
    x        = "CGPA",
    y        = "Salary",
    color    = "Country"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title    = element_text(face = "bold"),
    legend.position = "right"
  )

ggsave("output/figures/cgpa_vs_salary_by_country.png", width = 10, height = 6, dpi = 150)
cat("Plot saved to output/figures/cgpa_vs_salary_by_country.png\n")
library(tidyverse)

df <- read_csv("data/placed_salary_data.csv", show_col_types = FALSE)

df <- df %>%
  mutate(
    college_tier = factor(college_tier),
    country = factor(country),
    university_ranking_band = factor(university_ranking_band),
    specialization = factor(specialization),
    industry = factor(industry)
  )

dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)

# salary distribution
ggplot(df, aes(x = salary)) +
  geom_histogram(bins = 30) +
  labs(title = "Salary Distribution", x = "Salary", y = "Count") +
  theme_minimal()

ggsave("output/figures/salary_histogram.png", width = 8, height = 5)

ggplot(df, aes(y = salary)) +
  geom_boxplot() +
  labs(title = "Salary Boxplot", y = "Salary") +
  theme_minimal()

ggsave("output/figures/salary_boxplot.png", width = 6, height = 5)

# scatterplots for numeric predictors
p1 <- ggplot(df, aes(cgpa, salary)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = FALSE) +
  theme_minimal()

p2 <- ggplot(df, aes(backlogs, salary)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = FALSE) +
  theme_minimal()

p3 <- ggplot(df, aes(internship_count, salary)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = FALSE) +
  theme_minimal()

p4 <- ggplot(df, aes(aptitude_score, salary)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = FALSE) +
  theme_minimal()

p5 <- ggplot(df, aes(communication_score, salary)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = FALSE) +
  theme_minimal()

p6 <- ggplot(df, aes(internship_quality_score, salary)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = FALSE) +
  theme_minimal()

ggsave("output/figures/salary_vs_cgpa.png", p1, width = 7, height = 5)
ggsave("output/figures/salary_vs_backlogs.png", p2, width = 7, height = 5)
ggsave("output/figures/salary_vs_internship_count.png", p3, width = 7, height = 5)
ggsave("output/figures/salary_vs_aptitude_score.png", p4, width = 7, height = 5)
ggsave("output/figures/salary_vs_communication_score.png", p5, width = 7, height = 5)
ggsave("output/figures/salary_vs_internship_quality_score.png", p6, width = 7, height = 5)

# boxplots for categorical predictors
b1 <- ggplot(df, aes(college_tier, salary)) +
  geom_boxplot() +
  theme_minimal()

b2 <- ggplot(df, aes(country, salary)) +
  geom_boxplot() +
  theme_minimal()

b3 <- ggplot(df, aes(university_ranking_band, salary)) +
  geom_boxplot() +
  theme_minimal()

b4 <- ggplot(df, aes(specialization, salary)) +
  geom_boxplot() +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))

b5 <- ggplot(df, aes(industry, salary)) +
  geom_boxplot() +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))

ggsave("output/figures/salary_by_college_tier.png", b1, width = 7, height = 5)
ggsave("output/figures/salary_by_country.png", b2, width = 7, height = 5)
ggsave("output/figures/salary_by_university_ranking_band.png", b3, width = 7, height = 5)
ggsave("output/figures/salary_by_specialization.png", b4, width = 8, height = 5)
ggsave("output/figures/salary_by_industry.png", b5, width = 8, height = 5)

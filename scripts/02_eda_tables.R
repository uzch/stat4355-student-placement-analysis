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

dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)

# summary stats for numeric variables
num_summary <- df %>%
  select(salary, cgpa, backlogs, internship_count,
         aptitude_score, communication_score, internship_quality_score) %>%
  summarise(across(
    everything(),
    list(
      mean = ~mean(.),
      sd = ~sd(.),
      min = ~min(.),
      q1 = ~quantile(., 0.25),
      median = ~median(.),
      q3 = ~quantile(., 0.75),
      max = ~max(.)
    )
  ))

write_csv(num_summary, "output/tables/numeric_summary.csv")

# frequency tables for categorical variables
college_tab <- df %>% count(college_tier)
country_tab <- df %>% count(country)
ranking_tab <- df %>% count(university_ranking_band)
spec_tab <- df %>% count(specialization)
industry_tab <- df %>% count(industry)

write_csv(college_tab, "output/tables/college_tier_counts.csv")
write_csv(country_tab, "output/tables/country_counts.csv")
write_csv(ranking_tab, "output/tables/university_ranking_band_counts.csv")
write_csv(spec_tab, "output/tables/specialization_counts.csv")
write_csv(industry_tab, "output/tables/industry_counts.csv")

# correlation matrix for numeric variables
cor_mat <- df %>%
  select(salary, cgpa, backlogs, internship_count,
         aptitude_score, communication_score, internship_quality_score) %>%
  cor()

write.csv(cor_mat, "output/tables/correlation_matrix.csv")

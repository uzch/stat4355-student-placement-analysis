# ============================================================
# clean_data_prep.R
# Purpose:
#   - Read raw CSV
#   - Validate expected schema
#   - Perform project-scope cleaning
#   - Create placed-students-only analysis dataset
#   - Save audit-style cleaning outputs
# ============================================================

# Make sure to double-check your current working directory
# getwd()
# setwd("")

if (!require("tidyverse", quietly = TRUE)) {
  install.packages("tidyverse")
}

library(tidyverse)

# Paths to store files
dir.create("data", showWarnings = FALSE, recursive = TRUE)
dir.create("output", showWarnings = FALSE, recursive = TRUE)
dir.create("output/tables", showWarnings = FALSE, recursive = TRUE)

# Raw dataset
raw_path <- "data/global_placement.csv"

if (!file.exists(raw_path)) {
  stop("Raw data file not found at: ", raw_path)
}

raw_df <- read_csv(raw_path, show_col_types = FALSE)


expected_cols <- c(
  "cgpa",
  "backlogs",
  "college_tier",
  "country",
  "university_ranking_band",
  "internship_count",
  "aptitude_score",
  "communication_score",
  "specialization",
  "industry",
  "internship_quality_score",
  "placement_status",
  "salary"
)

missing_cols <- setdiff(expected_cols, names(raw_df))
extra_cols   <- setdiff(names(raw_df), expected_cols)

if (length(missing_cols) > 0) {
  stop("Missing expected columns: ", paste(missing_cols, collapse = ", "))
}

if (length(extra_cols) > 0) {
  message("Extra columns detected and retained: ", paste(extra_cols, collapse = ", "))
}

# Reorder to expected layout for consistency
raw_df <- raw_df %>% select(all_of(expected_cols), everything())

# Standardization
# trim character whitespace, normalize explicit factor levels,
# and enforce numeric/integer types where appropriate.

clean_df <- raw_df %>%
  mutate(
    across(where(is.character), ~str_squish(.x)),
    cgpa = as.numeric(cgpa),
    backlogs = as.integer(backlogs),
    internship_count = as.integer(internship_count),
    aptitude_score = as.numeric(aptitude_score),
    communication_score = as.numeric(communication_score),
    internship_quality_score = as.numeric(internship_quality_score),
    salary = as.numeric(salary),
    college_tier = factor(college_tier, levels = c("Tier 1", "Tier 2", "Tier 3")),
    country = factor(country, levels = c("Canada", "Germany", "India", "UK", "USA")),
    university_ranking_band = factor(
      university_ranking_band,
      levels = c("Top 100", "100-300", "300+")
    ),
    specialization = factor(
      specialization,
      levels = c("AI/ML", "Cloud", "Core CS", "Cybersecurity", "Data Science")
    ),
    industry = factor(
      industry,
      levels = c("Consulting", "Finance", "Healthcare", "Manufacturing", "Other", "Tech")
    ),
    placement_status = factor(
      placement_status,
      levels = c("Placed", "Not Placed")
    )
  )

# Data-quality audit
na_count_total <- sum(is.na(clean_df))
dup_count <- sum(duplicated(clean_df))

quality_summary <- tibble(
  metric = c(
    "n_rows_raw",
    "n_cols_raw",
    "total_missing_values",
    "duplicate_rows",
    "placed_rows",
    "not_placed_rows"
  ),
  value = c(
    nrow(clean_df),
    ncol(clean_df),
    na_count_total,
    dup_count,
    sum(clean_df$placement_status == "Placed", na.rm = TRUE),
    sum(clean_df$placement_status == "Not Placed", na.rm = TRUE)
  )
)

write_csv(quality_summary, "output/tables/data_quality_summary.csv")

missing_by_col <- tibble(
  variable = names(clean_df),
  missing_n = sapply(clean_df, function(x) sum(is.na(x))),
  missing_pct = round(100 * missing_n / nrow(clean_df), 3)
)

write_csv(missing_by_col, "output/tables/missing_by_variable.csv")


# Proposal logic:
# - salary regression will be run on placed students only
# - placement_status should not be used in salary modeling after filtering

salary_by_status <- clean_df %>%
  group_by(placement_status) %>%
  summarise(
    n = n(),
    min_salary = min(salary, na.rm = TRUE),
    max_salary = max(salary, na.rm = TRUE),
    mean_salary = mean(salary, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(salary_by_status, "output/tables/salary_by_placement_status.csv")

# Create analysis dataset
analysis_df <- clean_df %>%
  filter(placement_status == "Placed") %>%
  select(-placement_status)

# Additional checks
range_checks <- tibble(
  variable = c(
    "cgpa", "backlogs", "internship_count",
    "aptitude_score", "communication_score",
    "internship_quality_score", "salary"
  ),
  min_value = c(
    min(analysis_df$cgpa, na.rm = TRUE),
    min(analysis_df$backlogs, na.rm = TRUE),
    min(analysis_df$internship_count, na.rm = TRUE),
    min(analysis_df$aptitude_score, na.rm = TRUE),
    min(analysis_df$communication_score, na.rm = TRUE),
    min(analysis_df$internship_quality_score, na.rm = TRUE),
    min(analysis_df$salary, na.rm = TRUE)
  ),
  max_value = c(
    max(analysis_df$cgpa, na.rm = TRUE),
    max(analysis_df$backlogs, na.rm = TRUE),
    max(analysis_df$internship_count, na.rm = TRUE),
    max(analysis_df$aptitude_score, na.rm = TRUE),
    max(analysis_df$communication_score, na.rm = TRUE),
    max(analysis_df$internship_quality_score, na.rm = TRUE),
    max(analysis_df$salary, na.rm = TRUE)
  )
)

write_csv(range_checks, "output/tables/placed_data_range_checks.csv")

# Save cleaned datas
write_csv(clean_df, "data/global_placement_clean.csv")
write_csv(analysis_df, "data/placed_salary_data.csv")

message("Cleaning complete.")
message("- Clean full dataset saved to: data/global_placement_clean.csv")
message("- Placed-only analysis dataset saved to: data/placed_salary_data.csv")
message("- Audit tables saved to: output/tables/")

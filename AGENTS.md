# STAT 4355 Student Placement Salary Analysis

A reproducible applied linear modeling project that analyzes salary outcomes among placed students using the Global Student Placement & Salary Dataset.

This repository supports the full project workflow for **STAT 4355 Applied Linear Models**, including data preparation, exploratory data analysis, simple regression screening, multiple regression modeling, model selection, diagnostics, and final presentation/report deliverables.

## Project Overview

The goal of this project is to identify which student-related factors are most associated with salary after job placement.

The analysis focuses on students who received placements, allowing the regression model to explain variation in salary level rather than simply distinguishing between placed and unplaced students.

## Research Question

**Which academic, experiential, and background factors best explain salary among students who received job placements?**

## Dataset

**Source:** Kaggle  
**Dataset:** Global Student Placement & Salary Dataset  
**Access:** Public Kaggle dataset

### Original Data

- 10,000 observations
- 13 variables
- Includes placement status and salary outcomes

### Modeling Data

- 6,153 observations
- Placed students only
- `placement_status` removed before modeling
- `salary` used as the continuous response variable

## Modeling Decision

The regression analysis uses only students with job placements.

This is necessary because all unplaced students have salary equal to zero. Including those observations would cause the model to partially predict placement status rather than salary differences among placed students.

For this reason:

- use `data/placed_salary_data.csv` for modeling;
- do not use `placement_status` as a predictor;
- interpret results as salary modeling among placed students only.

## Repository Structure

```text
.
├── data/
│   ├── global_placement.csv
│   ├── global_placement_clean.csv
│   └── placed_salary_data.csv
├── scripts/
│   ├── 01_clean_data.R
│   ├── 02_eda_tables.R
│   └── 03_eda_plots.R
├── output/
│   ├── figures/
│   └── tables/
├── report/
├── slides/
└── README.md
```

## Data Files

| File | Description |
|---|---|
| `data/global_placement.csv` | Original Kaggle dataset |
| `data/global_placement_clean.csv` | Cleaned full dataset after type formatting and validation |
| `data/placed_salary_data.csv` | Placed-students-only dataset used for regression analysis |

## Current Scripts

| Script | Purpose |
|---|---|
| `scripts/01_clean_data.R` | Reads the raw dataset, validates structure, creates cleaned full data and placed-only analysis data |
| `scripts/02_eda_tables.R` | Creates exploratory summary tables, frequency tables, and correlation output |
| `scripts/03_eda_plots.R` | Creates exploratory figures for salary distribution and predictor relationships |

## Current Outputs

### Tables

Expected files in `output/tables/`:

```text
data_quality_summary.csv
missing_by_variable.csv
salary_by_placement_status.csv
placed_data_range_checks.csv
numeric_summary.csv
college_tier_counts.csv
country_counts.csv
university_ranking_band_counts.csv
specialization_counts.csv
industry_counts.csv
correlation_matrix.csv
```

### Figures

Expected files in `output/figures/`:

```text
salary_histogram.png
salary_boxplot.png
salary_vs_cgpa.png
salary_vs_backlogs.png
salary_vs_internship_count.png
salary_vs_aptitude_score.png
salary_vs_communication_score.png
salary_vs_internship_quality_score.png
salary_by_college_tier.png
salary_by_country.png
salary_by_university_ranking_band.png
salary_by_specialization.png
salary_by_industry.png
```

## Variables

### Response Variable

| Variable | Type | Description |
|---|---|---|
| `salary` | Continuous | Salary recorded for each placed student |

### Numeric Predictors

| Variable | Type | Description |
|---|---|---|
| `cgpa` | Continuous | Cumulative grade point average |
| `backlogs` | Discrete | Number of academic backlogs |
| `internship_count` | Discrete | Number of internships completed |
| `aptitude_score` | Continuous | Aptitude assessment score |
| `communication_score` | Continuous | Communication skills score |
| `internship_quality_score` | Continuous | Internship quality score |

### Categorical Predictors

| Variable | Type | Description |
|---|---|---|
| `college_tier` | Categorical | College tier classification |
| `country` | Categorical | Country associated with the student |
| `university_ranking_band` | Categorical | University ranking band |
| `specialization` | Categorical | Academic specialization |
| `industry` | Categorical | Placement industry |

## Analysis Workflow

The planned modeling workflow is:

1. Prepare cleaned placed-only analysis dataset.
2. Generate exploratory summary tables and figures.
3. Run simple regression screening for each predictor.
4. Fit the full multiple linear regression model.
5. Perform stepwise AIC model selection.
6. Compare candidate models using AIC and adjusted R-squared.
7. Check multicollinearity using VIF.
8. Perform residual diagnostics.
9. Evaluate whether transformation is needed.
10. Check influential observations.
11. Select and interpret the final model.
12. Export final tables and figures for the presentation and report.

## Remaining Analysis Tasks

The following scripts still need to be completed:

| Script | Purpose |
|---|---|
| `scripts/simple_regression_screening.R` | Run one simple regression per predictor and save a compact screening table |
| `scripts/model_selection.R` | Fit full model, run stepwise AIC, compare models, calculate VIF, and save final model tables |
| `scripts/model_diagnostics.R` | Generate residual diagnostics, transformation checks, and influence analysis outputs |

## Expected Future Outputs

### Model Selection Tables

```text
output/tables/simple_regression_summary.csv
output/tables/full_model_summary.csv
output/tables/model_comparison.csv
output/tables/final_model_coefficients.csv
output/tables/vif_selected_model.csv
```

### Diagnostic Figures and Tables

```text
output/figures/residuals_vs_fitted.png
output/figures/qq_plot.png
output/figures/residual_histogram.png
output/figures/cooks_distance.png
output/figures/leverage_plot.png
output/tables/influence_summary.csv
```

## Modeling Notes

Important modeling considerations:

- `placement_status` must not be used in the salary model.
- Simple regressions are used for screening, not final model selection.
- Categorical predictors should be evaluated at the model level, not treated as single-coefficient variables.
- Very small p-values should be formatted as `<0.001`, not displayed as `0`.
- Stepwise AIC should be supported by adjusted R-squared, VIF, diagnostics, and interpretability.
- The salary variable has a visible cap at 120,000, which should be discussed as a limitation and checked during diagnostics.

## Presentation Plan

The presentation has an 8-minute hard cutoff. The main deck should use no more than 7 slides:

1. Title and research question
2. Dataset and cleaning decision
3. Variables used
4. Exploratory data analysis
5. Simple regression screening
6. Full model and model selection
7. Diagnostics and conclusion

Backup slides may include:

- full variable definitions;
- full simple regression table;
- final model coefficient table;
- additional diagnostic plots;
- influence analysis details.

## Report Plan

The final report should include:

1. Introduction
2. Data description
3. Data cleaning
4. Exploratory data analysis
5. Simple regression screening
6. Full model and model selection
7. Final model interpretation
8. Residual diagnostics
9. Transformation discussion
10. Influence analysis
11. Limitations
12. Conclusion
13. Reflective process
14. Appendix with team roles, R scripts, and references

## Collaboration Guidelines

- Work from the current branch unless instructed otherwise.
- Keep scripts focused on one responsibility.
- Save tables to `output/tables/`.
- Save figures to `output/figures/`.
- Do not overwrite cleaned datasets unless intentionally updating the data-preparation step.
- Do not add unrelated files or screenshots of R output.
- Prefer reproducible scripts over manual changes.
- Keep commits focused and descriptive.

## R Environment

This project uses R/RStudio.

Common packages may include:

```r
tidyverse
ggplot2
MASS
car
broom
```

Install packages locally as needed, but avoid placing unnecessary package installation commands inside analysis scripts unless required for class reproducibility.

## Suggested Codex Tasks

When using Codex or another coding assistant, use narrow, file-specific tasks.

Good task examples:

```text
Read README.md and the current branch only. Do not modify files yet. Summarize the current repository structure and list the exact scripts and outputs still needed.
```

```text
Create scripts/simple_regression_screening.R using data/placed_salary_data.csv. Save output/tables/simple_regression_summary.csv. Do not modify existing cleaning or EDA scripts.
```

```text
Create scripts/model_selection.R. Fit the full salary model, run stepwise AIC, compare full and selected models using AIC and adjusted R-squared, run VIF, and save outputs to output/tables/. Do not modify existing cleaning or EDA scripts.
```

```text
Create scripts/model_diagnostics.R. Generate residual diagnostics, transformation checks, and influence analysis outputs for the selected model. Save figures to output/figures/ and tables to output/tables/.
```

## Project Standard

A strong final project should demonstrate a complete applied linear modeling workflow:

- clear research question;
- justified data cleaning decision;
- useful exploratory analysis;
- simple regression screening;
- full multiple regression model;
- reasonable variable selection;
- residual diagnostics;
- transformation discussion if needed;
- influential observation checks;
- honest limitations;
- clear conclusion.

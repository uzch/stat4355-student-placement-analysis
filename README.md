# STAT 4355 Student Placement Salary Analysis

A reproducible applied linear modeling project that analyzes salary outcomes among placed students using the Global Student Placement & Salary Dataset.

This repository supports the full **STAT 4355 Applied Linear Models** project workflow: data preparation, exploratory data analysis, simple regression screening, multiple regression modeling, model selection, diagnostics, final coefficient summaries, and presentation/report deliverables.

## Project Overview

The goal of this project is to identify which student-related factors are most associated with salary after job placement.

The analysis focuses on students who received placements. This keeps the regression model focused on explaining salary variation among placed students rather than mixing salary modeling with placement-status prediction.

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
├── output/
│   ├── figures/
│   └── tables/
├── report/
├── scripts/
│   ├── 01_clean_data.R
│   ├── 02_eda_tables.R
│   ├── 03_eda_plots.R
│   ├── 04_simple_regression_screening.R
│   ├── 05_model_selection.R
│   ├── 06_model_diagnostics.R
│   ├── 07_residual_analysis.R
│   ├── 08_subgroup_residual_checks.R
│   ├── 09_final_model_coefficients.R
│   └── archive/
├── slides/
│   └── presentation_skeleton.md
├── .gitignore
└── README.md
```

## Data Files

| File | Description |
|---|---|
| `data/global_placement.csv` | Original Kaggle dataset. |
| `data/global_placement_clean.csv` | Cleaned full dataset after type formatting and validation. |
| `data/placed_salary_data.csv` | Placed-students-only dataset used for regression analysis. |

## Variables

### Response Variable

| Variable | Type | Description |
|---|---|---|
| `salary` | Continuous | Salary recorded for each placed student. |

### Numeric Predictors

| Variable | Type | Description |
|---|---|---|
| `cgpa` | Continuous | Cumulative grade point average. |
| `backlogs` | Discrete | Number of academic backlogs. |
| `internship_count` | Discrete | Number of internships completed. |
| `aptitude_score` | Continuous | Aptitude assessment score. |
| `communication_score` | Continuous | Communication skills score. |
| `internship_quality_score` | Continuous | Internship quality score. |

### Categorical Predictors

| Variable | Type | Description |
|---|---|---|
| `college_tier` | Categorical | College tier classification. |
| `country` | Categorical | Country associated with the student. |
| `university_ranking_band` | Categorical | University ranking band. |
| `specialization` | Categorical | Academic specialization. |
| `industry` | Categorical | Placement industry. |

## Analysis Workflow

Run scripts from the repository root in numeric order.

| Step | Script | Purpose | Main outputs |
|---|---|---|---|
| 1 | `scripts/01_clean_data.R` | Validate raw data, standardize fields, create full cleaned and placed-only analysis datasets, and write audit tables. | `data/global_placement_clean.csv`, `data/placed_salary_data.csv`, `output/tables/data_quality_summary.csv`, `output/tables/missing_by_variable.csv`, `output/tables/salary_by_placement_status.csv`, `output/tables/placed_data_range_checks.csv` |
| 2 | `scripts/02_eda_tables.R` | Create numeric summaries, categorical frequency tables, and a correlation matrix. | `output/tables/numeric_summary.csv`, category count CSVs, `output/tables/correlation_matrix.csv` |
| 3 | `scripts/03_eda_plots.R` | Create salary distribution plots, numeric predictor scatterplots, and categorical salary boxplots. | `output/figures/salary_histogram.png`, `output/figures/salary_boxplot.png`, salary-by-predictor figures |
| 4 | `scripts/04_simple_regression_screening.R` | Screen each predictor with simple regression models. | `output/tables/simple_regression_summary.csv` |
| 5 | `scripts/05_model_selection.R` | Fit the full multiple regression model, run stepwise AIC selection, compare models, and export VIF results. | `output/tables/full_model_summary.csv`, `output/tables/model_comparison.csv`, `output/tables/final_model_coefficients.csv`, `output/tables/vif_selected_model.csv` |
| 6 | `scripts/06_model_diagnostics.R` | Evaluate transformations, influence, residual diagnostics, and prediction summaries for diagnostic/final model review. | `output/tables/diagnostics_summary.csv`, `output/tables/transformation_summary.csv`, `output/tables/influence_summary.csv`, diagnostic figures |
| 7 | `scripts/07_residual_analysis.R` | Compare OLS and Tobit residual behavior for base and interaction models. | `output/figures/resid_all_models.png`, `output/tables/coef_comparison_all_models.csv`, `output/tables/model_fit_summary.csv` |
| 8 | `scripts/08_subgroup_residual_checks.R` | Investigate residual patterns by country, college tier, specialization, and interaction subgroups. | subgroup residual tables and figures in `output/tables/` and `output/figures/` |
| 9 | `scripts/09_final_model_coefficients.R` | Export final model fit summary, final coefficient tables, interpretable numeric effects, predicted salary tables, and final diagnostics. | `output/tables/final_model_fit_summary.csv`, `output/tables/final_model_coefficients_clean.csv`, `output/tables/final_model_coefficients_slide.csv`, `output/tables/final_model_numeric_effects.csv`, `output/figures/final_model_residual_diagnostics.png` |

### Archived Scripts

Exploratory or superseded scripts live in `scripts/archive/`. These files are retained for project history and visual experimentation, but they are not part of the canonical numeric workflow.

## Final Model

The final reporting script fits an OLS model with numeric academic predictors, country-sensitive college-tier effects, country-sensitive specialization effects, university ranking band, and industry:

```r
salary ~ cgpa + aptitude_score + college_tier * country +
  country * specialization + university_ranking_band + industry
```

Use the final model outputs in `output/tables/final_model_fit_summary.csv`, `output/tables/final_model_coefficients_clean.csv`, `output/tables/final_model_coefficients_slide.csv`, and `output/tables/final_model_numeric_effects.csv` for the report and slides.

## Output Artifact Policy

The `output/` directory is intentionally tracked because this course project needs reviewable tables and figures without requiring every reader to rerun the full R workflow.

- `output/tables/` contains generated CSV summaries, model comparisons, diagnostic summaries, coefficient tables, and prediction tables.
- `output/figures/` contains generated PNG figures for exploratory analysis, diagnostics, residual investigations, and presentation/report visuals.
- If a script is changed in a way that affects results, rerun the relevant workflow step and commit the updated output artifacts with the script change.
- Do not manually edit generated CSV or PNG outputs. Update the responsible script and regenerate the artifact instead.
- Keep large unrelated local files, screenshots, and scratch exports out of the repository.

## Key Deliverables

| Deliverable | Location |
|---|---|
| Cleaned full dataset | `data/global_placement_clean.csv` |
| Placed-only modeling dataset | `data/placed_salary_data.csv` |
| Final model fit summary | `output/tables/final_model_fit_summary.csv` |
| Final model coefficients | `output/tables/final_model_coefficients_clean.csv` |
| Slide-ready coefficient table | `output/tables/final_model_coefficients_slide.csv` |
| Numeric effect interpretations | `output/tables/final_model_numeric_effects.csv` |
| Final residual diagnostics | `output/figures/final_model_residual_diagnostics.png` |
| Presentation outline | `slides/presentation_skeleton.md` |
| Report directory | `report/` |

## Modeling Notes

Important modeling considerations:

- `placement_status` must not be used in the salary model.
- Simple regressions are used for screening, not final model selection.
- Categorical predictors should be evaluated at the model level, not treated as single-coefficient variables.
- Very small p-values should be formatted as `<0.001` or with scientific notation, not displayed as `0`.
- Stepwise AIC should be supported by adjusted R-squared, VIF, diagnostics, and interpretability.
- The salary variable has a visible cap at 120,000, which should be discussed as a limitation and checked during diagnostics.
- The final model includes interaction terms because residual and subgroup checks suggested that country changes the interpretation of college tier and specialization.

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
- Run scripts from the repository root so relative paths resolve correctly.
- Keep scripts focused on one responsibility.
- Keep the numbered scripts as the canonical workflow and place exploratory/superseded work in `scripts/archive/`.
- Save tables to `output/tables/`.
- Save figures to `output/figures/`.
- Do not overwrite cleaned datasets unless intentionally updating `scripts/01_clean_data.R`.
- Do not add unrelated files or screenshots of R output.
- Prefer reproducible scripts over manual changes.
- Keep commits focused and descriptive.

## R Environment

This project uses R. RStudio project files are not tracked so the repository remains editor-agnostic. If you use RStudio, create a local `.Rproj` file as needed; `.gitignore` excludes it.

Common packages may include:

```r
tidyverse
ggplot2
MASS
car
broom
AER
patchwork
scales
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

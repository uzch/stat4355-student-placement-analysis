# STAT 4355 Presentation Skeleton  
## Student Placement Salary Analysis  
### 8-Minute Hard Cutoff Version

**Purpose of this file:**  
This is a working skeleton for the presentation deck. The goal is to create the slide structure now, then add final model results, diagnostic plots, and conclusions once the remaining analysis is finished.

**Presentation rule:**  
Use **7 main slides maximum**. Backup slides can be created but should not be presented unless asked during Q&A.

---

## Slide 1 — Title + Research Question  
**Target time:** 0:00–0:40

### Slide title
**Student Placement Salary Analysis**

### Slide content
- STAT 4355 Applied Linear Models
- Group 3: Uzayr Chaudhry, Nafisa Aurny, David Mwaria, Ruth Picazo
- Dataset: Global Student Placement & Salary Dataset
- Research question:  
  **Which student-related factors best explain salary among students who received job placements?**

### Speaker notes
Introduce the project quickly. State that the goal is to model salary among placed students using academic, experiential, and background variables.

### Visual suggestion
Simple title slide. No dense content.

---

## Slide 2 — Dataset + Cleaning Decision  
**Target time:** 0:40–1:40

### Slide title
**Dataset and Cleaning Approach**

### Slide content
- Source: Kaggle
- Original dataset: **10,000 observations, 13 variables**
- Modeling dataset: **6,153 placed students**
- Removed `placement_status` from modeling data
- No missing values / no duplicates in cleaned analysis dataset

### Key explanation
We restricted the analysis to placed students because all unplaced students have salary equal to 0. Including them would make the regression model partly predict whether a student was placed rather than explaining salary differences among placed students.

### Speaker notes
Emphasize that this was an intentional modeling decision, not arbitrary filtering.

### Visual suggestion
Small flow diagram:

`Original data -> filter placed students -> remove placement_status -> salary regression dataset`

---

## Slide 3 — Variables Used in the Model  
**Target time:** 1:40–2:25

### Slide title
**Response and Predictor Variables**

### Slide content
Use a table like this:

| Response Variable | Numeric Predictors | Categorical Predictors |
|---|---|---|
| `salary` | `cgpa`, `backlogs`, `internship_count`, `aptitude_score`, `communication_score`, `internship_quality_score` | `college_tier`, `country`, `university_ranking_band`, `specialization`, `industry` |

### Speaker notes
Explain that salary is continuous, so it fits the regression requirement. The predictors cover academic performance, internships, skill scores, institutional background, country, specialization, and industry.

### Visual suggestion
Clean three-column table. Do not overcrowd.

---

## Slide 4 — Exploratory Data Analysis  
**Target time:** 2:25–3:40

### Slide title
**Exploratory Data Analysis**

### Slide content
Include 2 visuals maximum:
1. Salary histogram  
2. Salary by country or salary by college tier boxplot

### Main takeaways
- Salary has a visible cap at **120,000**
- Salary differs strongly across some categorical groups
- Country and college tier appear more visually important than most individual numeric predictors
- Numeric scatterplots show weak individual linear trends

### Speaker notes
Say that EDA helped us understand the structure of the data before fitting models. The salary cap should be mentioned because it may affect residual behavior later.

### Visuals to use
- `salary_histogram.png`
- `salary_by_country.png` OR `salary_by_college_tier.png`

---

## Slide 5 — Simple Regression Screening  
**Target time:** 3:40–4:50

### Slide title
**Single-Predictor Regression Screening**

### Slide content
Create one compact summary table:

| Predictor | Type | R-squared | p-value | Main Takeaway |
|---|---|---:|---:|---|
| `cgpa` | Numeric | [insert] | [insert] | Weak alone, stronger after controls |
| `country` | Categorical | [insert] | [insert] | Strong group-level signal |
| `college_tier` | Categorical | [insert] | [insert] | Clear salary differences |
| Other predictors | Mixed | [insert] | [insert] | Lower individual explanatory power |

### Main explanation
Simple regressions were used as a screening step. They show which variables explain salary individually, but they do not determine the final model.

### Speaker notes
Important wording:
- “Simple regressions tell us what matters alone.”
- “The full model tells us what matters after controlling for other variables.”
- “A variable can look weak alone but become meaningful once categorical background variables are included.”

### Visual suggestion
Use a compact table. Avoid showing all coefficient details unless there is space.

---

## Slide 6 — Full Model and Model Selection  
**Target time:** 4:50–6:25

### Slide title
**Multiple Regression and Model Selection**

### Slide content
- Full model used all predictors except `placement_status`
- Stepwise AIC used to identify a candidate reduced model
- Adjusted R-squared used as a fit-versus-complexity check
- VIF used to check multicollinearity
- Final model chosen using:
  - AIC
  - adjusted R-squared
  - statistical significance
  - diagnostics
  - interpretability

### Placeholder table
| Model | Predictors Included | AIC | Adjusted R-squared | Notes |
|---|---|---:|---:|---|
| Full model | All predictors | [insert] | [insert] | Baseline comparison |
| Stepwise model | [insert] | [insert] | [insert] | Candidate final model |
| Final model | [insert] | [insert] | [insert] | Selected after diagnostics |

### Speaker notes
Explain that the full model checks how predictors behave together. Stepwise AIC helps remove variables that do not improve the model enough to justify added complexity.

### Visual suggestion
A model comparison table is better than a screenshot of R output.

---

## Slide 7 — Diagnostics, Limitations, and Conclusion  
**Target time:** 6:25–8:00

### Slide title
**Model Checking and Conclusion**

### Slide content
Split into two sections.

#### Diagnostics checked
- Residuals vs fitted values
- QQ plot
- Residuals vs key predictors
- Transformation check, such as Box-Cox or log(salary), if needed
- Influential point checks:
  - Cook’s distance
  - leverage / hat values
  - studentized residuals

#### Conclusion
- Final strongest predictors: [insert after model selection]
- Main salary drivers appear to be: [insert]
- Salary cap at 120,000 is an important limitation
- Future work could examine:
  - interaction terms
  - country-specific models
  - uncapped salary data
  - salary cap sensitivity check

### Speaker notes
This slide should show that the group did not just fit a model and stop. The rubric rewards residual analysis, model selection, and transformations if needed.

### Visual suggestion
Use one diagnostic plot if final results are ready. If not, list diagnostic checks and leave placeholders.

---

# Backup Slides  
Do not include these in the main 8-minute presentation unless needed.

---

## Backup Slide A — Full Variable Definitions

| Variable | Type | Description |
|---|---|---|
| `salary` | Continuous | Salary for placed students |
| `cgpa` | Continuous | Cumulative GPA |
| `backlogs` | Discrete | Number of academic backlogs |
| `college_tier` | Categorical | College tier classification |
| `country` | Categorical | Country associated with student |
| `university_ranking_band` | Categorical | Ranking band of university |
| `internship_count` | Discrete | Number of internships |
| `aptitude_score` | Continuous | Aptitude assessment score |
| `communication_score` | Continuous | Communication score |
| `specialization` | Categorical | Academic specialization |
| `industry` | Categorical | Placement industry |
| `internship_quality_score` | Continuous | Internship quality score |

---

## Backup Slide B — Full Simple Regression Table

Use this if asked how the screening was done.

| Predictor | Coefficient / Model Effect | p-value | R-squared | Interpretation |
|---|---:|---:|---:|---|
| [insert] | [insert] | [insert] | [insert] | [insert] |

---

## Backup Slide C — Final Model Coefficients

Use this if asked about exact model interpretation.

| Predictor | Estimate | p-value | Interpretation |
|---|---:|---:|---|
| [insert] | [insert] | [insert] | [insert] |

---

## Backup Slide D — Influence Analysis Details

Possible influential analysis criteria:
- High leverage: `h_ii > 2p/n`
- Cook’s distance: check unusually large values
- Studentized residuals: check large absolute residuals
- DFFITS / DFBETAS / COVRATIO if time allows

---

# Presentation Timing Guide

| Slide | Topic | Time |
|---|---|---:|
| 1 | Title + Research Question | 0:40 |
| 2 | Dataset + Cleaning | 1:00 |
| 3 | Variables | 0:45 |
| 4 | EDA | 1:15 |
| 5 | Simple Regression Screening | 1:10 |
| 6 | Full Model + Model Selection | 1:35 |
| 7 | Diagnostics + Conclusion | 1:35 |
| **Total** |  | **8:00** |

---

# Design Guidance

- Use one main idea per slide.
- Use figures instead of dense text where possible.
- Avoid screenshots of R output unless absolutely necessary.
- Keep detailed tables in backup slides.
- Do not exceed 7 main slides.
- Use consistent fonts, titles, and spacing.
- Make sure every figure has a clear title and readable axis labels.

---

# Current Files Likely Useful for Slides

## EDA figures
- `salary_histogram.png`
- `salary_by_country.png`
- `salary_by_college_tier.png`
- `salary_vs_cgpa.png`
- `cgpa_vs_salary_by_country.png`

## EDA/modeling tables
- simple regression numeric summary
- simple regression categorical summary
- full model summary
- final model comparison table once created

---

# Final Notes for the Person Building the Skeleton Deck

Build the deck now with placeholders. Do not wait for the final model to be complete.

The skeleton deck should already include:
- slide titles
- basic layout
- placeholder boxes for plots/tables
- speaker note prompts
- timing notes

Once final model selection and diagnostics are complete, we will replace placeholders with final tables, figures, and conclusions.

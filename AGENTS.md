# AGENTS.md

## Scope

Work only on the current branch unless told otherwise.

This is a STAT 4355 Applied Linear Models project in R.

Use `README.md` for project context.

Use `data/placed_salary_data.csv` for modeling.

Never use `placement_status` as a predictor.

Keep work inside the project scope:
- applied linear regression
- model selection
- residual diagnostics
- transformation checks if needed
- influence analysis
- presentation/report-ready outputs

## Communication Style

Use concise, technical, low-token responses.

Follow Caveman-style token discipline:
- no filler
- no long preambles
- no repeated explanations
- no motivational language
- no unnecessary caveats
- no verbose summaries
- short bullets preferred
- report only what changed, what ran, and what remains

Do not use joke/caveman wording in code, comments, tables, plots, report text, or slides.

At the end of each task, report only:
- files changed
- files created
- commands run
- issues / assumptions

## Paths

Read modeling data from:

```text
data/placed_salary_data.csv
```

Save scripts to:

```text
scripts/
```

Save tables to:

```text
output/tables/
```

Save figures to:

```text
output/figures/
```

Do not save generated outputs outside these folders unless explicitly asked.

## Do Not Modify

Do not modify existing cleaning or EDA scripts unless asked.

Do not overwrite cleaned datasets unless asked.

Do not inspect or depend on other branches unless asked.

Do not add screenshots of R output.

Do not create duplicate scripts with overlapping purpose.

Do not rename existing files unless asked.

Do not delete files unless asked.

Do not make Tobit the final model unless explicitly instructed.

## Figure Rules

Do not restore or recreate:

```text
output/figures/salary_vs_cgpa.png
```

That file is intentionally not needed.

Use this CGPA-related EDA figure instead:

```text
output/figures/cgpa_vs_salary_by_country.png
```

Use this residual comparison figure:

```text
output/figures/resid_comparison.png
```

Ignore missing-file or conflict issues involving `salary_vs_cgpa.png` unless explicitly asked.

## Plot Style

All new plots should be presentation/report ready.

Use clear, readable graphics:
- descriptive title
- readable axis labels
- readable legend title
- clean theme
- sufficient font size
- no cluttered labels
- no unreadable overlapping text
- no screenshots of plots
- save as `.png`
- use consistent dimensions

Prefer `ggplot2`.

Use `theme_minimal()` or another clean professional theme.

Use color only when it improves interpretation.

When color is useful:
- use clear contrast
- avoid excessive palettes
- keep color meaning consistent across related plots
- use colorblind-friendly palettes when practical

For plots similar to David's residual/model plots, prefer:
- readable titles
- neutral points with transparency
- strong fitted/smoothing line when useful
- dashed horizontal reference line at zero for residual plots
- comma formatting for salary axes
- side-by-side comparison plots when useful

For residual plots:
- plot fitted values on x-axis
- plot residuals or studentized residuals on y-axis
- include horizontal zero reference line
- avoid overinterpreting smoothing curves in code comments

For categorical salary plots:
- boxplots are acceptable but should be polished
- rotate x-axis labels when needed
- order categories when it improves readability
- include clear y-axis salary formatting

## R Style

Use simple readable R.

Prefer:

```r
tidyverse
ggplot2
MASS
car
broom
scales
patchwork
```

Use package loading only.

Avoid:

```r
install.packages()
large banner comments
unnecessary helper frameworks
over-engineered functions
screenshots of R output
```

Use clear names.

Comment only when explaining why.

Do not use large decorative comment blocks.

Format very small p-values as `<0.001`, not `0`.

Use reproducible scripts. Every final table or figure must be generated from code.

## Required Modeling Rules

Simple regression screening:
- numeric predictors: coefficient, p-value, R-squared, adjusted R-squared
- categorical predictors: model-level p-value, R-squared, adjusted R-squared
- save one compact summary table
- do not use simple regression results as final model selection

Model selection:
- fit full OLS model
- run stepwise AIC for candidate predictor selection
- compare full vs selected model with AIC, R-squared, and adjusted R-squared
- run VIF
- save final coefficient table
- remember: stepwise AIC is a selection method, not a model type

Diagnostics:
- residuals vs fitted
- QQ plot
- residual histogram
- Cook's distance
- leverage
- influence summary
- check transformation only if diagnostics suggest it
- discuss the 120000 salary cap if residuals show ceiling effects

Interaction model:
- compare base selected OLS model against OLS model with `college_tier * country`
- use AIC, adjusted R-squared, ANOVA, diagnostics, and interpretability
- interaction model remains OLS

Tobit:
- use only as sensitivity / salary-cap discussion unless explicitly instructed
- do not present Tobit as the main final model
- do not imply Tobit is mathematically equivalent to the OLS-selected model pipeline
- if used, state that it assumes right-censoring at 120000

## Current Key Model Context

Base selected OLS model:

```r
salary ~ cgpa + aptitude_score + college_tier + country +
  university_ranking_band + specialization + industry
```

Potential interaction OLS model:

```r
salary ~ cgpa + aptitude_score + college_tier * country +
  university_ranking_band + specialization + industry
```

Use the interaction model only if diagnostics/model comparison support it.

## Required Output Standards

Every table or figure must be reproducible from a script.

Tables should be compact and presentation/report friendly.

Figures should be clear, readable, and polished enough for slides.

Do not leave output files with misleading names.

Do not show p-values as exactly zero.

Do not use raw R console screenshots as deliverables.

## Final Task Report Format

When finished, respond in this format only:

```text
Files changed:
- ...

Files created:
- ...

Commands run:
- ...

Issues / assumptions:
- ...
```

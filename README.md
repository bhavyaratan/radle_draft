# Your Project Name

A reproducible repository for radiology AI vs. radiologist evaluations, modeled on a modern ML paper layout.
It includes **R-based analyses** for repeatability, accuracy, and mixed-effects modeling; **CSV model outputs**;
and **publication-ready figures** with CI workflows.

## Contents

```
.
├── .github/workflows/ci.yaml
├── R/
│   ├── 00_smoke_check.R
│   ├── 01_repeatability_analysis.R
│   ├── 02_accuracy_analysis.R
│   └── 03_mixed_effects_logistic_regression.R
├── configs/
│   └── experiment.yaml
├── data/
│   ├── raw/
│   └── processed/
├── docs/
├── figures/
├── manuscript/
├── models/
│   └── outputs/   # your CSVs go here (two sample CSVs included)
├── notebooks/
├── results/
└── scripts/
```

## Setup (R)

```r
install.packages("renv")
renv::init()
renv::install(c("tidyverse","readr","janitor","here","glue","yaml","lintr","rmarkdown","knitr",
                 "readxl","irr","rstatix","boot","lme4","reshape2"))
renv::snapshot()
```

## Data configuration

Edit `configs/experiment.yaml` and set the file paths to your Excel workbook(s)—these correspond to
your previously shared files:

- `repeatability.excel_path`: the workbook like **RadArena CRASH Lab Stats Repeatability.xlsx** (one sheet per model).
- `accuracy.excel_path` and `mixed.excel_path`: the sheet with **Radiologists' diagnoses (Responses)**.

Name normalization is handled with `rename_map` regexes so you can keep original column names and still get
canonical labels (e.g., `chatgpt_o3`, `claude_opus_4_1`).

## Running analyses

- **Repeatability (ICC + κ)**  
  ```r
  source("R/01_repeatability_analysis.R")
  ```

- **Accuracy (Friedman + Wilcoxon + bootstrap CIs)**  
  ```r
  source("R/02_accuracy_analysis.R")
  ```

- **Mixed-effects logistic regression**  
  ```r
  source("R/03_mixed_effects_logistic_regression.R")
  ```

Outputs:
- Combined tables: `results/`
- Figures: `figures/` (from `R/20_make_figures.R` placeholder or your own scripts)

## CSV model outputs

Drop CSVs into `models/outputs/`. I've placed the files you attached here already:
- `RadLE_LLM_Scoring.csv`
- `GPT_5_API_Latency_Results.csv`

These aren't used directly by the R scripts above unless you reference them, but they’re versioned and ready.

## Reproducibility & CI

A GitHub Actions workflow runs linting and the basic pipeline. Once your `renv.lock` is created and committed, the CI will be fast and reliable.

## Manuscript

Use `manuscript/` for your LaTeX (e.g., Springer Nature). You can symlink or copy final figures from `figures/` and tables from `results/`.

## Naming improvements

Your original scripts were renamed for clarity and to avoid spaces/special characters:
- `repeatability tests.R` → `R/01_repeatability_analysis.R`
- `accuracy analysis.R` → `R/02_accuracy_analysis.R`
- `MIXED EFFECTS LOGISTIC REGRESSION.R` → `R/03_mixed_effects_logistic_regression.R`

All code now reads paths from `configs/experiment.yaml`, and column names are normalized consistently.

---

*Last updated: 2025-09-28*
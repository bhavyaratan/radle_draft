suppressPackageStartupMessages({library(readxl);library(readr);library(dplyr);library(tidyr);library(rstatix);library(boot)})
INPUT <- Sys.getenv("ACCURACY_INPUT", "data/processed/diagnoses_anonymized.csv")
raw <- if (grepl("\\.xlsx?$", INPUT, ignore.case=TRUE)) readxl::read_excel(INPUT, sheet=1) else readr::read_csv(INPUT, show_col_types=FALSE)
names(raw) <- trimws(names(raw))

## [Patched for anonymized public data]
# --- Dynamic handling of available cohorts (radiologists/trainees may be missing) ---
existing_cols <- names(raw)
juniors <- intersect(c("A","B","C","D"), existing_cols)
seniors <- intersect(c("E","F","G","H"), existing_cols)
ai_models <- intersect(c("Gemini 2.5 Pro","ChatGPT-o3","Claude Opus 4.1","GPT-5 Thinking","Grok-4"), existing_cols)
comp_cols <- unique(c(juniors, seniors, ai_models))
if (length(comp_cols) < 2) stop("Not enough columns for comparison after anonymization.")

long <- raw %>% 
  pivot_longer(cols = all_of(comp_cols), names_to = "Rater", values_to = "Score") %>% 
  mutate(Rater = factor(Rater, levels = comp_cols))

fried_out <- friedman_test(Score ~ Rater | Case_ID, data = long)
k_w <- friedman_effsize(Score ~ Rater | Case_ID, data = long)
print(fried_out); print(k_w)

if (length(juniors)>0) raw <- raw %>% mutate(Juniors_mean = rowMeans(across(all_of(juniors)), na.rm = TRUE))
if (length(seniors)>0) raw <- raw %>% mutate(Seniors_mean = rowMeans(across(all_of(seniors)), na.rm = TRUE))
cohort_cols <- c(if (length(juniors)>0) "Juniors_mean", if (length(seniors)>0) "Seniors_mean", ai_models)
cohort_cols <- unique(cohort_cols[cohort_cols %in% names(raw)])

if (length(cohort_cols) >= 2) {
  cohort_long <- raw %>% pivot_longer(cols = all_of(cohort_cols), names_to = "Cohort", values_to = "Score") %>% mutate(Cohort=factor(Cohort, levels=cohort_cols))
  pair_cohort <- cohort_long %>% pairwise_wilcox_test(Score ~ Cohort, paired=TRUE, p.adjust.method="holm") %>% arrange(p.adj)
  print(pair_cohort)
  set.seed(42); boot_mean <- function(x,i) mean(x[i],na.rm=TRUE)
  boot_table <- cohort_long %>% group_by(Cohort) %>% summarise(mean_acc=mean(Score,na.rm=TRUE), boot_ci=list(boot(Score, boot_mean, R=2000)), .groups="drop") %>%
    rowwise() %>% mutate(lo=boot.ci(boot_ci, type="perc")$percent[4], hi=boot.ci(boot_ci, type="perc")$percent[5], `Mean (95% CI)`=sprintf("%.2f (%.2f–%.2f)",mean_acc,lo,hi)) %>%
    select(Cohort,`Mean (95% CI)`)
  print(boot_table)
} else message("Skipping cohort means/pairwise tests: insufficient groups.")

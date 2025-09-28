# R/02_accuracy_analysis.R
suppressPackageStartupMessages({
  library(readxl); library(dplyr); library(tidyr); library(rstatix); library(boot)
  library(janitor); library(yaml); library(glue); library(stringr)
})
`%||%` <- function(a, b) if (!is.null(a)) a else b
read_config <- function(path = "configs/experiment.yaml") yaml::read_yaml(path)

normalize_names <- function(nms, rename_map) {
  cleaned <- nms |> janitor::make_clean_names()
  if (!is.null(rename_map) && length(rename_map) > 0) {
    for (k in names(rename_map)) {
      cleaned <- ifelse(grepl(k, cleaned, ignore.case = TRUE), rename_map[[k]], cleaned)
    }
  }
  cleaned
}

main <- function() {
  cfg <- read_config()
  xlsx_path <- cfg$accuracy$excel_path
  sheet <- cfg$accuracy$sheet %||% "Sheet2"
  rename_map <- cfg$accuracy$rename_map
  juniors <- cfg$accuracy$juniors
  seniors <- cfg$accuracy$seniors
  ai_models <- cfg$accuracy$ai_models
  if (is.null(xlsx_path) || !file.exists(xlsx_path)) {
    stop(glue("Accuracy Excel not found at '{xlsx_path}'. Update configs/experiment.yaml -> accuracy.excel_path"))
  }
  raw <- readxl::read_excel(xlsx_path, sheet = sheet)
  names(raw) <- normalize_names(names(raw), rename_map)
  expect_cols <- c("case_id", juniors, seniors, ai_models)
  missing <- setdiff(expect_cols, names(raw))
  if (length(missing)) stop(glue("Missing expected columns: {paste(missing, collapse = ', ')}"))
  long <- raw %>% pivot_longer(cols = all_of(c(juniors, seniors, ai_models)),
                               names_to = "rater", values_to = "score") %>%
    mutate(rater = factor(rater, levels = c(juniors, seniors, ai_models)))
  fried_out <- rstatix::friedman_test(score ~ rater | case_id, data = long)
  k_w <- rstatix::friedman_effsize(score ~ rater | case_id, data = long)
  print(fried_out); print(k_w)
  pair_full <- long %>% rstatix::pairwise_wilcox_test(score ~ rater, paired = TRUE, p.adjust.method = "holm") %>% arrange(p.adj)
  print(pair_full)
  raw <- raw %>% mutate(juniors_mean = rowMeans(across(all_of(juniors)), na.rm = TRUE),
                        seniors_mean = rowMeans(across(all_of(seniors)), na.rm = TRUE))
  cohort_long <- raw %>% pivot_longer(cols = all_of(c("juniors_mean","seniors_mean", ai_models)),
                                      names_to = "cohort", values_to = "score") %>%
    mutate(cohort = factor(cohort, levels = c("juniors_mean","seniors_mean", ai_models)))
  pair_cohort <- cohort_long %>% rstatix::pairwise_wilcox_test(score ~ cohort, paired = TRUE, p.adjust.method = "holm") %>% arrange(p.adj)
  print(pair_cohort)
  set.seed(42)
  boot_mean <- function(x, i) mean(x[i], na.rm = TRUE)
  boot_table <- cohort_long %>% group_by(cohort) %>%
    summarise(mean_acc = mean(score, na.rm = TRUE),
              boot_ci = list(boot(score, boot_mean, R = 2000)),
              .groups = "drop") %>% rowwise() %>%
    mutate(lo = boot.ci(boot_ci, type = "perc")$percent[4],
           hi = boot.ci(boot_ci, type = "perc")$percent[5],
           `Mean (95% CI)` = sprintf("%.2f (%.2f–%.2f)", mean_acc, lo, hi)) %>%
    select(cohort, `Mean (95% CI)`)
  print(boot_table)
}
if (sys.nframe() == 0L) main()
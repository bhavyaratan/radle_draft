# R/03_mixed_effects_logistic_regression.R
suppressPackageStartupMessages({
  library(readr); library(dplyr); library(reshape2); library(lme4); library(yaml); library(glue); library(janitor)
})
`%||%` <- function(a, b) if (!is.null(a)) a else b
read_config <- function(path = Sys.getenv("CONFIG_FILE", unset = "configs/experiment.yaml")) yaml::read_yaml(path)

main <- function() {
  cfg <- read_config()
  csv_path <- cfg$mixed$csv_path
  juniors <- cfg$mixed$juniors
  seniors <- cfg$mixed$seniors
  ai_models <- cfg$mixed$ai_models
  rename_map <- cfg$mixed$rename_map
  if (is.null(csv_path) || !file.exists(csv_path)) {
    stop(glue("Mixed-effects CSV not found at '{csv_path}'. Update configs/experiment.yaml -> mixed.csv_path"))
  }
  df <- readr::read_csv(csv_path, show_col_types = FALSE)
  names(df) <- janitor::make_clean_names(names(df))
  if (!is.null(rename_map) && length(rename_map) > 0) {
    cn <- names(df)
    for (k in names(rename_map)) cn <- ifelse(grepl(k, cn, ignore.case = TRUE), rename_map[[k]], cn)
    names(df) <- cn
  }
  stopifnot(all(c("case_id") %in% names(df)),
            all(juniors %in% names(df)),
            all(seniors %in% names(df)),
            all(ai_models %in% names(df)))
  df <- df %>% mutate(juniors_mean = rowMeans(across(all_of(juniors)), na.rm = TRUE),
                      seniors_mean = rowMeans(across(all_of(seniors)), na.rm = TRUE))
  df_long <- reshape2::melt(df, id.vars = "case_id",
                            measure.vars = c(juniors, seniors, ai_models),
                            variable.name = "rater", value.name = "score")
  df_long$group <- NA_character_
  df_long$group[df_long$rater %in% juniors] <- "Junior"
  df_long$group[df_long$rater %in% seniors] <- "Senior"
  df_long$group[df_long$rater %in% ai_models] <- as.character(df_long$rater[df_long$rater %in% ai_models])
  df_long$correct <- as.integer(df_long$score >= 0.5)
  df_long$group <- factor(df_long$group, levels = c("Senior","Junior", ai_models))
  m_bin <- lme4::glmer(correct ~ group + (1|case_id) + (1|rater), data = df_long, family = binomial)
  cat("\n=== Mixed-effects logistic regression (correct ≥ 0.5), ref = Senior ===\n"); print(summary(m_bin))
  beta <- lme4::fixef(m_bin); se <- sqrt(diag(vcov(m_bin)))
  OR <- exp(beta); lwr <- exp(beta - 1.96*se); upr <- exp(beta + 1.96*se)
  wald <- summary(m_bin)$coefficients; pval <- wald[, "Pr(>|z|)"]
  res_table <- data.frame(Term = names(beta), OR = OR, Lwr95 = lwr, Upr95 = upr, P = pval,
                          row.names = NULL, check.names = FALSE)
  num_cols <- sapply(res_table, is.numeric); res_table_fmt <- res_table
  res_table_fmt[, num_cols] <- lapply(res_table_fmt[, num_cols], signif, 4)
  cat("\n=== Odds Ratios (Wald 95% CI) with p-values ===\n"); print(res_table_fmt)
}
if (sys.nframe() == 0L) main()

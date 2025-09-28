suppressPackageStartupMessages({library(readxl);library(readr);library(dplyr);library(reshape2);library(lme4)})
INPUT <- Sys.getenv("MIXED_INPUT", "data/processed/diagnoses_anonymized.csv")
df <- if (grepl("\\.xlsx?$", INPUT, ignore.case=TRUE)) readxl::read_excel(INPUT, sheet=1) else readr::read_csv(INPUT, show_col_types=FALSE)
names(df) <- trimws(names(df))

## [Patched for anonymized public data]
existing_cols <- names(df)
juniors <- intersect(c("A","B","C","D"), existing_cols)
seniors <- intersect(c("E","F","G","H"), existing_cols)
df <- df %>% rename(`ChatGPT-o3` = `ChatGPT 03`, `Claude Opus 4.1` = `Claude Opus 4`, `Grok-4` = `Grok 4`)
ai_models <- intersect(c("Gemini 2.5 Pro","ChatGPT-o3","Claude Opus 4.1","GPT-5 Thinking","Grok-4"), names(df))
measure_cols <- unique(c(juniors, seniors, ai_models))
if (length(measure_cols) < 2) stop("Not enough groups/columns to run mixed-effects model after anonymization.")

if (length(juniors)>0) df <- df %>% mutate(Juniors_mean = rowMeans(across(all_of(juniors)), na.rm = TRUE))
if (length(seniors)>0) df <- df %>% mutate(Seniors_mean = rowMeans(across(all_of(seniors)), na.rm = TRUE))

df_long <- reshape2::melt(df, id.vars="Case_ID", measure.vars=measure_cols, variable.name="Rater", value.name="Score")
df_long$Group <- NA_character_
if (length(juniors)>0) df_long$Group[df_long$Rater %in% juniors] <- "Junior"
if (length(seniors)>0) df_long$Group[df_long$Rater %in% seniors] <- "Senior"
df_long$Group[df_long$Rater %in% ai_models] <- as.character(df_long$Rater[df_long$Rater %in% ai_models])
df_long$correct <- as.integer(df_long$Score >= 0.5)

levels_vec <- unique(c(if (length(seniors)>0) "Senior", if (length(juniors)>0) "Junior", ai_models))
df_long$Group <- factor(df_long$Group, levels = levels_vec)

m_bin <- glmer(correct ~ Group + (1|Case_ID) + (1|Rater), data=df_long, family=binomial)
cat("\n=== Mixed-effects logistic regression (correct ≥ 0.5) ===\n"); print(summary(m_bin))

beta <- fixef(m_bin); se <- sqrt(diag(vcov(m_bin))); OR <- exp(beta); lwr <- exp(beta-1.96*se); upr <- exp(beta+1.96*se)
wald <- summary(m_bin)$coefficients; pval <- wald[, "Pr(>|z|)"]
res <- data.frame(Term=names(beta), OR=OR, Lwr95=lwr, Upr95=upr, P=pval, check.names=FALSE)
num <- sapply(res, is.numeric); res[num] <- lapply(res[num], signif, 4)
cat("\n=== Odds Ratios (Wald 95% CI) with p-values ===\n"); print(res)

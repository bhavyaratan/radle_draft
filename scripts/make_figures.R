suppressPackageStartupMessages({library(readr);library(dplyr);library(tidyr);library(ggplot2)})
INPUT <- Sys.getenv("FIG_INPUT", "data/processed/diagnoses_anonymized.csv")
OUTDIR <- "docs/figures"; dir.create(OUTDIR, showWarnings = FALSE, recursive = TRUE)
dat <- if (grepl("\\.xlsx?$", INPUT, ignore.case=TRUE)) readxl::read_excel(INPUT) else readr::read_csv(INPUT, show_col_types=FALSE)
names(dat) <- trimws(names(dat))
ai_models <- intersect(c("Gemini 2.5 Pro","ChatGPT-o3","Claude Opus 4.1","GPT-5 Thinking","Grok-4"), names(dat))
if (!length(ai_models)) { message("No model columns found for figure."); quit(save="no") }
long <- dat %>% pivot_longer(cols = all_of(ai_models), names_to = "Model", values_to = "Score")
agg <- long %>% group_by(Model) %>% summarise(Mean=mean(Score, na.rm = TRUE), .groups="drop")
p <- ggplot(agg, aes(x = Model, y = Mean)) + geom_col() + geom_text(aes(label=sprintf("%.2f",Mean)), vjust=-0.3, size=3) +
     labs(title="Mean accuracy by model", y="Mean accuracy", x=NULL) + coord_cartesian(ylim=c(0,1)) + theme_minimal() + theme(axis.text.x=element_text(angle=25, hjust=1))
ggsave(file.path(OUTDIR, "mean_accuracy_by_model.png"), p, width=9, height=5, dpi=300)
cat("Saved figure to", file.path(OUTDIR, "mean_accuracy_by_model.png"), "\n")

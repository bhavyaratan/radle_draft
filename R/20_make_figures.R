# R/20_make_figures.R
# Generates example figure(s) from results/combined_metrics.csv into figures/
source("R/_helpers.R")
suppressPackageStartupMessages({
  library(ggplot2)
})

dir.create("figures", showWarnings = FALSE, recursive = TRUE)

if (!file.exists("results/combined_metrics.csv")) {
  message("No results/combined_metrics.csv found. Run R/10_aggregate_results.R first.")
  quit(save = "no")
}

df <- readr::read_csv("results/combined_metrics.csv", show_col_types = FALSE)

p <- ggplot(df, aes(x = .data[[names(df)[1]]])) + 
  geom_bar() +
  ggtitle("Placeholder figure - customize aesthetics and mappings")

ggsave("figures/example_figure.png", p, width = 6, height = 4, dpi = 300)
message("Saved figures/example_figure.png")
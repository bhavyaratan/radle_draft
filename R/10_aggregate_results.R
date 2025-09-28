# R/10_aggregate_results.R
# Reads model output CSVs and produces combined metrics table in results/
source("R/_helpers.R")

dir.create("results", showWarnings = FALSE, recursive = TRUE)

csvs <- list.files("models/outputs", pattern = "\\.(csv|CSV)$", full.names = TRUE)
if (!length(csvs)) {
  message("No model output CSVs found in models/outputs/. Nothing to aggregate.")
  quit(save = "no")
}

all <- lapply(csvs, function(p) {
  df <- readr::read_csv(p, show_col_types = FALSE) |> janitor::clean_names()
  df$source_file <- basename(p)
  df
})

combined <- dplyr::bind_rows(all)
readr::write_csv(combined, file = "results/combined_metrics.csv")
message("Wrote results/combined_metrics.csv with ", nrow(combined), " rows.")
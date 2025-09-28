# R/00_smoke_check.R
# Basic checks that folders exist and CSVs are readable.
message("Running smoke check...")

dirs <- c("data/raw", "data/processed", "models/outputs", "figures", "results")
missing <- dirs[!dir.exists(dirs)]
if (length(missing)) stop("Missing dirs: ", paste(missing, collapse = ", "))

csvs <- list.files("models/outputs", pattern = "\\.(csv|CSV)$", full.names = TRUE)
if (length(csvs)) {
  message("Found ", length(csvs), " CSV(s) in models/outputs.")
  # Try reading the first one
  suppressPackageStartupMessages(library(readr))
  df <- readr::read_csv(csvs[1], show_col_types = FALSE)
  message("Preview of first CSV (nrow=", nrow(df), ", ncol=", ncol(df), "):")
  print(utils::head(df, 3))
} else {
  message("No CSVs in models/outputs yet (this is OK for first run).")
}

message("Smoke check passed.")
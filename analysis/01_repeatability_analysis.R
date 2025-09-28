# R/01_repeatability_analysis.R
suppressPackageStartupMessages({
  library(readxl)
  library(irr)
  library(yaml)
  library(glue)
  library(dplyr)
})

read_config <- function(path = "configs/experiment.yaml") yaml::read_yaml(path)

main <- function() {
  cfg <- read_config()
  file_ai <- cfg$repeatability$excel_path
  if (is.null(file_ai) || !file.exists(file_ai)) {
    stop(glue("Repeatability Excel not found at '{file_ai}'. Update configs/experiment.yaml -> repeatability.excel_path"))
  }
  ai_sheets <- readxl::excel_sheets(file_ai)
  for (sh in ai_sheets) {
    cat("\n====================================================\n")
    cat("Model:", sh, "\n")
    cat("====================================================\n")
    dat <- readxl::read_excel(file_ai, sheet = sh)[, -1, drop = FALSE]
    dat <- as.data.frame(lapply(dat, as.numeric))
    ic <- tryCatch(irr::icc(as.matrix(dat), model = "twoway", type = "agreement", unit = "single"),
                   error = function(e) NULL)
    cat("\n=== Intraclass Correlation (ICC[2,1]) ===\n")
    if (!is.null(ic)) print(ic) else cat("ICC could not be computed.\n")
    dat_ord <- lapply(dat, function(x) factor(as.numeric(x), levels = c(0, 0.5, 1), ordered = TRUE))
    raters <- names(dat_ord); K <- length(raters); k_vals <- c()
    for (i in seq_len(K - 1)) for (j in seq(i + 1, K)) {
      tmp <- data.frame(r1 = dat_ord[[i]], r2 = dat_ord[[j]])
      tmp <- tmp[stats::complete.cases(tmp), ]
      kap <- tryCatch(irr::kappa2(tmp, weight = "squared"), error = function(e) NULL)
      kv <- if (!is.null(kap)) round(kap$value, 2) else NA_real_
      k_vals <- c(k_vals, kv)
      agree <- mean(tmp$r1 == tmp$r2) * 100
      cat(sprintf("κ(%s vs %s) = %.2f | Exact agreement = %.1f%%\n", raters[i], raters[j], kv, agree))
    }
    if (length(k_vals) > 0 && any(!is.na(k_vals))) {
      cat(sprintf("Mean κ = %.2f; Range = %.2f–%.2f\n",
                  round(mean(k_vals, na.rm = TRUE), 2),
                  min(k_vals, na.rm = TRUE),
                  max(k_vals, na.rm = TRUE)))
    }
  }
}
if (sys.nframe() == 0L) main()
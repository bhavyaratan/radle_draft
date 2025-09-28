suppressPackageStartupMessages({library(readxl);library(irr);library(dplyr)})
FILE_INPUT <- Sys.getenv("REPEATABILITY_INPUT", "data/raw/RadArena CRASH Lab Stats Repeatability.xlsx")
if (!file.exists(FILE_INPUT)) { message("Repeatability workbook not found; skipping."); quit(save="no") }
ai_sheets <- excel_sheets(FILE_INPUT)
for (sh in ai_sheets) {
  cat("\n====================================================\n"); cat("Model:", sh, "\n"); cat("====================================================\n")
  dat <- readxl::read_excel(FILE_INPUT, sheet=sh)[, -1]; dat <- as.data.frame(lapply(dat, as.numeric))
  ic <- tryCatch(icc(as.matrix(dat), model="twoway", type="agreement", unit="single"), error=function(e) NULL)
  cat("\n=== Intraclass Correlation (ICC[2,1]) ===\n"); if (!is.null(ic)) print(ic) else cat("ICC could not be computed.\n")
  dat_ord <- lapply(dat, function(x) factor(as.numeric(x), levels=c(0,0.5,1), ordered=TRUE))
  raters <- names(dat_ord); K <- length(raters); k_vals <- c()
  for (i in 1:(K-1)) for (j in (i+1):K) {
    tmp <- data.frame(r1=dat_ord[[i]], r2=dat_ord[[j]]); tmp <- tmp[complete.cases(tmp),]
    kap <- tryCatch(kappa2(tmp, weight="squared"), error=function(e) NULL); kv <- if (!is.null(kap)) round(kap$value,2) else NA
    k_vals <- c(k_vals, kv); agree <- mean(tmp$r1==tmp$r2)*100
    cat(sprintf("κ(%s vs %s) = %.2f | Exact agreement = %.1f%%\n", raters[i], raters[j], kv, agree))
  }
  if (length(k_vals)>0) cat(sprintf("Mean κ = %.2f; Range = %.2f–%.2f\n", round(mean(k_vals,na.rm=TRUE),2), min(k_vals,na.rm=TRUE), max(k_vals,na.rm=TRUE)))
}

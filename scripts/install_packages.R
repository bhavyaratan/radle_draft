pkgs <- c("readxl","readr","dplyr","tidyr","rstatix","boot","irr","reshape2","lme4","ggplot2","stringr","digest")
for (p in pkgs) if (!requireNamespace(p, quietly = TRUE)) install.packages(p, repos = "https://cloud.r-project.org")

if (!requireNamespace("renv", quietly = TRUE)) install.packages("renv", repos = "https://cloud.r-project.org")
renv::init(bare = TRUE)
renv::snapshot()

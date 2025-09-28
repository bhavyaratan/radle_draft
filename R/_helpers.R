# R/_helpers.R
suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(stringr)
  library(janitor)
  library(here)
  library(glue)
  library(yaml)
})

read_config <- function(path = "configs/experiment.yaml") {
  if (!file.exists(path)) stop(glue("Config file not found at {path}"))
  yaml::read_yaml(path)
}
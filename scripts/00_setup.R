# 00_setup.R
# Environment setup for the oral acetaminophen MBMA project.
# Author: Pramod BR
# Date:   2026-07-11
#
# Always run this whole file at once (RStudio: Source button, or
# source("scripts/00_setup.R")). Do not run single lines - later lines
# depend on earlier ones.

# Package list ---------------------------------------------------------------
# rxode2   - ODE engine (absorption/central/elimination compartments)
# nlmixr2  - population PK layer on rxode2
# admixr2  - fits PK models to aggregate/summary-level data (core of this project)
# tidyverse, readxl - data wrangling, plotting, reading extracted PK tables
# here     - project-relative file paths
pkgs <- c("rxode2", "nlmixr2", "admixr2", "tidyverse", "readxl", "here")

# Install anything missing, then load everything ------------------------------
missing <- setdiff(pkgs, rownames(installed.packages()))
if (length(missing)) {
  message("Installing: ", paste(missing, collapse = ", "))
  install.packages(missing, repos = "https://cloud.r-project.org")
}

loaded <- vapply(pkgs, function(p)
  suppressPackageStartupMessages(require(p, character.only = TRUE)),
  logical(1))

if (any(!loaded)) {
  stop("These packages did not load: ", paste(pkgs[!loaded], collapse = ", "),
       "\nInstall them manually, then re-run this script.")
}

# Project paths --------------------------------------------------------------
paths <- list(
  data_raw  = here::here("data", "raw"),
  data_proc = here::here("data", "processed"),
  models    = here::here("models"),
  results   = here::here("results"),
  plots     = here::here("plots"),
  docs      = here::here("docs")
)
for (p in paths) dir.create(p, showWarnings = FALSE, recursive = TRUE)

# Reproducibility ------------------------------------------------------------
writeLines(capture.output(sessionInfo()),
           file.path(paths$results, "sessionInfo.txt"))
set.seed(20260711)   # keep the MC estimator reproducible

message("Setup complete. All ", length(pkgs), " packages loaded. admixr2 ",
        tryCatch(as.character(packageVersion("admixr2")), error = function(e) "?"))

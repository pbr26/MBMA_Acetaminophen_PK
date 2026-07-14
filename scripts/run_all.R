# run_all.R
# Run the entire MBMA workflow in order, from raw data to figures.
# Author: Pramod BR
# Date:   2026-07-11
#
# Usage:  open MBMA_Acetaminophen_PK.Rproj, then  source("scripts/run_all.R")

steps <- c(
  "scripts/00_setup.R",             # environment + packages + paths
  "scripts/02_data_extraction.R",   # clean the summary table
  "scripts/03_build_dataset.R",     # assemble the MBMA dataset
  "scripts/04_fit_model.R",         # fit 1-compartment base model
  "scripts/04b_two_compartment.R",  # 1- vs 2-compartment comparison
  "scripts/05_covariate_analysis.R",# dose-stratified covariate check
  "scripts/06_plots.R"              # publication figures
)

for (s in steps) {
  message("\n==== Running ", s, " ====")
  source(here::here(s))
}
message("\nAll steps complete. See results/ and plots/.")

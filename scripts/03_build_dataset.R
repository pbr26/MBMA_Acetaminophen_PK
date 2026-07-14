# 03_build_dataset.R
# Assemble the analysis-ready MBMA dataset from the cleaned summary table
# and the digitised concentration-time profiles.
# Author: Pramod BR
# Date:   2026-07-11

source(here::here("scripts", "00_setup.R"))

# Inputs ---------------------------------------------------------------------
summ <- readr::read_csv(file.path(paths$data_proc, "pk_summary_clean.csv"),
                        show_col_types = FALSE)          # from 02_data_extraction.R

prof <- readr::read_csv(file.path(paths$data_raw, "pk_profiles.csv"),
                        show_col_types = FALSE) %>%
        dplyr::filter(study_id != "EXAMPLE")             # drop the template example rows

# Build the aggregate profile dataset ----------------------------------------
# admixr2 fits to aggregate data, so each observation carries the study mean,
# its SD and N. STUDY is the between-study grouping; DOSE enters as a covariate.
mbma <- prof %>%
  dplyr::transmute(
    study_id,
    study    = as.integer(factor(study_id)),   # numeric study index
    dose_mg,
    formulation,
    time_h,
    dv_mean  = conc_mean_mg_L,                  # mean plasma conc (mg/L)
    dv_sd    = conc_sd_mg_L,                    # between-subject SD at that time
    n,
    dv_sem   = conc_sd_mg_L / sqrt(n),          # precision of the study mean
    source_ref
  ) %>%
  dplyr::arrange(study, dose_mg, time_h)

# Checks ---------------------------------------------------------------------
if (nrow(mbma) == 0) {
  message("No profile data yet - digitise curves into data/raw/pk_profiles.csv, ",
          "then re-run. Summary table still summarised below.")
} else {
  stopifnot(all(mbma$time_h >= 0), all(mbma$dv_mean > 0), all(mbma$n > 0))
  message(dplyr::n_distinct(mbma$study_id), " study arms, ",
          nrow(mbma), " concentration points across ",
          dplyr::n_distinct(mbma$dose_mg), " dose levels.")
}

# Dose coverage (useful for the later dose-effect analysis) ------------------
dose_cov <- summ %>%
  dplyr::distinct(study_id, dose_mg) %>%
  dplyr::count(dose_mg, name = "n_studies")
message("Dose levels represented in the summary table:")
print(dose_cov)

# Write ----------------------------------------------------------------------
readr::write_csv(mbma, file.path(paths$data_proc, "mbma_dataset.csv"))
message("Wrote ", file.path(paths$data_proc, "mbma_dataset.csv"))

# utils.R
# Shared helpers for the MBMA scripts.
# Author: Pramod BR
# Date:   2026-07-11

# build_studies(): turn the long mbma dataset into the named list of
# study specifications admixr2 expects (E, V, n, times, ev).
# cov_cols = names of per-study covariate columns to attach to each dosing
# event table (e.g. "DOSE", "FORM") so the model can reference them.
build_studies <- function(mbma, cov_cols = character(0)) {
  studies <- list()
  for (sid in unique(mbma$study_id)) {
    d <- mbma[mbma$study_id == sid, ]
    d <- d[order(d$time_h), ]

    # Build ev exactly like the working 04_fit_model.R (plain et, dose -> first
    # compartment = depot). Do NOT coerce with as.data.frame(): that strips the
    # event-table structure admixr2 needs and makes predictions return NA.
    ev <- rxode2::et(amt = d$dose_mg[1])
    for (cc in cov_cols) ev[[cc]] <- d[[cc]][1]  # attach constant covariate, keeps et class

    studies[[sid]] <- list(
      E     = d$dv_mean,
      V     = d$dv_sd^2,                          # variance vector (diagonal)
      n     = as.integer(d$n[1]),
      times = d$time_h,
      ev    = ev
    )
  }
  studies
}

# aic_row(): one tidy row summarising a fit for model comparison.
aic_row <- function(fit, label) {
  data.frame(
    model     = label,
    n_par     = length(fit$env$admExtra$struct),
    obj_2LL   = round(as.numeric(fit$objective), 2),
    AIC       = round(as.numeric(AIC(fit)), 2),
    stringsAsFactors = FALSE
  )
}

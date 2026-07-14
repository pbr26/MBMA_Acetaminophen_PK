# 05_covariate_analysis.R
# Evaluate covariate effects (dose, formulation) by STRATIFICATION: fit the
# same structural model to subgroups and compare the parameter estimates.
#
# Why stratification, not a covariate term in the model:
# admixr2 fits each study from its dosing-event table (E, V, n, times, ev) and
# does NOT propagate extra covariate columns into the structural equations
# (referencing e.g. DOSE inside the model gives "parameter required for
# solving: DOSE"). Subgroup fitting is the robust way to ask whether a
# study-level covariate shifts the PK, and is standard practice in MBMA.
# Author: Pramod BR
# Date:   2026-07-11

source(here::here("scripts", "00_setup.R"))
source(here::here("scripts", "utils.R"))

mbma <- readr::read_csv(file.path(paths$data_proc, "mbma_dataset.csv"),
                        show_col_types = FALSE)
if (nrow(mbma) == 0)
  stop("mbma_dataset.csv is empty - build the dataset first (03_build_dataset.R).")

# Structural model (one-compartment, first-order absorption) -----------------
base_mod <- function() {
  ini({
    tka <- log(1.5); tcl <- log(21); tv <- log(60)
    prop.sd <- c(0, 0.2)
    eta.ka ~ 0.09; eta.cl ~ 0.09; eta.v ~ 0.09
  })
  model({
    ka <- exp(tka + eta.ka); cl <- exp(tcl + eta.cl); v <- exp(tv + eta.v)
    d/dt(depot)   <- -ka * depot
    d/dt(central) <-  ka * depot - (cl / v) * central
    cp <- central / v
    cp ~ prop(prop.sd)
  })
}

# Fit the model to a subset and return a tidy row of back-transformed params --
fit_subset <- function(df, label) {
  if (dplyr::n_distinct(df$study_id) < 1 || nrow(df) < 4) {
    message("Skipping '", label, "' - too few data."); return(NULL)
  }
  studies <- build_studies(df)
  fit <- nlmixr2(base_mod, admData(), est = "admc",
                 control = admControl(studies = studies, n_sim = 3000L,
                                      cov_n_sim = 6000L, maxeval = 300L, seed = 1L))
  s <- fit$env$admExtra$struct
  data.frame(
    subgroup   = label,
    n_arms     = dplyr::n_distinct(df$study_id),
    ka_per_h   = round(exp(as.numeric(s[["tka"]])), 3),
    clf_L_h    = round(exp(as.numeric(s[["tcl"]])), 2),
    vf_L       = round(exp(as.numeric(s[["tv"]])),  2),
    obj_2LL    = round(as.numeric(fit$objective), 2),
    AIC        = round(as.numeric(AIC(fit)), 2),
    stringsAsFactors = FALSE
  )
}

# Dose-stratified comparison -------------------------------------------------
# Low dose = <= 700 mg (500/650), high dose = >= 1000 mg (1000/2000).
low  <- dplyr::filter(mbma, dose_mg <= 700)
high <- dplyr::filter(mbma, dose_mg >= 1000)

res <- dplyr::bind_rows(
  fit_subset(mbma, "All studies"),
  fit_subset(low,  "Low dose (<=700 mg)"),
  fit_subset(high, "High dose (>=1000 mg)")
)

# Optional formulation strata (only if both tablet and capsule have data) ----
forms <- unique(tolower(mbma$formulation))
if (any(grepl("capsule", forms)) && any(grepl("tablet", forms))) {
  tab <- dplyr::filter(mbma, grepl("tablet",  tolower(formulation)))
  cap <- dplyr::filter(mbma, grepl("capsule", tolower(formulation)))
  res <- dplyr::bind_rows(res,
                          fit_subset(tab, "Tablets only"),
                          fit_subset(cap, "Capsules only"))
} else {
  message("Formulation stratification skipped: only one formulation present ",
          "(current data are all tablets).")
}

print(res)
readr::write_csv(res, file.path(paths$results, "covariate_stratified.csv"))
message("Saved dose/formulation stratified comparison to results/.")

# Interpretation:
#   Compare clf_L_h and ka across the dose strata. A systematic shift (e.g.
#   apparent CL/F falling as dose rises) is the signature of dose-dependent
#   bioavailability - exactly what Rawlins (1977) reported for acetaminophen.

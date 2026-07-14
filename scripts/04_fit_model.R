# 04_fit_model.R
# Fit the structural PK model to the aggregate MBMA dataset with admixr2.
# Author: Pramod BR
# Date:   2026-07-11

source(here::here("scripts", "00_setup.R"))

# Data -----------------------------------------------------------------------
mbma <- readr::read_csv(file.path(paths$data_proc, "mbma_dataset.csv"),
                        show_col_types = FALSE)

if (nrow(mbma) == 0)
  stop("mbma_dataset.csv is empty. Digitise concentration-time profiles into ",
       "data/raw/pk_profiles.csv and run 03_build_dataset.R first.")

# Structural model -----------------------------------------------------------
# Starting model: one-compartment, first-order absorption (oral).
# Only apparent parameters are identifiable from oral data, so we estimate
# CL/F and V/F, not CL and V. Parameters are mu-referenced on the log scale
# (exp(theta + eta)), which admixr2 needs for its analytical gradients.
# Initial values: ka ~1.5/h, CL/F ~21 L/h (~350 mL/min), V/F ~60 L - literature-typical.
oral_1cmt <- function() {
  ini({
    tka <- log(1.5)  ; label("Log ka (1/h)")
    tcl <- log(21)   ; label("Log CL/F (L/h)")
    tv  <- log(60)   ; label("Log V/F (L)")
    prop.sd <- c(0, 0.2) ; label("Proportional residual error SD")
    eta.ka ~ 0.09
    eta.cl ~ 0.09
    eta.v  ~ 0.09
  })
  model({
    ka <- exp(tka + eta.ka)
    cl <- exp(tcl + eta.cl)
    v  <- exp(tv  + eta.v)
    d/dt(depot)   <- -ka * depot
    d/dt(central) <-  ka * depot - (cl / v) * central
    cp <- central / v
    cp ~ prop(prop.sd)
  })
}

# Assemble the study specifications ------------------------------------------
# One named entry per study arm: E=mean vector, V=variance vector (SD^2),
# n=sample size, times, ev=dosing event (single oral dose = dose_mg).
studies <- list()
for (sid in unique(mbma$study_id)) {
  d <- mbma[mbma$study_id == sid, ]
  d <- d[order(d$time_h), ]
  studies[[sid]] <- list(
    E     = d$dv_mean,
    V     = d$dv_sd^2,                       # diagonal variances (no cross-time cov available)
    n     = as.integer(d$n[1]),
    times = d$time_h,
    ev    = rxode2::et(amt = d$dose_mg[1])   # single oral dose into depot
  )
}
message("Assembled ", length(studies), " study arms for fitting.")

# Fit ------------------------------------------------------------------------
# admc = Monte Carlo estimator (documented workhorse). For a quick first screen,
# swap est="adfo"/control=adfoControl(studies=studies) - faster, less exact.
fit <- nlmixr2(
  oral_1cmt, admData(), est = "admc",
  control = admControl(
    studies   = studies,
    n_sim     = 3000L,
    cov_n_sim = 6000L,
    maxeval   = 300L,
    seed      = 1L
  )
)

# Results --------------------------------------------------------------------
print(fit)

struct <- fit$env$admExtra$struct            # log-scale structural estimates
ka <- exp(as.numeric(struct[["tka"]]))       # absorption rate constant (1/h)
cl <- exp(as.numeric(struct[["tcl"]]))       # apparent clearance CL/F (L/h)
v  <- exp(as.numeric(struct[["tv"]]))        # apparent volume V/F (L)

# Secondary (derived) parameters ---------------------------------------------
# ke  = CL/V ; half-life = ln2/ke.
# For a single oral dose in a 1-compartment model:
#   Tmax = ln(ka/ke)/(ka-ke)
#   Cmax = (Dose*ka)/(V*(ka-ke)) * (exp(-ke*Tmax) - exp(-ka*Tmax))
#   AUC(0-inf) = Dose / (CL/F)         (apparent AUC)
# AUC/Cmax/Tmax depend on dose, so they are reported at a reference dose.
ref_dose <- 1000                             # mg (change if you prefer another)
ke   <- cl / v
thalf<- log(2) / ke
tmax <- log(ka / ke) / (ka - ke)
cmax <- (ref_dose * ka) / (v * (ka - ke)) * (exp(-ke * tmax) - exp(-ka * tmax))
auc  <- ref_dose / cl

est_tbl <- data.frame(
  parameter = c("Absorption rate constant (ka)",
                "Apparent clearance (CL/F)",
                "Apparent volume of distribution (V/F)",
                "Elimination rate constant (ke)",
                "Elimination half-life (t1/2)",
                paste0("Time to peak at ", ref_dose, " mg (Tmax)"),
                paste0("Peak concentration at ", ref_dose, " mg (Cmax)"),
                paste0("Exposure at ", ref_dose, " mg (AUC0-inf)")),
  symbol    = c("ka", "CL/F", "V/F", "ke", "t1/2", "Tmax", "Cmax", "AUC0-inf"),
  estimate  = round(c(ka, cl, v, ke, thalf, tmax, cmax, auc), 3),
  unit      = c("1/h", "L/h", "L", "1/h", "h", "h", "mg/L", "mg*h/L"),
  stringsAsFactors = FALSE
)
print(est_tbl)

message("Objective (-2LL): ", round(fit$objective, 2),
        " | AIC: ", round(AIC(fit), 2))

# Save -----------------------------------------------------------------------
saveRDS(fit, file.path(paths$models, "fit_oral_1cmt.rds"))
readr::write_csv(est_tbl, file.path(paths$results, "params_oral_1cmt.csv"))
message("Saved fit to models/ and parameter table to results/.")

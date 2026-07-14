# 04b_two_compartment.R
# Fit a two-compartment alternative and compare it to the one-compartment
# base model by AIC (lower AIC = better trade-off of fit vs complexity).
# Author: Pramod BR
# Date:   2026-07-11

source(here::here("scripts", "00_setup.R"))
source(here::here("scripts", "utils.R"))

mbma <- readr::read_csv(file.path(paths$data_proc, "mbma_dataset.csv"),
                        show_col_types = FALSE)
if (nrow(mbma) == 0)
  stop("mbma_dataset.csv is empty - build the dataset first (03_build_dataset.R).")

studies <- build_studies(mbma)

# One-compartment base model (same as 04_fit_model.R) -------------------------
oral_1cmt <- function() {
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

# Two-compartment model ------------------------------------------------------
# Adds a peripheral (tissue) tank. Drug exchanges between central and
# peripheral at inter-compartmental clearance Q; this can capture an early
# rapid-distribution phase that one compartment cannot.
# IIV kept on ka, CL, Vc only to keep the random-effect dimension modest.
oral_2cmt <- function() {
  ini({
    tka <- log(1.5); tcl <- log(21); tvc <- log(45); tvp <- log(30); tq <- log(15)
    prop.sd <- c(0, 0.2)
    eta.ka ~ 0.09; eta.cl ~ 0.09; eta.vc ~ 0.09
  })
  model({
    ka <- exp(tka + eta.ka); cl <- exp(tcl + eta.cl); vc <- exp(tvc + eta.vc)
    vp <- exp(tvp); q <- exp(tq)
    d/dt(depot)      <- -ka * depot
    d/dt(central)    <-  ka * depot - (cl/vc) * central - (q/vc) * central + (q/vp) * peripheral
    d/dt(peripheral) <-  (q/vc) * central - (q/vp) * peripheral
    cp <- central / vc
    cp ~ prop(prop.sd)
  })
}

ctl <- function() admControl(studies = studies, n_sim = 3000L,
                             cov_n_sim = 6000L, maxeval = 300L, seed = 1L)

fit1 <- nlmixr2(oral_1cmt, admData(), est = "admc", control = ctl())
fit2 <- nlmixr2(oral_2cmt, admData(), est = "admc", control = ctl())

# Compare --------------------------------------------------------------------
cmp <- rbind(aic_row(fit1, "1-compartment"),
             aic_row(fit2, "2-compartment"))
cmp$dAIC <- cmp$AIC - min(cmp$AIC)          # 0 = best; >2 = meaningfully worse
print(cmp)

best <- cmp$model[which.min(cmp$AIC)]
message("Preferred structural model by AIC: ", best)

saveRDS(fit2, file.path(paths$models, "fit_oral_2cmt.rds"))
readr::write_csv(cmp, file.path(paths$results, "structural_model_comparison.csv"))
message("Saved 2-cmt fit and comparison table.")

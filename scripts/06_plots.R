# 06_plots.R
# Publication-quality figures from the fitted one-compartment model:
#   (1) observed means + model fit, faceted by study/dose
#   (2) observed vs population-predicted
#   (3) residuals vs time
# Predictions use the closed-form one-compartment oral solution with the
# fitted typical parameters, so no ODE re-solve is needed.
# Author: Pramod BR
# Date:   2026-07-11

source(here::here("scripts", "00_setup.R"))

mbma <- readr::read_csv(file.path(paths$data_proc, "mbma_dataset.csv"),
                        show_col_types = FALSE)
fit  <- readRDS(file.path(paths$models, "fit_oral_1cmt.rds"))

# Typical parameters from the fit --------------------------------------------
s   <- fit$env$admExtra$struct
ka  <- exp(as.numeric(s[["tka"]]))
cl  <- exp(as.numeric(s[["tcl"]]))     # CL/F
v   <- exp(as.numeric(s[["tv"]]))      # V/F
ke  <- cl / v
message(sprintf("Using ka=%.3f /h, CL/F=%.2f L/h, V/F=%.2f L", ka, cl, v))

# Closed-form one-compartment oral prediction (dose fully into depot) ---------
predict_conc <- function(t, dose, ka, ke, v) {
  (dose * ka) / (v * (ka - ke)) * (exp(-ke * t) - exp(-ka * t))
}

# Attach population prediction to each observed point ------------------------
mbma <- mbma %>%
  dplyr::mutate(pred = predict_conc(time_h, dose_mg, ka, ke, v),
                resid = dv_mean - pred,
                arm = paste0(study_id, " - ", dose_mg, " mg"))

# Extracted concentration table (observed + predicted) -----------------------
conc_tbl <- mbma %>%
  dplyr::transmute(
    study_id, dose_mg, formulation, time_h,
    obs_conc_mg_L  = round(dv_mean, 3),
    obs_sd_mg_L    = round(dv_sd, 3),
    n,
    pred_conc_mg_L = round(pred, 3),
    residual_mg_L  = round(resid, 3),
    source_ref
  ) %>%
  dplyr::arrange(study_id, dose_mg, time_h)
readr::write_csv(conc_tbl, file.path(paths$results, "concentration_obs_pred.csv"))
message("Wrote concentration table (", nrow(conc_tbl), " rows) to results/concentration_obs_pred.csv")

# Smooth prediction curves for the profile plot ------------------------------
grid <- mbma %>%
  dplyr::distinct(study_id, dose_mg, arm) %>%
  tidyr::crossing(time_h = seq(0, 12, by = 0.1)) %>%
  dplyr::mutate(pred = predict_conc(time_h, dose_mg, ka, ke, v))

theme_pub <- ggplot2::theme_bw(base_size = 11) +
  ggplot2::theme(panel.grid.minor = ggplot2::element_blank(),
                 strip.background = ggplot2::element_rect(fill = "grey92"))

# (1) Fit overlay, faceted -----------------------------------------------------
p1 <- ggplot2::ggplot(mbma, ggplot2::aes(time_h, dv_mean)) +
  ggplot2::geom_errorbar(ggplot2::aes(ymin = dv_mean - dv_sd, ymax = dv_mean + dv_sd),
                         width = 0.2, colour = "grey60") +
  ggplot2::geom_point(size = 1.6, colour = "#1F4E79") +
  ggplot2::geom_line(data = grid, ggplot2::aes(time_h, pred), colour = "#C00000", linewidth = 0.8) +
  ggplot2::facet_wrap(~ arm, scales = "free_y") +
  ggplot2::labs(x = "Time (h)", y = "Concentration (mg/L)",
                title = "Observed means (points) with model fit (line)") +
  theme_pub

# (2) Observed vs predicted ---------------------------------------------------
lim <- range(c(mbma$dv_mean, mbma$pred), na.rm = TRUE)
p2 <- ggplot2::ggplot(mbma, ggplot2::aes(pred, dv_mean, colour = study_id)) +
  ggplot2::geom_abline(slope = 1, intercept = 0, linetype = 2, colour = "grey50") +
  ggplot2::geom_point(size = 1.8) +
  ggplot2::coord_equal(xlim = lim, ylim = lim) +
  ggplot2::labs(x = "Population predicted (mg/L)", y = "Observed (mg/L)",
                colour = "Study", title = "Observed vs predicted") +
  theme_pub

# (3) Residuals vs time -------------------------------------------------------
p3 <- ggplot2::ggplot(mbma, ggplot2::aes(time_h, resid, colour = study_id)) +
  ggplot2::geom_hline(yintercept = 0, linetype = 2, colour = "grey50") +
  ggplot2::geom_point(size = 1.8) +
  ggplot2::labs(x = "Time (h)", y = "Residual (obs - pred, mg/L)",
                colour = "Study", title = "Residuals vs time") +
  theme_pub

# Save ------------------------------------------------------------------------
ggplot2::ggsave(file.path(paths$plots, "fit_profiles.png"),  p1, width = 9, height = 6, dpi = 300)
ggplot2::ggsave(file.path(paths$plots, "obs_vs_pred.png"),   p2, width = 6, height = 6, dpi = 300)
ggplot2::ggsave(file.path(paths$plots, "residuals_time.png"), p3, width = 7, height = 5, dpi = 300)
message("Saved 3 figures to plots/.")

# admixr2's own diagnostic (mean-fit + objective) as a cross-check ------------
adm_plots <- tryCatch(plot(fit, which = c("mean", "nll")), error = function(e) NULL)
if (!is.null(adm_plots)) message("admixr2 built-in plots available in `adm_plots`.")

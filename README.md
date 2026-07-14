# Model-Based Meta-Analysis of Oral Acetaminophen Pharmacokinetics

A reproducible **model-based meta-analysis (MBMA)** of the pharmacokinetics (PK) of oral immediate-release acetaminophen (paracetamol) in healthy adults, fit to **published aggregate (summary-level) data** using the [`admixr2`](https://cran.r-project.org/package=admixr2) R package.

Author: **Pramod BR**

---

## What this project does

It combines the published mean concentration–time results of several acetaminophen PK studies and fits a single pharmacokinetic model to them — recovering typical absorption, clearance and volume parameters without needing any individual patient data.

## Workflow

Run everything with `source("scripts/run_all.R")`, or step by step:

| Script | Purpose | Output |
|---|---|---|
| `00_setup.R` | Install/load packages, define paths, record versions | `results/sessionInfo.txt` |
| `02_data_extraction.R` | Clean and unit-standardise the extracted PK summary table | `data/processed/pk_summary_clean.csv` |
| `03_build_dataset.R` | Assemble the aggregate MBMA dataset (mean, SD, N per time) | `data/processed/mbma_dataset.csv` |
| `04_fit_model.R` | Fit the one-compartment, first-order-absorption model | `models/fit_oral_1cmt.rds`, `results/params_oral_1cmt.csv` |
| `04b_two_compartment.R` | Fit a two-compartment alternative and compare by AIC | `results/structural_model_comparison.csv` |
| `05_covariate_analysis.R` | Dose-stratified covariate comparison | `results/covariate_stratified.csv` |
| `06_plots.R` | Publication figures (fit overlay, obs-vs-pred, residuals) | `plots/*.png` |
| `utils.R` | Shared helpers (`build_studies`, `aic_row`) | — |

## Method in brief

`admixr2` fits an `nlmixr2`/`rxode2` PK model to **aggregate** data: for each study it uses the mean concentration vector, its variance, the sample size, the observation times, and the dosing event. The base structural model is one-compartment with first-order oral absorption, estimating apparent clearance (CL/F) and volume (V/F) — the only parameters identifiable from oral-only data.

## Current results (bridge data)

Fitted one-compartment, first-order-absorption model across 5 study arms (500–2000 mg):

| Parameter | Symbol | Estimate | Unit |
|---|---|---|---|
| Absorption rate constant | ka | ~1.9 | 1/h |
| Apparent clearance | CL/F | ~12.7 | L/h |
| Apparent volume of distribution | V/F | ~42 | L |
| Elimination rate constant | ke | ~0.30 | 1/h |
| Elimination half-life | t½ | ~2.3 | h |
| Exposure at 1000 mg | AUC₀–∞ | ~79 | mg·h/L |

**Structural model:** the 1-compartment model was preferred over a 2-compartment
alternative (AIC 2397.6 vs 2399.9 — adding a second compartment did not improve
the fit enough to justify the extra parameters).

**Covariate (dose):** in the dose-stratified check, the apparent parameters
shifted between the low-dose (≤700 mg) and high-dose (≥1000 mg) groups, consistent
with the known dose-dependence of oral acetaminophen bioavailability (Rawlins 1977).
The high-dose stratum has only 2 studies, so this is indicative, not definitive.

> **These numbers come from a bridge dataset** reconstructed from each study's real
> published NCA parameters (Cmax, Tmax, half-life). They validate the pipeline end to
> end; they are **not** final scientific estimates. For reportable results, replace the
> `BRIDGE_` rows in `data/raw/pk_profiles.csv` with digitized real curves
> (see `docs/02b_digitizing_guide.md`) and re-run `scripts/run_all.R`.

## Outputs produced

- `results/params_oral_1cmt.csv` — full parameter table (ka, CL/F, V/F, ke, t½, Tmax, Cmax, AUC)
- `results/structural_model_comparison.csv` — 1- vs 2-compartment AIC
- `results/covariate_stratified.csv` — dose-stratified parameters
- `results/concentration_obs_pred.csv` — observed vs predicted concentrations
- `plots/fit_profiles.png`, `plots/obs_vs_pred.png`, `plots/residuals_time.png`

## Repository layout

```
MBMA_Acetaminophen_PK/
├── data/raw/         extracted values + digitized profiles
├── data/processed/   cleaned, analysis-ready data
├── scripts/          00 ... 06 + utils + run_all
├── models/           saved fits (.rds)
├── results/          parameter tables, diagnostics
├── plots/            figures
├── docs/             literature review, screening log, guides, PDFs
└── MBMA_Acetaminophen_PK.Rproj
```

## Requirements

R (>= 4.2) with `admixr2`, `nlmixr2`, `rxode2`, `tidyverse`, `readxl`, `here`. A C/C++ toolchain is needed on first install (Rtools on Windows, Xcode CLT on macOS).

## Documentation

- `docs/01_systematic_literature_review.md` — study selection with per-paper rationale
- `docs/literature_screening_log.xlsx` — screening decisions + source links
- `docs/02b_digitizing_guide.md` — how to digitize the real curves
- `docs/Project_Documentation_Detailed.pdf` — full step-by-step analyst manual

## License

Released under the MIT License (see `LICENSE`).

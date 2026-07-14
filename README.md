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

| Quantity | Estimate |
|---|---|
| Absorption rate ka | ~1.9 /h |
| Apparent clearance CL/F | ~12.7 L/h |
| Apparent volume V/F | ~42 L |
| Preferred structural model | 1-compartment (lower AIC than 2-compartment) |

> **These numbers currently come from a bridge dataset** reconstructed from each study's real published NCA parameters (Cmax, Tmax, half-life). They validate the pipeline. For reportable results, replace the `BRIDGE_` rows in `data/raw/pk_profiles.csv` with digitized real curves (see `docs/02b_digitizing_guide.md`) and re-run.

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

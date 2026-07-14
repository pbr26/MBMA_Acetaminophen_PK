# Digitizing Guide — Extracting Concentration–Time Curves

**Author:** Pramod BR
**Date:** 2026-07-11
**Purpose:** Turn each published mean plasma concentration–time figure into numeric rows in `data/raw/pk_profiles.csv`, so `03_build_dataset.R` can build the MBMA dataset.

---

## 1. What you are extracting, and why

The model is fitted to the **mean concentration–time curve** of each study arm. A published figure is a picture; we need the numbers behind it. **Digitizing** means recovering the (time, concentration) coordinates of the plotted mean curve, plus the size of the error bars (the standard deviation, SD) and the number of subjects (N).

Each point you capture becomes one row with: `time_h`, `conc_mean_mg_L`, `conc_sd_mg_L`, `n`, plus `study_id`, `dose_mg`, `formulation`, `source_ref`.

**Target unit:** concentration in **mg/L**. Remember 1 mg/L = 1 µg/mL, so most papers need no numeric change — just confirm the axis unit.

---

## 2. The tool: WebPlotDigitizer

Free, browser-based, no install needed: <https://automeris.io/WebPlotDigitizer/> (or the desktop version).

### Step by step (do this once per figure)

1. **Get the figure.** Screenshot or crop the concentration–time plot from the paper's PDF and save it as a PNG.
2. **Load it.** In WebPlotDigitizer: *File → Load Image*, select your PNG.
3. **Choose plot type.** *2D (X-Y) Plot*.
4. **Calibrate the axes** — this is the critical step. Click four reference points and type in their real values:
   - two points on the **X-axis** (time), e.g. t = 0 and t = 4 h;
   - two points on the **Y-axis** (concentration), e.g. c = 0 and c = 10 mg/L.
   - **If the Y-axis is logarithmic**, tick the "Log Scale" box for Y during calibration — forgetting this is the most common digitizing error.
5. **Capture the mean curve.** Use *Manual* mode and click along the plotted mean line at each labelled sampling time. Aim for a point at every time tick the paper used (typically 0.25, 0.5, 1, 1.5, 2, 3, 4, 6, 8, 12 h — capture whatever the figure shows).
6. **Read the error bars.** For each time point, note the top of the error bar. `SD at that time = (value at top of bar) − (mean value)`. If the bars are standard error (SE, sometimes written SEM), convert: **SD = SE × √N**.
7. **Export.** *View Data → Download .CSV*. You'll get time,concentration pairs.
8. **Assemble the row.** Put those pairs into `pk_profiles.csv` with the study's `study_id`, `dose_mg`, `formulation`, `n`, and `source_ref`.

---

## 3. The exact format expected

Open `data/raw/pk_profiles.csv`. Delete the three `EXAMPLE` rows (the build script ignores them anyway) and add real ones:

```
study_id,dose_mg,formulation,time_h,conc_mean_mg_L,conc_sd_mg_L,n,source_ref,notes
S01,1000,IR tablet,0.5,6.2,1.4,6,Rawlins 1977,linear y-axis
S01,1000,IR tablet,1.0,9.1,1.8,6,Rawlins 1977,
S01,1000,IR tablet,2.0,7.3,1.6,6,Rawlins 1977,
```

Rules:
- One row per (study, dose, time) point.
- Same `study_id` as in the screening log / extraction sheet (S01–S09).
- If a study reports **several doses**, give each dose its own set of rows (same `study_id`, different `dose_mg`).
- Leave `conc_sd_mg_L` blank only if the paper truly shows no variability — but note it in `notes`, because points without SD get less weight-information in the model.

---

## 4. Per-paper worksheet (the 9 included studies)

Digitize the arms below. "Profile" = has a usable mean concentration–time figure to digitize. Confirm the exact axis units in each paper before you start.

| ID | Study | Arm(s) to digitize | Dose(s) | Notes |
|----|-------|--------------------|---------|-------|
| S01 | Rawlins 1977 | Oral curves (and IV for F) | 500, 1000, 2000 mg | Classic dose-ranging; digitize each oral dose separately |
| S02 | Divoll 1982 | Oral tablet, young adults | 650 mg | Also a fed arm if you want the food covariate |
| S03 | Ameer 1983 | Oral IR tablet | ~650 mg | Confirm a conc–time figure exists; else use summary only |
| S04 | Yue 2018 | **IR reference arm only** | 1000 mg | Ignore the sustained-release arms |
| S05 | Liu 2018 | **IR comparator arm(s)** | 1000 mg | Multiple-dose; digitize one dosing interval at steady state |
| S06 | Tablet/capsule comparison 2018 | Tablet arm; capsule arm | 500 mg | Two arms → formulation covariate; skip effervescent |
| S07 | Marroquín-Cardona 2016 | **Plain acetaminophen reference arm** | 650 mg | Ignore the caffeine (test) arm |
| S08 | High-absorption study 2003 | **Conventional reference tablet arm** | 500 mg | Ignore the fast-absorption test arm |
| S09 | Young women PK | Oral IR | confirm dose | Adds sex representation |

> For bioequivalence / sustained-release papers (S04, S05, S07, S08) digitize **only the plain immediate-release single-agent arm** — that is the arm that meets our inclusion criteria.

---

## 5. Quality checks before you run the model

- **Units:** every concentration in mg/L (= µg/mL). Convert if the paper used different units.
- **Peak sanity:** for a 1000 mg IR dose, Cmax should land roughly 8–12 mg/L around 0.5–1.5 h. If your digitized peak is wildly off, re-check the axis calibration (especially log vs linear).
- **Monotonic times:** each arm's times increase from ~0 upward.
- **N present:** every row has the arm's subject count.
- **Baseline:** the curve should start near 0 at t = 0 for a single oral dose.

Once a few arms are entered, run `03_build_dataset.R` — it will report how many arms and points it assembled and write `mbma_dataset.csv`. Then `04_fit_model.R`, `04b_two_compartment.R`, and `05_covariate_analysis.R` will run on real data.

---

## 6. Practical tips

- Start with **one clean study (S07 or S04)** to learn the workflow before doing all nine.
- Keep the cropped figure PNGs in `data/raw/` (e.g. `S07_fig2.png`) so the digitization is reproducible and auditable.
- Record anything unusual (log axis, SE vs SD, dose per arm) in the `notes` column — future-you and reviewers will thank you.
- More time points = a better-defined curve, but don't invent points where the figure has none.

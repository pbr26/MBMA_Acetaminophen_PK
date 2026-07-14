# Systematic Literature Review

## Model-Based Meta-Analysis of Oral Acetaminophen (Paracetamol) Pharmacokinetics

**Review date:** 2026-07-11
**Reviewer:** Pramod
**Companion file:** `literature_screening_log.xlsx` (Search Strategy · Screening Log · PRISMA Counts)

---

## 1. Objective

Identify published studies reporting summary-level (aggregate) pharmacokinetic (PK) data for **immediate-release (IR) oral acetaminophen in healthy adults**, suitable as input to a model-based meta-analysis (MBMA). The MBMA will use only aggregate (mean/SD, N, mean concentration-time profiles) data — no individual patient data — so eligibility is deliberately anchored on what a published summary can supply.

## 2. Eligibility criteria (PICO)

**Population.** Healthy adult volunteers (≥18 y), no overt hepatic or renal disease. Special populations (frail elderly, obesity, hepatic/renal impairment, pregnancy, pediatrics) are excluded from the primary dataset; where a study reports healthy-adult arms separately, only those arms are extracted.

**Intervention.** Single- or multiple-dose oral **immediate-release** acetaminophen — conventional tablet or capsule. Modified-release, effervescent, buffered fast-absorption, orally disintegrating, and liquid/suspension/syrup forms are outside scope (they change the absorption model, which is the very thing the MBMA is trying to estimate cleanly).

**Comparator.** None (this is a descriptive PK meta-analysis). Intravenous arms are used only to derive absolute bioavailability where a study reports both routes.

**Outcome.** At least one reported summary PK parameter with the dose stated — Cmax, Tmax, AUC(0–t) / AUC(0–∞), t½, CL/F, V/F, absolute or relative bioavailability (F) — and/or a digitizable mean plasma concentration-time profile.

## 3. Search strategy

Sources searched (web scoping search, 2026-07-11): PubMed/MEDLINE, Springer Nature Link, Wiley Online Library, ScienceDirect (Elsevier), and PubMed Central. Search concept blocks:

> (acetaminophen OR paracetamol) AND (pharmacokinetic\* OR bioavailability OR "concentration-time") AND oral AND (healthy volunteer\* OR healthy adult\*) AND (Cmax OR Tmax OR AUC OR "half-life" OR clearance)

No date limit was applied (classic dose-ranging anchor studies are essential to a PK MBMA); English-language full text.

> **Transparency note.** This is a *rapid scoping search* performed via web search, not yet a fully reproducible indexed database export. Before publication it should be re-run as a formal PubMed + Embase search with recorded hit counts, deduplication, and two-reviewer screening. The `.xlsx` log is structured to accept those final counts.

## 4. Study flow (PRISMA-style)

Approximately 40 records were surfaced across the search queries; 18 distinct candidate records were catalogued and assessed against the criteria. Of these, **9 studies were included** and 9 were excluded (with 3 review/regulatory papers retained as reference sources rather than data rows).

| Stage | Count |
|---|---|
| Candidate records catalogued | 18 |
| Full-text assessed | 18 |
| **Included (usable IR healthy-adult PK)** | **9** |
| Excluded — non-IR formulation | 4 |
| Excluded — population/disease | 2 |
| Excluded — confounded absorption | 1 |
| Excluded — no primary aggregate data (review/regulatory) | 3 |

## 5. Included studies — and why each was selected

**S01 — Rawlins et al., 1977 (Eur J Clin Pharmacol).** Single IV (1000 mg) plus oral 500/1000/2000 mg in 6 healthy volunteers; reports AUC and absolute bioavailability rising from 0.63 → 0.89 → 0.87 across doses, with a two-compartment disposition. *Selected* as the primary dose-ranging anchor: it directly informs the dose-dependent first-pass/bioavailability behavior the MBMA must reproduce, and supplies clearance and disposition priors.

**S02 — Divoll, Greenblatt, Ameer et al., 1982 (J Clin Pharmacol).** 650 mg oral IR tablet (and elixir) with IV reference in healthy young and elderly adults, fasted and fed; reports Cmax, Tmax, absorption half-life and absolute F (~79% young / 72% elderly). *Selected* because it gives a clean IR-tablet absorption picture in healthy adults and supports two covariates of interest (food and age) at the arm level.

**S03 — Ameer / Greenblatt, 1983 (absolute and relative bioavailability of oral acetaminophen preparations).** *Selected* because it directly quantifies absolute and relative bioavailability of IR oral preparations in healthy adults — a bioavailability prior for the IR tablet and a cross-check on S01/S02.

**S04 — Yue et al., 2018 (Clin Pharmacol Drug Dev).** Although the paper's focus is a 12-hour sustained-release formulation, its 3-way crossover includes a **standard IR 1000 mg reference arm** with full PK in healthy volunteers. *Selected* on the strength of that IR reference arm — a modern 1000 mg profile that adds between-study variability information alongside the 1977 data.

**S05 — Liu et al., 2018 (Clin Pharmacol Drug Dev).** Repeat-dose crossover comparing twice-daily SR against 3×/4×-daily paracetamol; the **IR comparator arms** provide multiple-dose, steady-state IR PK in healthy adults. *Selected* to inform accumulation/steady-state behavior for IR dosing.

**S06 — Tablet/capsule/effervescent comparison, ~2018.** *Selected* for its conventional IR **tablet and capsule** arms (Cmax ≈ 11.3 µg/mL at 1 h for 500 mg); the effervescent arm is excluded. Lets tablet-vs-capsule enter as a formulation covariate *within* the IR class.

**S07 — Bioequivalence of acetaminophen vs acetaminophen+caffeine, 2016 (Drugs R&D, healthy Mexican volunteers).** The **plain IR acetaminophen 650 mg reference arm** (Cmax 9.46 µg/mL, AUC0–t 35.89, AUC0–∞ 37.29 h·µg/mL, fasted) is a clean modern single-agent profile. *Selected*; the caffeine test arm is not used.

**S08 — High-absorption-rate paracetamol 500 mg formulation, 2003 (comparative bioavailability).** *Selected* for its **conventional IR 500 mg reference tablet arm**, reinforcing the 500 mg dose level; the fast-absorption test arm is excluded.

**S09 — Paracetamol PK and metabolism in young women.** Healthy adult (female) oral IR PK with Cmax, Tmax, AUC, CL/F. *Selected* to add sex representation and a second healthy-adult data source at standard oral dose.

Together the included set spans **500, 650, 1000 and 2000 mg**, single- and multiple-dose, tablet and capsule, both sexes, fasted and fed, and both classic (1977–1983) and modern (2003–2018) studies — the spread needed to identify a structural absorption/disposition model and to estimate between-study variability and a dose effect.

## 6. Excluded studies — and why

**S10 — Paracetamol + IV morphine co-administration, 2017 (Clin Drug Investig).** *Excluded:* IV morphine slows gastric emptying and delays/reduces oral absorption, and there is no morphine-free oral control arm — the absorption parameters are confounded and cannot inform a structural ka.

**S11 — Rygnestad/Stillings effervescent vs ordinary tablet, 2000.** *Excluded:* the study centers on the effervescent formulation (outside the IR-conventional scope); retained only as a qualitative reference on absorption rate.

**S12 — Kelly, sodium-bicarbonate buffered tablet.** *Excluded:* a buffered fast-absorption product whose faster gastric emptying makes it a different absorption class, not conventional IR.

**S13 — Forrest, Clements & Prescott, 1982, "Clinical Pharmacokinetics of Paracetamol" (review).** *Excluded* as a data row (secondary/review article, no primary aggregate data) but **retained as a reference source** for parameter priors and cross-checking.

**S14 — Biowaiver monograph for IR acetaminophen (J Pharm Sci).** *Excluded* as a regulatory review with no primary PK data; useful only for BCS-class/absorption context.

**S15 — Semi-physiological population PK in obesity, 2026.** *Excluded:* population enriched for obesity (a special group) and reports an individual-level NLME model rather than aggregate summaries; kept as an external model-comparison reference.

**S16 — Highly variable PK in frail older people, 2021.** *Excluded:* frail elderly (special population), outside the healthy-adult scope.

**S17 — IM vs oral syrup paracetamol in malaria.** *Excluded:* disease population and liquid syrup — fails both population and formulation criteria.

**S18 — Oral suspension bioequivalence study (NCT05022810).** *Excluded:* liquid suspension, not a conventional IR solid oral dosage form.

## 7. Data to extract from included studies

For each included arm: first author, year, dose (mg), N, fasting/fed state, formulation (tablet/capsule), sex distribution, mean age/weight where given, and the reported PK summaries (Cmax, Tmax, AUC0–t, AUC0–∞, t½, CL/F, V/F, F) with their variability (SD/SE/CV) and, where available, digitized mean concentration-time points. These populate `data/raw/` and are assembled into the MBMA dataset in `data/processed/`.

## 8. Limitations

The search is a rapid web-based scoping pass, not yet a fully reproducible indexed export; hit counts are approximate and screening was single-reviewer. Several included arms are reference arms embedded in bioequivalence or modified-release studies, so extraction must be careful to capture only the IR single-agent arm. Some older studies report parameters without full variability, which will require assumptions (documented at extraction) for weighting in the MBMA. These items should be resolved before the workflow is published.

---

*Sources for each record, including DOIs/URLs, are listed in `literature_screening_log.xlsx`.*

# 02_data_extraction.R
# Load the hand-extracted PK summary table, check it, standardise units,
# and write a clean version for dataset building.
# Author: Pramod BR
# Date:   2026-07-11

source(here::here("scripts", "00_setup.R"))

# Read the extraction sheet --------------------------------------------------
# One row per study-arm-dose. Blanks/NA = still to be transcribed from the PDF.
raw <- readr::read_csv(file.path(paths$data_raw, "pk_summary_extraction.csv"),
                       show_col_types = FALSE)

# Target units (everything converted to these):
#   concentration mg/L   (1 mg/L = 1 ug/mL, so ug/mL needs no conversion)
#   AUC           mg*h/L
#   time          h
#   clearance     L/h    (mL/min * 0.06 = L/h)
#   volume        L

# Required columns check -----------------------------------------------------
required <- c("study_id", "first_author", "year", "dose_mg", "formulation",
              "data_status", "source_ref")
stopifnot(all(required %in% names(raw)))

# Sanity checks - catch impossible values early ------------------------------
problems <- raw %>%
  dplyr::mutate(row = dplyr::row_number()) %>%
  dplyr::filter(
    (!is.na(dose_mg)  & dose_mg   <= 0) |
    (!is.na(cmax_mg_L)& cmax_mg_L <= 0) |
    (!is.na(tmax_h)   & tmax_h    <= 0) |
    (!is.na(f_abs)    & (f_abs < 0 | f_abs > 1))
  )
if (nrow(problems)) {
  print(problems[, c("row", "study_id", "dose_mg", "cmax_mg_L", "tmax_h", "f_abs")])
  warning(nrow(problems), " row(s) have out-of-range values - check the CSV.")
}

# Extraction progress --------------------------------------------------------
status_tbl <- raw %>% dplyr::count(data_status)
message("Extraction status:")
print(status_tbl)

n_studies <- dplyr::n_distinct(raw$study_id)
n_ready   <- sum(raw$data_status == "extracted", na.rm = TRUE)
message(n_studies, " studies, ", nrow(raw), " arm rows, ",
        n_ready, " rows already transcribed.")

# Write the cleaned copy -----------------------------------------------------
# (Units are already in target scale on entry; this is where conversions would
#  go if a future row is entered in mL/min or ug/mL.)
clean <- raw %>% dplyr::arrange(study_id, dose_mg)
readr::write_csv(clean, file.path(paths$data_proc, "pk_summary_clean.csv"))

message("Wrote ", file.path(paths$data_proc, "pk_summary_clean.csv"))

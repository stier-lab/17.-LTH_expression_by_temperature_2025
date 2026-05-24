# =============================================================================
# Purpose: Load + tidy the master metadata (one row per coral fragment) and
#          export a canonical lookup that all other scripts can join against.
# Input:   data/raw/metadata/metadata.csv
# Output:  data/processed/coral_metadata.rds
#          output/tables/01_metadata_summary.csv  (sample-size tally)
# =============================================================================

source(here::here("code", "00_setup.R"))

# ---- Load ------------------------------------------------------------------
meta_raw <- read_csv(file.path(DATA_RAW, "metadata", "metadata.csv"),
                     show_col_types = FALSE) |>
  janitor::clean_names()

# ---- Tidy ------------------------------------------------------------------
# Drop trailing whitespace in `thicket ` column; harmonize types
meta <- meta_raw |>
  rename(thicket = matches("^thicket")) |>
  mutate(
    species        = str_squish(species),
    thicket        = str_to_lower(str_squish(thicket)),
    id             = as.integer(id),
    sample         = str_squish(sample),
    wound          = factor(wound, levels = c("no", "yes")),
    tank           = as.integer(tank),
    treatment_c    = as.integer(treatment),
    treatment      = factor(treatment_c, levels = c(28, 31),
                            labels = c("28C", "31C")),
    biopsy_day     = as.integer(biopsy_day),
    collection_date= as_date(collection_date),
    biopsy_date    = as_date(biopsy_date),
    coord_lat      = as.numeric(coord_lat),
    coord_long     = as.numeric(coord_long),
    chlorophyll_ug_cm2 = as.numeric(chlorophyll_ug_cm_2),
    zooxanthellae_cells_cm2 = as.numeric(zooxanthellae_cells_cm_2),
    percent_growth_bw = as.numeric(percent_growth_bw),
    calculated_sa  = as.numeric(calculated_sa)
  ) |>
  select(-treatment_c, -ends_with("_cm_2"))

# Sanity: expected 192 destructive + 16 microscope + a small set of replicates
n_total <- nrow(meta)
message(glue::glue("Loaded metadata: {n_total} rows"))

# ---- Summary tally ---------------------------------------------------------
summary_tbl <- meta |>
  count(treatment, wound, thicket, name = "n") |>
  arrange(treatment, wound, thicket)

# ---- Save ------------------------------------------------------------------
dir.create(DATA_PROC, recursive = TRUE, showWarnings = FALSE)
dir.create(TBL_DIR,   recursive = TRUE, showWarnings = FALSE)
saveRDS(meta, file.path(DATA_PROC, "coral_metadata.rds"))
write_csv(summary_tbl, file.path(TBL_DIR, "01_metadata_summary.csv"))
write_csv(meta,        file.path(DATA_PROC, "coral_metadata.csv"))

message("Wrote coral_metadata.rds, coral_metadata.csv, 01_metadata_summary.csv")
print(summary_tbl)

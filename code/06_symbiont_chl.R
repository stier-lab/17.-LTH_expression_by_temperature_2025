# =============================================================================
# Purpose: Symbiont density (cells/cm^2) and chlorophyll-a (ug/cm^2).
#          Endpoint physiological response variables sampled destructively at
#          each biopsy timepoint.
#          Joins symbiont counts with metadata (chl-a is in metadata.csv).
# Input:   data/raw/symbiont_counts/Raw_counts.csv  (4 hemocytometer reps per coral)
#          data/raw/symbiont_counts/metadata_ordered_merge.csv
#          data/processed/coral_metadata.rds
# Output:  data/processed/symbiont_chl_clean.rds
#          figures/06_symbiont_chl_by_day.{pdf,png}
#          output/tables/06_symbiont_chl_summary.csv
# =============================================================================

source(here::here("code", "00_setup.R"))

raw_counts <- read_csv(file.path(DATA_RAW, "symbiont_counts", "Raw_counts.csv"),
                       show_col_types = FALSE) |>
  janitor::clean_names()
zoox_meta  <- read_csv(file.path(DATA_RAW, "symbiont_counts",
                                 "metadata_ordered_merge.csv"),
                       show_col_types = FALSE) |>
  janitor::clean_names()
meta <- readRDS(file.path(DATA_PROC, "coral_metadata.rds"))

# ---- Reps per coral -------------------------------------------------------
# Raw_counts has 4 hemocytometer counts per coral; we aggregate to mean cells/mL,
# then convert to cells/cm^2 using slurry volume and surface area.
reps <- raw_counts |>
  filter(!is.na(coral_id)) |>
  group_by(coral_id) |>
  summarise(
    mean_count    = mean(across(starts_with("count") | matches("^x?\\d")), na.rm = TRUE) |>
                      pmax(0),
    n_reps        = n(),
    .groups = "drop"
  )

# Fallback: many sheets pre-compute average; use Ordered_averages if reps are sparse
if (nrow(reps) < 100) {
  ordered <- read_csv(file.path(DATA_RAW, "symbiont_counts", "Ordered_averages.csv"),
                      show_col_types = FALSE) |>
    janitor::clean_names()
  reps <- ordered |>
    transmute(coral_id = as.integer(coral_id),
              mean_count = as.numeric(average_10000),
              n_reps = 4L)
}

# Join with per-coral metadata (treatment, day, SA, etc.)
zoox <- zoox_meta |>
  rename(thicket = matches("^thicket")) |>
  mutate(
    coral_id        = as.integer(coral_id),
    treatment       = factor(as.integer(treatment), levels = c(28, 31),
                              labels = c("28C", "31C")),
    biopsy_day      = as.integer(biopsy_day),
    thicket         = str_to_lower(str_squish(thicket)),
    sa_cm2          = as.numeric(calculated_sa_standard_curve),
    slurry_ml       = as.numeric(slurry_volume_m_l),
    zoox_avg_hemo   = as.numeric(zoox_average),
    cells_per_cm2   = (zoox_avg_hemo * 10000 * slurry_ml) / sa_cm2  # hemocytometer 1e4 dilution
  ) |>
  select(coral_id, treatment, biopsy_day, thicket, sa_cm2, cells_per_cm2)

# Pull chlorophyll from master metadata
chl <- meta |>
  filter(!is.na(chlorophyll_ug_cm2)) |>
  select(id, treatment, wound, thicket, biopsy_day, chlorophyll_ug_cm2)

phys <- zoox |>
  left_join(chl, by = c("coral_id" = "id",
                        "treatment" = "treatment",
                        "thicket"   = "thicket",
                        "biopsy_day"= "biopsy_day"))

saveRDS(phys, file.path(DATA_PROC, "symbiont_chl_clean.rds"))

# ---- Summary --------------------------------------------------------------
summary_tbl <- phys |>
  group_by(treatment, biopsy_day) |>
  summarise(
    n             = n(),
    mean_cells    = mean(cells_per_cm2, na.rm = TRUE),
    se_cells      = sd(cells_per_cm2, na.rm = TRUE) / sqrt(n()),
    mean_chl      = mean(chlorophyll_ug_cm2, na.rm = TRUE),
    se_chl        = sd(chlorophyll_ug_cm2, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  )
write_csv(summary_tbl, file.path(TBL_DIR, "06_symbiont_chl_summary.csv"))

# ---- Two-panel figure -----------------------------------------------------
p_zoox <- ggplot(phys, aes(factor(biopsy_day), cells_per_cm2,
                            fill = treatment)) +
  geom_boxplot(width = 0.6, outlier.shape = NA, alpha = 0.65) +
  geom_jitter(width = 0.15, height = 0, alpha = 0.4, size = 0.8) +
  scale_fill_manual(values = c(`28C` = "#56B4E9", `31C` = "#D55E00"),
                    name = "Temperature") +
  labs(x = "Biopsy day", y = expression(Symbionts~(cells~cm^{-2})),
       tag = "A") +
  theme_pub(10) + theme(legend.position = "none")

p_chl <- ggplot(phys, aes(factor(biopsy_day), chlorophyll_ug_cm2,
                           fill = treatment)) +
  geom_boxplot(width = 0.6, outlier.shape = NA, alpha = 0.65) +
  geom_jitter(width = 0.15, height = 0, alpha = 0.4, size = 0.8) +
  scale_fill_manual(values = c(`28C` = "#56B4E9", `31C` = "#D55E00"),
                    name = "Temperature") +
  labs(x = "Biopsy day", y = expression(Chl-a~(mu*g~cm^{-2})),
       tag = "B") +
  theme_pub(10)

p_combo <- p_zoox + p_chl + patchwork::plot_layout(guides = "collect") &
  theme(legend.position = "bottom")

save_fig(p_combo, "06_symbiont_chl_by_day", width = 170, height = 95)

cat("Wrote symbiont_chl_clean.rds, 06_symbiont_chl_summary.csv,",
    "06_symbiont_chl_by_day.{pdf,png}\n")

# =============================================================================
# Purpose: Buoyant-weight growth — % mass change and g/day per coral.
#          The raw sheet stores Excel formulas for the buoyant-weight algorithm
#          (Davies 1989 / Jokiel et al. 1978); we recompute in R rather than
#          trusting the Excel-evaluated cached values.
# Input:   data/raw/buoyant_weight/data.csv
# Output:  data/processed/buoyant_weight_clean.rds
#          figures/05_buoyant_weight_growth.{pdf,png}
#          output/tables/05_buoyant_weight_lm.csv
# =============================================================================

source(here::here("code", "00_setup.R"))

raw <- read_csv(file.path(DATA_RAW, "buoyant_weight", "data.csv"),
                show_col_types = FALSE) |>
  janitor::clean_names()

# Reference (calibration) measurements — these don't change between weighings
# so we use the row-level reference columns as supplied.
bw <- raw |>
  rename(thicket = matches("^thicket")) |>
  mutate(
    thicket    = str_to_lower(str_squish(thicket)),
    id         = as.integer(id),
    wound      = factor(wound, levels = c("no", "yes")),
    tank       = as.integer(tank),
    treatment  = factor(as.integer(treatment), levels = c(28, 31),
                        labels = c("28C", "31C")),
    biopsy_day = as.integer(biopsy_day),
    initial_w  = as.numeric(initial_coral_buoyant_weigh_uncorrected),
    final_w    = as.numeric(final_coral_weight_uncorrected),
    initial_temp = as.numeric(initial_temp_coral),
    final_temp   = as.numeric(final_temp_coral)
  ) |>
  filter(!is.na(initial_w), !is.na(final_w))

# Davies 1989 buoyant weight conversion:
# m_dry = m_buoy / (1 - rho_sw / rho_arag)
# Using rho_arag = 2.93 g/cm^3, rho_sw computed from temp + salinity reference.
# Here we approximate rho_sw at the recorded temperatures using a polynomial
# from the raw sheet's formula `-5e-6*T^2 + 7e-6*T + 1.0001` — same constants
# the field team used. Salinity correction omitted because S_field == S_ref.
rho_sw_temp <- function(t_c) -5e-6 * t_c^2 + 7e-6 * t_c + 1.0001
ARAG <- 2.93

bw <- bw |>
  mutate(
    initial_dry = initial_w / (1 - rho_sw_temp(initial_temp) / ARAG),
    final_dry   = final_w   / (1 - rho_sw_temp(final_temp)   / ARAG),
    delta_g     = final_dry - initial_dry,
    pct_growth  = 100 * delta_g / initial_dry,
    g_per_day   = delta_g / pmax(biopsy_day, 1)
  )

saveRDS(bw, file.path(DATA_PROC, "buoyant_weight_clean.rds"))

# ---- Quick LM --------------------------------------------------------------
m_growth <- lm(pct_growth ~ treatment * wound + thicket, data = bw)
res <- broom::tidy(m_growth, conf.int = TRUE) |>
  mutate(across(where(is.numeric), \(x) round(x, 4)))
write_csv(res, file.path(TBL_DIR, "05_buoyant_weight_lm.csv"))

# ---- Plot ------------------------------------------------------------------
p_bw <- ggplot(bw, aes(interaction(treatment, wound, sep = " · "),
                       pct_growth, fill = treatment)) +
  geom_boxplot(width = 0.55, outlier.shape = NA, alpha = 0.7) +
  geom_jitter(aes(colour = thicket), width = 0.18, height = 0,
              size = 1.6, alpha = 0.85) +
  scale_fill_manual(values  = c(`28C` = "#56B4E9", `31C` = "#D55E00"),
                    name = "Temperature") +
  scale_colour_manual(values = PAL_GENO, name = "Genotype") +
  labs(x = NULL, y = "% mass change (15 d)",
       title = "Coral growth under heating × wounding",
       subtitle = "Buoyant weight; Davies (1989) dry-mass conversion") +
  theme_pub(10) +
  theme(axis.text.x = element_text(angle = 0))

save_fig(p_bw, "05_buoyant_weight_growth", width = 150, height = 95)

cat("\n=== Buoyant weight LM ===\n")
print(res)

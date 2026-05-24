# =============================================================================
# Purpose: Wax-dipping surface-area calibration and per-coral SA estimates.
#          - Fit the standard curve: wax mass (g) -> SA (cm^2) from cylinders
#            of known diameter and height.
#          - Re-derive every coral's SA from its (wax_2 - wax_1) and the curve.
#          - Cross-check with caliper-based SA = 2π(d/2)·h.
# Input:   data/raw/wax_dipping/data.csv
#          data/raw/wax_dipping/Standard_curve.csv
# Output:  data/processed/wax_clean.rds
#          figures/07_wax_standard_curve.{pdf,png}
#          output/tables/07_wax_curve_fit.csv
# =============================================================================

source(here::here("code", "00_setup.R"))

sc <- read_csv(file.path(DATA_RAW, "wax_dipping", "Standard_curve.csv"),
               show_col_types = FALSE) |>
  janitor::clean_names()

wax <- read_csv(file.path(DATA_RAW, "wax_dipping", "data.csv"),
                show_col_types = FALSE) |>
  janitor::clean_names()

# ---- Standard curve --------------------------------------------------------
# Drop rows lacking core columns
sc_fit_data <- sc |>
  select(any_of(c("wax_mass", "wax_g", "wax_2_minus_wax_1",
                  "calculated_sa", "calculated_sa_caliper",
                  "diameter", "height"))) |>
  mutate(across(everything(), as.numeric))

# Locate the standard-curve x/y columns (sheet variant detection)
if (all(c("wax_2_minus_wax_1", "calculated_sa_caliper") %in% names(sc_fit_data))) {
  fit_df <- sc_fit_data |>
    transmute(wax_g = wax_2_minus_wax_1, sa = calculated_sa_caliper) |>
    filter(complete.cases(wax_g, sa), wax_g > 0, sa > 0)
} else if (all(c("diameter", "height") %in% names(sc_fit_data))) {
  fit_df <- sc_fit_data |>
    transmute(wax_g = wax_2_minus_wax_1,
              sa = 2 * pi * (diameter / 2) * height / 100) |>
    filter(complete.cases(wax_g, sa), wax_g > 0, sa > 0)
} else {
  stop("Cannot locate standard-curve columns in Standard_curve.csv")
}

cal <- lm(sa ~ wax_g, data = fit_df)
fit_tbl <- broom::tidy(cal, conf.int = TRUE)
write_csv(fit_tbl, file.path(TBL_DIR, "07_wax_curve_fit.csv"))

# ---- Apply to corals -------------------------------------------------------
wax_proc <- wax |>
  rename(thicket = matches("^thicket")) |>
  mutate(
    id           = as.integer(id),
    treatment    = factor(as.integer(treatment), levels = c(28, 31),
                          labels = c("28C", "31C")),
    biopsy_day   = as.integer(biopsy_day),
    diameter_mm  = as.numeric(diameter),
    height_mm    = as.numeric(height),
    dry_g        = as.numeric(dry_weight),
    wax_g        = as.numeric(wax_2_minus_wax_1),
    sa_caliper_cm2 = 2 * pi * (diameter_mm / 2) * height_mm / 100,
    sa_curve_cm2   = predict(cal, newdata = tibble(wax_g = wax_g))
  ) |>
  select(id, treatment, biopsy_day, thicket, wound, dry_g, wax_g,
         sa_caliper_cm2, sa_curve_cm2)

saveRDS(wax_proc, file.path(DATA_PROC, "wax_clean.rds"))

# ---- Plot the standard curve ----------------------------------------------
p_sc <- ggplot(fit_df, aes(wax_g, sa)) +
  geom_point(size = 2, alpha = 0.85) +
  geom_smooth(method = "lm", se = TRUE, colour = "#0072B2") +
  labs(x = "Wax mass (g)", y = expression(Surface~area~(cm^2)),
       title = "Wax-dipping standard curve",
       subtitle = sprintf("SA = %.1f + %.1f · wax  (R² = %.3f, n = %d)",
                          coef(cal)[1], coef(cal)[2],
                          summary(cal)$r.squared, nobs(cal))) +
  theme_pub(10)

save_fig(p_sc, "07_wax_standard_curve", width = 120, height = 95)

cat("\n=== Wax dipping ===\n")
print(fit_tbl)

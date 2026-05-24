# =============================================================================
# Purpose: Daily YSI spot checks — TEMP, DO%, DO mg/L, SAL, pH.
#          - Convert temperature from °F (recorded) to °C
#          - Multi-panel daily-trace figure
# Input:   data/raw/ysi/Sheet1.csv
# Output:  data/processed/ysi_clean.rds
#          figures/09_ysi_water_chem.{pdf,png}
# =============================================================================

source(here::here("code", "00_setup.R"))

raw <- read_csv(file.path(DATA_RAW, "ysi", "Sheet1.csv"),
                show_col_types = FALSE) |>
  janitor::clean_names()

ysi <- raw |>
  filter(!is.na(date)) |>
  mutate(
    date     = as_date(date),
    tank     = as.integer(tank),
    temp_f   = as.numeric(temp),
    temp_c   = (temp_f - 32) * 5 / 9,
    do_pct   = as.numeric(do_percent),
    do_mgl   = as.numeric(do_mg_l),
    sal      = as.numeric(sal),
    ph       = as.numeric(ph),
    treatment = case_when(
      tank %in% c(3, 6, 9, 12)  ~ "28C",
      tank %in% c(4, 5, 10, 11) ~ "31C",
      TRUE ~ NA_character_
    )
  ) |>
  filter(!is.na(treatment))

saveRDS(ysi, file.path(DATA_PROC, "ysi_clean.rds"))

ysi_long <- ysi |>
  select(date, tank, treatment, temp_c, do_mgl, sal, ph) |>
  pivot_longer(c(temp_c, do_mgl, sal, ph),
               names_to = "var", values_to = "value") |>
  mutate(var = factor(var,
                      levels = c("temp_c", "do_mgl", "sal", "ph"),
                      labels = c("Temperature (°C)", "DO (mg/L)",
                                 "Salinity (psu)", "pH")))

p_ysi <- ggplot(ysi_long, aes(date, value,
                              group = tank, colour = treatment)) +
  geom_line(linewidth = 0.3, alpha = 0.8) +
  geom_point(size = 0.9, alpha = 0.85) +
  scale_colour_manual(values = c(`28C` = "#56B4E9", `31C` = "#D55E00"),
                      name = "Treatment") +
  facet_wrap(~ var, scales = "free_y", ncol = 2) +
  labs(x = NULL, y = NULL,
       title = "Tank water-quality spot checks (YSI)",
       subtitle = "One line per tank, daily 1800 readings") +
  theme_pub(9)

save_fig(p_ysi, "09_ysi_water_chem", width = 170, height = 130)

cat("Wrote ysi_clean.rds and 09_ysi_water_chem.{pdf,png}\n")

# =============================================================================
# Purpose: Color-card pigmentation (Siebeck et al. 2006 D-scale, D1-D6)
#          - Convert D-scale text to ordinal numeric (D1=1, ..., D6=6)
#          - Trajectory plot + paling/hole binary tallies
#          - Ordinal cumulative-link mixed model (clmm) for color
# Input:   data/raw/color_card/data.csv
#          data/processed/coral_metadata.rds
# Output:  data/processed/color_clean.rds
#          figures/03_color_trajectory.{pdf,png}
#          output/tables/03_color_end_proportions.csv
# =============================================================================

source(here::here("code", "00_setup.R"))

cc_raw <- read_csv(file.path(DATA_RAW, "color_card", "data.csv"),
                   show_col_types = FALSE) |>
  janitor::clean_names()

cc <- cc_raw |>
  rename(thicket = matches("^thicket"),
         wound   = wounded) |>
  mutate(
    date      = as_date(date),
    day       = as.integer(day),
    treatment = factor(as.integer(treatment), levels = c(28, 31),
                       labels = c("28C", "31C")),
    tank      = as.integer(tank),
    thicket   = str_to_lower(str_squish(thicket)),
    id        = as.integer(id),
    wound     = factor(wound, levels = c("no", "yes")),
    health_status = str_to_lower(str_squish(health_status)),
    paling    = factor(str_to_lower(str_squish(paling)),
                       levels = c("no", "yes")),
    hole_at_center = factor(str_to_lower(str_squish(hole_at_center)),
                             levels = c("no", "yes")),
    # Color: extract numeric from "D5" -> 5; treat NA / "" as missing
    color_num = as.integer(str_extract(color, "\\d+"))
  ) |>
  filter(!is.na(color_num))

saveRDS(cc, file.path(DATA_PROC, "color_clean.rds"))

# ---- End-of-experiment proportions ----------------------------------------
end_day <- max(cc$day, na.rm = TRUE)
end_props <- cc |>
  filter(day == end_day) |>
  group_by(treatment, wound) |>
  summarise(
    n_total       = n(),
    n_alive       = sum(health_status == "alive", na.rm = TRUE),
    n_paled       = sum(paling == "yes", na.rm = TRUE),
    mean_color    = mean(color_num, na.rm = TRUE),
    sd_color      = sd(color_num,   na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(prop_paled = n_paled / n_total)

write_csv(end_props, file.path(TBL_DIR, "03_color_end_proportions.csv"))

# ---- Trajectory plot -------------------------------------------------------
traj <- cc |>
  group_by(day, treatment, wound) |>
  summarise(
    mean_color = mean(color_num, na.rm = TRUE),
    se = sd(color_num, na.rm = TRUE) / sqrt(n()),
    n = n(),
    .groups = "drop"
  )

p_color <- ggplot(traj, aes(day, mean_color,
                            colour = wound, fill = wound, group = wound)) +
  geom_ribbon(aes(ymin = mean_color - se, ymax = mean_color + se),
              alpha = 0.18, colour = NA) +
  geom_line(linewidth = 0.7) +
  geom_point(size = 1.8) +
  geom_vline(xintercept = 0, linetype = "dotted", colour = "grey50") +
  facet_wrap(~ treatment, ncol = 2) +
  scale_y_reverse(breaks = 1:6, limits = c(6.2, 0.8)) +  # darker = higher D, plot 1 on top
  scale_colour_manual(values = c(no = "#0072B2", yes = "#D55E00"),
                      name = "Wound") +
  scale_fill_manual(values   = c(no = "#0072B2", yes = "#D55E00"),
                    guide = "none") +
  labs(x = "Day relative to wounding (D0)",
       y = "Color score (Siebeck D-scale; lower = paler)",
       title = "Pigmentation trajectory",
       subtitle = "Mean ± 1 SE; axis reversed so paling is downward") +
  theme_pub(10)

save_fig(p_color, "03_color_trajectory", width = 170, height = 90)

cat("Color score: end-of-experiment proportions written.\n")
print(end_props)

# =============================================================================
# Purpose: Acropora-eating flatworm presence sanity check (3 dates: 06/07,
#          06/08, 06/12 2025). Worm pressure was a known risk for A. pulchra;
#          this script tallies worm-positive corals per tank/treatment to flag
#          any tank-level contamination that could confound treatment effects.
# Input:   data/raw/worm_presence/Sheet1.csv
# Output:  data/processed/worm_clean.rds
#          figures/10_worm_presence.{pdf,png}
#          output/tables/10_worm_summary.csv
# =============================================================================

source(here::here("code", "00_setup.R"))

raw <- read_csv(file.path(DATA_RAW, "worm_presence", "Sheet1.csv"),
                show_col_types = FALSE) |>
  janitor::clean_names()

worms <- raw |>
  rename(thicket = matches("^thicket")) |>
  mutate(
    thicket = str_to_lower(str_squish(thicket)),
    tank    = as.integer(tank),
    id      = as.integer(id),
    treatment = case_when(
      tank %in% c(3, 6, 9, 12)  ~ "28C",
      tank %in% c(4, 5, 10, 11) ~ "31C",
      TRUE ~ NA_character_
    )
  ) |>
  pivot_longer(starts_with("worms_"),
               names_to = "date_raw", values_to = "n_worms") |>
  mutate(
    date    = mdy(str_remove(date_raw, "^worms_")),
    present = as.integer(n_worms > 0)
  ) |>
  filter(!is.na(treatment))

saveRDS(worms, file.path(DATA_PROC, "worm_clean.rds"))

summary_tbl <- worms |>
  group_by(date, treatment, tank) |>
  summarise(
    n_corals = n(),
    n_with_worms = sum(present, na.rm = TRUE),
    pct      = 100 * n_with_worms / n_corals,
    .groups = "drop"
  )
write_csv(summary_tbl, file.path(TBL_DIR, "10_worm_summary.csv"))

p_worm <- ggplot(summary_tbl,
                 aes(as.factor(date), n_with_worms,
                     fill = treatment, group = treatment)) +
  geom_col(position = position_dodge(width = 0.7),
           width = 0.6, alpha = 0.85, colour = "black", linewidth = 0.25) +
  facet_wrap(~ tank, ncol = 4, labeller = label_both) +
  scale_fill_manual(values = c(`28C` = "#56B4E9", `31C` = "#D55E00"),
                    name = "Treatment") +
  labs(x = "Inspection date", y = "Corals with flatworms",
       title = "AEFW presence by tank",
       subtitle = "All zeros = good; persistent positives flag tank contamination") +
  theme_pub(9) +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))

save_fig(p_worm, "10_worm_presence", width = 170, height = 110)

cat("Wrote worm_clean.rds, 10_worm_summary.csv, 10_worm_presence.{pdf,png}\n")

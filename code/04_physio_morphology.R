# =============================================================================
# Purpose: 8 binary morphological characterizations of wound healing over time.
#          - For wounded corals only, plot cumulative proportion expressing each
#            trait by day × treatment.
#          - Logistic mixed models per trait (binomial GLMM) testing temperature
#            effect on time-to-trait-onset.
# Input:   data/raw/physio_morphology/data.csv
# Output:  data/processed/physio_clean.rds
#          figures/04_morphology_trajectories.{pdf,png}
#          output/tables/04_morphology_trait_glmm_summaries.csv
# =============================================================================

source(here::here("code", "00_setup.R"))

raw <- read_csv(file.path(DATA_RAW, "physio_morphology", "data.csv"),
                show_col_types = FALSE) |>
  janitor::clean_names()

ph <- raw |>
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
    across(c(tissue_over_wound, hole_in_center, polyp_in_hole, wound_smoothed,
             pigment_over_wound, tip_exist, tip_extension,
             new_corallites_on_tip, algae_on_wound),
           ~ as.integer(str_to_lower(str_squish(.x)) == "yes"))
  )

saveRDS(ph, file.path(DATA_PROC, "physio_clean.rds"))

# ---- Long-form for plotting ------------------------------------------------
traits <- c("tissue_over_wound", "hole_in_center", "polyp_in_hole",
            "wound_smoothed", "pigment_over_wound", "tip_exist",
            "tip_extension", "new_corallites_on_tip")

long <- ph |>
  filter(wound == "yes") |>
  select(day, treatment, tank, thicket, id, all_of(traits)) |>
  pivot_longer(all_of(traits), names_to = "trait", values_to = "expressed") |>
  filter(!is.na(expressed))

# proportion of wounded corals expressing trait by day × treatment
prop_df <- long |>
  group_by(day, treatment, trait) |>
  summarise(prop = mean(expressed), n = n(), .groups = "drop") |>
  mutate(trait = factor(trait, levels = traits,
                        labels = c("Tissue over wound", "Hole in center",
                                   "Polyp in hole", "Wound smoothed",
                                   "Pigment over wound", "Tip exists",
                                   "Tip extension", "New corallites on tip")))

p_traits <- ggplot(prop_df, aes(day, prop,
                                colour = treatment, group = treatment)) +
  geom_line(linewidth = 0.6) +
  geom_point(size = 1.4) +
  geom_vline(xintercept = 0, linetype = "dotted", colour = "grey50") +
  facet_wrap(~ trait, ncol = 4) +
  scale_colour_manual(values = c(`28C` = "#56B4E9", `31C` = "#D55E00"),
                      name = "Temperature") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1),
                     limits = c(0, 1)) +
  labs(x = "Day relative to wounding (D0)",
       y = "Wounded corals expressing trait",
       title = "Morphological wound-healing characteristics",
       subtitle = "Wounded corals only (n = 24 per treatment)") +
  theme_pub(9)

save_fig(p_traits, "04_morphology_trajectories", width = 200, height = 130)

# ---- Per-trait GLMM (binomial) --------------------------------------------
# Question: does treatment shift the probability of trait expression?
fit_one <- function(trait_name) {
  d <- long |> filter(trait == trait_name, day >= 0)
  if (length(unique(d$expressed)) < 2) return(NULL)
  fit <- tryCatch(
    lme4::glmer(expressed ~ treatment * day + (1 | tank) + (1 | thicket),
                family = binomial, data = d,
                control = lme4::glmerControl(optimizer = "bobyqa")),
    error = function(e) NULL
  )
  if (is.null(fit)) return(NULL)
  broom.mixed::tidy(fit, effects = "fixed") |>
    mutate(trait = trait_name, n = nrow(d))
}
trait_results <- map_dfr(traits, fit_one)
write_csv(trait_results, file.path(TBL_DIR, "04_morphology_trait_glmm_summaries.csv"))

cat("Wrote physio_clean.rds, 04_morphology_trajectories.{pdf,png},",
    "04_morphology_trait_glmm_summaries.csv\n")

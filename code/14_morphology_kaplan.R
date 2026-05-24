# =============================================================================
# Purpose: Time-to-onset analysis for each wound-healing morphological trait.
#          For each wounded coral, compute the day when each binary trait
#          first switches from 0 -> 1 ("event" day). Then fit Kaplan-Meier
#          curves and Cox proportional-hazards models comparing 28 vs 31 °C.
#          This is a more powerful framing than the day-by-day GLMMs because
#          it tests "does heating delay (or prevent) healing milestones?".
# Input:   data/processed/physio_clean.rds
# Output:  output/tables/14_km_event_summary.csv      — per-trait median time
#          output/tables/14_cox_hazard_ratios.csv     — HR for 31 vs 28
#          figures/14_morphology_KM.{pdf,png}         — KM facet figure
# =============================================================================

source(here::here("code", "00_setup.R"))
suppressPackageStartupMessages({
  library(survival)
  library(survminer)
})

ph <- readRDS(file.path(DATA_PROC, "physio_clean.rds"))

traits <- c("hole_in_center", "polyp_in_hole", "wound_smoothed",
            "pigment_over_wound", "tip_exist", "tip_extension",
            "new_corallites_on_tip")

# For each (coral, trait) compute: event day = first day with value 1
# (post-wounding only, day >= 0). Right-censor at last observation if 0.
compute_events <- function(d, trait) {
  d |>
    filter(wound == "yes", !is.na(day), day >= 0) |>
    mutate(y = .data[[trait]]) |>
    group_by(id, treatment, tank, thicket) |>
    arrange(day, .by_group = TRUE) |>
    summarise(
      event_day = {
        first1 <- which(y == 1)[1]
        if (is.na(first1)) max(day, na.rm = TRUE) else day[first1]
      },
      event = as.integer(any(y == 1, na.rm = TRUE)),
      .groups = "drop"
    ) |>
    mutate(trait = trait)
}
events <- map_dfr(traits, ~ compute_events(ph, .x))

# ---- KM summary tables ----------------------------------------------------
km_summary <- events |>
  group_by(trait, treatment) |>
  summarise(
    n_corals    = n(),
    n_events    = sum(event),
    median_day  = median(event_day[event == 1]),
    iqr_low     = quantile(event_day[event == 1], 0.25, na.rm = TRUE),
    iqr_high    = quantile(event_day[event == 1], 0.75, na.rm = TRUE),
    .groups = "drop"
  )
write_csv(km_summary, file.path(TBL_DIR, "14_km_event_summary.csv"))

# ---- Cox PH per trait -----------------------------------------------------
fit_cox <- function(tr) {
  d <- events |> filter(trait == tr)
  if (sum(d$event) < 5) return(NULL)
  fit <- tryCatch(
    coxph(Surv(event_day, event) ~ treatment + strata(thicket),
          data = d),
    error = function(e) NULL
  )
  if (is.null(fit)) return(NULL)
  s <- summary(fit)
  tibble(
    trait      = tr,
    n          = s$n,
    n_event    = s$nevent,
    HR_31_vs28 = s$conf.int[1, "exp(coef)"],
    HR_lo      = s$conf.int[1, "lower .95"],
    HR_hi      = s$conf.int[1, "upper .95"],
    z          = s$coefficients[1, "z"],
    p          = s$coefficients[1, "Pr(>|z|)"]
  )
}
cox_results <- map_dfr(traits, fit_cox)
write_csv(cox_results, file.path(TBL_DIR, "14_cox_hazard_ratios.csv"))

# ---- KM facet figure ------------------------------------------------------
# Build per-trait, per-treatment survival curves manually for ggplot
km_curves <- events |>
  group_by(trait, treatment) |>
  group_modify(\(d, k) {
    d <- dplyr::arrange(d, event_day)
    times <- sort(unique(d$event_day))
    # Build a step at every distinct day, NA-safe
    n_at_risk <- sapply(times, \(t) sum(d$event_day >= t))
    n_events  <- sapply(times, \(t) sum(d$event_day == t & d$event == 1))
    haz       <- n_events / pmax(n_at_risk, 1)
    surv      <- cumprod(1 - haz)
    out_day   <- c(0, times)
    out_surv  <- c(1, surv)
    tibble(day = out_day,
           surv = out_surv,
           cum_event = 1 - out_surv)
  }) |>
  ungroup() |>
  mutate(trait = factor(trait,
                        levels = traits,
                        labels = c("Hole in center", "Polyp in hole",
                                   "Wound smoothed", "Pigment over wound",
                                   "Tip exists", "Tip extension",
                                   "New corallites on tip")))

p_km <- ggplot(km_curves, aes(day, cum_event,
                              colour = treatment, group = treatment)) +
  geom_step(linewidth = 0.7) +
  facet_wrap(~ trait, ncol = 4) +
  scale_colour_manual(values = c(`28C` = "#56B4E9", `31C` = "#D55E00"),
                      name = "Temperature") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1),
                     limits = c(0, 1)) +
  labs(x = "Days after wounding",
       y = "Cumulative % corals expressing trait",
       title = "Heat delays the regenerative-tip program but not wound closure",
       subtitle = "Kaplan-Meier curves for each wound-healing milestone (n = 24 corals × treatment)") +
  theme_pub(9)

save_fig(p_km, "14_morphology_KM", width = 200, height = 130)

cat("\n=== Cox PH hazard ratios (31 °C vs 28 °C) ===\n")
print(cox_results |> mutate(across(where(is.numeric), \(x) round(x, 3))))

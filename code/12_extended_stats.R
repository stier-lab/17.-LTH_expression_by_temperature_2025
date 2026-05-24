# =============================================================================
# Purpose: Extended statistical analysis — proper mixed-effects models for
#          all primary responses, with treatment × wound × day interactions,
#          tank + genet random effects (per Progress Notes 2026-04-29).
#
#          For each response, this script produces:
#            - LMM/GLMM with full interaction structure
#            - Type-III ANOVA (lmerTest::anova) for fixed effects
#            - emmeans contrasts (Tukey-adjusted)
#            - DHARMa residual diagnostics (saved as PNG)
#            - R²m / R²c (MuMIn::r.squaredGLMM)
#            - Effect-size summary table
#
# Input:   data/processed/{pam_clean,color_clean,buoyant_weight_clean,
#                          symbiont_chl_clean,physio_clean}.rds
# Output:  output/models/12_<response>_lmm.rds       — fitted model objects
#          output/tables/12_anova_summary.csv         — Type-III ANOVA all responses
#          output/tables/12_emmeans_contrasts.csv     — pairwise contrasts
#          output/tables/12_r2_summary.csv            — marginal/conditional R²
#          figures/12_diagnostics/<response>.png      — DHARMa plots
# =============================================================================

source(here::here("code", "00_setup.R"))
suppressPackageStartupMessages({
  library(MuMIn)
})

DIAG_DIR <- file.path(FIG_DIR, "12_diagnostics")
dir.create(DIAG_DIR, recursive = TRUE, showWarnings = FALSE)

results_anova <- list()
results_emm   <- list()
results_r2    <- list()

# ---- Helpers ---------------------------------------------------------------
save_dharma <- function(model, name) {
  res <- DHARMa::simulateResiduals(model, n = 500, refit = FALSE)
  png(file.path(DIAG_DIR, paste0(name, ".png")),
      width = 1600, height = 800, res = 160)
  plot(res)
  dev.off()
  invisible(res)
}

record_results <- function(model, response_name) {
  # Type-III ANOVA
  if (inherits(model, "lmerMod") || inherits(model, "lmerModLmerTest")) {
    av <- as.data.frame(anova(model, type = 3))
    av$term <- rownames(av); av$response <- response_name
    results_anova[[response_name]] <<- av
  } else if (inherits(model, "glmerMod")) {
    av <- as.data.frame(car::Anova(model, type = 3))
    av$term <- rownames(av); av$response <- response_name
    results_anova[[response_name]] <<- av
  }
  # R²
  r2 <- tryCatch(MuMIn::r.squaredGLMM(model), error = function(e) NULL)
  if (!is.null(r2)) {
    results_r2[[response_name]] <<- tibble::tibble(
      response = response_name,
      R2_marginal    = r2[1, "R2m"],
      R2_conditional = r2[1, "R2c"]
    )
  }
  save_dharma(model, response_name)
}

# ---- 1. PAM Fv/Fm -----------------------------------------------------------
cat("\n=== 1. PAM Fv/Fm ===\n")
pam <- readRDS(file.path(DATA_PROC, "pam_clean.rds")) |>
  mutate(thicket = as.factor(thicket))

m_pam <- lme4::lmer(
  fv_fm ~ treatment * wound * day + (1 | tank) + (1 | thicket) + (1 | id),
  data = pam, REML = TRUE
)
saveRDS(m_pam, file.path(MOD_DIR, "12_pam_lmm.rds"))
record_results(m_pam, "pam_fvfm")

# Day-specific contrasts (treatment effect within each day, marginalizing wound)
emm_pam <- emmeans::emmeans(m_pam, ~ treatment * wound,
                             at = list(day = c(0, 3, 7, 10, 14)),
                             by = "day")
results_emm[["pam_fvfm"]] <- as_tibble(pairs(emm_pam, adjust = "tukey")) |>
  mutate(response = "pam_fvfm")

# ---- 2. Color score (ordinal D-scale) --------------------------------------
cat("\n=== 2. Color score ===\n")
color <- readRDS(file.path(DATA_PROC, "color_clean.rds"))

m_color <- lme4::lmer(
  color_num ~ treatment * wound * day + (1 | tank) + (1 | thicket) + (1 | id),
  data = color, REML = TRUE
)
saveRDS(m_color, file.path(MOD_DIR, "12_color_lmm.rds"))
record_results(m_color, "color_dscale")

emm_color <- emmeans::emmeans(m_color, ~ treatment * wound,
                              at = list(day = c(0, 3, 7, 10, 14)),
                              by = "day")
results_emm[["color_dscale"]] <- as_tibble(pairs(emm_color, adjust = "tukey")) |>
  mutate(response = "color_dscale")

# ---- 3. Buoyant-weight growth ----------------------------------------------
cat("\n=== 3. Buoyant weight ===\n")
bw <- readRDS(file.path(DATA_PROC, "buoyant_weight_clean.rds"))

m_bw <- lme4::lmer(
  pct_growth ~ treatment * wound + (1 | tank) + (1 | thicket),
  data = bw, REML = TRUE
)
saveRDS(m_bw, file.path(MOD_DIR, "12_bw_lmm.rds"))
record_results(m_bw, "growth_pct")

emm_bw <- emmeans::emmeans(m_bw, ~ treatment * wound)
results_emm[["growth_pct"]] <- as_tibble(pairs(emm_bw, adjust = "tukey")) |>
  mutate(response = "growth_pct", day = NA_integer_)

# ---- 4. Symbiont density (cells/cm^2) --------------------------------------
cat("\n=== 4. Symbiont density ===\n")
phys <- readRDS(file.path(DATA_PROC, "symbiont_chl_clean.rds")) |>
  filter(is.finite(cells_per_cm2), cells_per_cm2 > 0) |>
  mutate(thicket = factor(thicket),
         biopsy_day_c = biopsy_day - 1)  # day 1 -> 0 anchor

# Use lognormal-ish: log(cells) ~ treatment * day + (1 | tank) + (1 | thicket)
m_zoox <- lme4::lmer(
  log(cells_per_cm2) ~ treatment * wound * biopsy_day_c +
    (1 | tank) + (1 | thicket),
  data = phys, REML = TRUE
)
saveRDS(m_zoox, file.path(MOD_DIR, "12_zoox_lmm.rds"))
record_results(m_zoox, "log_zoox_density")

emm_zoox <- emmeans::emmeans(m_zoox, ~ treatment * wound,
                             at = list(biopsy_day_c = c(0, 2, 9, 14)),
                             by = "biopsy_day_c", type = "response")
results_emm[["log_zoox_density"]] <- as_tibble(pairs(emm_zoox, adjust = "tukey")) |>
  mutate(response = "log_zoox_density")

# ---- 5. Morphological traits (binomial GLMM, per-trait) --------------------
cat("\n=== 5. Morphological traits (binomial GLMM) ===\n")
ph <- readRDS(file.path(DATA_PROC, "physio_clean.rds")) |>
  filter(wound == "yes", !is.na(day), day >= 0)

traits <- c("polyps_out", "hole_in_center", "polyp_in_hole",
            "wound_smoothed", "pigment_over_wound", "tip_exist",
            "tip_extension", "new_corallites_on_tip", "algae_on_wound")

fit_trait <- function(tr) {
  d <- ph |> mutate(y = .data[[tr]]) |> filter(!is.na(y))
  if (length(unique(d$y)) < 2 || nrow(d) < 30) return(NULL)
  m <- tryCatch(
    lme4::glmer(y ~ treatment * day + (1 | tank) + (1 | thicket),
                family = binomial, data = d,
                control = lme4::glmerControl(optimizer = "bobyqa",
                                             optCtrl = list(maxfun = 1e5))),
    error = function(e) NULL,
    warning = function(w) NULL
  )
  if (is.null(m)) return(NULL)
  # Type-II Wald
  av <- as.data.frame(car::Anova(m, type = 2)) |>
    tibble::rownames_to_column("term") |>
    mutate(response = paste0("morph_", tr), n_obs = nrow(d))
  tidy <- broom.mixed::tidy(m, effects = "fixed") |>
    mutate(response = paste0("morph_", tr))
  list(model = m, anova = av, tidy = tidy)
}

morph_results <- map(traits, fit_trait) |> setNames(traits) |> compact()
for (tr in names(morph_results)) {
  saveRDS(morph_results[[tr]]$model,
          file.path(MOD_DIR, paste0("12_morph_", tr, "_glmm.rds")))
  results_anova[[paste0("morph_", tr)]] <- morph_results[[tr]]$anova
}

# Combine morphology coefficients
morph_tidy <- map_dfr(morph_results, "tidy")
write_csv(morph_tidy, file.path(TBL_DIR, "12_morph_fixed_effects.csv"))

# ---- Aggregate + save ------------------------------------------------------
all_anova <- bind_rows(results_anova, .id = "response_id") |>
  mutate(across(where(is.numeric), \(x) round(x, 5)))
write_csv(all_anova, file.path(TBL_DIR, "12_anova_summary.csv"))

all_emm <- bind_rows(results_emm) |>
  mutate(across(where(is.numeric), \(x) round(x, 5)))
write_csv(all_emm, file.path(TBL_DIR, "12_emmeans_contrasts.csv"))

all_r2 <- bind_rows(results_r2) |>
  mutate(across(where(is.numeric), \(x) round(x, 3)))
write_csv(all_r2, file.path(TBL_DIR, "12_r2_summary.csv"))

# ---- Console summary -------------------------------------------------------
cat("\n=== Type-III ANOVA: continuous responses ===\n")
print(all_anova |>
        filter(response_id %in% c("pam_fvfm", "color_dscale",
                                   "growth_pct", "log_zoox_density")) |>
        select(response_id, term, any_of(c("F value", "Pr(>F)",
                                           "Chisq", "Pr(>Chisq)"))))

cat("\n=== R² (marginal / conditional) ===\n")
print(all_r2)

cat("\nWrote: 12_anova_summary.csv, 12_emmeans_contrasts.csv,",
    "12_r2_summary.csv, 12_morph_fixed_effects.csv,",
    "diagnostics in figures/12_diagnostics/\n")

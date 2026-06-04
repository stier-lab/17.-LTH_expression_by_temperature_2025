# =============================================================================
# Purpose: Sensitivity analysis for the samples/tanks Molly flagged as odd
#          (see notes/QAQC_flagged_samples.md). Re-runs the key treatment-effect
#          tests with the flagged colonies (116, 121) and the slow ambient tank
#          (tank 3) removed, and compares the treatment effect to the full-data
#          model. If the conclusions hold, the flags are documented but
#          inconsequential.
# Input:   data/processed/{pam_clean,color_clean,buoyant_weight_clean}.rds
# Output:  output/tables/22_sensitivity_flagged.csv
# =============================================================================

source(here::here("code", "00_setup.R"))

FLAGGED_IDS  <- c(116, 121)
FLAGGED_TANK <- 3

results <- list()

# Helper: extract the treatment×day (or treatment) F and p from an lmerTest fit
grab <- function(model, label, term) {
  av <- as.data.frame(anova(model))
  av$term <- rownames(av)
  row <- av[av$term == term, , drop = FALSE]
  if (nrow(row) == 0) return(NULL)
  tibble(
    response   = label,
    term       = term,
    F_value    = round(row[["F value"]], 2),
    p_value    = signif(row[["Pr(>F)"]], 3)
  )
}

# ---- PAM Fv/Fm: treatment × day ----
pam <- readRDS(file.path(DATA_PROC, "pam_clean.rds")) |>
  mutate(thicket = factor(thicket))
pam_drop <- pam |> filter(!id %in% FLAGGED_IDS, tank != FLAGGED_TANK)

f_full <- lmerTest::lmer(fv_fm ~ treatment * wound * day + (1|tank) + (1|thicket) + (1|id),
                         data = pam, REML = FALSE)
f_drop <- lmerTest::lmer(fv_fm ~ treatment * wound * day + (1|tank) + (1|thicket) + (1|id),
                         data = pam_drop, REML = FALSE)
results$pam_full <- grab(f_full, "PAM Fv/Fm (full data)",     "treatment:day")
results$pam_drop <- grab(f_drop, "PAM Fv/Fm (flagged dropped)","treatment:day")

# ---- Color D-scale: treatment × day ----
col <- readRDS(file.path(DATA_PROC, "color_clean.rds")) |>
  mutate(thicket = factor(thicket))
col_drop <- col |> filter(!id %in% FLAGGED_IDS, tank != FLAGGED_TANK)

c_full <- lmerTest::lmer(color_num ~ treatment * wound * day + (1|tank) + (1|thicket) + (1|id),
                         data = col, REML = FALSE)
c_drop <- lmerTest::lmer(color_num ~ treatment * wound * day + (1|tank) + (1|thicket) + (1|id),
                         data = col_drop, REML = FALSE)
results$col_full <- grab(c_full, "Color D-scale (full data)",     "treatment:day")
results$col_drop <- grab(c_drop, "Color D-scale (flagged dropped)","treatment:day")

# ---- Buoyant-weight growth: treatment main effect (OLS, single obs/coral) ----
bw <- readRDS(file.path(DATA_PROC, "buoyant_weight_clean.rds")) |>
  mutate(thicket = factor(thicket))
bw_drop <- bw |> filter(!id %in% FLAGGED_IDS, tank != FLAGGED_TANK)

grab_lm <- function(model, label) {
  av <- as.data.frame(car::Anova(model, type = 2))
  av$term <- rownames(av)
  row <- av[av$term == "treatment", , drop = FALSE]
  tibble(response = label, term = "treatment",
         F_value = round(row[["F value"]], 2),
         p_value = signif(row[["Pr(>F)"]], 3))
}
g_full <- lm(pct_growth ~ treatment * wound * thicket, data = bw)
g_drop <- lm(pct_growth ~ treatment * wound * thicket, data = bw_drop)
results$bw_full <- grab_lm(g_full, "Growth % (full data)")
results$bw_drop <- grab_lm(g_drop, "Growth % (flagged dropped)")

out <- bind_rows(results)
write_csv(out, file.path(TBL_DIR, "22_sensitivity_flagged.csv"))

cat("\n=== Sensitivity to flagged samples (corals 116/121 + tank 3) ===\n")
print(as.data.frame(out))
cat("\nIf the key treatment terms stay significant in both rows of each pair,",
    "the flagged samples do not drive the conclusions.\n")
cat("Wrote output/tables/22_sensitivity_flagged.csv\n")

# =============================================================================
# Agent A — Diagnostic suite for continuous-response LMMs / LM
#   Models:  12_pam_lmm.rds, 12_color_lmm.rds, 12_zoox_lmm.rds, 12_bw_lm.rds
#   Checks:  DHARMa residuals, convergence/singularity, influence, emmeans
#            direction sanity vs biological expectation.
#   Outputs: output/diagnostics/A_continuous_diagnostics.csv
#            output/diagnostics/A_continuous_report.md
#            figures/diagnostics/A_<model>_*.png
# =============================================================================

suppressPackageStartupMessages({
  source(here::here("code", "00_setup.R"))
  library(DHARMa)
  library(lme4)
  library(lmerTest)
  library(emmeans)
  library(car)
  library(lmtest)
  library(influence.ME)
  library(tibble)
  library(dplyr)
  library(readr)
})

DIAG_OUT <- file.path(OUT_DIR, "diagnostics")
DIAG_FIG <- file.path(FIG_DIR, "diagnostics")
dir.create(DIAG_OUT, recursive = TRUE, showWarnings = FALSE)
dir.create(DIAG_FIG, recursive = TRUE, showWarnings = FALSE)

# ---- Result accumulator ----------------------------------------------------
rows <- list()
add_row <- function(model, check, statistic = NA_real_, p_value = NA_real_,
                    threshold = NA_character_, status = "PASS", notes = "") {
  rows[[length(rows) + 1]] <<- tibble(
    model = model, check = check,
    statistic = suppressWarnings(as.numeric(statistic)),
    p_value   = suppressWarnings(as.numeric(p_value)),
    threshold = as.character(threshold),
    status    = status,
    notes     = notes
  )
}

# ---- DHARMa helper for mixed models ---------------------------------------
run_dharma <- function(model, model_name, fig_prefix) {
  sim <- tryCatch(
    DHARMa::simulateResiduals(model, n = 1000, refit = FALSE, seed = 42),
    error = function(e) { message("DHARMa failed: ", conditionMessage(e)); NULL }
  )
  if (is.null(sim)) {
    add_row(model_name, "DHARMa_simulation", NA, NA, "n/a", "FAIL",
            "simulateResiduals errored")
    return(invisible(NULL))
  }

  # KS uniformity
  ks <- testUniformity(sim, plot = FALSE)
  add_row(model_name, "DHARMa_KS_uniformity",
          statistic = unname(ks$statistic), p_value = ks$p.value,
          threshold = "p>=0.05",
          status = ifelse(ks$p.value >= 0.05, "PASS",
                          ifelse(ks$p.value >= 0.01, "WARN", "FAIL")),
          notes = "Kolmogorov-Smirnov on scaled residuals")

  # Dispersion
  disp <- tryCatch(testDispersion(sim, plot = FALSE),
                   error = function(e) NULL)
  if (!is.null(disp)) {
    add_row(model_name, "DHARMa_dispersion",
            statistic = unname(disp$statistic), p_value = disp$p.value,
            threshold = "p>=0.05",
            status = ifelse(disp$p.value >= 0.05, "PASS",
                            ifelse(disp$p.value >= 0.01, "WARN", "FAIL")),
            notes = "Ratio of obs/sim residual variance")
  }

  # Outliers
  out <- tryCatch(testOutliers(sim, plot = FALSE, type = "bootstrap"),
                  error = function(e) tryCatch(testOutliers(sim, plot = FALSE),
                                               error = function(e) NULL))
  if (!is.null(out)) {
    add_row(model_name, "DHARMa_outliers",
            statistic = unname(out$statistic), p_value = out$p.value,
            threshold = "p>=0.05",
            status = ifelse(out$p.value >= 0.05, "PASS",
                            ifelse(out$p.value >= 0.01, "WARN", "FAIL")),
            notes = "Excess outliers vs expected")
  }

  # Save DHARMa diagnostic plot
  png(file.path(DIAG_FIG, paste0(fig_prefix, "_dharma.png")),
      width = 1600, height = 800, res = 150)
  plot(sim)
  dev.off()

  invisible(sim)
}

# ---- Convergence / singularity for lmer ------------------------------------
check_lmer_convergence <- function(model, model_name) {
  sing <- lme4::isSingular(model, tol = 1e-4)
  add_row(model_name, "isSingular",
          statistic = as.integer(sing), p_value = NA,
          threshold = "FALSE",
          status = ifelse(sing, "WARN", "PASS"),
          notes = "Singular fit means a variance component is at/near zero")

  vc <- as.data.frame(VarCorr(model))
  zero_vc <- vc[vc$vcov < 1e-6 & !is.na(vc$vcov), , drop = FALSE]
  add_row(model_name, "variance_components_near_zero",
          statistic = nrow(zero_vc), p_value = NA,
          threshold = "0",
          status = ifelse(nrow(zero_vc) == 0, "PASS", "WARN"),
          notes = paste0("VarCorr (grp:var): ",
                         paste(sprintf("%s:%.2e", vc$grp, vc$vcov),
                               collapse = "; ")))

  # Convergence messages from optimizer
  msg <- model@optinfo$conv$lme4$messages
  if (is.null(msg)) msg <- character(0)
  add_row(model_name, "optimizer_convergence_messages",
          statistic = length(msg), p_value = NA,
          threshold = "0",
          status = ifelse(length(msg) == 0, "PASS", "WARN"),
          notes = paste(msg, collapse = " | "))
}

# ---- Influence (Cook's distance) -------------------------------------------
top_cooks_lmer <- function(model, model_name, k = 3) {
  inf <- tryCatch(
    influence.ME::influence(model, obs = TRUE),
    error = function(e) NULL
  )
  if (is.null(inf)) {
    add_row(model_name, "cooks_distance",
            NA, NA, "max < 4/n", "WARN",
            "influence.ME::influence failed (likely too slow); skipped")
    return(NULL)
  }
  cd <- as.numeric(influence.ME::cooks.distance(inf))
  n <- length(cd)
  thresh <- 4 / n
  top_idx <- order(cd, decreasing = TRUE)[seq_len(min(k, n))]
  add_row(model_name, "cooks_distance_max",
          statistic = max(cd, na.rm = TRUE), p_value = NA,
          threshold = sprintf("< %.4f (4/n)", thresh),
          status = ifelse(max(cd, na.rm = TRUE) < thresh, "PASS", "WARN"),
          notes = paste0("Top-", k, " obs idx: ",
                         paste(top_idx, collapse = ","),
                         "; cd: ",
                         paste(sprintf("%.3f", cd[top_idx]), collapse = ",")))
  invisible(cd)
}

top_cooks_lm <- function(model, model_name, k = 3) {
  cd <- cooks.distance(model)
  n  <- length(cd)
  thresh <- 4 / n
  top_idx <- order(cd, decreasing = TRUE)[seq_len(min(k, n))]
  add_row(model_name, "cooks_distance_max",
          statistic = max(cd, na.rm = TRUE), p_value = NA,
          threshold = sprintf("< %.4f (4/n)", thresh),
          status = ifelse(max(cd, na.rm = TRUE) < thresh, "PASS", "WARN"),
          notes = paste0("Top-", k, " obs idx: ",
                         paste(top_idx, collapse = ","),
                         "; cd: ",
                         paste(sprintf("%.3f", cd[top_idx]), collapse = ",")))
  invisible(cd)
}

# ---- Direction sanity via emmeans ------------------------------------------
# Expectation: under 31C stress (vs 28C control), PAM Fv/Fm should DROP,
# symbiont density should DROP, color should LIGHTEN (lower D-scale), and
# growth should DROP. We average across thicket and wound to get the marginal
# treatment effect at end-of-experiment.

check_direction <- function(model, model_name, response_label,
                            day_var = "day", day_val = 14,
                            expect = c("decrease", "increase"),
                            include_day = TRUE) {
  expect <- match.arg(expect)
  emm <- tryCatch({
    if (include_day) {
      at_list <- setNames(list(day_val), day_var)
      emmeans::emmeans(model, ~ treatment, at = at_list)
    } else {
      emmeans::emmeans(model, ~ treatment)
    }
  }, error = function(e) { message("emmeans failed: ", conditionMessage(e)); NULL })
  if (is.null(emm)) {
    add_row(model_name, paste0("emmeans_direction_", response_label),
            NA, NA, expect, "FAIL", "emmeans errored")
    return(NULL)
  }
  cs <- as.data.frame(pairs(emm, reverse = FALSE, adjust = "none"))
  # contrast is treatment28 - treatment31 (alphabetical/numeric first - second)
  # i.e. control - heated. Positive => control higher than heated.
  est <- cs$estimate[1]
  pv  <- cs$p.value[1]
  observed_dir <- ifelse(est > 0, "decrease", "increase") # of heated vs control
  ok <- observed_dir == expect
  add_row(model_name, paste0("emmeans_direction_", response_label),
          statistic = est, p_value = pv,
          threshold = paste0("expected: heated ", expect, " vs control"),
          status = ifelse(ok, "PASS", "WARN"),
          notes = sprintf("contrast %s = %.4f (p=%.3g); observed heated %s",
                          cs$contrast[1], est, pv, observed_dir))
  invisible(cs)
}

# =============================================================================
# 1. PAM Fv/Fm -- 12_pam_lmm.rds
# =============================================================================
cat("\n=== Model 1: PAM Fv/Fm ===\n")
m_pam <- readRDS(file.path(MOD_DIR, "12_pam_lmm.rds"))
check_lmer_convergence(m_pam, "12_pam_lmm")
run_dharma(m_pam, "12_pam_lmm", "A_pam")
top_cooks_lmer(m_pam, "12_pam_lmm")
check_direction(m_pam, "12_pam_lmm", "pam_fvfm",
                day_var = "day", day_val = 14, expect = "decrease")

# =============================================================================
# 2. Color D-scale -- 12_color_lmm.rds
# =============================================================================
cat("\n=== Model 2: Color D-scale ===\n")
m_color <- readRDS(file.path(MOD_DIR, "12_color_lmm.rds"))
check_lmer_convergence(m_color, "12_color_lmm")
run_dharma(m_color, "12_color_lmm", "A_color")
top_cooks_lmer(m_color, "12_color_lmm")
# Color: bleaching makes corals LIGHTER → lower color_num. Expect heated DECREASE.
check_direction(m_color, "12_color_lmm", "color_dscale",
                day_var = "day", day_val = 14, expect = "decrease")

# =============================================================================
# 3. log Symbiont density -- 12_zoox_lmm.rds
# =============================================================================
cat("\n=== Model 3: log(symbionts/cm^2) ===\n")
m_zoox <- readRDS(file.path(MOD_DIR, "12_zoox_lmm.rds"))
check_lmer_convergence(m_zoox, "12_zoox_lmm")
run_dharma(m_zoox, "12_zoox_lmm", "A_zoox")
top_cooks_lmer(m_zoox, "12_zoox_lmm")
# day variable in this model is biopsy_day_c
check_direction(m_zoox, "12_zoox_lmm", "log_zoox",
                day_var = "biopsy_day_c", day_val = 14, expect = "decrease")

# =============================================================================
# 4. Buoyant-weight growth % -- 12_bw_lm.rds (OLS)
# =============================================================================
cat("\n=== Model 4: BW growth % (lm) ===\n")
m_bw <- readRDS(file.path(MOD_DIR, "12_bw_lm.rds"))

# Save diagnostic plot panel
png(file.path(DIAG_FIG, "A_bw_lm_base.png"),
    width = 1600, height = 1200, res = 150)
par(mfrow = c(2, 2)); plot(m_bw); par(mfrow = c(1, 1))
dev.off()

# Shapiro-Wilk on residuals
sw <- shapiro.test(resid(m_bw))
add_row("12_bw_lm", "shapiro_residual_normality",
        statistic = unname(sw$statistic), p_value = sw$p.value,
        threshold = "p>=0.05",
        status = ifelse(sw$p.value >= 0.05, "PASS",
                        ifelse(sw$p.value >= 0.01, "WARN", "FAIL")),
        notes = "Shapiro-Wilk on OLS residuals")

# Breusch-Pagan heteroscedasticity
bp <- lmtest::bptest(m_bw)
add_row("12_bw_lm", "breusch_pagan_heteroscedasticity",
        statistic = unname(bp$statistic), p_value = bp$p.value,
        threshold = "p>=0.05",
        status = ifelse(bp$p.value >= 0.05, "PASS",
                        ifelse(bp$p.value >= 0.01, "WARN", "FAIL")),
        notes = "BP test for non-constant variance")

# VIF (only meaningful in additive model; saturated 3-way -> singularities expected)
add_row("12_bw_lm", "VIF",
        statistic = NA, p_value = NA, threshold = "<5 per term",
        status = "WARN",
        notes = "Saturated 3-way interaction lm; VIFs uninterpretable. Skipped.")

# DHARMa works on lm too
sim_bw <- tryCatch(
  DHARMa::simulateResiduals(m_bw, n = 1000, seed = 42),
  error = function(e) NULL
)
if (!is.null(sim_bw)) {
  ks <- testUniformity(sim_bw, plot = FALSE)
  add_row("12_bw_lm", "DHARMa_KS_uniformity",
          statistic = unname(ks$statistic), p_value = ks$p.value,
          threshold = "p>=0.05",
          status = ifelse(ks$p.value >= 0.05, "PASS",
                          ifelse(ks$p.value >= 0.01, "WARN", "FAIL")),
          notes = "DHARMa KS on simulated residuals")
  png(file.path(DIAG_FIG, "A_bw_dharma.png"),
      width = 1600, height = 800, res = 150)
  plot(sim_bw); dev.off()
}

top_cooks_lm(m_bw, "12_bw_lm")

# Direction sanity: no day variable in BW model
check_direction(m_bw, "12_bw_lm", "growth_pct",
                expect = "decrease", include_day = FALSE)

# =============================================================================
# Write outputs
# =============================================================================
diag_df <- dplyr::bind_rows(rows)
write_csv(diag_df, file.path(DIAG_OUT, "A_continuous_diagnostics.csv"))

# Per-model narrative
summarize_model <- function(df, m) {
  sub <- df[df$model == m, , drop = FALSE]
  bullets <- vapply(seq_len(nrow(sub)), function(i) {
    sprintf("- **%s** [%s]: %s%s",
            sub$check[i], sub$status[i],
            ifelse(is.na(sub$statistic[i]), "",
                   sprintf("stat=%.4g ", sub$statistic[i])),
            ifelse(nzchar(sub$notes[i]), sub$notes[i], ""))
  }, character(1))
  paste(c(paste0("## ", m), bullets, ""), collapse = "\n")
}

models_in_order <- c("12_pam_lmm", "12_color_lmm", "12_zoox_lmm", "12_bw_lm")
report <- c(
  "# Agent A — Continuous-response model diagnostics",
  paste0("Generated: ", Sys.time()),
  "",
  paste0("Models reviewed: ",
         paste(models_in_order, collapse = ", ")),
  "",
  "## Summary",
  sprintf("- Total checks: %d", nrow(diag_df)),
  sprintf("- PASS: %d", sum(diag_df$status == "PASS")),
  sprintf("- WARN: %d", sum(diag_df$status == "WARN")),
  sprintf("- FAIL: %d", sum(diag_df$status == "FAIL")),
  "",
  unlist(lapply(models_in_order, summarize_model, df = diag_df))
)
writeLines(report, file.path(DIAG_OUT, "A_continuous_report.md"))

cat("\n=== DIAGNOSTIC SUMMARY ===\n")
cat(sprintf("Total: %d | PASS: %d | WARN: %d | FAIL: %d\n",
            nrow(diag_df),
            sum(diag_df$status == "PASS"),
            sum(diag_df$status == "WARN"),
            sum(diag_df$status == "FAIL")))
fails <- diag_df[diag_df$status == "FAIL", , drop = FALSE]
if (nrow(fails) > 0) {
  cat("\nFAIL items:\n")
  print(fails, n = Inf)
} else {
  cat("\nNo FAIL items.\n")
}

cat("\nWrote:\n",
    " - ", file.path(DIAG_OUT, "A_continuous_diagnostics.csv"), "\n",
    " - ", file.path(DIAG_OUT, "A_continuous_report.md"), "\n",
    " - figures: ", DIAG_FIG, "/A_*.png\n", sep = "")

# =============================================================================
# Purpose: Run the full LTH analysis pipeline in dependency order.
#          Source this once from the project root: `Rscript code/_run_all.R`
#          Total runtime ~3 minutes (Apex XML parse dominates first pass).
# =============================================================================

# Source from project root regardless of cwd
project_root <- normalizePath(dirname(dirname(sys.frame(1)$ofile %||% "code/_run_all.R")))
if (!dir.exists(file.path(project_root, "code"))) {
  project_root <- here::here()
}
setwd(project_root)

scripts <- c(
  "01_load_clean_metadata.R",
  "02_pam_analysis.R",
  "03_color_card_analysis.R",
  "04_physio_morphology.R",
  "05_buoyant_weight.R",
  "06_symbiont_chl.R",
  "07_wax_dipping.R",
  "08_apex_temperature.R",
  "09_ysi_water_chem.R",
  "10_worms.R",
  "11_combined_figure.R",
  "12_extended_stats.R",
  "13_genet_interaction.R",
  "14_morphology_kaplan.R",
  "15_multivariate.R"
)

t0 <- Sys.time()
for (s in scripts) {
  cat("\n============================================================\n",
      "Running:", s, "\n",
      "============================================================\n", sep = "")
  tic <- Sys.time()
  source(file.path("code", s))
  toc <- Sys.time()
  cat("  -> done in", round(as.numeric(toc - tic, units = "secs"), 1), "s\n")
}
t1 <- Sys.time()
cat("\n\nFull pipeline complete in",
    round(as.numeric(t1 - t0, units = "mins"), 2), "min.\n")

# Save session info for reproducibility provenance
dir.create("output", showWarnings = FALSE)
writeLines(capture.output(sessionInfo()), "output/session_info.txt")

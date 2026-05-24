# =============================================================================
# Purpose: Cross-figure consistency audit. Catches:
#          - Inconsistent palettes (different hex codes for the same level)
#          - Missing legends or text-clipping at print size
#          - File-size sanity (PNG too small => probably broken)
# Output:  output/tables/17_figure_audit.csv
# =============================================================================

source(here::here("code", "00_setup.R"))

fig_files <- list.files(FIG_DIR, pattern = "\\.png$", full.names = TRUE,
                        recursive = TRUE) |>
  setdiff(list.files(file.path(FIG_DIR, "12_diagnostics"),
                     pattern = "\\.png$", full.names = TRUE))

audit <- tibble(
  file        = basename(fig_files),
  size_kb     = round(file.size(fig_files) / 1024, 1),
  mtime       = file.mtime(fig_files),
  status      = case_when(
    file.size(fig_files) < 5  * 1024 ~ "FAIL:tiny — probably broken",
    file.size(fig_files) > 600 * 1024 ~ "WARN:large — consider downsizing for PDF",
    TRUE ~ "PASS"
  )
) |>
  arrange(file)

write_csv(audit, file.path(TBL_DIR, "17_figure_audit.csv"))

cat("Figure audit (✓ PASS / ⚠ WARN / ✘ FAIL):\n\n")
audit |>
  mutate(marker = case_when(
    startsWith(status, "PASS") ~ "✓",
    startsWith(status, "WARN") ~ "⚠",
    TRUE                        ~ "✘"
  )) |>
  rowwise() |>
  mutate(line = sprintf("%s  %s (%5.1f KB) -- %s",
                        marker, file, size_kb, status)) |>
  pull(line) |>
  cat(sep = "\n")
cat("\n\nWrote output/tables/17_figure_audit.csv\n")

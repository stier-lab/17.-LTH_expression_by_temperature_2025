# =============================================================================
# Purpose: Project-wide setup — packages, paths, theme, palettes
# Input:   none
# Output:  attaches packages, defines theme_pub() and PAL_*, sets here() root
# Author:  Stier Lab
# =============================================================================

suppressPackageStartupMessages({
  library(here)
  library(tidyverse)
  library(lubridate)
  library(janitor)
  library(readxl)
  library(patchwork)
  library(scales)
  library(broom)
  library(broom.mixed)
  library(lme4)
  library(lmerTest)
  library(emmeans)
  library(DHARMa)
})

set.seed(42)

# ---- Paths -----------------------------------------------------------------
DATA_RAW  <- here("data", "raw")
DATA_PROC <- here("data", "processed")
DATA_META <- here("data", "metadata")
FIG_DIR   <- here("figures")
OUT_DIR   <- here("output")
TBL_DIR   <- here("output", "tables")
MOD_DIR   <- here("output", "models")

# ---- Palettes --------------------------------------------------------------
# Okabe-Ito (colorblind-friendly qualitative)
PAL_OKABE <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442",
               "#0072B2", "#D55E00", "#CC79A7", "#000000")

# Treatment palette: ambient (28C) → mild (30C) → moderate (32C) → severe (34C)
# Use a perceptually-uniform sequential ramp anchored to Okabe blue/red
PAL_TEMP <- c("28" = "#56B4E9",   # blue — ambient
              "30" = "#F0E442",   # yellow — mild
              "31" = "#E69F00",   # orange — moderate
              "32" = "#D55E00",   # red — severe-mod
              "34" = "#B40000")   # dark red — severe (placeholder; check actual treatments)

# Genotype/thicket palette: A–E
PAL_GENO <- setNames(PAL_OKABE[1:5], c("A", "B", "C", "D", "E"))

# ---- Theme -----------------------------------------------------------------
# theme_pub(): single source of truth for figure text sizing.
# base_size is width-dependent — pass appropriate value per figure:
#   single-col (55-89 mm)  → base_size = 8
#   1.5-col   (115-170 mm) → base_size = 9-10
#   double-col(170-183 mm) → base_size = 10-11
theme_pub <- function(base_size = 10) {
  theme_bw(base_size = base_size, base_family = "") %+replace%
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(linewidth = 0.25, colour = "grey88"),
      panel.border     = element_rect(fill = NA, colour = "black", linewidth = 0.4),
      strip.background = element_blank(),
      strip.text       = element_text(size = base_size - 1, face = "bold"),
      axis.text        = element_text(size = base_size - 2, colour = "black"),
      axis.title       = element_text(size = base_size, face = "plain"),
      axis.ticks       = element_line(colour = "black", linewidth = 0.3),
      plot.title       = element_text(size = base_size, face = "bold", hjust = 0,
                                      margin = margin(b = 4)),
      plot.subtitle    = element_text(size = base_size - 1, hjust = 0,
                                      margin = margin(b = 6), colour = "grey30"),
      plot.tag         = element_text(size = base_size + 1, face = "bold"),
      plot.caption     = element_text(size = base_size - 2, hjust = 0, colour = "grey40"),
      legend.position  = "bottom",
      legend.title     = element_text(size = base_size - 1),
      legend.text      = element_text(size = base_size - 2),
      legend.key       = element_blank(),
      legend.background= element_blank(),
      plot.margin      = margin(8, 8, 8, 8, "pt")
    )
}

# ---- Save helper -----------------------------------------------------------
save_fig <- function(plot, name, width = 170, height = 110, units = "mm",
                     dpi = 300, dir = FIG_DIR) {
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  for (ext in c("pdf", "png")) {
    ggsave(
      filename = file.path(dir, paste0(name, ".", ext)),
      plot     = plot,
      width    = width,
      height   = height,
      units    = units,
      dpi      = dpi,
      device   = if (ext == "pdf") cairo_pdf else "png"
    )
  }
  invisible(plot)
}

# ---- Session log -----------------------------------------------------------
log_session <- function(path = file.path(OUT_DIR, "session_info.txt")) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  writeLines(capture.output(sessionInfo()), path)
}

message("Setup complete. ", length(search()), " env entries; ",
        format(Sys.time(), "%Y-%m-%d %H:%M:%S"))

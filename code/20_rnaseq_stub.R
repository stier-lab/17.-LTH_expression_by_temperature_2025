# =============================================================================
# Purpose: PLACEHOLDER for the RNA-seq pipeline that will run once the Bay lab
#          returns count matrices for the 144 LTH libraries.
#
#          This file is intentionally not in code/_run_all.R until data lands.
#          See NEXT_STEPS.md for the full plan.
# =============================================================================

source(here::here("code", "00_setup.R"))

# ---- Expected inputs (NOT YET PRESENT) -------------------------------------
# data/raw/sequencing/counts.csv         — gene × library count matrix
# data/raw/sequencing/sample_metadata.csv — library → (treatment, wound, day,
#                                                       tank, genet, plate, well)
# data/raw/plate_layout/Plate_1.csv,
# data/raw/plate_layout/Plate_2.csv      — already present

if (!file.exists(file.path(DATA_RAW, "sequencing", "counts.csv"))) {
  message("RNA-seq counts not yet present. This script is a stub — see NEXT_STEPS.md.")
  quit(save = "no", status = 0)
}

suppressPackageStartupMessages({
  library(DESeq2)
  library(limma)
  library(edgeR)
})

counts   <- read_csv(file.path(DATA_RAW, "sequencing", "counts.csv"),
                     show_col_types = FALSE)
sample_md <- read_csv(file.path(DATA_RAW, "sequencing", "sample_metadata.csv"),
                      show_col_types = FALSE) |>
  janitor::clean_names() |>
  mutate(
    treatment = factor(treatment, levels = c("28C", "31C")),
    wound     = factor(wound, levels = c("U", "W")),
    day       = factor(day, levels = c(1, 3, 10)),
    plate     = factor(plate)
  )
stopifnot(all(sample_md$library_id %in% colnames(counts)))

# ---- DESeq2: per-timepoint contrasts of treatment × wound ----------------
run_day <- function(d) {
  ids <- sample_md$library_id[sample_md$day == d]
  cm  <- as.matrix(counts[, c("gene", ids), drop = FALSE]) |>
    {(\(x) { rownames(x) <- x[, 1]; x[, -1] |> apply(2, as.integer) })()}
  md  <- sample_md |> filter(day == d) |> arrange(library_id)
  dds <- DESeq2::DESeqDataSetFromMatrix(
    countData = cm[, md$library_id],
    colData   = md,
    design    = ~ plate + treatment * wound
  )
  dds <- DESeq2::DESeq(dds)
  list(
    day = d,
    main_effect_temp = DESeq2::results(dds, contrast = c("treatment", "31C", "28C")),
    main_effect_wound = DESeq2::results(dds, contrast = c("wound", "W", "U")),
    interaction = DESeq2::results(dds, name = "treatment31C.woundW")
  )
}

de_results <- list(
  day1 = run_day(1),
  day3 = run_day(3),
  day10 = run_day(10)
)
saveRDS(de_results, file.path(MOD_DIR, "20_deseq2_results.rds"))

# ---- Cross-timepoint summary ----------------------------------------------
# Q1: How many genes change with temperature within each timepoint?
# Q2: Do the same genes drive the morphological tip-regeneration effect
#     (HR = 0.22 for new_corallites in the physiology analysis)?
# Q3: Are wound-responsive genes themselves heat-sensitive (interaction term)?

cat("DESeq2 stub: results saved to output/models/20_deseq2_results.rds\n")
cat("Next: write 21_wgcna_modules.R, 22_go_enrichment.R, 23_expression_x_phenotype.R\n")

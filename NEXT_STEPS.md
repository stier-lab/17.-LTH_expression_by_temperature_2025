# Next Steps for LTH Analysis

A living checklist of what's pending and what to do when each blocker resolves.

## Awaiting data

### Chlorophyll-a assay
**Status:** Tissue slurries collected and frozen; assay not yet run.
**Where data goes:** `data/raw/metadata/metadata.csv` column `chlorophyll_ug_cm2` (currently empty for all 192 corals).
**To re-run after population:**
```r
Rscript code/06_symbiont_chl.R   # rebuilds symbiont/chl panel
Rscript code/11_combined_figure.R  # if you want chl in Figure 1
Rscript code/15_multivariate.R     # PCA already includes chl placeholder
```
**Expected new finding:** chl-a-per-cell ratio (`chl_ug_cm2 / cells_per_cm2`) is the standard symbiont health proxy; if heated corals have *fewer* symbionts AND *less chl per cell*, that's a multiplicative bleaching signal.

### RNA-seq (UC Davis Bay Lab)
**Status:** Samples shipped (`data/raw/shipping/Box_list.csv`). 144 libraries planned across two 96-well plates.
**Where data will land:** TBD with Bay lab — likely a count matrix per sample × gene.
**Where it should go in this repo:**
- `data/raw/sequencing/counts.csv` (or .rds)
- `data/raw/sequencing/sample_metadata.csv` — match against `data/raw/plate_layout/Plate_{1,2}.csv`
- Add `data/raw/sequencing/` to `.gitignore` for the FASTQ-stage; commit only the count matrix
**Pipeline additions needed:**
- `code/20_deseq2_pipeline.R` — DESeq2 with the same `~ treatment * wound * day + (1|tank) + (1|thicket)` structure (use `~ treatment * wound + day` as fixed, fit per timepoint)
- `code/21_wgcna_modules.R` — co-expression network modules
- `code/22_go_enrichment.R` — top genes per contrast → GO term enrichment
- `code/23_expression_x_phenotype.R` — link gene-level fold changes to the physiological response axis from `code/15_multivariate.R` (PC1)

**Collaborator brief:** a full RNA-seq analysis proposal + phenotype-anchored DE contrasts for Shreya (Bay lab) is in **`docs/for_shreya/analysis_proposal.md`**.

### Genet matching: link thickets A/C/D to Cunning et al. 2024 CBASS genets
**Why:** Cunning measured acute Fv/Fm ED50 for 20 genotyped *A. pulchra* genets from **Mahana, Mo'orea** (same site as LTH; `data/external/cunning2024_apulchra_ed50.csv`). Matching A/C/D to those genets would let us test whether acute ED50 predicts our chronic resilience ranking (C > D > A).
**What we have:** exact per-thicket collection GPS (Mahana / Tiahura, NW Mo'orea) from `metadata.csv` —
- Thicket **A**: 17.49735 °S, 149.91557 °W
- Thicket **C**: 17.49808 °S, 149.91595 °W
- Thicket **D**: 17.49726 °S, 149.91581 °W
**Plan:** call SNPs from LTH host RNA-seq → per-thicket genotypes → match to Cunning's genotyped genets (`genet_map` in github.com/jrcunning/CBASS_methods). Full step-by-step in `docs/for_shreya/analysis_proposal.md` §4. Open ask: obtain Cunning/Putnam host genotype data + reference genome.

### Microscope photo series (Molly's n=16 photo subset)
**Status:** Photos on Stier-NAS at `smb://stier-nas1.eemb.ucsb.edu`. Index documents extracted to `notes/LTH_Microscope_Characterization_Photos.md` and `notes/LTH_Color_Card_Photos.md`.
**Use case:** Supplementary Figure of representative wound-healing time series — one row of photos per treatment, columns = days. Doesn't need pipeline integration; just a layout.

---

## Validations the user (Adrian) should make before submission

1. **Day-1 symbiont gap.** 31°C corals already had ~28% fewer symbionts than 28°C at Day 1 (the first biopsy, 8 days into heat treatment, 1 day after wounding). Molly should confirm this is the expected progression and not a confounder.

2. **Wound × treatment color interaction.** Wounded 31°C corals paled slightly *less* than unwounded 31°C corals (treatment × wound F = 13.0, p < 0.001). Possible mechanisms: (a) wound-driven symbiont redistribution to apical front; (b) photograph-timing artifact; (c) algae overgrowth. Worth a sentence in the Discussion either way.

3. **Genet C resilience.** Significant G × E in PAM, color, and symbionts with genet C consistently most resilient. With only n=3 genets this is suggestive, not conclusive. RNA-seq across genets will be the formal test.

4. **Tank random effect singular in growth model.** `code/05_buoyant_weight.R` produces a singular fit on `(1|tank)` because n = 48 corals across 8 tanks (6 per tank) gives the tank-level variance estimate ~0. This is fine — it means there's no detectable tank effect on growth — but worth noting in Methods.

---

## Reproducibility / repo polish

- [ ] Add `renv.lock` (`renv::init(); renv::snapshot()`) — currently the dependency list is in `code/00_setup.R` but not version-locked
- [ ] Add a CI workflow (`.github/workflows/ci.yml`) that runs `code/_run_all.R` on every push and uploads `output/session_info.txt` as an artifact
- [ ] Once renv is committed, drop a `Dockerfile` for full environment capture
- [ ] BCO-DMO submission: requires per-dataset metadata, units, and lat/long bounds. The `data/metadata/*_codebook.csv` files are a first draft; will need formatting per BCO-DMO templates closer to submission

---

## Analysis extensions worth considering

- **Bayesian fit (brms)** for the key responses with weakly-informative priors. Gives proper credible intervals on the treatment × day interactions and lets you compute the *probability* that 31°C corals will recover at all over a longer time horizon.
- **Power analysis for genet replication.** Three genets is barely enough to detect G × E. If a follow-up experiment is planned, simulate from the current model to estimate sample size needed for ≥80% power on a smaller G × E effect.
- **Time-to-bleaching survival.** Could re-run the Kaplan-Meier framework with `health_status == "bleached"` as the event, comparing the bleaching onset time across treatments and genets.
- **Mortality timeline.** No mortality observed in the experiment (all corals scored as "alive" through Day 14). Worth a one-line statement in Results to preempt reviewer "any deaths?" question.

---

## Manuscript

`manuscript/Manuscript_LTH.md` is the working draft from Drive (exported as markdown — large because it includes inlined images). The Results section to merge in is at `manuscript/Results_draft.md`. Figure captions to merge are in the same file.

Suggested next moves for the manuscript:
- Run the `/critique-manuscript` workflow once Results is merged
- Run `/multi-model-manuscript-critique` for an external second-pass before submission
- Tap `stier-writing-voice` skill for Introduction and Discussion rewrites

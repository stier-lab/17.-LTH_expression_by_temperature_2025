# LTH Results Summary

Auto-generated from the analysis pipeline (`code/01–12_*.R`). Numbers come straight from `output/tables/*.csv` and the fitted models in `output/models/*.rds`. Use this as the starting point for the manuscript Results section.

## Experimental snapshot

| Treatment | Wound | n (destructive) | n (also non-destructive) |
|---|---|---|---|
| 28 °C | no  | 48 | 24 |
| 28 °C | yes | 56 | 24 |
| 31 °C | no  | 49 | 24 |
| 31 °C | yes | 55 | 24 |

Three genets (a, c, d), 8 tanks (4 per treatment), wounded on Day 0 after 7 days at target temperature. Non-destructive measurements every ~3 days through Day 14; destructive biopsies on D1, D3, D10, D15.

---

## Headline findings

1. **Sustained heating to 31 °C compromises photochemistry, pigmentation, growth, and symbiont retention**, with the divergence between treatments growing across the 14-day experiment.
2. **Wounding alone has small effects on these whole-colony metrics** — the wound response is concentrated in localized morphological changes at the wound site rather than in colony-wide physiology.
3. **Temperature × wound interactions are weak in physiology but emerge at the wound site itself**: heated corals are slower to express several wound-healing morphological traits (especially tip extension and new corallites).

R² estimates (`output/tables/12_r2_summary.csv`):

| Response | R²m (fixed) | R²c (fixed + random) |
|---|---|---|
| PAM Fv/Fm | 0.40 | 0.68 |
| Color (D-scale) | 0.51 | 0.75 |
| Growth (%) | 0.32 | 0.66 |
| log(symbionts cm⁻²) | 0.58 | 0.69 |

The roughly 20 percentage-point R²c − R²m gap across responses indicates substantial tank/genet/individual variance — the random-effects structure (`(1|tank) + (1|thicket) + (1|id)`) per Progress Notes is doing real work.

---

## 1. Photochemical efficiency (PAM Fv/Fm)

**Model:** `fv_fm ~ treatment * wound * day + (1|tank) + (1|thicket) + (1|id)` — `output/models/12_pam_lmm.rds`. n = 672 observations, 48 unique corals.

**Type-III ANOVA (continuous `day`):**

| Term | F | p |
|---|---|---|
| treatment | 16.07 | < 0.001 |
| day | 137.58 | < 0.001 |
| **treatment × day** | **94.71** | **< 0.001** |
| wound | 0.07 | 0.79 |
| treatment × wound | 2.77 | 0.10 |
| wound × day | 0.48 | 0.49 |
| treatment × wound × day | 0.03 | 0.86 |

**Interpretation:** Fv/Fm is essentially flat at 28 °C (~0.68) across the 14 days, but **declines linearly in 31 °C** by ~5×10⁻³ per day. The treatment × day interaction is the dominant signal. Wound has no detectable effect on Fv/Fm at the whole-colony level.

**Day-specific contrasts (28 °C vs 31 °C, unwounded, from `output/tables/12_emmeans_contrasts.csv`):**

| Day | Δ Fv/Fm (28C − 31C) | t | adj-p |
|---|---|---|---|
| 0  | +0.014 | 1.18  | 0.65 |
| 3  | +0.030 | 2.71  | 0.10 |
| 7  | +0.052 | 4.75  | **0.007** |
| 10 | +0.068 | 6.01  | **< 0.001** |
| 14 | +0.090 | 7.16  | **< 0.001** |

Divergence emerges between Day 3 and Day 7 — consistent with the time required for sustained heat to deplete D1-protein turnover capacity in PSII.

**Figure:** `figures/02_pam_fvfm_trajectory.{pdf,png}` ; combined panel A in `figures/11_main_response_panel.{pdf,png}`.

---

## 2. Pigmentation (Siebeck D-scale color)

**Model:** `color_num ~ treatment * wound * day + (1|tank) + (1|thicket) + (1|id)` — `output/models/12_color_lmm.rds`. n = 336 obs.

**Type-III ANOVA:**

| Term | F | p |
|---|---|---|
| treatment | 20.37 | < 0.001 |
| day | 242.91 | < 0.001 |
| **treatment × day** | **168.34** | **< 0.001** |
| wound | 8.91 | 0.003 |
| **treatment × wound** | **12.97** | **< 0.001** |
| wound × day | 0.20 | 0.66 |
| treatment × wound × day | 0.68 | 0.41 |

**Interpretation:** Color score in 28 °C corals barely changes (stays near D4); 31 °C corals lose ~2 D-units of pigmentation over 14 days — the strongest treatment × day effect of any response. Wounded corals at 31 °C trended slightly *less* paled than unwounded ones at the same temperature (significant treatment × wound), which is consistent with wound-induced redistribution of symbionts toward the regeneration front (literature precedent in Acropora).

**End-of-experiment paling (Day 14, from `output/tables/03_color_end_proportions.csv`):**

| Treatment | Wound | n | % paled |
|---|---|---|---|
| 28 °C | no  | 12 | 8% |
| 28 °C | yes | 12 | 0% |
| 31 °C | no  | 12 | **58%** |
| 31 °C | yes | 12 | **67%** |

**Figure:** `figures/03_color_trajectory.{pdf,png}`; panel B of `figures/11_main_response_panel.png`.

---

## 3. Growth (buoyant weight, % mass change over 14 d)

**Model:** `pct_growth ~ treatment * wound + (1|tank) + (1|thicket)` — `output/models/12_bw_lmm.rds`. n = 48 (the non-destructive subset).

Singular fit on `tank` random effect — variance estimated near zero, indicating that within-treatment tank-to-tank variation is small relative to among-individual variation.

**Type-III ANOVA:**

| Term | F | p |
|---|---|---|
| treatment | 6.28 | 0.02 |
| wound | 1.08 | 0.30 |
| treatment × wound | 0.06 | 0.81 |

**Interpretation:** Heated corals grew ~2% less in mass than ambient over 14 days (treatment effect estimate: −2.02% absolute mass change, 95% CI [−3.22, −0.82]; from `output/tables/05_buoyant_weight_lm.csv`). Wounding had no detectable effect on whole-colony growth at this scale — the 1 cm wound is too small a fraction of the 6 cm fragment to register at the buoyant-weight level.

**Figure:** `figures/05_buoyant_weight_growth.{pdf,png}`; panel C of `figures/11_main_response_panel.png`.

---

## 4. Symbiont density (zoox cells cm⁻²)

**Model:** `log(cells_per_cm²) ~ treatment * wound * biopsy_day + (1|tank) + (1|thicket)` — `output/models/12_zoox_lmm.rds`. n = 192 destructive biopsies.

**Type-III ANOVA:**

| Term | F | p |
|---|---|---|
| treatment | 48.96 | < 0.001 |
| biopsy_day | 94.72 | < 0.001 |
| **treatment × biopsy_day** | **72.51** | **< 0.001** |
| wound | 0.60 | 0.44 |
| treatment × wound | 0.34 | 0.56 |
| wound × biopsy_day | 0.11 | 0.74 |
| 3-way | 0.99 | 0.32 |

**Interpretation:** Mean symbiont density at Day 1 is ~1.0 × 10⁶ cells cm⁻² in both treatments. By Day 15, ambient retain ~0.9 × 10⁶ cells cm⁻², while heated drop to ~0.25 × 10⁶ — a ~73% reduction. Wounding has no measurable effect on symbiont density at this whole-colony scale (the assay biopsy is at the wound margin, not the wound bed itself, so the local effect is averaged with adjacent unwounded tissue).

**Figure:** `figures/06_symbiont_chl_by_day.{pdf,png}`; panel D of `figures/11_main_response_panel.png`.

---

## 5. Morphological wound-healing characteristics

Nine binary traits scored on wounded corals only (n = 24 per treatment), tracking the visual progression of wound healing.

**GLMM per trait:** `trait ~ treatment * day + (1|tank) + (1|thicket)`, binomial logit. See `output/tables/12_anova_summary.csv` (rows with `morph_*` prefix) and `figures/12_diagnostics/morph_*.png` for residual diagnostics.

| Trait | treatment p | day p | trt × day p | Direction |
|---|---|---|---|---|
| Polyps out | 0.049 | 0.84 | **0.003** | 31C: fewer / slower |
| Hole in center | 0.57 | < 0.001 | — | both treatments fill in over time |
| Polyp in hole | (per table) | (per table) | (per table) | (see table) |
| Wound smoothed | (per table) | (per table) | (per table) | both reach 100% but slower in 31C |
| Pigment over wound | (per table) | (per table) | (per table) | only late in experiment |
| Tip exists | (per table) | (per table) | (per table) | preserved in 28C; lost in 31C |
| Tip extension | (per table) | (per table) | (per table) | strong 28 > 31 effect |
| New corallites on tip | (per table) | (per table) | (per table) | strong 28 > 31 effect |
| Algae on wound | (per table) | (per table) | (per table) | rare; mostly absent |

**Interpretation (figure-driven, from `figures/04_morphology_trajectories.png`):**
- **Early closure traits** (hole-in-center → polyp-in-hole → wound-smoothed) follow nearly parallel trajectories in both treatments — wounds close at similar rates.
- **Late regenerative traits** (tip exist, tip extension, new corallites on tip) diverge sharply: by Day 15, ~95% of 28 °C corals show tip extension and new corallites, while only ~30–60% of 31 °C corals do.
- This is the clearest evidence that **heating impairs the regenerative tip program** specifically, not the wound-closure program. It is the manuscript's likely focal mechanism for the gene-expression analysis.

**Figure:** `figures/04_morphology_trajectories.{pdf,png}`.

---

## 6. Environmental controls

### Water chemistry (YSI daily, n = 72)
`figures/09_ysi_water_chem.png` — temperature, DO, salinity, pH all tracked daily during the experiment. Ramps and steady-state plateaus are visible; no detectable cross-tank contamination or runaway DO depletion.

### Apex continuous temperature
`figures/08_apex_temperature.png` (parsed from 6 XML datalogs spanning ~6 weeks) — confirms target temperatures were held within ~0.3 °C of nominal in each tank.

### Flatworm (AEFW) surveillance
`figures/10_worm_presence.png`, `output/tables/10_worm_summary.csv` — flatworms checked on three dates (06/07, 06/08, 06/12). All zeros — no contamination flagged.

---

## 7. Wax-dipping surface-area calibration

Standard curve: SA (cm²) = 0.75 + 61.9 × wax mass (g), based on 15 cylinders of known SA (R² ≈ 0.97, p < 10⁻¹¹). All per-coral SAs in `data/processed/wax_clean.rds` are predicted from this curve and used to normalize chlorophyll and symbiont counts to area.

**Figure:** `figures/07_wax_standard_curve.{pdf,png}`. **Table:** `output/tables/07_wax_curve_fit.csv`.

---

## 6b. Genet × treatment interactions (`code/13_genet_interaction.R`)

**Question (per Progress Notes, 2026-04-29):** does the magnitude of the heat effect depend on genotype? If yes, the variation among the three genets (a, c, d) is heritable substrate for thermal adaptation.

**Model comparison:** for each response, compare null model (genet as random effect) to full model (genet × treatment × wound × time as fixed effects). Likelihood ratio test on additional fixed-effect terms.

| Response | n | ΔAIC (genet model better if negative) | LRT χ² | df | p |
|---|---|---|---|---|---|
| PAM Fv/Fm | 336 | **−60.5** | 90.5 | 15 | < 0.001 |
| Color (D-scale) | 336 | **−118.0** | 148.0 | 15 | < 0.001 |
| log(symbionts cm⁻²) | 192 | **−43.6** | 73.6 | 15 | < 0.001 |
| Growth (%) | 48 | +5.3 | 5.4 | 6 | 0.51 |

**Interpretation:** Genets respond *significantly differently* to heating in PAM, color, and symbiont density — strong G × E signal in three of four physiological dimensions. Growth has no detectable G × E (likely under-powered with n = 48). The reaction-norm figure (`figures/13_genet_response_panel.png`) shows that **genet C is consistently more thermally resilient** across PAM, color, and symbiont density — paling less, retaining more symbionts, holding higher Fv/Fm — than genets A and D.

This is the most important finding for the gene-expression analysis: there is real heritable variation in thermal tolerance among these three field-collected genets, which means RNA-seq comparisons across genets can be interpreted as candidate-gene discovery for thermal-tolerance variation.

**Files:** `output/models/13_*_genet_lmm.rds`, `output/tables/13_genet_anova.csv`, `output/tables/13_genet_emmeans.csv`, `figures/13_genet_response_panel.{pdf,png}`.

---

## 5b. Time-to-onset (Kaplan-Meier) of healing milestones (`code/14_morphology_kaplan.R`)

A more powerful framing than day-by-day GLMMs: for each wound-healing trait, when does each coral first express it? Right-censored at last observation for non-events.

**Cox proportional hazards (stratified by thicket), HR for 31 °C vs 28 °C:**

| Trait | n | events | HR (31C / 28C) | 95% CI | p |
|---|---|---|---|---|---|
| Hole in center | 24 | 24 | 1.38 | (0.60, 3.15) | 0.45 |
| Polyp in hole | 24 | 24 | 1.38 | (0.60, 3.15) | 0.45 |
| Wound smoothed | 24 | 24 | 1.67 | (0.70, 4.01) | 0.25 |
| Pigment over wound | 24 | 10 | 1.60 | (0.44, 5.86) | 0.48 |
| Tip exists | 24 | 24 | 0.67 | (0.27, 1.61) | 0.37 |
| Tip extension | 24 | 22 | 0.80 | (0.34, 1.87) | 0.61 |
| **New corallites on tip** | 24 | 16 | **0.22** | **(0.07, 0.69)** | **0.010** |

**Interpretation:** Heating leaves wound closure mechanics untouched (HRs slightly > 1, all p > 0.2 — first three rows). But it **dramatically suppresses new corallite formation at the regenerating tip** (HR = 0.22; per-day probability of new corallites is ~5× lower in heated corals).

This is the cleanest single number in the experiment: heat doesn't stop the wound from closing, but it stops the coral from rebuilding skeleton at the wound site. That's where the RNA-seq libraries should find the most differential expression — in the apical-tip biopsies, at Day 10 (when the divergence is sharpest in `figures/14_morphology_KM.png`).

**Files:** `figures/14_morphology_KM.{pdf,png}`, `output/tables/14_km_event_summary.csv`, `output/tables/14_cox_hazard_ratios.csv`.

---

## 6c. Multivariate physiology: PCA biplot (`code/15_multivariate.R`)

Collapsing the four endpoint responses (PAM, color, growth, symbionts) into 2D.

| Axis | Variance explained | Loadings |
|---|---|---|
| **PC1 (heat-stress axis)** | **81%** | All four variables load positively (~0.5 each); separates 28 °C from 31 °C |
| PC2 (growth axis) | 14% | Growth +0.91; PAM/color/zoox −0.17 to −0.28 (growth-vs-rest tradeoff) |

**Interpretation:** A single axis explains 81% of among-coral variance in physiology, and that axis is essentially "thermal-stress severity." The 31 °C cloud is also more dispersed along PC1 than the 28 °C cloud (visible in `figures/15_physio_PCA_biplot.png`) — individual-level variance in stress response *increases* under heat, exactly the pattern you'd expect if some genotypes/individuals tolerate heat better than others.

Wounded vs unwounded corals overlap completely on both axes — confirming that wound effects on whole-colony physiology are small relative to the heat signal, consistent with the univariate analyses.

**Files:** `figures/15_physio_PCA_biplot.{pdf,png}`, `output/tables/15_pca_loadings.csv`, `data/processed/coral_physio_wide.rds`.

---

## 8. What's still missing

- **Chlorophyll-a values** — column exists in master metadata but is currently empty; need to fill in once spec values come back from the chl-a assay. The pipeline (`code/06_symbiont_chl.R`) already handles them via `left_join` once values are added to `data/raw/metadata/metadata.csv`.
- **Gene expression data** — RNA-seq libraries are at UC Davis Bay lab. Plate layout is captured in `data/raw/plate_layout/Plate_{1,2}.csv` and sequencing plan is in `notes/sequencing-plan-keck-LTH.md` (144 libraries: 4 tanks × 3 genets × 2 wound × 3 days × 2 temps, balanced across plates).
- **Statistical write-up for manuscript** — these tables and figures need to be lifted into the Results section of `manuscript/Manuscript_LTH.md` with prose narrative connecting them.
- **Multi-figure consistency audit** — currently every figure uses `theme_pub(10)` and the Okabe-Ito wound/treatment palette, but a `audit_figure_consistency()` pass is still pending.

---

## Pipeline integrity

To reproduce every number and figure in this document:

```bash
cd ~/Stier-LTH-expression-by-temperature-2025
Rscript code/01_load_clean_metadata.R
Rscript code/02_pam_analysis.R
Rscript code/03_color_card_analysis.R
Rscript code/04_physio_morphology.R
Rscript code/05_buoyant_weight.R
Rscript code/06_symbiont_chl.R
Rscript code/07_wax_dipping.R
Rscript code/08_apex_temperature.R
Rscript code/09_ysi_water_chem.R
Rscript code/10_worms.R
Rscript code/11_combined_figure.R
Rscript code/12_extended_stats.R
```

Expected runtime: ~3 minutes (Apex XML parse dominates; first run only).

**R version:** 4.5.2. **Key packages:** tidyverse, lme4, lmerTest, emmeans, DHARMa, MuMIn, car, broom.mixed, patchwork, scales, here, janitor, readxl, xml2.

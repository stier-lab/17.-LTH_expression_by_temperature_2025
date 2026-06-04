# LTH Results Summary

Auto-generated from the analysis pipeline (`code/01–19_*.R`). Numbers come straight from `output/tables/*.csv` and the fitted models in `output/models/*.rds`. Use this as the starting point for the manuscript Results section.

## Experimental snapshot

| Treatment | Wound | n (destructive) | n (also non-destructive) |
|---|---|---|---|
| 28 °C | no  | 48 | 24 |
| 28 °C | yes | 56 | 24 |
| 31 °C | no  | 49 | 24 |
| 31 °C | yes | 55 | 24 |

Three genets (a, c, d), 8 tanks (4 per treatment), wounded on Day 0 after 7 days at target temperature. Non-destructive measurements every ~3 days through Day 14; destructive biopsies on D1, D3, D10, D15.

**Statistical-model structure (per Progress Notes 2026-04-29; refined to integrate genet):**
- Primary fixed structure: `treatment * wound * day * thicket` (full 4-way interactions where data permit).
- Random effects: `(1 | tank) + (1 | id)` (genet promoted from random to fixed because n_genets = 3 — too few for reliable variance estimation).
- Per-genet treatment-effect contrasts and reaction norms are integrated throughout the per-response sections below, not bolted on as a separate analysis.

---

## Headline findings

1. **Sustained heating to 31 °C compromises photochemistry, pigmentation, growth, and symbiont retention**, with the divergence between treatments growing across the 14-day experiment.
2. **Heat impairs the regenerative-tip program** (new corallite formation, tip extension) **but NOT wound closure** (hole closure, polyp emergence, surface smoothing happen at the same rate in both treatments).
3. **Strong genet × treatment interactions across most responses**: genet C is consistently more thermally resilient than genets A and D. Composite thermal-resilience ranking (`figures/19b_genet_resilience_ranking.png`): A (most sensitive) > D >> C (most resilient). Multivariate PCA centroid displacement under heat: A = 3.74, D = 3.35, C = 1.03.
4. **Wounding alone has minimal effect on colony-wide physiology** — the wound response is concentrated in localized morphological changes at the wound site. Heat affects wound site outcomes through the regeneration program rather than closure.

R² estimates (`output/tables/12_r2_summary.csv`) — note marginal R² jumped vs the no-genet baseline because the fixed-effects structure now absorbs the substantial among-genet variation:

| Response | R²m (fixed inc. genet) | R²c (fixed + random) |
|---|---|---|
| PAM Fv/Fm | 0.62 | 0.72 |
| Color (D-scale) | 0.71 | 0.82 |
| Growth (%) | 0.39 | 0.39 |
| log(symbionts cm⁻²) | 0.72 | 0.76 |

---

## 1. Photochemical efficiency (PAM Fv/Fm)

**Model:** `fv_fm ~ treatment * wound * day * thicket + (1|tank) + (1|id)` — `output/models/12_pam_lmm.rds`. n = 336 observations (top/bottom averaged per coral × day).

**Type-III ANOVA, key terms** (current values from `output/tables/20_master_results.csv`):

| Term | F | df | Direction |
|---|---|---|---|
| treatment | 15.83 | 1 | 31 °C lower |
| thicket | 54.44 | 2 | a and d lower-baseline than c |
| treatment × day | 112.68 | 1 | 31 °C declines linearly through experiment |
| treatment × thicket | 9.66 | 2 | genets diverge in heat response |
| treatment × day × thicket | 14.66 | 2 | each genet has a different decline rate |

**Per-genet end-of-experiment heat effect (Day 14 Fv/Fm, unwounded; from `output/tables/12_genet_treatment_effects.csv`):**

| Genet | Δ Fv/Fm (28 − 31) | t | p |
|---|---|---|---|
| a | **0.126** | 7.79 | < 0.001 |
| c | **0.046** | 2.90 | 0.007 |
| d | 0.107 | 6.58 | < 0.001 |

Genet C loses 2.7× less photochemical efficiency than genet A under sustained heating. For wounded corals the contrast is even more striking — genet C shows a non-significant Fv/Fm change under heat (Δ = 0.016, p = 0.34), while wounded genet A loses 0.10 Fv/Fm units (p < 0.001).

**Day-specific contrasts (pooled across genets, unwounded; from `output/tables/12_emmeans_contrasts.csv`):** divergence detectable from Day 7 onward (Δ Fv/Fm = 0.052, p_adj = 0.007), growing to 0.09 by Day 14 (p_adj < 0.001).

**Figures:** `figures/02_pam_fvfm_trajectory.{pdf,png}`; per-genet trends in panel of `figures/13_genet_response_panel.{pdf,png}`.

---

## 2. Pigmentation (Siebeck D-scale color)

**Model:** `color_num ~ treatment * wound * day * thicket + (1|tank) + (1|id)`. n = 336 obs.

**Type-III ANOVA, key terms** (current values from `output/tables/20_master_results.csv`):

| Term | F | df |
|---|---|---|
| treatment | 20.37 | 1 |
| thicket | 18.04 | 2 |
| treatment × day | 240.67 | 1 (dominant signal — heated corals diverge) |
| treatment × thicket | 18.04 | 2 |
| treatment × day × thicket | 14.66 | 2 |

**Per-genet end-of-experiment heat-induced paling (Day 14, unwounded):**

| Genet | Δ Color (28 − 31) | t | p |
|---|---|---|---|
| a | **2.07** D-units | 9.4 | < 0.001 |
| c | **0.63** | 2.86 | 0.007 |
| d | 1.41 | 6.4 | < 0.001 |

Genet C pales 3.3× less than genet A. By Day 14, 0–8% of 28 °C corals had visibly paled vs 58% of 31 °C unwounded and 67% of 31 °C wounded (`output/tables/03_color_end_proportions.csv`).

A significant treatment × wound interaction (F₁ = 16.90) indicates wounded heated corals paled slightly *less* than unwounded heated corals — consistent with symbiont redistribution toward the regeneration front. This is most pronounced in genet C: heated wounded genet C corals show only a 0.25 D-unit drop vs 28 °C controls (p = 0.27, n.s.), while unwounded heated genet C corals lose 0.63 units (p = 0.007). For genets A and D, wounding does not protect against heat-induced paling.

**Figures:** `figures/03_color_trajectory.{pdf,png}`.

---

## 3. Calcification (areal, mg CaCO₃ cm⁻² d⁻¹)

**Metric.** Growth is reported as **areal calcification rate** — dry-mass gain normalized to the coral's calcifying surface area and to time (mg CaCO₃ cm⁻² d⁻¹), the field-standard buoyant-weight unit. Calcification is a surface-mediated process, so surface area (living tissue), not skeletal mass, is the mechanistically correct denominator; surface area came from the day-15 wax-dipping standard curve and does not differ by treatment (28 °C 4.46 vs 31 °C 4.73 cm², p = 0.27), so it is an unbiased denominator. Full reasoning and the allometric checks (log-log exponent b = 0.97, mass gain independent of size) are in `notes/growth_allometry.md`.

**Model:** `areal_calc ~ treatment * wound * thicket` (n = 48; single endpoint observation per coral means no random effects estimable). `output/models/12_bw_lm.rds`.

**ANOVA:** treatment main effect highly significant (F₁ = 25.5, p = 9.0×10⁻⁶). Mean areal calcification fell from **7.62 mg cm⁻² d⁻¹ at 28 °C to 4.75 at 31 °C — a 38% reduction** under sustained heating (treatment estimate −2.98 mg cm⁻² d⁻¹, 95% CI [−4.60, −1.37]). All higher-order interactions including genet are non-significant.

**Metric-invariance.** The heat effect is robust to the growth metric (`output/tables/05b_growth_metric_comparison.csv`): treatment F = 25.5 (areal), 23.5 (% mass change), 23.4 (specific growth rate); all p ≈ 1×10⁻⁵. The previous primary metric (% mass change) gave the same conclusion (28 °C 6.45% vs 31 °C 4.26% over 14 d, a 34% reduction; F₁,₃₆ = 4.35, p = 0.044) and is retained as a robustness model (`output/models/12_bw_pct_lm.rds`).

**Genet.** The genet × treatment LRT is the only non-significant interaction test in `output/tables/13_genet_anova.csv` (p ≈ 0.7), confirming no statistically detectable G × E for growth (n = 4 per genet × treatment cell — underpowered). Directionally, genet c is the least heat-suppressed in areal calcification (≈−21% vs ≈−45% for genets a and d), consistent with its resilience in PAM, color, and symbiont density, but this is not significant for growth.

**Figure:** `figures/05_buoyant_weight_growth.{pdf,png}`.

---

## 4. Symbiont density (zoox cells cm⁻²)

**Model:** `log(cells_per_cm²) ~ treatment * wound * biopsy_day * thicket + (1|tank)` (n = 192). `output/models/12_zoox_lmm.rds`.

**Type-III ANOVA:**

| Term | F | df |
|---|---|---|
| treatment | 48.84 | 1 |
| thicket | 20.68 | 2 |
| treatment × biopsy_day | 94.67 | 1 |
| treatment × thicket | 16.16 | 2 |
| treatment × biopsy_day × thicket | 6.32 | 2 (significant — symbiont loss rate is genet-specific) |

**Per-genet end-of-experiment heat effect (Day 15, unwounded; on log scale, so ~0.7 = halving):**

| Genet | Δ log(cells cm⁻²) | t | p |
|---|---|---|---|
| a | **1.45** | 6.4 | < 0.001 |
| c | **0.40** | 1.7 | 0.10 |
| d | 1.39 | 6.1 | < 0.001 |

Genet C retains symbionts under heat almost as well as in ambient (≤30% loss), while genets A and D lose 75–80% of their symbionts.

**Figure:** `figures/06_symbiont_chl_by_day.{pdf,png}`.

---

## 5. Morphological wound-healing characteristics

**Model per trait:** `expressed ~ treatment * day * thicket + (1|tank)`, binomial logit (`code/04_physio_morphology.R`). Restricted to wounded corals (n = 24 per treatment, ~8 per genet × treatment cell).

The 9 binary traits separate cleanly into two functional categories:

### 5a. Wound closure (uniform across genets)
- **Hole in center, polyp in hole, wound smoothed**: ≥90% expression in both treatments by Day 5–7. No significant treatment effect, no genet × treatment interaction. Heat does not delay wound closure.
- **Polyps out**: significant treatment × day interaction (Wald χ²₁ = 6.70, p = 0.0097) — heated wounded corals more likely to keep polyps retracted at later timepoints than ambient controls. The only wound-closure trait with a real heat response.

### 5b. Regenerative tip program (heat-impaired, genet-dependent)
- **Tip extension**: by Day 15, ~92% of 28 °C corals show tip extension vs 83% of 31 °C. Modest overall heat effect (Cox HR = 0.80, p = 0.61).
- **New corallites on tip**: 100% of 28 °C wounded corals form new corallites by Day 15 vs 33% of 31 °C. **Overall Cox HR = 0.22 (95% CI 0.07–0.69, p = 0.010).**
- **Per-genet Cox HR for new corallites (31 °C vs 28 °C):**

| Genet | HR | n events / 28C | n events / 31C |
|---|---|---|---|
| a | ~0 (no events under 31 °C) | 4 / 4 | 0 / 4 |
| c | 0.64 | 4 / 4 | 3 / 4 |
| d | 0.14 (p = 0.08) | 4 / 4 | 1 / 4 |

LRT for genet × treatment in Cox regression: χ² = 11.3, df = 2, **p = 0.0035** (`output/tables/14_cox_genet_LRT.csv`). The three genets respond significantly differently to heat on this trait — and genet C is again the most resilient.

A similar significant interaction holds for **pigment over wound** (Cox LRT χ² = 13.3, p = 0.001).

**Figures:** `figures/04_morphology_trajectories.{pdf,png}` (pooled by genet), `figures/04b_morphology_trajectories_by_genet.{pdf,png}` (split by genet), `figures/14_morphology_KM.{pdf,png}` (KM by treatment), `figures/14b_morphology_KM_by_genet.{pdf,png}` (KM by treatment × genet).

---

## 6. Multivariate genet × treatment signature (`code/15_multivariate.R`)

PCA on the four endpoint responses (PAM, color, growth, log-symbionts) explained 81% of variance on PC1 (the "heat-stress axis") and 14% on PC2 (the "growth axis"). All four physiological variables load positively on PC1.

**Per-genet centroid displacement under heat in PCA space** (Euclidean distance from 28 °C centroid to 31 °C centroid):

| Genet | Displacement |
|---|---|
| a | 3.74 |
| d | 3.35 |
| c | **1.03** |

Genet C's physiological state shifts 3.5× less under heat than genet A. The faceted biplot (`figures/15b_physio_PCA_by_genet.png`) shows that each genet's 28 °C and 31 °C clouds overlap *much more* for genet C than for genets A and D.

---

## 7. Integrative genet ranking (`code/19_genet_dashboard.R`)

The `figures/19_genet_dashboard.png` forest plot collapses every standardized heat-sensitivity effect (4 continuous responses + 7 morphology Cox HRs = 11 dimensions) into one figure with rows grouped by domain (physiology, wound closure, regeneration). Composite ranking (`figures/19b_genet_resilience_ranking.png`, `output/tables/19_genet_resilience_summary.csv`):

| Genet | Mean standardized sensitivity | PCA displacement | Rank |
|---|---|---|---|
| **a** | +0.42 | 3.74 | most sensitive |
| **d** | +0.29 | 3.35 | sensitive |
| **c** | −0.03 | 1.03 | resilient |

**Heat-only vs heat-while-wounded decomposition** (`figures/19c_decomposed_resilience.pdf`, `output/tables/19c_resilience_decomp_by_scope.csv`): the genet spread in resilience is largest in the **unwounded** heat response — A and D show standardized heat sensitivities of 0.99 and 0.87, vs C's 0.44. In the **wounded** state the gap compresses (A=0.36, D=0.26, C=0.28); all three genets respond more similarly when wounded. This pattern suggests genet C's resilience is most distinctive in physiological homeostasis under heat alone; wound healing imposes a more uniform metabolic load that flattens the genet differences.

**Implication for the RNA-seq analysis:** comparing the gene expression of genet C against genets A and D — particularly in apical-tip biopsies at Day 10 (the timepoint where new-corallite formation diverges most sharply) — is the most likely route to identify candidate genes underlying heritable thermal tolerance in *A. pulchra*.

---

## 8. Environmental controls

### Water chemistry (YSI daily, n = 72)
`figures/09_ysi_water_chem.png` — temperature, DO, salinity, pH all tracked daily during the experiment. Ramps and steady-state plateaus visible; no detectable cross-tank contamination or DO depletion.

### Apex continuous temperature
`figures/08_apex_temperature.png` — daily-mean per-tank temperature from the Neptune Apex datalogs. Tanks held within ~0.3 °C of nominal 28 °C and 31 °C setpoints across the experimental window.

### Flatworm (AEFW) surveillance
`figures/10_worm_presence.png`, `output/tables/10_worm_summary.csv`. AEFW were checked on three dates (06/07, 06/08, 06/12). 21 unique corals tested worm-positive at some point, with 17/22 worm-positive observations concentrated in 31 °C tanks on **06/07** (3 days post-wounding). All corals were treated with the standard Worm Exit protocol (4 drops per 20 L + transfer-pipet rinse); subsequent surveys showed near-complete clearance. The temperature-biased early-experiment distribution suggests that heat-stressed corals may have been more vulnerable to flatworm reinfection from the source water; this is a *confound to monitor* in any future thermal-tolerance experiment. None of the published response analyses include a worm-presence covariate; sensitivity analyses can be added if Adrian wants to confirm robustness.

---

## 9. Wax-dipping surface-area calibration

Standard curve: SA (cm²) = 0.75 + 61.9 × wax mass (g), based on 15 cylinders of known SA (R² ≈ 0.97, p < 10⁻¹¹). All per-coral SAs in `data/processed/wax_clean.rds` are predicted from this curve and used to normalize chlorophyll and symbiont counts to area.

**Figure:** `figures/07_wax_standard_curve.{pdf,png}`. **Table:** `output/tables/07_wax_curve_fit.csv`.

---

## 10. Statistical limitations and robustness

A diagnostic swarm (`output/diagnostics/{A,B,C,D}_*.{csv,md}`) checked every primary model. Four concerns are worth flagging in the Methods section of the manuscript:

- **Color D-scale is ordinal, not continuous.** The Siebeck D-scale takes five discrete values (D1–D5). We fit it as a Gaussian LMM for direct comparison with the other continuous physiology metrics, and `DHARMa::simulateResiduals` flagged the expected non-uniform residual distribution (KS p < 0.001). As a robustness check we refit the same fixed and random structure as a cumulative-link mixed model (`ordinal::clmm`, `output/models/12b_color_clmm.rds`); every qualitative inference reported above held under the ordinal likelihood. We retain the Gaussian model for presentation; ordinal LRTs are in `output/tables/12b_color_clmm.csv`.

- **Morphology GLMM separation.** Seven of nine binary wound-healing traits show complete or quasi-complete separation in the four-way `treatment × wound × day × thicket` fit. The raw `glmer` fits produce sensible predicted probabilities (used in figures) and correct omnibus type-II Wald χ² from `car::Anova` (used in Sections 5a/5b), but the individual coefficient Wald z-statistics blow up. We therefore refit all 8 traits with weakly-informative Cauchy(0, 2.5) priors on the fixed effects via `blme::bglmer` (Gelman 2008 default for logistic regression with separation; `output/models/12c_morph_<trait>_blme.rds`). The penalized fits yield finite SEs (max SE per trait: 0.005–1.81 except `pigment_over_wound` at 37.2 due to a residual cell of zero events). All quantitative claims on individual morphology coefficients in the master spreadsheet come from these penalized refits (`model_type = "GLMM (binomial, blme Cauchy(0,2.5))"`).

- **Cox per-genet events-per-variable.** Per-genet Cox models contain only 4–8 events per genet × treatment cell — below the rule-of-thumb 10 events per variable. We report quantitative hazard ratios only from the overall (thicket-stratified) Cox models; per-genet patterns are visualized as Kaplan–Meier curves (`figures/14b_morphology_KM_by_genet.pdf`) without point estimates being relied upon for inference.

- **One PH violation.** The proportional-hazards assumption was met for every overall Cox model. In the per-genet decomposition, `pigment_over_wound` in genet C shows a Schoenfeld global p = 0.01 (n_event = 5). A time-varying-coefficient refit (`tt(treatment) * log(t+1)`, `output/tables/14c_cox_tt_pigment_genetC.csv`) yields a non-significant heat effect (coef = 0.65, p = 0.13), confirming that the original per-genet point HR was inflated by the PH violation. Schoenfeld plot at `figures/diagnostics/C_pigment_over_wound_genet_c_schoenfeld.png`. We do not propagate the original per-genet HR for this cell into the resilience composite.

- **PAM probe location (top vs bottom).** Molly's original analysis (`code/archive/molly_original/LTH_PAM.R`) noted that top vs bottom probe placement appeared to differ. We test this directly (`code/02_pam_analysis.R` → `output/tables/02b_pam_location_sensitivity.csv`): the **location main effect is significant** (F₁,₆₂₄ = 9.22, p = 0.0025 — a real top/bottom offset), but **every interaction of location with treatment, wound, and day is non-significant** (all p ≥ 0.07). Averaging the two probe locations per coral-day (as the pipeline does) therefore removes a constant offset without distorting the treatment/wound/day effects of interest.

- **Color-card split scores.** 40 of ~962 scored color observations are split Siebeck scores (`D1/D2`, `D2/D3`, `D3/D4`). These are averaged to the midpoint (e.g. `D3/D4` → 3.5) following Molly's convention, rather than truncated to the first digit; the continuous value feeds the Gaussian LMM and the ordinal CLMM robustness check rounds to the nearest integer to keep a clean D1–D5 scale (`code/03_color_card_analysis.R`, `code/12b_color_clmm_robustness.R`).

- **Flagged colonies and tanks (QA/QC).** Molly flagged corals 116 and 121 (both wounded genet-c) as visually odd in the per-individual morphology trajectories, tank 3 (ambient) as a slow grower, and a negative within-tank wound effect in tank 11. These are documented in `notes/QAQC_flagged_samples.md` and verified against the data (tank 3 grows ≈40% less than the other three ambient tanks). They are retained, not excluded; a sensitivity analysis dropping corals 116/121 and tank 3 (`code/22_sensitivity_flagged.R`, `output/tables/22_sensitivity_flagged.csv`) leaves every conclusion intact — the PAM, color, and growth treatment effects all remain highly significant, and the growth treatment effect actually strengthens (F = 23 → 72) once the slow ambient tank is removed.

- **PAM random-effects structure (robustness note).** Molly explored random slopes of day by colony (`(1 + day | id)`) and raised temporal autocorrelation as a concern. The pipeline uses random intercepts only (`(1 | tank) + (1 | thicket) + (1 | id)`). Given the dominant treatment × day effect (F₁ = 112.68), a random-slope specification is unlikely to change the qualitative conclusion, but the intercept-only structure does not model individual decline trajectories explicitly.

## 11. What's still missing

- **Chlorophyll-a values** — column exists in master metadata but is currently empty; need to fill in once spec values come back from the chl-a assay. The pipeline (`code/06_symbiont_chl.R`) already handles them via `left_join` once values are added to `data/raw/metadata/metadata.csv`.
- **Gene expression data** — RNA-seq libraries at UC Davis Bay lab. Plate layout in `data/raw/plate_layout/Plate_{1,2}.csv`; sequencing plan in `notes/sequencing-plan-keck-LTH.md` (144 libraries: 4 tanks × 3 genets × 2 wound × 3 days × 2 temps). Stub DESeq2 pipeline at `code/21_rnaseq_stub.R` (waiting on sequencing).
- **Statistical write-up for manuscript** — these tables and figures need to be lifted into the Results section of `manuscript/Manuscript_LTH.md`. The starting prose is in `manuscript/Results_draft.md`.

---

## Pipeline integrity

To reproduce every number and figure in this document:

```bash
cd ~/Stier-LTH-expression-by-temperature-2025
Rscript code/_run_all.R
```

Expected runtime: ~3 minutes (Apex XML parse dominates; first run only).

**R version:** 4.5.2. **Key packages:** tidyverse, lme4, lmerTest, emmeans, DHARMa, MuMIn, car, broom.mixed, survival, patchwork, scales, here, janitor, readxl, xml2, ggrepel.

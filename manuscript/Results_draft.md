# LTH Manuscript — Results section draft

Drafted from `RESULTS.md` and the underlying model objects. Numbers and p-values come straight from `output/tables/12_anova_summary.csv`, `output/tables/14_cox_hazard_ratios.csv`, and `output/tables/13_genet_anova.csv`. Effect sizes refer to the bracketed contrasts in `output/tables/12_emmeans_contrasts.csv`.

Replace `[Fig. 1]` / `[Fig. 2]` references with final figure assignments at submission time. Statistical methods are written for the Methods section, not duplicated here.

---

## Results

### Sustained heating at 31 °C compromises photochemistry, pigmentation, growth, and symbiont retention

Eight independent tanks were held at 28 °C or 31 °C (four per treatment) for the duration of the experiment, with daily means within ±0.3 °C of nominal (Fig. 1A). All 192 *Acropora pulchra* fragments were exposed to their assigned temperature for seven days before wounding (Day 0).

Whole-colony photochemical efficiency (Fv/Fm) declined linearly through the experiment in 31 °C tanks (~5 × 10⁻³ d⁻¹) while remaining stable at ~0.68 in 28 °C tanks (treatment × day F₁ = 112.68, p < 0.001; R²_marginal = 0.62, R²_conditional = 0.72; Fig. 1B). The decline was largest in genets a and d (Day-14 unwounded Δ Fv/Fm = 0.126 and 0.107 respectively, both p < 0.001) and ~2.7× smaller in the most resilient genet c (Δ = 0.046, p = 0.007). For wounded corals the genet contrast was sharper still: genet c showed no detectable Fv/Fm change under heat (Δ = 0.016, p = 0.34), while wounded genets a and d lost 0.10 Fv/Fm units (both p < 0.001).

Pigmentation diverged more dramatically. Color score (Siebeck D-scale) was essentially flat in 28 °C controls (~D4) and dropped to ~D2 in 31 °C tanks by Day 14 (treatment × day F₁ = 240.67, p < 0.001). 67% of heated wounded corals and 58% of heated unwounded corals visibly paled by Day 14, against 0–8% in ambient. A significant treatment × wound interaction (F₁ = 16.90, p < 0.001) indicated wounded heated corals paled slightly less than unwounded heated corals — consistent with symbiont redistribution toward the regeneration front, and largely driven by genet c (wounded heated genet c corals lost only 0.25 D-units vs 28 °C controls, p = 0.27 n.s., while unwounded heated genet c corals lost 0.63 D-units, p = 0.007).

Whole-colony growth (buoyant-weight % mass change over 14 d) was 34% lower in heated tanks (mean 4.26% vs 6.45%; treatment F₁,₃₆ = 4.35, p = 0.044). Symbiont density dropped sharply in heated tanks across the four destructive biopsy timepoints, with a significant treatment × biopsy-day interaction (F₁ = 94.67, p < 0.001; R²_marginal = 0.72, R²_conditional = 0.76) and a significant three-way genet × treatment × biopsy-day interaction (F₂ = 6.32, p < 0.005) — symbiont-loss rates were ~3.5× steeper in genets a and d than in the resilient genet c.

A principal-components analysis of end-of-experiment physiology (PAM Fv/Fm, color, growth, log-symbionts) collapsed 81% of among-coral variance onto a single "thermal-stress axis" (PC1) on which all four variables loaded positively (~0.5 each; [Fig. 2A]). The 31 °C cloud was more dispersed along PC1 than the 28 °C cloud, indicating that individual-level variance in physiological response increases under thermal stress.

### Heating impairs the regenerative tip program, not wound closure

Wounded corals were tracked daily for nine visual morphological characteristics of healing. Wound closure proceeded at essentially identical rates in both treatments: by Day 5, ≥90% of corals in both treatments had a hole filled by a polyp (Cox HR = 1.38, 95% CI 0.60–3.15, p = 0.45) and a smooth wound surface (HR = 1.67, 95% CI 0.70–4.01, p = 0.25; [Fig. 2B]).

By contrast, the regenerative-tip program — formation of new corallites on the wound site — was severely impaired by heating. By Day 15, all 28 °C wounded corals had developed new corallites at the tip; only 33% of 31 °C wounded corals had done so. The instantaneous hazard of new-corallite formation was 78% lower in 31 °C corals (Cox HR = 0.22, 95% CI 0.07–0.69, p = 0.010, stratified by thicket). Tip extension showed a similar but weaker pattern (HR = 0.80, 95% CI 0.34–1.87, p = 0.61), and pigment-over-wound was a late and rare event under both temperatures. Among the wound-closure traits, *polyps out* showed a significant treatment × day interaction (Wald χ²₁ = 6.70, p = 0.010) — heated wounded corals were more likely to retain retracted polyps at later timepoints — but the overall hazard of any polyp emergence did not differ between treatments. A time-varying-coefficient refit (`tt(treatment) * log(t+1)`) for the one per-genet PH violation — pigment-over-wound in genet c, n_event = 5 — yielded a non-significant heat effect (coef = 0.65, p = 0.13), confirming that the original per-genet HR was inflated by the PH violation.

### Heritable variation in thermal tolerance among genets

Three field-collected genets (a, c, d) showed significant genet × treatment interactions for photochemistry (LRT χ²₁₅ = 90.5, p < 0.001), pigmentation (χ²₁₅ = 148.1, p < 0.001), and symbiont density (χ²₁₅ = 73.6, p < 0.001), but not for growth (χ²₆ = 5.3, p = 0.51). Genet c was consistently more thermally resilient than genets a and d across all three physiological dimensions ([Fig. 2C]), retaining higher Fv/Fm, more symbionts, and less paling under heating. A composite resilience ranking that integrates standardized heat sensitivity across 11 response dimensions (`figures/19b_genet_resilience_ranking.pdf`, `output/tables/19_genet_resilience_summary.csv`) places genet c (mean standardized sensitivity = −0.03) well clear of genets a (+0.42, most sensitive) and d (+0.29). In multivariate physiology space, genet c's centroid shifts only 1.03 PC-units under heat while genet a's shifts 3.74 and genet d's shifts 3.35 (Euclidean distance between 28 °C and 31 °C centroids in the PCA from [Fig. 2A]).

Decomposing the standardized heat sensitivities by wound state clarified where the genet differences live. In unwounded corals, the genet spread was large (mean standardized sensitivity: a = 0.99, d = 0.87, c = 0.44), but in wounded corals the spread compressed to near-uniformity (a = 0.36, d = 0.26, c = 0.28; `figures/19c_decomposed_resilience.pdf`). Wound healing imposes a metabolic load that homogenizes the genet-level heat response, while the unwounded homeostatic state best resolves the heritable variation.

This heritable variation in thermal tolerance among only three genets indicates that *A. pulchra* on Mo'orea's fringing reef harbors substantial genotype-level diversity in heat response — a substrate for selection under continued ocean warming.

---

## Statistical methods (paragraph for Methods section)

See the full Statistical Analysis subsection in `manuscript/Manuscript_LTH.md`. Briefly: we fit `lme4::lmer` (with Kenward-Roger denominator df from `lmerTest`) to the four continuous physiological responses as `response ~ treatment × wound × day × thicket + (1 | tank) + (1 | id)`, treating genet (thicket) as fixed because n_genets = 3 (Bolker 2008, Gelman 2005). The (1|id) random effect is dropped for the destructively-sampled symbiont and one-shot buoyant-weight responses. For nine binary morphological wound-healing traits we fit binomial GLMMs (`lme4::glmer`) of `trait ~ treatment × day × thicket + (1 | tank)` restricted to wounded corals; seven traits required a Cauchy(0, 2.5) penalized refit (`blme::bglmer`; Gelman et al. 2008) to handle complete or quasi-complete separation. Omnibus type-II Wald χ² and predicted probabilities come from the unpenalized fits; per-coefficient Wald z's come from the penalized refits. The Siebeck D-scale is ordinal — Gaussian fit retained for presentation, with `ordinal::clmm` confirming every inference held. Time-to-onset of healing milestones via thicket-stratified `survival::coxph`; PH met for every overall model; the one per-genet PH violation (`pigment_over_wound`, genet c, n_event = 5) was followed up with a `tt(treatment) * log(t+1)` time-varying refit. Per-genet Cox models contain only 4–8 events per cell, so per-genet patterns are shown as Kaplan-Meier curves only; quantitative HRs are reported from the overall stratified models. Multivariate physiology summarized via centered+scaled PCA on the four endpoint responses; the standardized heat-sensitivity dashboard composites across 11 response dimensions, and a decomposed variant splits sensitivities into heat-only (unwounded) and heat-while-wounded scopes. All pairwise contrasts Tukey-adjusted via `emmeans::emmeans`. Residual diagnostics: `DHARMa::simulateResiduals` plus a dedicated diagnostic-agent suite (`output/diagnostics/`). Every numerical claim traces to a row in `output/tables/20_master_results.csv`. All analyses reproducible from `code/_run_all.R`. Pipeline: https://github.com/stier-lab/17.-LTH_expression_by_temperature_2025.

---

## Figure captions (draft)

**Fig. 1 (`figures/16_manuscript_fig1.pdf`).** Sustained heating compromises *Acropora pulchra* photochemistry and regeneration. **(A)** Daily mean tank temperatures from the Apex monitoring system across the experimental window (n = 8 tanks). Dashed lines mark the 28 °C and 31 °C target setpoints. **(B)** Photochemical efficiency (Fv/Fm) trajectory by temperature × wound treatment. Mean ± 1 SE across n = 48 corals tracked non-destructively. Treatment × day interaction F₁ = 112.68, p < 0.001. **(C)** Kaplan-Meier curves of two diagnostic wound-healing milestones in wounded corals: wound closure (left, no treatment effect, HR = 1.67, p = 0.25) and new-corallite formation at the regenerating tip (right, treatment effect HR = 0.22, p = 0.010). **(D)** PCA biplot of end-of-experiment physiology (Fv/Fm, color, growth, log symbionts cm⁻²); shaded ellipses are 68% confidence by temperature. PC1 (81% of variance) is the thermal-stress axis on which all four variables load positively.

**Fig. 2 (composite for online supplement) (`figures/04_morphology_trajectories.pdf` + `figures/13_genet_response_panel.pdf`).** Full morphological trajectories and genet × treatment reaction norms. Top: cumulative percent of wounded corals expressing each of nine wound-healing characteristics by day and temperature. Bottom: end-of-experiment reaction norms for the three field-collected genets (a, c, d) on each of the four endpoint responses; non-parallel lines indicate genet × treatment interactions.

---

## Numbers Adrian needs to verify before submission

- The Day-1 symbiont density gap (~28% lower in 31C than 28C) implies the heat treatment was already affecting symbiont density before wounding; if this seems surprising it should be confirmed against the field-team's expectation
- The "wounded heated paled less than unwounded heated" pattern is statistically significant but small and may not be biologically meaningful — Molly should sanity-check whether this is real or an artifact of differential photograph timing
- Chlorophyll-a values are not yet in the master metadata; the pipeline already handles them via left-join and will need re-running once values are populated

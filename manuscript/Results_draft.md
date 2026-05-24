# LTH Manuscript — Results section draft

Drafted from `RESULTS.md` and the underlying model objects. Numbers and p-values come straight from `output/tables/12_anova_summary.csv`, `output/tables/14_cox_hazard_ratios.csv`, and `output/tables/13_genet_anova.csv`. Effect sizes refer to the bracketed contrasts in `output/tables/12_emmeans_contrasts.csv`.

Replace `[Fig. 1]` / `[Fig. 2]` references with final figure assignments at submission time. Statistical methods are written for the Methods section, not duplicated here.

---

## Results

### Sustained heating at 31 °C compromises photochemistry, pigmentation, growth, and symbiont retention

Eight independent tanks were held at 28 °C or 31 °C (four per treatment) for the duration of the experiment, with daily means within ±0.3 °C of nominal (Fig. 1A). All 192 *Acropora pulchra* fragments were exposed to their assigned temperature for seven days before wounding (Day 0).

Whole-colony photochemical efficiency (Fv/Fm) declined linearly through the experiment in 31 °C tanks (~5 × 10⁻³ d⁻¹) while remaining stable at ~0.68 in 28 °C tanks (treatment × day F₁,₆₀₅ = 94.7, p < 0.001; R²_marginal = 0.40, R²_conditional = 0.68; Fig. 1B). Pairwise contrasts at Day 7 first detected significant divergence between treatments in unwounded corals (ΔFv/Fm = 0.052, t = 4.75, p_adj = 0.007), and by Day 14 the gap had widened to ΔFv/Fm = 0.090 (t = 7.16, p_adj < 0.001).

Pigmentation diverged more dramatically. Color score (Siebeck D-scale) was essentially flat in 28 °C controls (~D4) and dropped to ~D2 in 31 °C tanks by Day 14 (treatment × day F₁,₂₇₃ = 168.3, p < 0.001). 67% of heated wounded corals and 58% of heated unwounded corals visibly paled by Day 14, against 0–8% in ambient. A small but significant treatment × wound interaction (F = 13.0, p < 0.001) indicated that wounded heated corals paled slightly less than unwounded heated corals — consistent with symbiont redistribution toward the regeneration front.

Whole-colony growth (buoyant-weight % mass change over 14 d) was 31% lower in heated tanks (mean 4.1% vs 6.5%; treatment F₁,₄₂ = 6.28, p = 0.02), with no effect of wounding (F = 1.08, p = 0.30) or interaction (F = 0.06, p = 0.81). Symbiont density dropped 73% in heated tanks across the four destructive biopsy timepoints (Days 1, 3, 10, 15), from ~1.0 × 10⁶ cells cm⁻² at Day 1 to ~0.25 × 10⁶ cells cm⁻² at Day 15 (treatment × biopsy day F₁,₁₈₃ = 72.5, p < 0.001; R²_marginal = 0.58).

A principal-components analysis of end-of-experiment physiology (PAM Fv/Fm, color, growth, log-symbionts) collapsed 81% of among-coral variance onto a single "thermal-stress axis" (PC1) on which all four variables loaded positively (~0.5 each; [Fig. 2A]). The 31 °C cloud was more dispersed along PC1 than the 28 °C cloud, indicating that individual-level variance in physiological response increases under thermal stress.

### Heating impairs the regenerative tip program, not wound closure

Wounded corals were tracked daily for nine visual morphological characteristics of healing. Wound closure proceeded at essentially identical rates in both treatments: by Day 5, ≥90% of corals in both treatments had a hole filled by a polyp (Cox HR = 1.38, 95% CI 0.60–3.15, p = 0.45) and a smooth wound surface (HR = 1.67, 95% CI 0.70–4.01, p = 0.25; [Fig. 2B]).

By contrast, the regenerative-tip program — formation of new corallites on the wound site — was severely impaired by heating. By Day 15, all 28 °C wounded corals had developed new corallites at the tip; only 33% of 31 °C wounded corals had done so. The instantaneous hazard of new-corallite formation was 78% lower in 31 °C corals (Cox HR = 0.22, 95% CI 0.07–0.69, p = 0.010, stratified by thicket). Tip extension showed a similar but weaker pattern (HR = 0.80, 95% CI 0.34–1.87, p = 0.61), and pigment-over-wound was a late and rare event under both temperatures.

### Heritable variation in thermal tolerance among genets

Three field-collected genets (a, c, d) showed significant genet × treatment interactions for photochemistry (LRT χ²₁₅ = 90.5, p < 0.001), pigmentation (χ²₁₅ = 148.0, p < 0.001), and symbiont density (χ²₁₅ = 73.6, p < 0.001), but not for growth (χ²₆ = 5.4, p = 0.51). Genet c was consistently more thermally resilient than genets a and d across all three physiological dimensions ([Fig. 2C]), retaining higher Fv/Fm, more symbionts, and less paling under heating.

This heritable variation in thermal tolerance among only three genets indicates that *A. pulchra* on Mo'orea's fringing reef harbors substantial genotype-level diversity in heat response — a substrate for selection under continued ocean warming.

---

## Statistical methods (paragraph for Methods section)

We fit linear mixed-effects models (`lme4::lmer`) to the four primary continuous responses with the structure response ~ treatment × wound × day + (1 | tank) + (1 | thicket) + (1 | id) (with id dropped for the symbiont and growth analyses where each coral contributed a single observation). For the nine binary morphological traits we fit generalized linear mixed models with logit link (`lme4::glmer`) of structure trait ~ treatment × day + (1 | tank) + (1 | thicket), restricted to wounded corals. We tested genet × treatment interactions via likelihood-ratio comparison of nested models, dropping (1 | thicket) and adding thicket as a fixed effect (and its interactions with treatment, wound, and day) to the alternative model. Time-to-onset of healing milestones was analyzed via Cox proportional-hazards models (`survival::coxph`) stratified by thicket. Multivariate physiology was summarized via centered and scaled PCA on the four endpoint responses. All p-values for pairwise contrasts are Tukey-adjusted from `emmeans::emmeans`. Residual diagnostics for every model were screened via `DHARMa::simulateResiduals`; full diagnostic plots are in `figures/12_diagnostics/`. All analyses are reproducible by sourcing `code/_run_all.R`. Full pipeline at https://github.com/stier-lab/17.-LTH_expression_by_temperature_2025 (Stier Lab).

---

## Figure captions (draft)

**Fig. 1 (`figures/16_manuscript_fig1.pdf`).** Sustained heating compromises *Acropora pulchra* photochemistry and regeneration. **(A)** Daily mean tank temperatures from the Apex monitoring system across the experimental window (n = 8 tanks). Dashed lines mark the 28 °C and 31 °C target setpoints. **(B)** Photochemical efficiency (Fv/Fm) trajectory by temperature × wound treatment. Mean ± 1 SE across n = 48 corals tracked non-destructively. Treatment × day interaction F = 94.7, p < 0.001. **(C)** Kaplan-Meier curves of two diagnostic wound-healing milestones in wounded corals: wound closure (left, no treatment effect, HR = 1.67, p = 0.25) and new-corallite formation at the regenerating tip (right, treatment effect HR = 0.22, p = 0.010). **(D)** PCA biplot of end-of-experiment physiology (Fv/Fm, color, growth, log symbionts cm⁻²); shaded ellipses are 68% confidence by temperature. PC1 (81% of variance) is the thermal-stress axis on which all four variables load positively.

**Fig. 2 (composite for online supplement) (`figures/04_morphology_trajectories.pdf` + `figures/13_genet_response_panel.pdf`).** Full morphological trajectories and genet × treatment reaction norms. Top: cumulative percent of wounded corals expressing each of nine wound-healing characteristics by day and temperature. Bottom: end-of-experiment reaction norms for the three field-collected genets (a, c, d) on each of the four endpoint responses; non-parallel lines indicate genet × treatment interactions.

---

## Numbers Adrian needs to verify before submission

- The Day-1 symbiont density gap (~28% lower in 31C than 28C) implies the heat treatment was already affecting symbiont density before wounding; if this seems surprising it should be confirmed against the field-team's expectation
- The "wounded heated paled less than unwounded heated" pattern is statistically significant but small and may not be biologically meaningful — Molly should sanity-check whether this is real or an artifact of differential photograph timing
- Chlorophyll-a values are not yet in the master metadata; the pipeline already handles them via left-join and will need re-running once values are populated

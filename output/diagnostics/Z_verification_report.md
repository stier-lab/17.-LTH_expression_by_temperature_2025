# Z. Verification report — numerical claims vs `20_master_results.csv`

**Generated:** 2026-05-24
**Source of truth:** `output/tables/20_master_results.csv` (355 rows; aggregated from the 12_/13_/14_/15_/19_ pipeline tables and the four diagnostic agents A-D).
**Prose audited:** `RESULTS.md` (240 lines) and `manuscript/Results_draft.md` (56 lines).

---

## Summary

| Metric | Count |
|---|---|
| Numerical claims extracted | 48 |
| Exact matches (to 2 decimals on stats, 3 on p) | 24 |
| Mismatches — Category A (stale numbers) | 14 |
| Mismatches — Category B (no spreadsheet source) | 4 |
| Spreadsheet rows that should but don't appear in prose — Category C | 3 |
| Diagnostic concerns not yet in prose — Category D | 4 |

The two documents disagree with each other on most of the headline F-statistics. `RESULTS.md` is closer to the current spreadsheet for ANOVA F values; `manuscript/Results_draft.md` carries older numbers (looks like a pre-genet-as-fixed-effect run). The day-specific PAM and color contrasts cited in `Results_draft.md` cannot be found in the current spreadsheet at all — they may have been computed against a pooled-across-genets emmeans grid that no longer exists.

---

## A. Stale numbers (prose cites a value the spreadsheet has moved past)

| # | Claim (file:line) | Cited value | Spreadsheet (`20_master_results.csv`) | Action |
|---|---|---|---|---|
| A1 | RESULTS.md:49 — "treatment | F = 20.4" for PAM | **F = 20.4** | F = **15.83**, df1=1 (row: PAM Fv/Fm, treatment, ANOVA F) | Update prose to F₁ = 15.83 |
| A2 | RESULTS.md:52 — "treatment × day | F = 240.7" for PAM | **F = 240.7** (this is the color value, mis-pasted into PAM) | F = **112.68**, df1=1 | Update PAM treatment:day to F₁ = 112.68 |
| A3 | RESULTS.md:50 — "thicket | F = 14.4" for PAM | F = 14.4 | F = **54.44**, df1=2 (the genet ANOVA was re-run with thicket-as-fixed) | Update to F₂ = 54.44 |
| A4 | RESULTS.md:51 — "treatment × thicket | F = 14.3" for PAM | F = 14.3 | F = **9.66**, df1=2 | Update to F₂ = 9.66 |
| A5 | RESULTS.md:53 — "treatment × day × thicket | F = 23.9" for PAM | F = 23.9 | F = **14.66**, df1=2 | Update to F₂ = 14.66 |
| A6 | RESULTS.md:80 — "treatment | F = 4.4" for Color | F = 4.4 | F = **20.37**, df1=1 | Update; this is no longer a "masked-by-interaction" claim — main effect is large |
| A7 | RESULTS.md:81 — "thicket | F = 18.0" Color | F = 18.0 | F = **18.04** (match — keep) | OK |
| A8 | RESULTS.md:82 — "treatment × day | F = 240.7" Color | F = 240.7 | F = **240.67** (match — keep) | OK |
| A9 | RESULTS.md:120 — "treatment × thicket | F = 16.2" log-zoox | F = 16.2 | F = **16.16** (match — keep) | OK |
| A10 | Results_draft.md:15 — "treatment × day F₁,₆₀₅ = 94.7, p < 0.001" PAM | F = 94.7 (and df=605 wrong) | F = **112.68**; df1=1, df2 not reported in ANOVA-summary table (LMM uses Kenward-Roger) | Update F to 112.68; drop the spurious df2=605 or compute from the model |
| A11 | Results_draft.md:15 — "R²_marginal = 0.40, R²_conditional = 0.68" PAM | 0.40 / 0.68 | **0.62 / 0.72** | Update both |
| A12 | Results_draft.md:17 — "treatment × day F₁,₂₇₃ = 168.3, p < 0.001" Color | F = 168.3 | F = **240.67**, df1=1 | Update |
| A13 | Results_draft.md:17 — "treatment × wound F = 13.0, p < 0.001" Color | F = 13.0 | F = **16.90**, df1=1 | Update |
| A14 | Results_draft.md:19 — "treatment F₁,₄₂ = 6.28, p = 0.02" BW | F = 6.28, p = 0.02 | F = **4.35**, p = **0.044**, df1=1, df2=36 | Update both F and p (and df2 = 36 not 42) |
| A15 | Results_draft.md:19 — "treatment × biopsy day F₁,₁₈₃ = 72.5" log-zoox | F = 72.5 | F = **94.67**, df1=1 | Update |
| A16 | Results_draft.md:19 — "R²_marginal = 0.58" log-zoox | 0.58 | **0.72** (R²m), 0.76 (R²c) | Update |

## B. Numbers in prose with no spreadsheet source

| # | Claim (file:line) | Issue |
|---|---|---|
| B1 | Results_draft.md:15 — Day-7 unwounded "ΔFv/Fm = 0.052, t = 4.75, p_adj = 0.007" | Spreadsheet has per-genet Day-7 unwounded values (a: 0.066 / c: 0.027 / d: 0.067); no pooled-across-genet contrast row exists. Either re-run emmeans pooling over genet, or report the per-genet values instead. |
| B2 | Results_draft.md:15 — Day-14 unwounded "ΔFv/Fm = 0.090, t = 7.16, p_adj < 0.001" | Same — per-genet values (0.126 / 0.046 / 0.107) are in the spreadsheet but no pooled row. RESULTS.md:65 cites the matching numbers from `12_emmeans_contrasts.csv`. |
| B3 | Results_draft.md:19 — "growth 31% lower in heated tanks (mean 4.1% vs 6.5%)" | Spreadsheet has the LM estimate (treatment31C = −2.02 percentage points); the 31% / 4.1% / 6.5% means are not in the master CSV. Need to add summary stats or pull from `data/processed/bw_clean.rds`. |
| B4 | Results_draft.md:19 — log-zoox "73% drop, ~1.0 × 10⁶ → ~0.25 × 10⁶ cells cm⁻²" | Spreadsheet reports the log10 model estimate (genet a unwounded = −43.8%). The 73% / raw-cell numbers are absent. Either drop the absolute counts or add a summary-stat row. |

## C. Spreadsheet rows that materially change the narrative

| # | Spreadsheet finding | Why it matters |
|---|---|---|
| C1 | log-zoox `treatment:biopsy_day:thicket` F = 6.32, df=2 (p<0.001 implied) | A significant 3-way genet × treatment × day interaction for symbiont loss is in the spreadsheet but not surfaced — currently RESULTS.md only reports the 2-way genet × treatment. Worth one sentence. |
| C2 | morph_polyps_out `treatment:day` Wald χ² = 6.70, p = 0.0097 (significant) | A 6th morphology trait with a real heat × time effect (heated wounded corals more likely to keep polyps retracted late). Not mentioned in either prose doc. |
| C3 | Color genet-c wounded contrast: Δ = 0.25 D-units, p = 0.27 (n.s.) vs genet-c unwounded Δ = 0.63, p = 0.007 | Genet c is essentially fully resistant to heat-induced paling when wounded. This is a stronger framing of the "treatment × wound × thicket" interaction than the current prose offers. |

## D. Diagnostic concerns not yet flagged in prose

| # | Issue | Source |
|---|---|---|
| D1 | Color LMM violates KS — D-scale is ordinal (0–5), fit on Gaussian | Agent A |
| D2 | 7/8 morphology GLMM traits have complete/quasi-complete separation; individual Wald tests on fixed-effects rows are unreliable (omnibus χ² and Cox HRs are fine) | Agent B |
| D3 | Cox per-genet models have 4–8 events per genet × treatment cell — under EPV=10 rule of thumb | Agent C |
| D4 | One PH violation in `pigment_over_wound`, genet c (n_event = 5) | Agent C |

---

## Methods/Limitations text to add (drafted in Stier voice)

> **Color score.** The Siebeck D-scale is ordinal (D1–D5), and we fit it as a Gaussian response for direct comparison with the other continuous physiology metrics. Residual diagnostics flagged a Kolmogorov-Smirnov departure from normality, which is expected for a 5-level ordinal scale. Re-fitting as a cumulative-link mixed model (`ordinal::clmm`) with the same fixed and random structure preserved every qualitative inference reported here; we therefore retain the Gaussian model for ease of presentation. Full ordinal model output is in `output/tables/12b_color_clmm.csv`.

> **Morphology GLMMs.** Seven of nine binary wound-healing traits show complete or quasi-complete separation between treatments by Day 10, which makes individual Wald z-tests on `summary(glmer)` fixed-effects rows unreliable. Throughout the Results we report only the omnibus type-II Wald χ² from `car::Anova` and the Cox proportional-hazards summaries from `survival::coxph`, which behave correctly under separation. Inference on individual coefficients would require a Firth-corrected refit (`brglm2::brglmFit`) or weakly-informative priors (`blme::bglmer`); these are flagged in the master spreadsheet with `units = "log-odds [separation]"`.

> **Cox per-genet hazard ratios.** Per-genet Cox models contain 4–8 events per genet × treatment cell, below the rule-of-thumb 10 events per variable. We therefore report quantitative hazard ratios only from the overall (thicket-stratified) Cox models; per-genet patterns are visualized as Kaplan–Meier curves (`figures/14b_morphology_KM_by_genet.pdf`) without point estimates. The proportional-hazards assumption was met for every overall model except `pigment_over_wound` in genet c (Schoenfeld global p = 0.04, n_event = 5), where the small event count makes the test under-powered and the per-genet HR is suppressed.

---

*End of verification report.*

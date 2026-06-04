# Growth metric: why areal calcification, and the allometry behind it

Decided 2026-06-04. Implemented in `code/05_buoyant_weight.R`; flows through
the growth models in `12`, `13`, the PCA in `15`/`16`, and the resilience
dashboard in `19`.

## The question

How should we estimate "growth" of an *Acropora pulchra* fragment from buoyant
weight? The original analysis (and Molly's archived script) used **% mass
change** = ΔM / M_initial.

## The allometric problem with % mass change

Acropora is a branching coral and **calcification is a surface-mediated
process** — new aragonite is deposited under the living tissue veneer, mostly
at the growing tips. So the amount of new mass a fragment can add scales with
its **living tissue surface area**, not with its existing skeletal mass (which
is mostly dead aragonite). `% mass change` normalizes by skeletal mass — the
wrong denominator — and assumes growth is proportional to current mass
(exponential growth).

If fragments differ in size or in mass-to-surface ratio (branchiness/density),
% mass change is a biased comparison: purely from geometry, ΔM/M declines with
size even if per-area calcification is identical.

## What the data say (n = 48 growth corals, all biopsied terminally at day 15)

| Check | Result | Reading |
|---|---|---|
| log-log exponent `ln(Mf) ~ ln(Mi)` | b = 0.97 | growth ≈ proportional over this range |
| ΔM vs initial mass | r = 0.12, p = 0.42 | absolute gain **independent of size** |
| ΔM vs surface area | r = 0.06 | gain doesn't track SA across individuals |
| initial mass by treatment | 8.27 vs 8.08 g | **balanced** — no treatment bias |
| initial mass by genet | c = 8.96 vs a/d 7.7–7.9 g | genet c fragments are larger |

Fragments were well size-standardized (7–10 g), so the allometric bias in %
mass change is **weak in practice**. The heat effect is the same under % mass
change, specific growth rate (SGR), and areal calcification (treatment
F ≈ 23–26, p ≈ 1×10⁻⁵; `output/tables/05b_growth_metric_comparison.csv`).

## Is surface area a valid denominator? (yes)

The concern with dividing by SA is that heat might shrink the tissue/surface,
making the denominator itself treatment-dependent (circular). It is not:

- **Day-15 SA does not differ by treatment** (28 °C 4.46 vs 31 °C 4.73 cm²,
  F = 1.25, p = 0.27).
- **SA is stable across all biopsy days** (≈4.5–5.4 cm², both treatments),
  so the day-15 wax SA is a good proxy for the calcifying surface present
  throughout the 15-day window — even though we lack a day-0 SA (SA was only
  measured destructively at the terminal biopsy).

## Decision

**Primary growth metric = areal calcification rate (mg CaCO₃ cm⁻² d⁻¹)** =
1000 · ΔM(g) / SA(cm²) / days, using the day-15 wax standard-curve SA. Reasons:

1. Mechanistically correct — calcification is surface-mediated, so per-unit
   living-tissue area is the physiological currency.
2. Field-standard, comparable unit (Jokiel et al. 1978; Davies 1989) — the same
   buoyant-weight literature the conversion already cites.
3. Puts large (genet c) and small fragments on a common per-tissue basis.

**% mass change and SGR are reported as robustness checks**; the heat
conclusion is metric-invariant.

## Caveats (carry into Methods)

- SA was measured terminally (day 15), not at day 0. Justified because SA is
  stable and treatment-independent across the experiment, but it is a proxy.
- We use wax standard-curve SA (mean ≈ 4.6 cm²), not caliper cylinder SA
  (≈ 2.5 cm²); the wax method captures real surface texture and is the more
  accurate estimate.
- ΔM does not correlate with SA across individuals (r = 0.06) — within this
  narrow SA range, per-coral calcification physiology varies more than the SA
  itself. Per-area normalization is still the correct currency for
  cross-fragment and cross-study comparison; an ANCOVA with SA as a covariate
  (rather than a ratio) gives the same treatment conclusion because SA is a
  non-significant covariate.
- Genet × treatment interaction for growth is non-significant under every
  metric (n = 4 per genet × treatment cell — underpowered); genet c is
  directionally the least heat-suppressed (≈−21% areal vs ≈−45% for a, d),
  consistent with its resilience in PAM/color/symbionts, but not statistically
  significant for growth.

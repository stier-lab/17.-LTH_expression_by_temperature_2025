# Agent D — PCA + Genet LRT Diagnostics
_Run: 2026-05-24 15:45:53_

## PCA (15_multivariate.R)

- n = 48 corals on 4 vars (pam_end, color_end, growth_pct, zoox_end)
- Variance explained: PC1=81.4%, PC2=13.6%, PC3=3.0%, PC4=2.1%
- PC1+PC2 = **95.0%** (PASS)
- Kaiser: 1 PCs with eigenvalue > 1 (eigenvals 3.26, 0.54, 0.12, 0.08)
- Center = TRUE, Scale = TRUE (PASS)

### Loadings

- **PC1** (81.4%): zoox_end=+0.53, color_end=+0.53, pam_end=+0.52, growth_pct=+0.41
- **PC2** (13.6%): growth_pct=+0.91, color_end=-0.28, pam_end=-0.26, zoox_end=-0.17
- **PC3** (3.0%): pam_end=-0.81, zoox_end=+0.42, color_end=+0.40, growth_pct=-0.03
- **PC4** (2.1%): zoox_end=+0.71, color_end=-0.70, growth_pct=-0.07, pam_end=+0.03

## Genet LRTs (13_genet_interaction.R)

### pam_fvfm
- n_obs = 336; fixed params: null=8, full=24 (Δfx=16). Total npar Δ=15 (reported df=15).
- REML status: null=FALSE, full=FALSE, saved=FALSE (all should be FALSE)
- Convergence: null singular=FALSE, full singular=FALSE, warnings=0
- LRT χ²(15) = 90.49, p = 8.02e-13 (recomputed 8.02e-13)
### color_dscale
- n_obs = 336; fixed params: null=8, full=24 (Δfx=16). Total npar Δ=15 (reported df=15).
- REML status: null=FALSE, full=FALSE, saved=FALSE (all should be FALSE)
- Convergence: null singular=FALSE, full singular=FALSE, warnings=0
- LRT χ²(15) = 148.07, p = 5.84e-24 (recomputed 5.84e-24)
### log_zoox
- n_obs = 192; fixed params: null=8, full=24 (Δfx=16). Total npar Δ=15 (reported df=15).
- REML status: null=FALSE, full=FALSE, saved=FALSE (all should be FALSE)
- Convergence: null singular=FALSE, full singular=FALSE, warnings=0
- LRT χ²(15) = 73.57, p = 1.03e-09 (recomputed 1.03e-09)

### growth_pct
- lm-based F-test (no time dim); F(6, 36) = 0.90, p = 0.509
- Fixed params: null=6, full=12 (Δ=6, reported df=6)

## Effect direction vs. emmeans

- **PAM Fv/Fm**: Δ(31C-28C) by genet = a=-0.148, c=-0.037, d=-0.131 — additive (parallel)
- **Color (D-scale)**: Δ(31C-28C) by genet = a=-2.250, c=-0.375, d=-1.750 — additive (parallel)
- **Growth (%)**: Δ(31C-28C) by genet = a=-2.596, c=-0.884, d=-2.733 — additive (parallel)
- **log10 symbionts cm⁻²**: Δ(31C-28C) by genet = a=-0.583, c=-0.214, d=-0.517 — additive (parallel)

## Summary verdicts

- PCA: **PASS**
- pam_fvfm LRT: **PASS**
- color_dscale LRT: **PASS**
- log_zoox LRT: **PASS**
- growth_pct F-test: **PASS**

# Agent A — Continuous-response model diagnostics
Generated: 2026-05-24 15:44:37.2024

Models reviewed: 12_pam_lmm, 12_color_lmm, 12_zoox_lmm, 12_bw_lm

## Summary
- Total checks: 30
- PASS: 22
- WARN: 5
- FAIL: 3

## 12_pam_lmm
- **isSingular** [PASS]: stat=0 Singular fit means a variance component is at/near zero
- **variance_components_near_zero** [PASS]: stat=0 VarCorr (grp:var): id:3.84e-05; tank:1.92e-04; Residual:6.60e-04
- **optimizer_convergence_messages** [PASS]: stat=0 
- **DHARMa_KS_uniformity** [PASS]: stat=0.0575 Kolmogorov-Smirnov on scaled residuals
- **DHARMa_dispersion** [PASS]: stat=0.9074 Ratio of obs/sim residual variance
- **DHARMa_outliers** [PASS]: stat=2 Excess outliers vs expected
- **cooks_distance** [WARN]: influence.ME::influence failed (likely too slow); skipped
- **emmeans_direction_pam_fvfm** [PASS]: stat=0.08351 contrast 28C - 31C = 0.0835 (p=6.76e-05); observed heated decrease

## 12_color_lmm
- **isSingular** [PASS]: stat=0 Singular fit means a variance component is at/near zero
- **variance_components_near_zero** [PASS]: stat=0 VarCorr (grp:var): id:3.13e-02; tank:2.88e-02; Residual:9.04e-02
- **optimizer_convergence_messages** [PASS]: stat=0 
- **DHARMa_KS_uniformity** [FAIL]: stat=0.1662 Kolmogorov-Smirnov on scaled residuals
- **DHARMa_dispersion** [PASS]: stat=0.8941 Ratio of obs/sim residual variance
- **DHARMa_outliers** [PASS]: stat=2 Excess outliers vs expected
- **cooks_distance** [WARN]: influence.ME::influence failed (likely too slow); skipped
- **emmeans_direction_color_dscale** [PASS]: stat=1.353 contrast 28C - 31C = 1.3525 (p=1.83e-05); observed heated decrease

## 12_zoox_lmm
- **isSingular** [PASS]: stat=0 Singular fit means a variance component is at/near zero
- **variance_components_near_zero** [PASS]: stat=0 VarCorr (grp:var): tank:3.31e-02; Residual:2.05e-01
- **optimizer_convergence_messages** [PASS]: stat=0 
- **DHARMa_KS_uniformity** [FAIL]: stat=0.12 Kolmogorov-Smirnov on scaled residuals
- **DHARMa_dispersion** [PASS]: stat=0.8714 Ratio of obs/sim residual variance
- **DHARMa_outliers** [FAIL]: stat=4 Excess outliers vs expected
- **cooks_distance** [WARN]: influence.ME::influence failed (likely too slow); skipped
- **emmeans_direction_log_zoox** [PASS]: stat=1.888 contrast 28C - 31C = 1.8882 (p=1.56e-07); observed heated decrease

## 12_bw_lm
- **shapiro_residual_normality** [PASS]: stat=0.9666 Shapiro-Wilk on OLS residuals
- **breusch_pagan_heteroscedasticity** [PASS]: stat=14.02 BP test for non-constant variance
- **VIF** [WARN]: Saturated 3-way interaction lm; VIFs uninterpretable. Skipped.
- **DHARMa_KS_uniformity** [PASS]: stat=0.1302 DHARMa KS on simulated residuals
- **cooks_distance_max** [WARN]: stat=0.2365 Top-3 obs idx: 2,38,16; cd: 0.236,0.162,0.129
- **emmeans_direction_growth_pct** [PASS]: stat=2.055 contrast 28C - 31C = 2.0550 (p=3.53e-05); observed heated decrease


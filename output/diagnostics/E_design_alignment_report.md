# E. Design alignment audit

Generated: 2026-05-25 13:03:24 

| Status | Count |
|---|---|

INFO PASS WARN 
   1   30    3 

## Status summary

### WARN (3)

- **12_pam_lmm / random slope on day?**: Could add (day|id) for individual trajectories but expect singular fit with 8 obs per id
- **12_color_lmm / ordinal data on Gaussian**: Addressed by 12b CLMM robustness check; KS-violation noted in Section 10
- **12_zoox_lmm / biopsy_day_c centering**: Centered correctly at Day 1 baseline

### INFO (1)

- **12_pam_lmm / n observations**: n_corals=48, days=-1,0,3,6,9,12,14

### PASS (30)

- **12_pam_lmm / fixed structure**: 4-way fixed structure required for genet x heat x wound x time
- **12_pam_lmm / random structure**: tank for tank-level confounds, id for repeated measures on same coral
- **12_pam_lmm / balance (tank x treatment)**: 8 unique tank x treatment cells expected (4 tanks per temp, fully nested)
- **12_pam_lmm / (1|tank) sufficient?**: tanks are uniquely IDed; no need for tank:treatment crossed term
- **12_color_lmm / fixed structure**: same 4-way as PAM
- **12_bw_lm / fixed structure**: no day term — single endpoint measurement
- **12_bw_lm / no random effects?**: tank (n=8) and id (n=48) would be singular with 1 obs/coral
- **12_bw_lm / n**: Cells in design: 12 (2 trt x 2 wound x 3 genet = 12)
- **12_bw_lm / df residual**: Adequate residual df for 3-way model
- **12_zoox_lmm / fixed structure**: biopsy_day_c is centered at Day 1; 4-way as for PAM
- **12_zoox_lmm / drop (1|id) — destructive**: Correct — destructive sampling means each id has 1 obs
- **12c_morph_hole_in_center_blme.rds / fixed structure**: Restricted to wounded corals; wound is a stratification, not a covariate
- **12c_morph_hole_in_center_blme.rds / Cauchy(0,2.5) prior**: Prior addresses 7/8 separation issue from Agent B
- **12c_morph_new_corallites_on_tip_blme.rds / fixed structure**: Restricted to wounded corals; wound is a stratification, not a covariate
- **12c_morph_new_corallites_on_tip_blme.rds / Cauchy(0,2.5) prior**: Prior addresses 7/8 separation issue from Agent B
- **12c_morph_pigment_over_wound_blme.rds / fixed structure**: Restricted to wounded corals; wound is a stratification, not a covariate
- **12c_morph_pigment_over_wound_blme.rds / Cauchy(0,2.5) prior**: Prior addresses 7/8 separation issue from Agent B
- **12c_morph_polyp_in_hole_blme.rds / fixed structure**: Restricted to wounded corals; wound is a stratification, not a covariate
- **12c_morph_polyp_in_hole_blme.rds / Cauchy(0,2.5) prior**: Prior addresses 7/8 separation issue from Agent B
- **12c_morph_polyps_out_blme.rds / fixed structure**: Restricted to wounded corals; wound is a stratification, not a covariate
- **12c_morph_polyps_out_blme.rds / Cauchy(0,2.5) prior**: Prior addresses 7/8 separation issue from Agent B
- **12c_morph_tip_exist_blme.rds / fixed structure**: Restricted to wounded corals; wound is a stratification, not a covariate
- **12c_morph_tip_exist_blme.rds / Cauchy(0,2.5) prior**: Prior addresses 7/8 separation issue from Agent B
- **12c_morph_tip_extension_blme.rds / fixed structure**: Restricted to wounded corals; wound is a stratification, not a covariate
- **12c_morph_tip_extension_blme.rds / Cauchy(0,2.5) prior**: Prior addresses 7/8 separation issue from Agent B
- **12c_morph_wound_smoothed_blme.rds / fixed structure**: Restricted to wounded corals; wound is a stratification, not a covariate
- **12c_morph_wound_smoothed_blme.rds / Cauchy(0,2.5) prior**: Prior addresses 7/8 separation issue from Agent B
- **14_cox_* / stratification**: Per-genet HRs in separate per-genet models (low EPV caveat in Section 10)
- **14_cox_* / wounded-only at risk**: Confirmed in script 14
- **15_pca / centering + scaling**: Confirmed in script 15


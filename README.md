# LTH: Long-Term Heating × Wounding × Gene Expression in *Acropora pulchra*

Project #17 of the Coral Regeneration program. May–July 2025, Gump Station, Mo'orea, French Polynesia.

## Research question

Branching corals like *Acropora pulchra* regenerate readily after physical damage to the apical (growing) tip, and elevated temperatures are known to slow growth and bleach symbionts. **How do those two stressors interact?** Specifically: does mild long-term heating (+3 °C above ambient) compromise wound regeneration, and what gene-expression machinery underlies any response?

## Design

| Factor | Levels |
|---|---|
| **Temperature** | 28 °C (ambient) vs 31 °C (heated). Ramped 1 °C/day from ambient. |
| **Wound** | Wounded (~1 cm clipped off growing tip with band-saw + caliper) vs unwounded sham. Applied 7 days after target temperature was reached. |
| **Genotype (thicket)** | A, C, D (random effect). |
| **Tank** | 8 total: 4 per temperature (28 °C: 3, 6, 9, 12; 31 °C: 4, 5, 10, 11). Random effect. |
| **Time** | Daily non-destructive obs. Destructive biopsies at D0, D1, D3, D10, D15. |

**Coral fragments (n = 208 total):**
- **192** for gene expression + destructive physiology (chl-a, symbionts) — distributed across the 3 genotypes × 4 tanks × 2 temperatures × 2 wound × ~4 timepoints
- **48** of these 192 also tracked for non-destructive metrics (PAM, color card, buoyant weight)
- **16** dedicated to daily microscope photography (genotypes A and C only)

The full README from Drive lives at `notes/project_README_from_drive.md`. Detailed protocols are in `notes/Experimental_Plan_Gene_Expression.md` and `notes/Experimental_Plan_Microscope_photographs.md`. The plate layout / sequencing plan is in `notes/sequencing-plan-keck-LTH.md`.

## Authors

- **Molly Brzezinski** — UCSB Stier Lab; experimental execution, data management, microscope analysis. ORCID 0000-0002-0417-3406
- **Shreya Banerjee** — UC Davis Bay Lab; RNA-seq analysis
- **Michelle Diminuco** — UGA Osenberg Lab; field collection
- **Ashley W. Seifert** — University of Kentucky; regeneration biology PI. ORCID 0000-0001-6576-3664
- **Craig W. Osenberg** — UGA; ORCID 0000000319187904
- **Adrian C. Stier** (corresponding) — UCSB; astier@ucsb.edu, ORCID 0000-0002-4704-4145
- **Rachael A. Bay** — UC Davis; gene expression PI

## Data inventory

| Stream | Source file | Rows | What it captures |
|---|---|---|---|
| Coral metadata (one per fragment) | `data/raw/metadata/metadata.csv` | 208 | thicket, id, sample purpose, tank, treatment, wound, biopsy day, biopsy date, calculated SA, chl-a, zoox |
| PAM (Fv/Fm) | `data/raw/pam/PAM_data.csv` | 672 obs | F, M, Y, E, Fv/Fm by date × tank × sample × location (top/bottom) |
| Color card (Siebeck D-scale) | `data/raw/color_card/data.csv` | 336 obs | health_status, color (D-scale), paling, hole_at_center |
| Morphological characterization (8 binary traits) | `data/raw/physio_morphology/data.csv` | 768 obs | tissue_over_wound, hole_in_center, polyp_in_hole, wound_smoothed, pigment_over_wound, tip_exist, tip_extension, new_corallites_on_tip, algae_on_wound |
| Buoyant weight (growth) | `data/raw/buoyant_weight/data.csv` | 48 corals | initial + final coral & plug weights, water density correction |
| Wax dipping (surface area) | `data/raw/wax_dipping/data.csv` | 192 corals | diameter, height, dry weight, wax weights, SA from standard curve |
| Standard curve for wax | `data/raw/wax_dipping/Standard_curve.csv` | 19 | wax mass vs SA from cylinders |
| Symbiont counts | `data/raw/symbiont_counts/Raw_counts.csv` | 768 (4 reps × 192) | hemocytometer cell counts → cells/cm² via wax SA |
| Worm presence | `data/raw/worm_presence/Sheet1.csv` | 192 corals × 3 dates | counts on 06/07, 06/08, 06/12 |
| APEX temperature/pH | `data/raw/apex/datalog*.xml` | continuous | per-tank temperature and pH, 6 datalog files spanning May–June |
| YSI daily spot checks | `data/raw/ysi/Sheet1.csv` | 72 obs | TEMP, DO%, DO mg/L, SAL, PH at 1800 daily |
| Sequencing plate layout | `data/raw/plate_layout/Plate_{1,2}.csv` | 96 wells × 2 | wells, sample ID, day, temp, wound, tank, genotype |
| Sample shipment manifest | `data/raw/shipping/{Box_list,Tube_Labeling,metadata}.csv` | varies | shipped to UC Davis Bay lab |

**Photographs** (color-card and microscope) are NOT in this repo — they live on the Stier Lab NAS at `smb://stier-nas1.eemb.ucsb.edu`. See `notes/LTH_Color_Card_Photos.md` and `notes/LTH_Microscope_Characterization_Photos.md` for index pointers.

**RNA-seq reads** are processed at UC Davis (Bay lab) and will be archived under NCBI BioProject (TBD).

## How to reproduce

### Prerequisites
- R ≥ 4.3.0
- The packages listed at the top of `code/00_setup.R` (tidyverse, lubridate, janitor, readxl, patchwork, scales, broom, broom.mixed, lme4, lmerTest, emmeans, DHARMa, here)

### Steps
1. Clone: `git clone git@github.com:stier-lab/17.-LTH_expression_by_temperature_2025.git`
2. Open `Stier-LTH-expression-by-temperature-2025.Rproj` in RStudio.
3. Restore packages: `renv::restore()` (once `renv.lock` is committed)
4. Run the pipeline in order:
   ```r
   source("code/01_load_clean_metadata.R")   # tidy metadata, save to data/processed/
   source("code/02_pam_analysis.R")          # PAM Fv/Fm × treatment × wound × day
   source("code/03_color_card_analysis.R")   # D-scale color trajectories
   source("code/04_physio_morphology.R")     # 8 binary morphology characteristics over time
   source("code/05_buoyant_weight.R")        # growth (% mass change)
   source("code/06_symbiont_chl.R")          # chl-a, zooxanthellae density
   source("code/07_wax_dipping.R")           # SA via standard curve
   source("code/08_apex_temperature.R")      # parse XML, plot tank temp trace
   source("code/09_ysi_water_chem.R")        # DO, pH, salinity over time
   source("code/10_worms.R")                 # worm presence sanity check
   source("code/11_combined_figure.R")       # multi-panel summary
   ```
5. Figures and tables land in `figures/` and `output/tables/`; processed datasets in `data/processed/`.

## Directory structure

```
.
├── code/
│   ├── 00_setup.R                  # packages, theme_pub(), palettes, paths
│   ├── 01_load_clean_metadata.R    # one-row-per-fragment master metadata
│   ├── 02_pam_analysis.R           # PAM Fv/Fm
│   ├── 03_color_card_analysis.R    # Siebeck D-scale color
│   ├── 04_physio_morphology.R      # 8 wound-healing traits
│   ├── 05_buoyant_weight.R         # growth
│   ├── 06_symbiont_chl.R           # symbionts + chlorophyll
│   ├── 07_wax_dipping.R            # surface area
│   ├── 08_apex_temperature.R       # XML → tank temp time series
│   ├── 09_ysi_water_chem.R         # water-quality spot checks
│   ├── 10_worms.R                  # worm presence
│   ├── 11_combined_figure.R        # multi-panel summary figure
│   ├── plate_fig.R                 # Molly's existing plate-layout figure
│   └── functions/                  # shared helpers
├── data/
│   ├── raw/                        # Immutable — never edit
│   ├── processed/                  # Regenerable
│   └── metadata/                   # Per-stream codebooks (from Drive READ.ME tabs)
├── figures/                        # Publication figures (PDF + PNG)
├── output/
│   ├── tables/                     # CSV summaries
│   └── models/                     # Saved model objects (.rds)
├── manuscript/
│   └── Manuscript_LTH.md           # Working draft (exported from Drive)
└── notes/
    ├── project_README_from_drive.md
    ├── Experimental_Plan_Gene_Expression.md
    ├── Experimental_Plan_Microscope_photographs.md
    ├── Field_Notes_A._pulchra_healing_notes.md
    ├── Progress_Notes.md
    └── sequencing-plan-keck-LTH.md
```

## Stats decisions (locked from Progress Notes 2026-04-29)

- **Random effects:** `(1 | tank) + (1 | thicket)` for all mixed models (genet, not nested).
- **Fixed structure:** `~ treatment * wound * day` for repeated-measures response variables (PAM, color, buoyant weight, morphology), where `day` is centered on the wounding date (D0).
- **Family:** Gaussian with identity link for continuous responses; binomial with logit link for the 8 binary morphological traits; negative binomial (or quasi-poisson) for symbiont counts.
- **Reference levels:** treatment = `28C`, wound = `no`.
- **Multiple comparisons:** `emmeans` contrasts with Tukey adjustment within day.

Cross-references for the analysis approach (per Progress Notes):
- Frontiers in Ecology and Evolution: https://www.frontiersin.org/journals/ecology-and-evolution/articles/10.3389/fevo.2022.979278/full
- Molecular Ecology: https://onlinelibrary.wiley.com/doi/full/10.1111/mec.15535
- Molecular Ecology: https://onlinelibrary.wiley.com/doi/full/10.1111/mec.15820

## License

Code: MIT. Data: CC-BY 4.0 (until publication, then DOI). Manuscript: All rights reserved.

## Funding

NSF support to A.C. Stier and collaborators. Field work at the UC Berkeley Gump Research Station, Mo'orea, French Polynesia.

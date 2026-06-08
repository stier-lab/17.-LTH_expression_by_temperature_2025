# LTH RNA-seq: analysis proposal & genet-matching plan

**For:** Shreya Banerjee (UC Davis, Bay lab)
**From:** Adrian Stier lab (LTH project #17 — *Expression by Temperature 2025*)
**Re:** what the 144 RNA-seq libraries should test, and how to link the three
LTH thickets (A, C, D) to Ross Cunning's genotyped *A. pulchra* CBASS genets.
**Status:** phenotype analysis complete; this is the open genomics piece.
**Last updated:** 2026-06-07.

---

## 1. One-paragraph context

The LTH experiment crossed **wounding** (clip the growing tip, yes/no) with
**chronic heating** (28 °C vs 31 °C, weeks) in *Acropora pulchra* from Mahana,
Mo'orea, using **three field-collected parent thickets (A, C, D)**. The
phenotypic analysis is done and points to three results the transcriptomics
should explain mechanistically:

1. **Heat impairs *regeneration*, not wound *closure*.** Wounds seal at the same
   rate in both temperatures, but new-corallite formation at the regenerating
   tip collapses under heat (Cox HR = 0.22, p = 0.010). The lesion is in the
   skeletal-regrowth program, not re-epithelialization.
2. **Genotype-level thermal tolerance: C > D > A.** Genet C is the most resilient
   across photochemistry, pigmentation, symbiont retention, and calcification;
   the heat effect on physiology is 2.7–3.5× weaker in C than in A or D.
3. **The 31 °C stress is chronic-sublethal.** It sits ~4.4 °C *below* the acute
   Fv/Fm ED50 for this population (35.4 °C; Cunning et al. 2024), so the
   responses are accumulated sublethal stress, not acute photoinhibition.

Full numbers: `RESULTS.md` and `output/tables/20_master_results.csv` (single
source of truth). Sampling design: `notes/sequencing-plan-keck-LTH.md`.

---

## 2. RNA-seq design (as built)

144 libraries (`notes/LTH_PlateLayout_with_IDs`, plate maps in `data/raw/plate_layout/`):

- **Margin biopsies** (wound margin vs matched unwounded margin) at **Days 1, 3, 10**
- **Factors:** temperature (28/31) × wound (W/U) × genotype (A/C/D) × day, with
  4 tanks/temperature; fully interleaved across 2 plates / 1 NovaSeq run
  (temperature, wound, day, tank, genotype all orthogonal to plate/lane).

This balance means the design cleanly supports the contrasts below without
batch confounding.

## 3. Proposed differential-expression analysis (phenotype-anchored)

Suggested model (DESeq2 / limma-voom), host reads:

```
~ treatment * wound * day + genotype   (+ tank as a covariate/random term)
```

Priority contrasts, each tied to a phenotypic result:

| # | Contrast | Phenotype it explains | What to look for |
|---|----------|----------------------|------------------|
| A | **wound × temperature at the tip** (W vs U, 31 vs 28) | heat blocks regeneration not closure (result 1) | biomineralization / SCRiP / carbonic anhydrase / galaxin / skeletal-matrix genes **down** in wounded-heated; re-epithelialization/immune genes intact |
| B | **genotype main + genotype × temperature** | C > D > A resilience (result 2) | constitutive vs heat-inducible thermal-tolerance genes (HSPs, antioxidants, symbiosis/ROS handling) distinguishing C from A/D |
| C | **temperature × day** (chronic trajectory) | progressive sublethal decline (result 3) | accumulating stress signature (proteostasis, apoptosis, symbiont-nutrient) rather than acute photoinhibition spike |
| D | **wound × day** (healing time-course) | trait-onset timing in the morphology data | early (D1) wound-response vs later (D10) regrowth modules |

Tie-in: the **Day 10** tip biopsies are where new-corallite divergence is
sharpest in the phenotype data — the highest-yield timepoint for contrast A.

Symbiont (*Symbiodiniaceae*) reads, if retained, can corroborate the measured
symbiont-density loss and genet C's retention.

---

## 4. The genet-matching question (A, C, D ↔ Cunning genets)

**Why it matters.** Cunning et al. 2024 (*Coral Reefs*, doi:10.1007/s00338-024-02577-7)
measured **acute** CBASS Fv/Fm **ED50** for **20 genotyped *A. pulchra* genets
from Mahana, Mo'orea** (range 34.4–36.6 °C; ED50 predicts classic bleaching,
R = 0.74). Our experiment measured **chronic** resilience for 3 thickets from the
same site. If we can match thickets A/C/D to Cunning genets, we can ask a novel
question: **does an 18-hour acute assay predict chronic, wound-context
resilience?** That would be a strong, publishable cross-method validation.

**The obstacle.** The LTH thicket labels A, C, D are **arbitrary** — there is no
a priori link to Cunning's numbered genets.

### What we already have to work with

- **Exact GPS for each LTH parent thicket** (decimal degrees, from
  `data/raw/metadata/metadata.csv`, columns `coord_lat`/`coord_long`):

  | Thicket | Latitude (°S) | Longitude (°W) | n fragments |
  |---|---|---|---|
  | **A** | 17.49735 | 149.91557 | 72 |
  | **C** | 17.49808 | 149.91595 | 72 |
  | **D** | 17.49726 | 149.91581 | 64 |

  The three thickets are ~40–90 m apart, all within the Mahana / Tiahura
  *A. pulchra* stand on NW Mo'orea — the **same named site** Cunning sampled
  ("mahana", collected Dec 2022; see his repo `data/classic_cbass/collection_metadata.csv`).

- **Host RNA-seq reads from all three thickets** (forthcoming) — enough to call
  genotype-distinguishing SNPs.

- **Cunning's genets are genotyped** — `data/reproducibility/genet_map.xlsx` and
  the CBASS data in `github.com/jrcunning/CBASS_methods`; per-genet ED50 is
  cached for us at `data/external/cunning2024_apulchra_ed50.csv`.

### Proposed matching strategy (primary: genotype; supporting: space)

**Step 1 — call genotypes for A/C/D from the LTH host reads.**
Map host reads to an *Acropora* reference (e.g. *A. millepora* / *A. pulchra*
assembly), call SNPs (GATK or bcftools), and build a per-thicket genotype
profile. Because each thicket is one parent colony, all fragments of a thicket
should be (near-)clonal — a useful internal QC: confirm within-thicket identity
and between-thicket distinctness first.

**Step 2 — obtain Cunning's host genotype data.** This is the pivotal ask. We
need their per-genet **SNP genotypes** (not just ED50 + genet number). Likely
held by Cunning / Putnam; check the CBASS_methods repo / associated genomic
archive, or request directly (co-authors Detmer & Moeller are in the UCSB/Mo'orea
network — easy intro). Confirm reference genome / SNP panel so calls are
comparable.

**Step 3 — match.** Compute pairwise identity/relatedness between each LTH thicket
genotype and the 20 Cunning genets (identity-by-state, or a relatedness metric
robust to different SNP panels). A clonal match → direct genet assignment; a
high-relatedness near-match → same lineage / clonemate. Report match confidence.

**Step 4 — supporting spatial check.** Compare LTH thicket GPS to Cunning's genet
collection waypoints (his metadata lists handheld GPS IDs "Shedd1/Shedd3"; exact
coords may need to be requested). Spatial proximity is **suggestive, not
conclusive** — *A. pulchra* forms clonal thickets, so adjacent colonies can be
the same genet, and distant ones can be clonemates via fragmentation. Use space
only to corroborate the genotype match.

**Step 5 — the payoff analysis.** If matched, correlate Cunning's **acute ED50**
against our **chronic resilience** (per-thicket scores in
`output/tables/19_genet_resilience_summary.csv`; ranking C > D > A) and against
the genet × temperature DE signal (contrast B). Even a 3-point match is a
meaningful qualitative test (does the chronically-resilient genet have the
highest acute ED50?); a clonemate-level match strengthens it.

### Honest fallback

If genotype data can't be obtained or the panels aren't comparable, we fall back
to a **population-level** statement (already in the manuscript): both acute
(CBASS) and chronic (LTH) methods independently detect substantial heritable
thermal-tolerance variation in Mahana *A. pulchra*. The genet-level correlation
is the upside if matching succeeds.

---

## 5. Concrete next steps / asks

- [ ] **Shreya:** SNP-calling pipeline on LTH host reads → per-thicket genotypes
      + within/between-thicket identity QC (Step 1).
- [ ] **Shreya + Adrian:** request Cunning/Putnam host genotype data + exact genet
      collection coords; confirm reference genome (Step 2).
- [ ] **Shreya:** relatedness/identity matching A/C/D ↔ 20 genets (Step 3).
- [ ] **Adrian:** confirm the LTH collection site name with Gump/field team
      (coords say Mahana/Tiahura; lock the site label).
- [ ] **Joint:** DE analysis contrasts A–D (Section 3); then the acute-vs-chronic
      correlation (Step 5) once matching resolves.

Questions → Adrian. Phenotype data, code, and the cached Cunning ED50 table are
all in this repo.

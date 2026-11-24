# Lattice corpus — radial-angular signatures v1 (CP-02, #7)

Date: 2026-11-24 · Agent: jjcav84/Devin
Extractor: `scripts/extract_lattice_signatures.py` (PIL+numpy, no native deps beyond requirements.lock equivalents — Pillow/NumPy)
Data: `geometry/lattice/signatures_v1.json` (34 images, 521 KB)

## Corpus

Ravenproofs mirror `research/GEOMETRIC_INTELLIGENCE_INNOVATION/source_corpus/lattice-images/` — 34 JPEGs (~15 MB), provenance `SOURCE_CORPUS_MANIFEST.csv` (35 rows from `johnstobey/lattice-images-`, `COPIED_IDENTICAL` + source git SHAs). Per-image SHA-256 recorded in the JSON.

## Method (v1 — honest scope)

Per image: Otsu-quantile ink mask ( darkest 5% of L ), two center
estimates (image center, ink centroid), radius = 95% ink-mass quantile,
signature = ink mass on a 36-angle × 8-radius grid normalized to a
distribution, plus a structure-tensor orientation histogram (unoriented,
5° bins, top-6 peaks) as edge-class lite.

**This is not a vertex/edge/crossing vector graph.** Stroke
vectorization, junction detection and crossing-vs-connection analysis
remain frontier items — the RVC-IMG vortex work shows the threshold
graph approach and its sensitivity limits.

## Findings

- All 34 are thin-line art: ink fraction 0.051–0.089. 31× 1024×1024,
  3× 1107×960 (`ma at`, `nut`, `seth`, `sakhmet` — non-square variants).
- Center offset (ink centroid vs image center) ranges 2.05 px
  (`book of the dead lattice`) to 341.8 px (`lattice mercury`) —
  centering is NOT uniform across the corpus; signatures are reported
  in both center frames for this reason.
- Pairwise signature distance (total variation, image-center frame,
  n=561 pairs): min 0.180, median 0.551, max 0.806 — the corpus is
  diverse; no near-duplicate variants.
- Closest pairs (full signature): `lattice seth` ~ `sakhmet lattice`
  (0.180) — both Egyptian-figure variants; `cygnus` ~ `mercury` (0.242);
  `amun` ~ `hathor` (0.244); `aquarius` ~ `pisces` (0.245);
  `isis` ~ `osiris` (0.247).
- Angular-only projection (radial bands collapsed): closest pair
  `Gemini_Generated_Image_8yx5…` ~ `lattice amun` (0.062) — a
  Gemini-generated plate angularly resembles a named variant;
  `Gemini_…u5o6…` ~ `ursa major` (0.076); `Taurus` ~ `raven.jpg` (0.085).
- Nearest-neighbor structure clusters loosely by theme (Egyptian
  figures pair together) but median angular distance 0.34 rules out a
  shared 12-fold template across the corpus.

## What this does and does not establish

- **Established**: reproducible per-image ink signatures with hash
  provenance; measurable variant-correspondence structure (nearest
  neighbors, thematic clustering) at the distribution level.
- **Not established**: geometric isomorphism between variants, shared
  generating rule, correspondence to Z/12 ring elements, or any
  artwork-to-ring mapping. Ink-signature similarity is not structural
  equivalence — a proper test needs the vector-graph layer.
- **Counterexample discipline**: `center_offset_px` outliers show why
  frame-relative claims need the declared coordinate frame; signatures
  computed about the wrong center would manufacture false correspondences.

## Reproduce

```bash
python3 scripts/extract_lattice_signatures.py \
    ~/workspace/Ravenproofs/research/GEOMETRIC_INTELLIGENCE_INNOVATION/source_corpus/lattice-images
```

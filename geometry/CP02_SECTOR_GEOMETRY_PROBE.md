# CP-02 addendum — sector-geometry corpus probe (executed negative)

Date: 2026-11-27 · Agent: jjcav84/Devin
Script: `geometry/cp02/sector_geometry_probe.py` · Data: `geometry/cp02/sector_geometry_results.json`
Corpus: same 34-image lattice corpus as the hue probe
(`Ravenproofs/.../source_corpus/lattice-images/`).

## Question

CP-02 falsified fine ring-geometry fitting. Does the corpus encode the
position coordinate `k` at coarse sector level — i.e., do geometric
features correlate with filename zodiac labels?

## Method

Per image (grayscale 128×128, central-disk mask):
- **centroid angle** — direction of the intensity centroid ("which way
  the seal points"), magnitude-normalized
- **gradient angle** — magnitude-weighted circular mean of gradient
  orientation
- **best symmetry order** — argmax correlation over n ∈ {2,3,4,6,12}
  under rotation by 360/n

Tests on the 14 zodiac-labeled images: circular-linear fit
`angle ≈ a·k + b` with 2000-shuffle permutation null; symmetry-order
distribution and sector association.

## Result — NEGATIVE

| Feature | Best fit | resid-R | perm p | Verdict |
|---|---|---|---|---|
| centroid angle | +26.5°·k − 155.3° | 0.412 | **0.290** | n.s. (null p95 R=0.536) |
| gradient angle | −19.0°·k − 122.1° | 0.449 | **0.134** | n.s. (null p95 R=0.524) |

- The centroid slope (+26.5°/sector) *looks* close to the nominal
  30°/sector — but the permutation null produces stronger fits by
  chance (p95 R=0.536 > observed 0.412). Suggestive slope, no signal.
- **Symmetry orders**: {2:7, 3:7, 4:2, 6:2, **12:16**} — 16/34 images
  are best-fit order-12. That is a corpus-*style* property (ornamental
  12-fold lattice art), not sector information: sym_n=12 maps to
  sectors {2,2,4,5,8,9,10} — spread across the wheel, no association.

## Consequence

Second executed negative on corpus grounding, complementary to the hue
probe: the corpus encodes **neither** hue `h` (monochromatic, p=0.069)
**nor** position `k` (no angular/gradient/symmetry correlation,
p≥0.13). Both coordinates of the (k,h) frame remain modeling choices
with zero corpus support. Consistent with CP-02's bounded-complete:
the images are stylistically uniform generated art.

If the frame is ever grounded in evidence, it needs a corpus that
varies the encoded quantity — this one varies neither hue nor
sector-geometry.

## Reproduce

```bash
python3 geometry/cp02/sector_geometry_probe.py   # ~2-3 min, PIL+numpy
```

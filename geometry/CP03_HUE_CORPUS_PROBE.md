# CP-03 addendum — hue corpus probe (executed negative)

Date: 2026-11-27 · Agent: jjcav84/Devin
Script: `geometry/cp03/hue_corpus_probe.py` · Data: `geometry/cp03/hue_corpus_results.json`
Corpus: `Ravenproofs/research/GEOMETRIC_INTELLIGENCE_INNOVATION/source_corpus/lattice-images/` (34 images)

## Question

Does the image corpus assign the hue coordinate `h` — i.e., do image
colors carry Z/12 hue structure correlated with sector labels?

## Method

Per image: PIL load → 128×128 → saturation×value-weighted circular-mean
hue (grays down-weighted) → `h12 = round(hue/30) mod 12`. Tests:
(A) corpus-wide hue isotropy (Rayleigh + 12-bin χ²), (B) zodiac-labeled
subset filename-sector vs hue circular correlation with 2000-shuffle
permutation null.

## Result — NEGATIVE, and informative

- **Corpus is hue-monochromatic**: all 34 images' dominant hues fall in
  34.9–72.3° (mean resultant R=0.986 at 61.2°, Rayleigh p≈4e-15,
  χ²=195 on 12 bins). The corpus sits at h≈1–2 everywhere — one warm
  palette, not twelve.
- **No sector→hue correlation**: best fit `hue ≈ 0.8°·k + 61.3°`
  (essentially flat), permutation **p=0.069** — not significant; the
  high residual-R is an artifact of near-zero hue variance (any label
  assignment "correlates" when all hues are ~61°).
- Zodiac-labeled images (n=14) show no hue ordering by sector; the
  Egyptian-deity and other images are equally monochromatic.

## Consequence for hue-layer/v1

The spec's disclosed caveat — *"hue independence is a modeling choice;
no corpus evidence assigns it"* — is now **strengthened to an executed
negative**: the corpus does not encode hue as an independent coordinate
at all (it is constant, not merely unassigned). Case C (h independent)
remains a modeling choice with zero corpus support; if the hue layer is
ever grounded in evidence, it needs a corpus that actually varies hue —
this one cannot supply it.

Consistent with CP-02's bounded-complete verdict: the images are
stylistically uniform generated art, not mathematical encodings of
(k,h). Fine geometry was falsified there; hue variation is falsified
here.

## Reproduce

```bash
python3 geometry/cp03/hue_corpus_probe.py   # ~60s, stdlib+PIL+numpy
```

Corpus path is absolute to this machine's Ravenproofs checkout; the
script documents the expected input layout.

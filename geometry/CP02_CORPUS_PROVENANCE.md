# CP-02 addendum — corpus provenance and exhaustion check

Date: 2026-11-27 · Agent: jjcav84/Devin

## Question

The hue and sector-geometry probes both returned executed negatives on
the same 34-image corpus. Before treating that as definitive, is there
*other* local image data that could carry hue or sector structure?

## Findings

1. **Single provenance chain.** The Ravenproofs corpus
   (`research/GEOMETRIC_INTELLIGENCE_INNOVATION/source_corpus/
   lattice-images/`, 34 images) contains 21 files **byte-identical**
   (sha256-verified, e.g. `lattice libra.jpeg` =
   `a150957e…f970`) to `tobey-memory/bundle/Artifact_and_Handoff/
   lattice_assets/` (21 files). The Ravenproofs set adds ~13 generated/
   evidence images on top. There is no second independent lattice-image
   collection.
2. **Exhaustive workspace sweep.** `find ~/workspace -iname '*.png|jpg|
   jpeg|webp'` across all ~35 local checkouts: the only zodiac/seal
   imagery is the known corpus. Remaining hits are unrelated project
   assets (logos, favicons, course diagrams dia1–8, website captures,
   vendor docs, memes). `tobey-memory/lattice/` is `leaves.jsonl`
   (tabular data, not images); `01_corpus/` dirs are text corpora.
3. **z12x documents are data, not imagery** — the GeometryIR fixtures
   encode coordinates directly and are already consumed by the
   interchange contract; they cannot serve as hue/sector *evidence*
   for the frame's empirical grounding.

## Consequence — corpus grounding is closed locally

Both frame coordinates `(k, h)` now have **executed negatives on the
entire locally available image corpus**, and no additional local source
exists that could change the result. The only remaining evidence
channels are:

- **External**: the original recognition material (the "alien math"
  source — per CONSTITUTION Article 7 still an evidence-search
  obligation, e.g. the reported YouTube clip whose date/provenance is
  unverified).
- **Synthetic labeled data**: could be generated, but cannot ground a
  claim about *source* material — it would only test the pipeline.

Until external evidence surfaces, `(k,h)` stands as a modeling choice —
now with the strongest available negative: the complete local corpus
falsified on both coordinates.

# CP-03 addendum — source-text probe: does the Tobey material contain (k,h)?

Date: 2026-11-28 · Agent: jjcav84/Devin

## Question

The hue and sector-geometry probes returned executed negatives on the
34-image corpus, and the corpus-provenance addendum closed the local
image hunt. One evidence channel remained nominally open: the **source
text** — the original Tobey course material and decoded artifacts in
`tobey-memory`. If the `(k,h)` frame descends from the source material,
the vocabulary should appear there. This probe tests that directly.

## Corpora probed (all local, all Tobey-source)

| Corpus | Size | Path |
|---|---|---|
| Course v2.0 clean text | 23,706 lines | `tobey-memory/bundle/Source_Course/Tobey_Course_Clean_Copies/Tobey_Course_v2.0_clean.txt` |
| Canonical lesson corpus | 24 files, 2,201 lines | `tobey-memory/recursiverse/01_BASELINE/original/tobey_three_language/01_corpus/lesson_01..24.txt` |
| Bundle markdown artifacts | incl. `SENTENCE_ISOMORPHISM_MAP.md` (~1 MB), natal pipeline outputs, decode reports | `tobey-memory/bundle/**`, `tobey-memory/incoming/*.zip` (extracted) |
| Lattice address table | 268 records | `tobey-memory/lattice/leaves.jsonl` |

## Results

**`hue`: 0 occurrences in every corpus.** Not once, across ~26k lines
of course text, all 24 lessons, and every decoded/bundle artifact.

**`color`/`colour`: ~19 hits total, all metaphorical** — verified by
context inspection: eye-color comparison, "blue+red=purple NOW" (a
past/future blending metaphor for the zodiac wheel), "colored glasses",
"colored by sentiment", "different colored ink" for chart overlays, and
one false positive ("Colo/**rado**"). No occurrence assigns color to a
coordinate, sign, house, degree, or position.

**`sector`: 0 in course text and lessons.** The only hits are in natal
pipeline outputs where "sector" is a *text-segmentation index*
("initial sector", "sector 0 (48)") — passage slicing, unrelated to
coordinates.

**The material's actual coordinate vocabulary is astrology**:
`zodiac` 229, `house` 232, `sign` 587, `degree` 291, `cancer` 67,
`aries` 89 hits in the course text. The 12-fold structure the course
elaborates is the zodiac — matching the structure CP-02 already
falsified for fine geometry — plus duodecimal *arithmetic* philosophy
("base of the duodecimal system"), not a (k,h) product space.

**`lattice/leaves.jsonl` addresses carry no semantic signal**: fields
are `ring`∈[0,11], `harmonic`∈[1,12], `page`/`cell`/`level`∈[0,143] —
superficially Z/12 × Z/12 × Z/144-shaped. But `ring-memory-spec.md`
documents `coord_of(content) = sha256(content)[0] mod 12` —
content-hash-derived addresses. Empirically confirmed: ring
distribution is uniform across source types (lattice_assets, natal,
course all spread over all 12 rings), and 120/144 (ring,harmonic)
pairs are occupied by 268 records — consistent with uniform hash
assignment, not semantic coordinate placement.

## Verdict — third executed negative, strongest channel yet

| Channel | Result |
|---|---|
| Image pixels (hue) | monochromatic, h≈1–2 constant — `CP03_HUE_CORPUS_PROBE.md` |
| Image geometry (sector) | centroid/gradient slopes inside permutation null — `CP02_SECTOR_GEOMETRY_PROBE.md` |
| **Source text (this probe)** | **zero hue vocabulary; color metaphor-only; sector absent** |

The `(k,h)` frame — and specifically `h` — has **no basis in any local
Tobey-source material**: not in the images, not in the course text, not
in the lessons, not in the decoded artifacts, not in the lattice
address table. The hue layer is confirmed as a **Cognition-side
modeling choice**, now falsified on three independent channels
including the originating text itself.

`k`'s astrology analogues (sign/house/degree) remain covered by the
CP-02 bounded-complete verdict; the course's own 12-fold structure is
the zodiac, which that verdict already addressed.

## What remains open

Per CONSTITUTION Article 7, the only untested channel is **external
recognition material** — the reported "alien math" source (e.g. the
YouTube clip whose date/provenance is unverified). Nothing local can
change the verdict above; only genuinely external evidence could.

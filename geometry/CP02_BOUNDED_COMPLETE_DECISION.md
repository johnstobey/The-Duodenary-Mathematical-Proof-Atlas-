# CP-02 (#7) — Bounded-complete decision document

Date: 2026-11-24 · Agent: jjcav84/Devin · Status: DECISION REQUESTED — analysis only; acceptance is the owner's call.

Issue #7 asks for SVG/JSON geometry extraction from artwork — explicit
vertices/edges/layers/crossings/angle/radius plus source hash —
rotation/reflection/antipode/orbit/edge-class invariant tests, variant
correspondence, cross-repo mapping, and non-duplicating coordination with
Ravenproofs contracts `RVC-EXEC-20261113-002` and `RVC-IMG-20261115-011`
(both claimed by other agents; extraction is not duplicated here). Five PRs
merged to main this session bound what is achievable; this document records
the evidence and the options.

## 1. Requirement vs. delivered evidence

| #7 requirement | Status | Evidence |
|---|---|---|
| Geometry extraction: vertices/edges/layers/crossings/angle/radius + source hash | PARTIAL (bounded) | IR baseline `geometry/inputs/twelve_sector_baseline_v1.json` carries 12 nodes, relations, provenance sha256 — but every node is `evidence: mathematical_derivation` and the source PNG is `binary_available:false` upstream (PR #25 `7b70f14`). The lattice corpus is hash-manifested (34 JPEGs, ~15 MB, Ravenproofs mirror) yet raster→graph extraction is falsified for it (PRs #29 `b5e5135`, #30 `e986f40`). `signatures_v1.json` delivers distribution-level ink signatures, not vector graphs (PR #27 `7b60d3a`). |
| Rotation/reflection/antipode/orbit/edge-class invariant tests | MET at IR↔ring level (partial coverage of the list) | `scripts/check_geometry_ir.py` 14/14, exit 0 (PR #25): successor 12-cycle orbit, antipode J(k)=k+6 involution, antipodal relations == J-pairs, CRT (k%4,k%3), coordinate frame, crossings discipline, provenance hash. Reflection is covered only via the antipodal involution (no independent mirror test); edge-class reduces to C07 crossings discipline, which passes vacuously (`not_annotated`). |
| Correspondence among variants | PARTIAL | `signatures_v1.json`: pairwise total-variation median 0.551 (n=561 pairs), nearest neighbors cluster by theme (Egyptian-figure variants), NO shared 12-fold template. Distribution-level correspondence only — no vertex-level isomorphism established. |
| Cross-repo mapping | MET | `geometry/CP02_CROSS_REPO_MAPPING.md` (PR #25; corpus section corrected PR #26 `0e57f4f`): field map IR→canonical Z/12; corpus verified mirrored byte-identical in `Ravenproofs:…/SOURCE_CORPUS_MANIFEST.csv`. |
| Coordinate with RVC contracts, no duplicated extraction | MET | Scope boundary documented in `CP02_CROSS_REPO_MAPPING.md`; RVC-IMG owns seal/vortex raster extraction, RVC-EXEC owns the execution contract. `SACRED_SEALS_WITH_IMAGES.pdf` page audit remains RVC-IMG-20261115-011's deliverable — not duplicated. |
| Artwork-fidelity vector extraction for this corpus | FALSIFIED (two independent probes) | `skeleton_stability_probe.txt` (PR #29): Zhang-Suen junction counts vary ~50× across ink thresholds (Lattice Aries 6→33→355) — naive raster→graph not viable. `rotational_symmetry_v1.json` (PR #30): 0/34 images show dominant 12-fold order (dominant orders: 1×9, 2×13, 3×7, 4×1, 6×3, 8×1; peak/runner-up power ratio median 1.92); k=12 appears in the top-4 of only 1 image. |

## 2. Verified vs. falsified

**Verified**

- IR↔ring consistency: 14/14 invariant checks pass on the vendored
  TwelveSector baseline (`python3 scripts/check_geometry_ir.py`).
- Corpus inventory + provenance: 34 JPEGs with per-image SHA-256 in the
  signatures JSON; manifest-verified byte-identical Ravenproofs mirror.
- Reproducible ink signatures: 36-angle × 8-radius distributions in both
  center frames (center offsets range 2–342 px, so both frames are reported).

**Falsified / not established**

- Skeleton→graph extraction stability for this corpus (threshold-sensitive
  junction counts, ~50× swing).
- Dominant 12-fold rotational order in any corpus image.
- Raster-level artwork→ring correspondence for this corpus.
- Geometric isomorphism between variants — ink-signature similarity is not
  structural equivalence.

## 3. Non-claims

- No artwork fidelity: the IR baseline is a generated idealization whose
  source binary is unavailable; nothing here verifies pixels. The raster
  evidence layer remains RVC-IMG's.
- No hardware physics, device operation, or semantic interpretation — per
  issue scope.
- No claim that variants share a generating rule or map onto Z/12 elements.
- Signatures are distribution summaries; they do not substitute for a
  vertex/edge/crossing graph.

## 4. Decision options

**(a) ACCEPT as bounded-complete** — raster-vector extraction descoped for
this corpus on measured evidence; the IR/mapping/invariant layer stands.

- Pros: honest — every requirement is either met at the level the available
  sources support or falsified with reproducible probes; closes the issue
  without unfunded frontier work; all artifacts and hashes preserved for
  future corpora.
- Cons: the literal "vertices/edges/crossings from artwork" clause is unmet
  for the lattice corpus; a reviewer wanting vector graphs must look to
  RVC-IMG outputs or a new corpus.

**(b) RETAIN OPEN — parametric curve-fitting** per detected structure
(fit circles/lines/arcs to ink ridges, then graph).

- Pros: could in principle recover vector graphs where thinning failed.
- Cons: low expected value — the rotational-symmetry probe already shows
  the corpus lacks the 12-fold order that would make fitted parameters
  ring-interpretable; adds model assumptions without a falsifiable target;
  risks open-ended scope.

**(c) RESCOPE** — move the raster-vector requirement to a corpus with
vectorizable sources (SVG-native art, or the RVC-IMG vortex
`graph.json`-style threshold outputs).

- Pros: keeps the extraction requirement alive where achievable; leverages
  already-claimed contract outputs instead of duplicating them.
- Cons: requires the owner to re-point the issue; the lattice corpus then
  has no vector-graph deliverable at all.

## 5. Recommendation

Accept as bounded-complete (option a). Two independent falsifications bound
the raster→vector path for the only hash-manifested corpus in scope, and the
one published geometry artifact verifies cleanly against the canonical ring
at the consistency level that is actually checkable without its source
binary. The honest deliverable is: invariant/mapping layer (met), corpus
inventory + signatures (met), and documented negatives that prevent
overclaiming. Parametric fitting (b) has low expected value given the
rotational-symmetry negative; rescope (c) is viable but is a scope decision,
not an evidence gap this issue can close.

## 6. Decision authority

Acceptance, descope, or rescope of issue #7 is the repository owner's
decision. This document is analysis with pinned evidence; it does not
constitute acceptance, and no issue state was changed by its author.

## Evidence index (SHA-256, this repo @ main `aade3e9`)

| Artifact | SHA-256 (prefix) |
|---|---|
| `geometry/inputs/twelve_sector_baseline_v1.json` | `a3b625d4…` |
| `geometry/lattice/signatures_v1.json` | `f519fa66…` |
| `geometry/lattice/rotational_symmetry_v1.json` | `2e914f6a…` |
| `geometry/lattice/skeleton_stability_probe.txt` | `75987067…` |
| `geometry/lattice/LATTICE_SIGNATURES_V1.md` | `7eba814d…` |
| `scripts/check_geometry_ir.py` | `1658a839…` |
| `scripts/extract_lattice_signatures.py` | `286005de…` |
| `scripts/probe_skeleton_stability.py` | `f9279d8c…` |
| `scripts/analyze_rotational_symmetry.py` | `3facbffb…` |
| `geometry/CP02_CROSS_REPO_MAPPING.md` | `d39f5ebf…` |

Merged PRs: #25 `7b70f14`, #26 `0e57f4f`, #27 `7b60d3a`, #29 `b5e5135`,
#30 `e986f40`.

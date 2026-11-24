# CP-02 (#7) — Geometry artifact → canonical Z/12 mapping

Date: 2026-11-24 · Agent: jjcav84/Devin · Status: IN PROGRESS (extraction owned elsewhere; this is the Atlas-side invariant/mapping layer)

## Scope boundary (anti-duplication)

The issue directs coordination with Ravenproofs contracts
`RVC-EXEC-20261113-002` (claimed: ChatGPT GPT-6 session, branch
`agent/RVC-EXEC-20261113-002`, no remote head at time of writing) and
`RVC-IMG-20261115-011` (claimed: OpenAI Codex CLI session, remote head
`9eab213`, deliverables under `agent_results/RVC-IMG-20261115-011/`).
This change does **not** re-extract source imagery. It consumes the
already-published geometry IR artifact and tests it against the
canonical ring interface delivered by CP-01 (#6, merged via PRs #14/#18).

## Consumed input

| Field | Value |
|---|---|
| Artifact | `geometry/inputs/twelve_sector_baseline_v1.json` (vendored copy) |
| Upstream path | `Ravenproofs:research/GEOMETRIC_INTELLIGENCE_INNOVATION/experiments/2026-11-23_chunks_2_4/TWELVE_SECTOR_BASELINE.json` |
| Upstream commit | `368a06702254163d1ada855678db619faf9d395c` (Ravenproofs main) |
| Vendored file SHA-256 | `a3b625d4ab2bae46e21efaa1b0023bcbf13b89806b478664052f03ec1500a10b` |
| Declared source | `image(20261123-144941).png`, sha256 `f7d698393301dc4cb92648113f586aee5e2b182ed9d6f7e653fa2e2feec475e6`, `binary_available: false` |

## Field mapping (IR → canonical interface)

| IR element | Canonical meaning | Check |
|---|---|---|
| `nodes[].k ∈ {0..11}` | element of `ZMod 12` / `C12` | C01 |
| `nodes[].theta_deg = 30k` | angular position, frame: center origin, zero=top, clockwise, y-down | C02 |
| successor `k → k+1 mod 12` | ring successor `σ`; single 12-cycle orbit | C03 |
| `nodes[k+6] = −nodes[k]` | antipode `J(k) = k+6` (`Duodenary.opposite`) | C04 |
| `relations[type=antipodal]` | the six J-pairs `{k, k+6}` (12 directed entries) | C05 |
| `k → (k mod 4, k mod 3)` | CP-01 CRT coordinates — all 12 pairs distinct (Latin incidence) | C06 |
| `crossings` | visual crossings vs connected vertices must stay distinct; `not_annotated` passes vacuously | C07 |
| `source.sha256` | provenance requirement | C08 |

## What is and is not claimed

- **Verified**: internal consistency of the IR artifact and its
  correspondence to the canonical `ZMod 12` ring structure
  (successor orbit, J-involution, CRT incidence). 14/14 checks,
  `python3 scripts/check_geometry_ir.py` → exit 0.
- **Not verified**: fidelity to any source artwork. Every node carries
  `evidence: mathematical_derivation` — this baseline is a *generated*
  idealization; the source PNG binary is unavailable upstream
  (`binary_available: false`). Raster-level extraction with threshold
  sensitivity analysis exists in `RVC-IMG-20261115-011`
  (`derived/vortex-threshold-128-graph.json` et al.) and remains the
  evidence layer for source-image claims.
- **Not claimed**: hardware physics, device operation, or semantic
  interpretation of the geometry — per issue scope.

## Source corpus availability (corrected 2026-11-24)

The remote repos `johnstobey/lattice-images-` and
`johnstobey/tobey-resolution` do not resolve via the available GitHub
token, **but their contents are already mirrored byte-identical inside
Ravenproofs** — verified this session:

- `Ravenproofs:research/GEOMETRIC_INTELLIGENCE_INNOVATION/SOURCE_CORPUS_MANIFEST.csv`
  — 44 rows: 35 × `lattice-images-`, 8 × `tobey-resolution`,
  1 conversation-upload; 42 rows `COPIED_IDENTICAL` with source git
  SHAs and byte sizes.
- `source_corpus/lattice-images/` — 34 JPEGs, ~15 MB, real binaries
  (zero files < 2 KB): Gemini-generated plates plus named lattice
  images (aries, taurus, amun, anubis, aquarius, capricorn, hathor,
  horus, isis, leo, libra, mercury, raven, sakhmet, cygnus, …).
- `source_corpus/blueprint_deliverables/` — the tobey-resolution
  `geometric/blueprint_deliverables` payload: `qutip_lindblad_floquet.py`,
  `meep_nonreciprocal_sparam.py`, `SurfaceCodeStabilizer.lean`,
  `TopologicalInvariant.lean`, `substrate_v2_config.json`,
  `manifest.tsv` (per-file sha256 + PDF-page provenance).

Consequence: CP-02 source extraction is **not** blocked on repo access;
the corpus is local to Ravenproofs with hash provenance. Extraction
ownership of raven/vortex/seal imagery remains with RVC-IMG-20261115-011;
lattice-image graph extraction is available scope for this issue.

- `SACRED_SEALS_WITH_IMAGES.pdf` (11,052,626 bytes) is present in
  Ravenproofs root; page-level seal audit is RVC-IMG deliverable
  `SACRED_SEALS_PAGE_AUDIT.md` — not duplicated here.

## Reproduce

```bash
python3 scripts/check_geometry_ir.py            # 14/14, exit 0
python3 scripts/check_geometry_ir.py <other.json>  # any GeometryIR v1 doc
```

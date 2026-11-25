# CP-04 (#9) — Cross-repo certified interface adoption: consumer matrix

Date: 2026-11-24 · Agent: jjcav84/Devin · Status: IN PROGRESS
Canonical interface: Atlas `closed_ring_z12_mathlib` (`ZMod 12 ≃+* ZMod 4 × ZMod 3`, `C12 ≃+* ZMod 12`, transport layer) — CP-00/CP-01, accepted.

## Consumer matrix

| Consumer | Repo | Interface consumed | Evidence | Status |
|---|---|---|---|---|
| tobey-relational-decoder | Ravenproofs `projects/tobey-relational-decoder/04_formal` | Atlas `closed_ring_z12_mathlib` path dep; `AtlasConsumption.lean` 5 inherited theorems; Lean CI | Ravenproofs PR #60 (merged `940f88a`) — "DCC-01 Stage 4 consumer 2" | **ADOPTED** — canonical Mathlib path |
| tobey-three-language | `jjcav84/tobey-three-language` | GeometryIR `z12x` interchange (Lisp+Prolog consumers); Rust `geometry.rs` Z/12 aspects + 144 slots + antipodal TSV | CRIA-02: A1 consumer registration DONE — PRs #3 (Lisp consumer+fixture), #4 (Prolog `read_geometry_ir/1`) | **ADOPTED** at interchange level; native execution unverified |
| Recursiverse-Suite | `johnstobey/Recursiverse-Suite` | `recursiverse_engine.py` Z/12+Z/144, 64 closed masks, `coordinate_envelope.schema.json`, `adapters/geometry_ir/z12x_reader.py` | Chunk-4 audit: 144 fine-grid antipode cases, 4096 intersections pass; PR #53 merged `5bc93a2` — reader emits canonical_sector/fine_144 envelopes, 24/24 GIR vectors, 7/7 adversarial rejections | **ADOPTED at interchange level** — GeometryIR/z12x Python reader merged |
| Machine | `johnstobey/Machine` | `coords.rs` + `COORDINATE_SEMANTICS_SPEC.md`, `driver/src/geomframe.rs` | audit: strict degree-longitude vs sector-index; legacy `floor(degree) mod 12` unit error documented; PR #7 merged `3984633` — GeoAnchor +9/+3 source-defined shifts, explicit Orientation non-claim, antipode k→k+6 invariance | semantics certified; **frame conversion MERGED** |
| z12z-Memory-Module | `johnstobey/z12z-Memory-Module` | `lattice.rs` antipodal +6/+72/+864 (ring/page/cell), `coordinate_envelope.rs`, `provenance.rs` | audit: 12-sector/144-fine/1728-cell anchor round-trips pass; PR #9 merged `54faecf` — `ProvenanceRecord` (schema Z12MEM-PROVENANCE/1, typed `SignedCoordinate`, two-layer verify, deterministic signing) | compatibility-tested; **provenance signatures MERGED** |
| Alien-math-decoded-2 | `johnstobey/Alien-math-decoded-2` | `AtlasConsumption.lean` — imports `ZMod12Transport`/`C12ZModBridge`/`CRTMathlib`; `lakefile.lean` `require closed_ring_z12_mathlib from git` pinned `2d84d17`; Lean v4.14.0; exact/apply-only inheritance + `#print axioms` | direct clone inspection this session (repo active, pushed 2026-11-24) | **ADOPTED** — strongest form: git-pinned Lake dep, axiom-inheriting |
| oversight | `johnstobey/oversight` | provenance/review only — explicitly not math kernel | reuse map | n/a |
| Omni-Lattice-Suite, Machine-Artifacts- | — | — | repos do not resolve under available token | **DEFERRED** per critical-path doc (integrate after interfaces stable) |

## Semantic boundaries (must not be conflated — from Chunk-4 audit)

1. **Image pair vs memory pair**: image `(k, J(k))` is an antipodal *relation*; memory `paired_kj` is sector k + subdivision j. `(0,6)` = antipodal relation, but packed fine `(k=0,j=6)` = q=6; fine antipode of q=0 is q=72. Different types — never translate as equivalent.
2. **Frame anchors**: image frame is top-origin clockwise; Aries-zero/Cancer-zero domain frames require an explicit source-defined anchor mapping. None may be assumed.
3. **Z/144 vs (Z/12)²**: certified non-isomorphic on both sides (Atlas `product_exponent`/`cyclic144_not_exponent12`; Ravenproofs crosswalk executable witness).

## Gap list (audit integration hypothesis — still open)

- [x] typed interchange → three-language compiler — **done via z12x (A1)**
- [x] Python geometry reader → Recursiverse-Suite — **MERGED**: Recursiverse-Suite#53 (`5bc93a2`; `adapters/geometry_ir/z12x_reader.py`, 24/24 GIR vectors via convert, governance-clean)
- [x] frame-anchor conversion → Machine — **MERGED**: Machine#7 (`3984633`; `driver/src/geomframe.rs`, GeoAnchor +9/+3 source-defined shifts, explicit Orientation non-claim, 8/8 unit + 40/40 suite green on mini)
- [x] provenance-preserving signature records → z12z-Memory-Module — **MERGED**: z12z-Memory-Module#9 (`54faecf`; `src/provenance.rs`, `ProvenanceRecord` binds typed coordinate to source artifact w/ sha256 digests, deterministic signing, tamper-evident; fmt/clippy/133 tests green on mini)
- [ ] native code execution + end-to-end adapter integration — audit: **not done** (Lean consumers tobey-decoder + Alien-math-decoded-2 now cover the formal path)

## Verification log

- 2026-11-25: all three compatibility-gap PRs merged by owner — Recursiverse-Suite#53 `5bc93a2`, Machine#7 `3984633`, z12z-Memory-Module#9 `54faecf`. Every named gap item in the audit integration hypothesis is now landed on a consumer main branch; remaining open item is native end-to-end execution.
- 2026-11-25: z12z-Memory-Module cloned; `src/provenance.rs` added — `ProvenanceRecord` w/ `SignedCoordinate::{Envelope,LatticeAddress}`, `sign()` (deterministic, no clock), `verify_self`/`verify_source`, serde round-trip + tamper tests. Verified on mini (dell cargo disabled): fmt clean, clippy -D warnings clean, `cargo test --all` 133/133. PR #9 open, CI green.
- 2026-11-25: Machine cloned; `geomframe.rs` built per Chunk-4 boundary (explicit anchor + orientation, no assumed correspondence); cargo test on mini (dell builds disabled) 40/40 green. Machine PR #7 open.
- 2026-11-25: Recursiverse-Suite cloned; `adapters/geometry_ir/` reader built + self-checked (z12x parse → validate → emit → convert → 24/24 GIR vectors); adversarial rejection 7/7; GOV-005 required `adapters/` placement (artifacts//tests/ immutable). PR #53 open, CI green.
- 2026-11-24: Alien-math-decoded-2 upgraded UNVERIFIED→ADOPTED after direct clone; `AtlasConsumption.lean` + `lakefile.lean` git-pin inspected. `gh search code` returned empty (index lag) — direct clone is ground truth.

## Sources

- `Ravenproofs:research/GEOMETRIC_INTELLIGENCE_INNOVATION/experiments/2026-11-23_chunks_2_4/CROSS_REPOSITORY_FINDINGS.md` (Chunk-4 audit, compatibility results)
- `Ravenproofs` git: PR #60 (`940f88a`), CRIA-02 commits `0a45e10`, `ef85cd9`, `5d3106d`, `21d7f0a`
- `roadmap/CRITICAL_PATH_2026-11-22.md` reuse map
- Repo accessibility verified this session via `gh repo view` (7/9 resolve)

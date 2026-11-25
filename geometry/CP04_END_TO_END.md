# CP-04 end-to-end execution — native adapters on shared fixture

Date: 2026-11-25 · Agent: Devin · Status: executed; consumer PRs open

The Chunk-4 audit's last open item — "native code execution and adapter
integration: not done" — is now exercised end-to-end. One GeometryIR
source document flows through three independent native
implementations, all asserting against the same expected values.

## Pipeline

```
geometry_ir_baseline.z12x            (GI-DR-01/GeometryIR/v1, sha256 f3ef27c9…)
  │
  ├─ Recursiverse-Suite (Python, dell)
  │    artifacts/geometry_ir/z12x_reader.py
  │      read_geometry_ir → node_envelopes (12× canonical_sector)
  │                     → antipode_envelopes (12× fine_144)
  │    artifacts/coordinate_envelope.py::convert  aries_zero → cancer_zero
  │
  ├─→ geometry/cp04_e2e_fixture.json   (CP04-E2E/1, sha256 d86e9ec0…;
  │     regenerated after Recursiverse promotion #54/#55 — cases
  │     identical, only z12x_path metadata updated from adapters/ to
  │     artifacts/geometry_ir/)
  │      24 cases + antipode pairs + node angles + source pins
  │
  ├─ Machine (Rust, mini)               tests/cp04_e2e.rs        — PR #8
  │    geomframe: image sector/angle → machine Sector/Longitude
  │    under both declared anchors; antipode k→k+6 invariance
  │
  └─ z12z-Memory-Module (Rust, mini)    tests/cp04_e2e.rs        — PR #10
       coordinate_envelope: convert_sector/convert_fine both directions
       provenance: ProvenanceRecord sign → verify_self + verify_source
       against the real vendored .z12x bytes
```

## What ran where

| Stage | Where | Result |
|---|---|---|
| Fixture generation (reader + convert) | dell, `python3 geometry/cp04_e2e_fixture.py` | 24 cases emitted; `--check` mode detects drift |
| Recursiverse reader self-check | dell | 24/24 GIR vectors via convert (pre-existing, re-verified by generator) |
| Machine geomframe e2e | mini `cargo test --test cp04_e2e` | **5/5 pass**; full driver suite 45 green |
| z12z envelope + provenance e2e | mini `cargo test --all` | **136/136 pass** (3 new); fmt + clippy -D warnings clean |

## Defect found and fixed by the exercise

z12z `FrameType` used bare `snake_case` serde → wire names `fine144` /
`cell1728`, while the contract vocabulary (GI-DR-01, Recursiverse
`contracts/coordinate_vectors.json`, emitted envelopes) is `fine_144` /
`cell_1728`. A contract envelope with `frame_type: "fine_144"` was
rejected on deserialization — the provenance record could not even
 ingest half the emitted cases. Fixed via explicit `#[serde(rename)]`
on both variants (z12z-Memory-Module PR #10). No stored payloads used
either spelling; grep-verified before the change.

## What this does and does not claim

- **Claims:** three independent native implementations (Python reader,
  Machine geomframe, z12z envelope+provenance) agree on all 24
  contract cases derived from one real z12x document; provenance
  records bind emitted envelopes to the actual source bytes and detect
  tampering; antipode structure survives frame conversion.
- **Does not claim:** the consumers share a wire protocol (each has its
  own types; the fixture is the agreement point), image-to-domain
  physical correspondence (still requires declared anchors per the
  Chunk-4 boundary), or digital-signature non-repudiation (records are
  integrity/provenance bindings).

## Artifacts

- `geometry/cp04_e2e_fixture.py` — generator; `--check` verifies the
  committed fixture hasn't drifted
- `geometry/cp04_e2e_fixture.json` — the shared fixture (24 cases)
- Consumer copies: `Machine:tobey-recursive-integration/driver/tests/fixtures/`,
  `z12z-Memory-Module:tests/fixtures/` (+ vendored `geometry_ir_baseline.z12x`)

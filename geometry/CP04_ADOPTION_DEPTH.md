# CP-04 addendum — adoption-depth audit

Date: 2026-11-27 · Agent: jjcav84/Devin · Method: call-site trace (grep,
non-test paths) across all three consumers at current mains.

## Verdict: INTERCHANGE-PROVEN — now WIRED in all three consumers

*(Original audit verdict below; superseded 2026-11-28 — see Update.)*

The z12x/hue_pair interchange is **conformance-complete but not wired
into any production path**. Every consumer can parse and convert the
contract — verified end-to-end — but nothing outside test harnesses
calls the interchange code.

| Consumer | Interchange code | Non-test callers | Verdict |
|---|---|---|---|
| Machine (`9d39154c` → wired) | `driver/src/geomframe.rs` + `coordhouse.rs` | **`coord-house` CLI subcommand — production path** (PR #11) | **WIRED** |
| z12z (`39f8191` → wired) | `src/provenance.rs` + CLI | **`prov-sign`/`prov-verify` — production path** (PR #14) | **WIRED** |
| Recursiverse (`b960ccc` → wired) | `artifacts/geometry_ir/envelope_emit.py` | **CLI emitter — production path** (PR #58) | **WIRED** |

Evidence: `grep -rn` for `geomframe|hue_pair|GeoAnchor` (Machine, excl.
tests) → no hits outside `geomframe.rs` internals; `ProvenanceRecord|
HuePair|convert_hue_pair` (z12z src/) → definitions + in-file tests
only; `convert_hue_pair|z12x_reader|read_geometry_ir` (Recursiverse,
all .py) → only the defining modules and `tests/geometry_ir/`.

## What this means

- **The port is proven; no cargo has shipped.** Three languages
  demonstrably agree on the contract — that was the CP-04 deliverable.
  But "adoption" today means *conformance*, not *use*.
- This is the honest stage for an interchange: prove portability
  before wiring. The risk it creates is **semantic drift** — consumers
  could diverge silently until a real pipeline exercises the contract.
- The frozen `convert()` dispatcher not routing `hue_pair` is consistent
  with this state: no production caller needs it yet.

## Concrete wiring candidates (where real adoption would land)

| Consumer | Existing production surface | Natural interchange hook |
|---|---|---|
| Machine | `houses.rs`/`subsign.rs`/`temporal.rs` compute in `coords::Sector` space (sign↔house affine map, house cusps) | `geomframe::image_sector_to_machine` / `hue_pair_to_machine` feed image/z12x-derived sectors into the same `Sector` type the production modules already consume |
| z12z | `ledger.rs` `LedgerEvent`/`make_event`/`append` — hash-chained memory events | `ProvenanceRecord::sign` attaches source-bytes binding to coordinate-bearing ledger events; complements (not replaces) `fuse::provenance` receipts |
| Recursiverse | `artifacts/` pipeline + `artifacts/geometry_ir/` canonical modules | an artifact-build step invoking `z12x_reader.read_geometry_ir` → `coordinate_envelope.convert`/`hue_pair.convert_hue_pair` for envelope-bearing artifacts |

## Update 2026-11-27 — Machine wired (PR #11)

`coord-house <envelope.json> [--rising N]` is the first non-test consumer:
envelope JSON → geomframe → `Sector` → `houses.rs` sign_house +
Equal House chart_house, emitting a `coord-house/1` receipt with
`input_sha256`. Supports the fixture-validated frame set
(canonical_sector, fine_144, hue_pair); all else rejected by name.
Verified on mini: full suite green incl. 6 new coordhouse tests +
CLI smoke on real fixture envelopes. z12z and Recursiverse remain
test-only — the pattern to replicate.

## What "real adoption" would require

1. One production call path per consumer (not a test): e.g., Machine
   driver accepts a z12x/hue_pair coordinate input and routes it through
   `houses.rs`; z12z ledger event carries a `ProvenanceRecord`;
   Recursiverse artifact emits envelopes via the reader.
2. A receipt: the e2e fixture check already proves conformance; adoption
   needs a *production-output* check (e.g., driver result diff,
   ledger verify, artifact schema validation).
3. Then — and only then — does the hue_pair canonical-dispatch question
   become pressing: a production caller inside Recursiverse would argue
   for routing `hue_pair` through `convert()`.

## Recommendation

Sequence: **wire one consumer end-to-end first** (Machine is the
smallest surface — `geomframe` already returns the production `Sector`
type), prove the receipt, then replicate the pattern to z12z and
Recursiverse. This converts "three languages can parse it" into "the
system uses it" — and generates the evidence that would justify the
dispatch amendment.

## Update 2026-11-28 — all three consumers wired

The audit's recommended sequence executed end-to-end:

- **Machine** (PR #11): `coord-house` — envelope JSON → geomframe →
  houses.rs sign_house + Equal House chart_house, coord-house/1
  receipt with input_sha256.
- **z12z** (PR #14): `prov-sign`/`prov-verify` — strict
  CoordinateEnvelope serde → Z12MEM-PROVENANCE/1 record;
  two-layer verify, exit 0/1/2.
- **Recursiverse** (PR #58): `envelope_emit.py` — z12x doc →
  geometry-ir-envelopes/1 artifact (24 envelopes + cancer_zero
  transports + source sha256); GOV-005-safe additive files only.

Each was verified on its native build path (mini for Rust, uv/pytest
for Python) and exercised against real CP04-E2E fixture envelopes.
"Production-unused" is now historical: the interchange is load-bearing
in all three consumers.

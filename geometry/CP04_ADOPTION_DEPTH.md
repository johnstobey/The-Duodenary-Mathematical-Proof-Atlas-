# CP-04 addendum — adoption-depth audit

Date: 2026-11-27 · Agent: jjcav84/Devin · Method: call-site trace (grep,
non-test paths) across all three consumers at current mains.

## Verdict: INTERCHANGE-PROVEN, PRODUCTION-UNUSED

The z12x/hue_pair interchange is **conformance-complete but not wired
into any production path**. Every consumer can parse and convert the
contract — verified end-to-end — but nothing outside test harnesses
calls the interchange code.

| Consumer | Interchange code | Non-test callers | Verdict |
|---|---|---|---|
| Machine (`9d39154c`) | `driver/src/geomframe.rs` — `pub mod` in lib.rs | **only** `driver/tests/cp04_e2e.rs` | TEST-ONLY |
| z12z (`39f8191`) | `src/coordinate_envelope.rs`, `src/provenance.rs` | **only** `tests/cp04_e2e.rs`; `main.rs` uses unrelated `fuse::provenance` | TEST-ONLY (dead code in binary) |
| Recursiverse (`b960ccc`) | `artifacts/geometry_ir/{z12x_reader,hue_pair}.py` | **zero imports** outside tests; `coordinate_envelope.convert` itself has no production callers | UNUSED |

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

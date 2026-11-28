# Interchange end-to-end chain (CP-04)

`scripts/interchange_e2e.py` runs the complete production interchange
path wired across the three consumer repos as a single receipt-linked
pipeline, and emits an `interchange-e2e/1` receipt.

## The chain

```
z12x doc ──emit──▶ geometry-ir-envelopes/1 ──┐
                                             ├─▶ envelope {anchor,frame_type,value}
fixture hue cases ───────────────────────────┘        │
        │                                            ▼
        │                              z12z prov-sign ─▶ Z12MEM-PROVENANCE/1
        │                                            │
        │                              z12z prov-verify ─▶ VERIFIED / REJECTED
        │                                            │
        └──────────────────────────────▶ Machine coord-house ─▶ coord-house/1
```

| Leg | Tool | Repo | Runs on |
|---|---|---|---|
| emit | `artifacts/geometry_ir/envelope_emit.py` | Recursiverse-Suite | dell (python3) |
| sign | `z12mem prov-sign` | z12z-Memory-Module | mini (Rust) |
| verify | `z12mem prov-verify` | z12z-Memory-Module | mini (Rust) |
| consume | `tobey_recursive coord-house` | Machine | mini (Rust) |

The Rust legs execute on the mini build host over a single staged
directory + `run.sh` (project rule: write on dell, build on mini).

## Coverage — the complete interchange surface

- **24 z12x envelopes**: every envelope `envelope_emit.py` produces for
  the pinned `geometry_ir_baseline.z12x` fixture (12 node
  `canonical_sector` + 12 antipode `fine_144`), each signed against the
  z12x document itself.
- **144 hue_pair envelopes**: every conversion case in
  `geometry/cp04_e2e_fixture.json`'s hue section, signed against
  `geometry/hue_layer_v1.json`.

That is all three fixture-validated frame types (`canonical_sector`,
`fine_144`, `hue_pair`) flowing through sign → verify → consume.

## Evidence

Committed snapshot: `engineering/interchange_e2e_results.json`
(receipt from the verified run). Per-envelope entries carry the
provenance-record sha256, coord-house receipt sha256, input sha256,
verify verdict, and computed `sign_house`/`machine_sector`.

Result of the committed run: **168/168 envelopes ok**; the tamper leg
(one record verified against the wrong source) returns **REJECTED**
(exit 1), proving `prov-verify` is not vacuous.

Source pins cross-validate against the CP04-E2E fixture:
z12x sha256 `f3ef27c9…` and hue spec sha256 `bc5e3f26…` match the
fixture's recorded `sources` block.

## Reproduce / drift-check

```sh
python3 scripts/interchange_e2e.py                                  # full run -> .lake/interchange-e2e/RECEIPT.json
python3 scripts/interchange_e2e.py --check engineering/interchange_e2e_results.json
```

`--check` reruns the entire chain and diffs the deterministic fields
(`sources` sha256s, `emit`, `coverage`, `tamper_leg`, `results`,
`summary`); environment fields (git heads, binary sha256s, paths) are
recorded but not compared. Exit 1 on any drift.

Also wired as the advisory `interchange-e2e` gate in
`scripts/verify_all.py` — it SKIPs where the Recursiverse sibling
checkout or the mini build host is unreachable (e.g. CI), WARNs on
drift, and never blocks the required gates.

## Honest limits

- Hue envelopes are derived from the Atlas hue-layer spec, not z12x —
  the emitter does not produce them (documented non-claim). They enter
  the chain at the fixture layer instead.
- Remote legs use the debug binaries current on mini at run time; the
  receipt records their sha256 under `environment` for provenance but
  `--check` does not pin them (rebuilds drift legitimately).
- `coord-house` runs without `--rising`, so receipts carry
  `sign_house` only; the Equal House `chart_house` path is covered by
  Machine's own e2e suite, not this chain.
- The chain certifies interchange *mechanics* (parse → sign → verify →
  consume), not corpus grounding — the hue/sector corpus negatives in
  `geometry/CP03_HUE_CORPUS_PROBE.md` and
  `geometry/CP02_SECTOR_GEOMETRY_PROBE.md` stand unchanged.

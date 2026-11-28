# Cross-repo consumer receipts — generated snapshot

Generated: 2026-11-28 03:41 UTC by `scripts/cross_repo_status.py` — do not edit by hand;
regenerate with `python3 scripts/cross_repo_status.py --write`.
Receipts: `roadmap/consumer_receipts.json` · verified live via `gh`.

Receipts: 15 · OK: 15 · drift/unreachable: 0

| Atlas issue | CP | Consumer | Repo | Ref | Live state | Status | Note |
|---|---|---|---|---|---|---|---|
| #9 | CP-04 | tobey-relational-decoder | Ravenproofs | PR#60 | MERGED | OK | DCC-01 consumer 2: AtlasConsumption.lean path dep |
| #9 | CP-04 | tobey-three-language | tobey-three-language | PR#3 | MERGED | OK | CRIA-02 A1: Lisp consumer + fixture |
| #9 | CP-04 | tobey-three-language | tobey-three-language | PR#4 | MERGED | OK | CRIA-02 A1: Prolog read_geometry_ir/1 |
| #9 | CP-04 | Alien-math-decoded-2 | The-Duodenary-Mathematical-Proof-Atlas- | commit:2d84d17 | PRESENT | OK | lakefile in Alien-math-decoded-2 pins closed_ring_z12_mathli |
| #9 | CP-04 | Recursiverse-Suite | Recursiverse-Suite | PR#53 | MERGED | OK | z12x reader -> coordinate envelopes (5bc93a2) |
| #9 | CP-04 | Recursiverse-Suite | Recursiverse-Suite | PR#54 | MERGED | OK | Amendment A1 geometry_ir carve-out |
| #9 | CP-04 | Recursiverse-Suite | Recursiverse-Suite | PR#55 | MERGED | OK | reader promoted to canonical artifacts/ |
| #9 | CP-04 | Recursiverse-Suite | Recursiverse-Suite | PR#57 | MERGED | OK | hue_pair additive contract extension (b960ccc) |
| #9 | CP-04 | Machine | Machine | PR#7 | MERGED | OK | geomframe GeoAnchor conversion (3984633) |
| #9 | CP-04 | Machine | Machine | PR#8 | MERGED | OK | e2e fixture through geomframe (63e71eb8) |
| #9 | CP-04 | Machine | Machine | PR#10 | MERGED | OK | hue_pair consumer (9d39154c) |
| #9 | CP-04 | z12z-Memory-Module | z12z-Memory-Module | PR#9 | MERGED | OK | ProvenanceRecord (54faecf) |
| #9 | CP-04 | z12z-Memory-Module | z12z-Memory-Module | PR#10 | MERGED | OK | e2e + frame-name serde fix (133e707) |
| #9 | CP-04 | z12z-Memory-Module | z12z-Memory-Module | PR#12 | MERGED | OK | hue_pair frame + e2e (b0f126e) |
| #9 | CP-04 | z12z-Memory-Module | z12z-Memory-Module | PR#13 | MERGED | OK | hue provenance bound to hue spec (39f8191) |

## Reading

- `OK` = receipt verified live this run (PR MERGED / commit present).
- `DRIFT` = the consumer-side claim no longer holds (PR reopened/
  unmerged, force-push removed the merge). `UNREACHABLE` = repo or
  token cannot be read — treated as unverified, not failed.
- This ledger tracks *receipts*, not scientific truth; Atlas issues
  remain the canonical task queue (CP-06).

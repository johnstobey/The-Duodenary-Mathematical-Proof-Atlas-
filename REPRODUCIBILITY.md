# REPRODUCIBILITY — verify the Atlas from a fresh clone

Goal: any clone of this repository can re-verify all committed evidence
without trusting the spec author, the CI provider, or any single reviewer.
`AUTONOMY.md` explains *why*; this file is the *how*.

## Prerequisites

| Requirement | Version | Install |
|---|---|---|
| Python | 3.12+ (CI uses 3.12) | system |
| Lean toolchain | `leanprover/lean4:v4.14.0` (pinned by `lean-toolchain`) | `curl https://elan.lean-lang.org/elan-init.sh -sSf \| sh` — elan auto-resolves on first `lake` call |
| Lake | via elan | same |
| Python deps | hash-locked | `python -m pip install --require-hashes -r requirements.lock` |
| gh CLI | any recent | optional — only for advisory live-state gates |
| Sibling checkout | `~/workspace/Recursiverse-Suite` | optional — only for the cp04-fixture gate |

## Verify

```bash
git clone git@github.com:johnstobey/The-Duodenary-Mathematical-Proof-Atlas-.git
cd The-Duodenary-Mathematical-Proof-Atlas-
python -m pip install --require-hashes -r requirements.lock
python3 scripts/verify_all.py --preflight   # what can this machine run?
python3 scripts/verify_all.py               # all gates → .lake/verify-all/RECEIPT.json
```

Optional depth:

```bash
python3 scripts/verify_all.py --with-mathlib    # + mathlib bridge package (downloads cache, ~GB)
python3 scripts/verify_all.py --with-receipts   # + live consumer-repo receipts (needs gh auth + repo access)
python3 scripts/verify_all.py --only emit-vectors   # single gate
```

## What each layer proves

| Layer | Command | Proves |
|---|---|---|
| Lean kernel | `lake build` (inside reproduce) | theorems hold; axiom audit forbids `sorryAx` |
| Emitted contract | `emit-vectors` vs `contracts/coordinate_vectors.json` | Lean output == committed V01–V10 vectors, byte-identical |
| Finite checks | `finite_checks.py --check` | exhaustive small-model verification + counterexamples |
| Schema/evidence | `validate.py`, `reproduce.py` unittest discover | typed claims, no unsupported promotion |
| CP-03 hue | `check_hue_layer.py` | 144-pair algebra + operator relations |
| CP-02 geometry | `check_geometry_ir.py` | GeometryIR→Z/12 invariants on committed input |
| CP-04 fixture | `cp04_e2e_fixture.py --check` | shared interchange fixture regenerates byte-identical (needs Recursiverse checkout) |
| CP-05 physics | `cp05_contrasts.py` | all contrast metrics reproduce from committed flux evidence |
| Ledger | `queue_status.py`, `check_issue_deps.py` | issue-queue dependency states (advisory — live state) |
| Tree cleanliness | `tree-clean` gate | no gate silently modified tracked files |

## Honest limits

- **cp04-fixture needs the sibling Recursiverse-Suite checkout** at
  `~/workspace/Recursiverse-Suite` (hardcoded in the generator). Without
  it the gate SKIPs — clone that repo to the same relative path to enable.
- **Advisory gates need `gh` auth** with access to the private repos;
  they verify *live* state, which legitimately drifts between queue-snapshot
  cron runs — WARN is expected, not failure.
- **CI (verify.yml) is the authoritative merge gate**; verify_all mirrors
  it and extends it with the checks CI cannot run (consumer-dependent,
  heavy mathlib is opt-in on both).
- Reproducibility covers *committed evidence*. It cannot verify spec
  *content* — that requires falsification probes (see
  `geometry/CP03_HUE_CORPUS_PROBE.md` for the pattern).

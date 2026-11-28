# AUTONOMY — dependency and threat map

Date: 2026-11-27 · Status: living document
Purpose: make the project's trust assumptions explicit so no work is
silently hostage to a single principal, and so every claim is
re-verifiable without trusting the spec author.

## Actors and access

| Actor | Controls | We observe |
|---|---|---|
| `johnstobey` (repo owner) | All repos private under this account; spec issuance; CONSTITUTION adoption (v0.1 still *proposed*); GOV-005/EDP-01/claims.json; ACCEPT/CLOSE calls on issues | gh pushes as collaborator `jjcav84` |
| `jjcav84` (push identity) | Commit authorship on all Atlas-program repos | sole push credential in use |
| Agent sessions (Devin, Claude, …) | Implementation labor; parallel sessions share the repos | pre-flight duplication checks required by AGENTS.md |
| Consumer repos | Recursiverse-Suite, Machine, z12z-Memory-Module | private; cross-repo CI needs a PAT (owner decision pending) |

## Borrowed vs. independently verifiable

| Asset | Source | Independent check? |
|---|---|---|
| Duodenary algebra / Lean proofs | Atlas `closed_ring_z12*` | **Yes** — Lean kernel re-checks from source; `lake env lean Verify*.lean` must show no `sorryAx` |
| V01–V10 coordinate contract | `contracts/coordinate_vectors.json` | **Yes** — `lake exe emit-vectors` must reproduce byte-identical |
| Hue layer v1 spec + fixture | `geometry/hue_layer_v1.json`, `cp04_e2e_fixture.json` | **Yes** — `check_hue_layer.py`, `cp04_e2e_fixture.py --check`, three consumer implementations agree |
| CP-05 physics evidence | `engineering/cp05/` committed flux JSONs | **Yes** — `cp05_contrasts.py` recomputes all metrics, exit 1 on drift; blocking CI |
| Ravenproofs image corpus | `research/GEOMETRIC_INTELLIGENCE_INNOVATION/` | **Data, not proof** — partially falsified (CP-02 geometry, hue probe); never treat as ground truth |
| GI-DR-01 disposition / EDP-01 gate | Ravenproofs `edp01/` | Owner-controlled protocol; `HOLD`/`REJECT` receipts are data, work continues authorized scope |
| Governance rules | CONSTITUTION.md (proposed), GOV-005, claims.json | Owner-discretionary — can change unilaterally |

## Chokepoints and fallbacks

| Chokepoint | If it fails | Fallback |
|---|---|---|
| Owner ACCEPT/CLOSE calls | Queue stalls | `scripts/verify_all.py` receipt makes acceptance machine-reproducible; owner becomes optional reviewer |
| Governance amendment needed | Protected paths blocked | Additive carve-outs (proven: `artifacts/geometry_ir/hue_pair.py`); merged git history cannot be unmerged by governance |
| `mini` build host (Rust) | No cargo builds/tests | Documented; dell builds disabled by policy — treat mini loss as pause, not loss (CI also builds) |
| Private-repo access / PAT | Cross-repo receipts can't run in GHA | Receipts verified locally via `cross_repo_status.py --with-receipts`; needs read-scoped PAT secret — owner decision |
| Spec *content* adversarial | Verification cannot fix a wrong definition | Falsification probes (`geometry/cp03/hue_corpus_probe.py` pattern): test specs against data |

## Operating rules (derived)

1. **Verify before trust.** Every external claim cites this-session tool
   output; `verify_all.py` is the executable form of that rule.
2. **Additive-only in protected paths.** Never modify GOV-005/EDP-01
   protected files; extend beside them. Amendments are the owner's call.
3. **Pin everything.** Fixtures, evidence, contracts carry sha256;
   drift is a build failure, not a warning.
4. **Git history is the immutable record.** Merged + pushed work survives
   any later governance or access change on the owner's side.
5. **Local clones are the continuity plan.** Everything needed to
   re-verify lives in the repos; a fresh clone + `verify_all.py`
   reproduces the evidence state.
6. **Falsify specs, don't just verify them.** Verification checks
   internal consistency; probes check spec-vs-reality. Both are required.

## What this map cannot defend against

- Repo deletion or access revocation by the owner — local clones
  preserve merged work, but new spec issuance stops. Inherent.
- A spec whose *definitions* are adversarial — only falsification
  work detects that; keep probing.
- Compromise of the `jjcav84` or agent credentials — rotate; treat gh
  token as sensitive.

## Executable acceptance

```bash
python3 scripts/verify_all.py                # all committed-evidence gates
python3 scripts/verify_all.py --list         # gate inventory
python3 scripts/verify_all.py --with-mathlib # + mathlib bridge package
python3 scripts/verify_all.py --with-receipts# + cross-repo consumer receipts
```

Writes `.lake/verify-all/RECEIPT.json`: git HEAD, per-gate commands,
exit codes, durations, log sha256. Exit 0 iff all required gates pass;
advisory gates (live GitHub state, credentials) warn without failing.

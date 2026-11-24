# CP-05 (#10) — Geometric-blueprint engineering triage

Date: 2026-11-24 · Agent: jjcav84/Devin
Subject: `tobey-resolution/geometric/blueprint_deliverables/` (DeepSeek v2.0 handoff), mirrored at `Ravenproofs:research/GEOMETRIC_INTELLIGENCE_INNOVATION/source_corpus/blueprint_deliverables/` — per-file sha256 in `manifest.tsv`.
Status: **PROPOSED DESIGNS — not validated apparatus.** Config self-discloses `simulated_in_context:false, formally_verified_in_context:false, physically_fabricated:false`.

## Per-file audit

| File | Claim | Assessment |
|---|---|---|
| `qutip_lindblad_floquet.py` (206 ln) | 6-site Floquet ring → synthetic gauge field; benchmarks: occupation>1e-3, Q>1e4, chirality>1e-6 | Real Lindblad/Floquet model, plausible parameters; **benchmarks partly tautological, no baseline ablation** (see defects) |
| `meep_nonreciprocal_sparam.py` (277 ln) | gyrotropic interface → chiral edge; benchmarks: S21>−3dB, S12<−20dB, isolation>17dB | Real FDTD setup; **S21 check tautological; non-gyrotropic baseline is dead code** |
| `TopologicalInvariant.lean` (164 ln) | nontrivial flux ⟹ protected chiral edge | Honest: `axiom bulk_boundary_correspondence` (TKNN) explicitly documented as physical axiom, not hidden; main theorem proved *from* it; imports Mathlib |
| `SurfaceCodeStabilizer.lean` (183 ln) | 4-qubit stabilizer algebra | `native_decide` machine-checked, no sorry claimed |
| `substrate_v2_config.json` | BENCH-01/02 falsifiability metrics | Honest metadata block; benchmarks are targets, not results |

## Defect register

**D1 — No baseline/ablation in either physics script (critical).** Neither script runs a control case that isolates the claimed mechanism: QuTiP never runs ΔJ=0 or uniform-coupling; Meep's `build_geometry(gyrotropic=False)` reference branch is **dead code, never called**. Without controls, chirality/isolation cannot be attributed to the proposed mechanism vs. drive asymmetry or numerics. *This is exactly the "advantage against a baseline" test the issue requires — currently absent.*

**D2 — Tautological benchmarks.**
- QuTiP BENCH-B: `γ_k = ω0/Q_target` is set as input; ring-down measuring ≈γ yields Q_eff≈10⁴ — the ">10⁴" threshold tests the input, not a prediction. Ring-down window is <2 e-folds (γ=2π·1MHz → τ≈159ns vs ~280ns window).
- Meep BENCH-1: S-parameters normalized to `max(flux_fwd)` — the forward peak is 0 dB *by construction*; "S21>−3dB at peak" passes trivially. Only the isolation figure carries information.

**D3 — Cosmetic temperature.** QuTiP computes `n_th` at 15 mK but never uses it — no thermal collapse operators; the simulation is T=0. The "millikelvin cryogenic" framing is decorative at simulation level.

**D4 — Imprecise mechanism claim.** QuTiP hopping `J_ij(t)=J0+ΔJ·cos(Ωt+φij)` multiplies a *real* Hermitian coupling; the phase gradient enters only the modulation, so the "synthetic gauge field" exists only in the Floquet effective Hamiltonian — docstring overstates the bare-H structure.

**D5 — Unverified material convention.** Meep `mu_offdiag=1jα` gyrotropy sign/Hermitian handling is asserted in comments, not validated against a known solution.

## Execution status (environment)

- `qutip`, `meep`: **not installed** on dell — execution environment-blocked. Requirements: `pip install numpy qutip` (feasible); `conda install -c conda-forge pymeep` (heavy MPI stack — not attempted).
- Lean files: require Mathlib-pinned env (v4.14.0 + cache) — runnable but unrun here; `TopologicalInvariant.lean`'s axiom is honestly disclosed regardless.
- **No simulation was executed** — consistent with the source's own `simulated_in_context:false`.

## Falsification matrix

| Benchmark | Falsifier | Current status |
|---|---|---|
| QuTiP occupation>1e-3 | driven-dissipative steady state absent | unexecuted |
| QuTiP Q>10⁴ | ring-down γ_eff ≠ input γ | **soft — near-tautological (D2)** |
| QuTiP chirality>1e-6 | no net circulation vs. drive-only control | **missing control (D1)** |
| Meep S21>−3dB | — | **tautological (D2)** |
| Meep S12<−20dB & isolation>17dB | reciprocal/unpatterned control shows same isolation | **missing control (D1)** |
| BENCH-01/02 (config) | hardware metrics | fabrication-gated, out of scope |

## Upgrade decision

**DO NOT advance toward fabrication or "validated design" status.** The deliverables are coherent proposed designs with honest self-disclosure, but: (1) zero executions exist anywhere in the provenance chain; (2) the two physics scripts lack the baseline controls that would make their benchmarks falsifiable; (3) two of four physics benchmarks are tautological as written.

**Required next step (ordered):**
1. Add control runs — QuTiP: ΔJ=0 / uniform-J ablation measuring chirality; Meep: call the existing `gyrotropic=False` branch, verify isolation collapses.
2. Install qutip (cheap) and execute QuTiP script + ablation; treat Meep as a separate environment task (conda/mini build host per deployment policy).
3. Replace tautological benchmarks with mechanism-attributed metrics (chirality *difference* vs. control; isolation *difference* vs. non-gyrotropic).
4. Only then does "measurable transport/coupling advantage against a baseline" become testable — and only then does independent scientific review apply.

Honest classification: **PROPOSED — internally consistent, externally unvalidated, benchmark design flawed in two places.**

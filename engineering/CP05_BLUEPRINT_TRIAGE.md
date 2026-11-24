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

---

## Addendum 2026-11-25 — first executions (Devin, dell)

Environment: `qutip 4.7.6` in `/tmp/qutip-venv` (5.3.1 incompatible with numpy pin). The delivered script targets the **qutip 3.x API** and needed three mechanical repairs to run at all: coefficient lists `[Qobj, func]` (4.x format), `qt.Options(...)` object instead of `options={...}` dict, static Hamiltonian term as bare `Qobj`. No physics was changed. Script provenance: hash-pinned upstream file copied to `/tmp`, patched there — corpus untouched.

### QuTiP execution results

Reduced-fidelity variants (`/tmp/qutip_reduced.py`, identical physics, `N_SITES`/`N_FOCK`/`MODE` parameterized; `MODE∈{gauge,uniform,static}` where uniform keeps ΔJ but sets φ_ij=0, static sets ΔJ=0):

| Config | dim | mode | ⟨n⟩_ss | χ_ss | Q_eff | occ>1e-3 | Q>1e4 | \|χ\|>1e-6 |
|---|---|---|---|---|---|---|---|---|
| N=3, n_f=2 | 8 | gauge | 1.28e-4 | **−9.56e-6** | 1.0000e4 | FAIL | FAIL | PASS |
| N=3, n_f=2 | 8 | uniform | 1.34e-4 | +4.1e-19 | 1.0000e4 | FAIL | FAIL | FAIL |
| N=3, n_f=2 | 8 | static | 1.34e-4 | −5.7e-19 | 1.0000e4 | FAIL | FAIL | FAIL |
| N=4, n_f=2 | 16 | gauge | 0.5274 | **+1.28e-3** | 1.0000e4 | PASS | PASS | PASS |
| N=4, n_f=2 | 16 | uniform | 0.5276 | +3.4e-17 | 1.0000e4 | PASS | FAIL | FAIL |
| N=4, n_f=2 | 16 | static | 0.5276 | −2.1e-16 | 1.0000e4 | PASS | PASS | FAIL |

N=6, n_f=2 (dim 64) and the original N=6, n_f=3 (dim 729) runs were still in progress at time of writing.

**What this establishes:**
- **D1 partially remediated (QuTiP side).** The missing-control defect is now tested: at both fidelities the phase-gradient run produces net chirality (−9.6e-6 at dim 8; +1.28e-3 at dim 16) while uniform-modulation and static controls give χ at machine zero (~1e-17–1e-19). The claimed mechanism — Floquet phase gradient → circulation — **reproduces, and the contrast isolates it to the gradient specifically** (uniform ΔJ modulation does not substitute).
- **Occupation is not mechanism-dependent.** ⟨n⟩_ss is identical across all three modes to ~0.03% (drive-limited); only χ differentiates. This is what a mechanism-attributed metric should look like.
- **Q benchmark is structurally unpassable, worse than D2 stated.** γ_k=ω0/Q_target is the *only* decay channel; the ring-down fit returns γ_eff=γ_k exactly → Q_eff=10⁴ exactly → the strict `Q_eff > 10⁴` check fails by construction (observed: FAIL or boundary-noise PASS). No parameter choice inside this model can pass BENCH-B honestly.
- **Performance claim falsified.** Docstring: "typically completes in 30–90 seconds." Observed: the dim-729 original has consumed **>84 CPU-minutes without finishing** (still running); dim-16 runs took ~10–20 min each under load. The "30–90 s" figure is off by ≥50×.
- Chirality sign differs between dim 8 (−) and dim 16 (+) — magnitude is the meaningful quantity; sign is convention/N-parity dependent.

### Lean deliverables — worse than "unrun"

Both `.lean` files **fail to parse as delivered**: a plain-text banner (filename + `====` rule + prose) precedes `import Mathlib`, and the closing `-/` implies the opening `/-!` was lost in PDF extraction. After mechanically stripping the banner (lines 1–25 / 1–27, corpus untouched, repair in `/tmp` only):

- `SurfaceCodeStabilizer.lean`: **does not compile** under Mathlib @ `4bbdccd` / Lean v4.14.0 — contains an actual `sorry` at line 87 (contradicting its "No `sorry` is used" docstring) plus universe-constraint and stuck-typeclass errors at lines 93/113/135/154. Broken beyond mechanical repair.
- `TopologicalInvariant.lean`: **compiles clean** (exit 0, no errors/warnings) after two mechanical repairs — banner strip plus one mis-indented structure field (`Transport.backward`). No `sorry`/`admit`. However: the "main theorem" `chiral_edge_state_of_nontrivial_flux` is literally `:= bulk_boundary_correspondence N L h` — a one-line restatement of the axiom, so all content sits in the declared physical axioms. Its second axiom `floquet_modulation_is_nontrivial` is **vacuous**: the statement `∀ N L, IsNontrivial L → 0 < N` contains no δJ/J₀ parameters despite the docstring describing them — it asserts nothing about Floquet modulation. Only genuine proved content: `allOnesRing_trivial` (a `Finset.prod_const_one` exercise) and the contrapositive sanity check.

**New defect — D6:** the Lean deliverables are extraction-corrupted; at least one contains an undisclosed `sorry` plus elaboration failures, and the other's headline theorem is an axiom restatement with one vacuous axiom. As delivered they are not kernel-checked evidence of anything; even repaired, they formalize definitions + axioms, not proofs of the physical claims.

### Revised remediation status

1. ~~QuTiP controls~~ — **done at reduced fidelity** (this addendum); full-fidelity confirmation pending the dim-64/729 runs.
2. Meep `gyrotropic=False` control — still unrun; `conda install -c conda-forge pymeep` not attempted (heavy MPI stack; candidate for mini build host per deployment policy).
3. Benchmark redesign — now concrete: replace absolute thresholds with **contrast metrics** (χ_gauge − χ_control; isolation_gauge − isolation_control). BENCH-B should be deleted or replaced by a prediction the model actually makes (e.g., measured γ_eff vs. independent ring-down theory).
4. Full-fidelity QuTiP completion — running; if it does not finish in reasonable wall-time, that itself is the finding (the design point is computationally impractical as specified).

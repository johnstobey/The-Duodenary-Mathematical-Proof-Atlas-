# CP-05 benchmark redesign — contrast metrics, not absolute thresholds

Date: 2026-11-25 · Agent: Devin · Status: SPECIFIED, partially executed
Supersedes: the threshold benchmarks in the blueprint deliverables
(`meep_nonreciprocal_sparam.py`, `qutip_lindblad_floquet.py`) as
specified in `CP05_BLUEPRINT_TRIAGE.md` defects D2/D3.

## Design rules (learned from execution)

1. **Every mechanism claim needs a control arm.** An absolute
   threshold cannot distinguish "the mechanism works" from "the metric
   is trivially satisfiable". The benchmark is the *contrast* between
   mechanism-on and mechanism-off runs under otherwise identical
   conditions.
2. **Normalization must not reference the measured peak.** The
   delivered S-parameters normalize to `max(forward flux)` — S21 peak
   is 0 dB by construction, making `|S21|² > −3 dB` unfalsifiable.
   Normalize to an independent reference (control run, empty cell, or
   absolute flux calibration) or report raw values.
3. **Thresholds derive from the control's observed spread**, not from
   round numbers. A threshold is meaningful only relative to what the
   null model produces.
4. **Report absolute values AND contrast.** The absolute number says
   what the device does; the contrast says what the mechanism adds.

## QuTiP leg ( Lindblad-Floquet chirality )

| # | Metric | Definition | Executed result (dim 64) | Verdict |
|---|---|---|---|---|
| Q1 | chirality contrast | \|χ_gauge\| − max(\|χ_uniform\|, \|χ_static\|) | 4.70e-6 − 4.0e-19 ≈ **4.7e-6** (~13 orders of magnitude) | PASS — mechanism isolated to phase gradient |
| Q2 | occupation consistency | relative spread of ⟨n⟩_ss across modes | ~4% (drive-limited, expected) | sanity check, not a mechanism metric |
| Q3 | ~~Q_eff > 10⁴~~ | — | Q_eff = 10⁴ exactly by construction (γ_k sole decay channel) | **DELETE** — unfalsifiable; tests an input, not the simulation |
| Q4 | steady-state reached | \|d⟨n⟩/dt\| at window end below tol | not measured — add to harness | TODO |

Replaces: BENCH-A (occupation >1e-3 — fails at every executed fidelity;
⟨n⟩ is drive-limited ~2e-4) and BENCH-B (Q>1e4 — structurally
unpassable). The only surviving mechanism metric is Q1; Q2 is a
consistency check.

## Meep leg ( gyrotropic-interface S-parameters )

| # | Metric | Definition | Executed result | Verdict |
|---|---|---|---|---|
| M1 | isolation contrast | isolation_gyro − isolation_control at peak | +36.38 − (−0.02) = **+36.40 dB** | PASS — exceeds any reasonable margin |
| M2 | backward suppression | S12_gyro − S12_control at peak | −36.38 − (+0.02) = **−36.40 dB** | PASS |
| M3 | forward transmission preserved | S21_gyro ≈ S21_control (edge mode still transmits forward) | gyro fwd=1.90e11 vs control fwd=1.25 (**11 orders apart — flux normalization is material-model-dependent, not comparable across runs**); within-run directionality confirmed: gyro fwd/bwd=+36.38 dB absolute, control −0.02 dB | **PARTIAL** — absolute cross-model comparison needs a common reference (vacuum/empty-cell flux); within-run absolute directionality verified |
| M4 | spec-band coverage | fraction of band where M1+M2 hold simultaneously | 100/100 bins (gyro) vs 0/100 (control) | PASS |

Replaces: `|S21|² > −3 dB` (tautological under own-peak
normalization), `|S12|² < −20 dB` (keep as absolute spec but report
alongside control), `isolation > 17 dB` (keep — now has a control
reference).

## Data gaps to close for full redesign execution

- **Absolute flux values**: resolved — raw flux sidecar dumped; finding
  is that cross-model absolute flux is NOT comparable (material-dependent
  normalization). M3 re-scoped to within-run absolute directionality
  (verified) + future common-reference run.
- **χ uncertainty**: QuTiP χ values are single deterministic runs;
  report solver tolerance or repeat-seed spread if stochastic elements
  are added.
- **Parameter sensitivity**: DONE — Meep 3×3 LLG scan below shows a
  sharp σ threshold and broad pass region; QuTiP χ vs N_SITES spans
  dim 8/16/64 with consistent sign-magnitude behavior.

## Meep parameter scan (executed 2026-11-24/25, mini)

Grid: `LLG_FREQ ∈ {0.4, 0.5, 0.6}` × `LLG_SIGMA ∈ {0.5, 1.0, 2.0}`,
`gamma=0.02`, `alpha=0.005` fixed, `MEEP_MODE=gyro`, identical
disorder/ports/flux. 9/9 combos completed (~970–1010 s wall each,
3-way parallel). Isolation at peak transmission frequency:

| σ \ f | 0.4 | 0.5 | 0.6 |
|---|---|---|---|
| 0.5 | −1.92 dB · 0/100 · FAIL | +0.70 dB · 0/100 · FAIL | +11.69 dB · 0/100 · FAIL |
| 1.0 | +23.90 dB · 100/100 · PASS | **+36.38 dB · 100/100 · PASS** | +26.36 dB · 100/100 · PASS |
| 2.0 | +37.09 dB · 100/100 · PASS | +35.36 dB · 100/100 · PASS | +34.45 dB · 100/100 · PASS |

**Structure:** sharp susceptibility threshold — σ=0.5 fails everywhere
(weak gyrotropy cannot overcome disorder/backscattering), σ≥1.0 passes
everywhere with 34–37 dB isolation. Within each σ row, f=0.5 (source
center) is near-optimal at σ=1.0; the pass region is broad, not a
fine-tuned point. The +36.38 dB working-point result is typical, not
exceptional.

Working point reference (freq=0.5, sigma=1.0): isolation **+36.38 dB**,
100/100 spec bins.

Absolute-flux confirmation runs (gyro vs control at the working point,
raw flux sidecar via patched harness `/tmp/meep_scan_flux.py` on mini)
completed 2026-11-25. Results:

- Gyro reproduced +36.38 dB isolation, 100/100 bins, all PASS —
  patch changed instrumentation only, not physics.
- Within-run absolute directionality: gyro fwd/bwd flux ratio =
  +36.38 dB; control = −0.02 dB (fwd/bwd = 1.004 — reciprocal as
  required).
- **Cross-model absolute flux is not comparable**: gyro peak forward
  flux 1.90e11 vs control 1.25 — the dispersive gyrotropic material
  model normalizes fields differently. M3 therefore stays PARTIAL:
  a common reference (vacuum cell or empty-waveguide run) is required
  before "forward transmission preserved" can be asserted in absolute
  terms. This is a harness limitation, not a physics finding.

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
| M3 | forward transmission preserved | S21_gyro ≈ S21_control (edge mode still transmits forward) | **directional fraction** (material-self-normalized): gyro **99.98%** / clean-gyro 99.42% / controls 49.89% of escaping flux exits forward; disorder *increases* isolation +22.3→+36.4 dB and forward flux 5× (3.7e10→1.9e11); eigenmode S-params attempted — **meep MPB silently ignores H_susceptibilities** (uniform vgrp=1/√12 all bands = plain-ε12 modes) and non-dispersive gyrotropic μ is forbidden (real-symmetric off-diag constraint) → absolute insertion-loss NOT certifiable in this toolchain | **BOUNDED-PASS** — forward transmission real, dominant, disorder-robust; absolute S21-vs-incident requires a solver with genuine gyrotropic eigenmode support (COMSOL/HFSS/MPB-native Polder) |
| M4 | spec-band coverage | fraction of band where M1+M2 hold simultaneously | 100/100 bins (gyro) vs 0/100 (control) | PASS |

Replaces: `|S21|² > −3 dB` (tautological under own-peak
normalization), `|S12|² < −20 dB` (keep as absolute spec but report
alongside control), `isolation > 17 dB` (keep — now has a control
reference).

## Data gaps to close for full redesign execution

- **Absolute flux values**: resolved — cross-model raw flux is not
  comparable (material-model-set scale, proven by the σ=0 reference
  run agreeing with the static-ε control to ~1e-6 relative). M3
  re-scoped to material-self-normalized directional
  fraction (99.98% gyro vs 49.89% control) + clean-vs-disordered
  contrast; eigenmode S-params proven unavailable for this material
  class (see attempt log below).
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
- σ=0 same-normalization reference run (2026-11-25): flux agrees with
  the static-ε control to ~1e-6 max relative (peak fwd/bwd
  1.2502/1.2556 identical to 4 decimals — *not* bit-identical;
  corrected 2026-11-27 by `cp05_contrasts.py` recomputation) — proves
  flux scale is material-model-set and the LLG→static reduction is
  numerically exact to ppm.
- **Eigenmode S-parameter attempt (2026-11-25) — definitive negative:**
  two variants executed on mini. (a) `EigenModeSource` band-1 launch:
  gyro S21 ≈ −105 dB all bands — launched mode does not transmit.
  (b) point-source + `add_mode_monitor` decomposition, bands 1–10,
  both directions, gyro+control: gyro coefficients show symmetric
  ± amplitudes and **uniform vgrp = 1/√12 ≈ 0.2887 across every
  band/frequency** — the signature of MPB solving plain-ε12 modes,
  i.e. it **silently ignores `H_susceptibilities`** (a time-domain
  auxiliary-field model with no frequency-domain tensor equivalent
  supplied to the eigenmode solver). Control decomposition is sane
  (reciprocal medium, correct modes) which confirms the diagnosis.
  The alternative non-dispersive gyrotropic-μ formulation is forbidden
  by meep's real-symmetric off-diagonal constraint — the original
  blueprint defect D7 in another guise. **Absolute insertion-loss
  (S21 vs incident mode power) is not certifiable with meep 1.36 for
  this material class**; closure requires a solver with genuine
  gyrotropic eigenmode support.
- **Clean-device contrast run (2026-11-25, `MEEP_MODE=clean` =
  gyrotropic geometry, disorder off):** isolation +22.32 dB,
  100/100 bins, fwd_frac 99.42% — vs disordered +36.38 dB / 99.98%.
  Disorder *improves* forward transmission ~5× in absolute flux and
  ~14 dB in isolation: consistent with chiral-mode protection, and
  direct evidence that forward transmission is preserved rather than
  merely surviving.

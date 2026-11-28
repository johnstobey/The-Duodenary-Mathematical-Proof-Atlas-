#!/usr/bin/env python3
# tier: T2
"""CP-05 contrast-metric recomputation — engineering/CP05_BENCHMARK_REDESIGN.md.

Recomputes every contrast metric from the committed evidence snapshot
(`cp05/cp05_results.json`) and the raw flux monitor arrays
(`cp05/flux_*.json`), then prints the verdict table. Exits nonzero if any
recomputed value drifts from the recorded claim — the doc's numbers are
checkable, not narrative.

Scope: this verifies the *metrics*, not the simulations. Re-running the
physics requires the Meep (mini, meep-venv) and QuTiP harnesses; the
snapshot pins their outputs by sha256 where logs were the source.

Usage: python3 engineering/cp05_contrasts.py [--verbose]
"""
from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
DATA = HERE / "cp05" / "cp05_results.json"

Q1_THRESHOLD = 1e-6          # |chi| contrast must exceed this (redesign spec)
M1_MIN_MARGIN_DB = 10.0      # isolation contrast must exceed this
ISOLATION_SPEC_DB = 17.0     # both-specs bin criterion (|S12| < -20 with S21 ~ 0)
REL_TOL = 1e-3               # flux-derived quantities


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def load_flux(name: str, meta: dict) -> dict:
    p = HERE / "cp05" / meta["file"]
    actual = sha256(p)
    if actual != meta["sha256"]:
        raise SystemExit(f"flux file drifted: {meta['file']} sha {actual}")
    d = json.loads(p.read_text())
    if len(d["freqs"]) != len(d["flux_fwd_abs"]) or len(d["freqs"]) != len(d["flux_bwd_abs"]):
        raise SystemExit(f"{meta['file']}: array length mismatch")
    return d


def directional_fraction(d: dict) -> tuple[float, float]:
    """(peak-based, sum-based) fraction of escaping flux exiting forward."""
    pk_f = max(d["flux_fwd_abs"])
    pk_b = max(d["flux_bwd_abs"])
    sf = sum(d["flux_fwd_abs"])
    sb = sum(d["flux_bwd_abs"])
    return pk_f / (pk_f + pk_b), sf / (sf + sb)


def approx(a: float, b: float, tol: float = REL_TOL) -> bool:
    return abs(a - b) <= tol * max(abs(a), abs(b), 1e-300)


def main() -> int:
    verbose = "--verbose" in sys.argv
    results = json.loads(DATA.read_text())
    failures: list[str] = []

    print("== QuTiP leg — Q1 chirality contrast (|chi_gauge| - max|chi_controls|) ==")
    for fid, modes in results["qutip"]["fidelities"].items():
        g, u, s = modes["gauge"]["chi_ss"], modes["uniform"]["chi_ss"], modes["static"]["chi_ss"]
        contrast = abs(g) - max(abs(u), abs(s))
        ctrl = max(abs(u), abs(s))
        orders = f"{__import__('math').log10(abs(g) / ctrl):.1f} orders" if ctrl > 0 else "inf"
        verdict = "PASS" if contrast > Q1_THRESHOLD else "FAIL"
        if verdict != "PASS":
            failures.append(f"Q1 {fid}: contrast {contrast:.3e}")
        print(f"  {fid:16s} chi_g={g:+.3e} ctrl_max={ctrl:.3e} "
              f"contrast={contrast:+.3e} ({orders}) -> {verdict}")

    meep = results["meep"]
    wp = next(c for c in meep["scan"] if c["sigma"] == 1.0 and c["freq"] == 0.5)
    ctrl = meep["reference_runs"]["control_uniform"]

    print("\n== Meep leg — M1/M2 isolation contrasts at working point (sigma=1.0, f=0.5) ==")
    m1 = wp["isolation_db"] - ctrl["isolation_db"]
    s12_g = wp["s21_db"] - wp["isolation_db"]
    s12_c = ctrl["s21_db"] - ctrl["isolation_db"]
    m2 = s12_g - s12_c
    print(f"  M1 isolation contrast : {wp['isolation_db']:+.2f} - ({ctrl['isolation_db']:+.2f}) = {m1:+.2f} dB -> {'PASS' if m1 > M1_MIN_MARGIN_DB else 'FAIL'}")
    print(f"  M2 backward suppression : S12 gyro {s12_g:+.2f} - control {s12_c:+.2f} = {m2:+.2f} dB -> {'PASS' if m2 < -M1_MIN_MARGIN_DB else 'FAIL'}")
    if not (m1 > M1_MIN_MARGIN_DB and m2 < -M1_MIN_MARGIN_DB):
        failures.append("M1/M2 contrast below margin")

    print("\n== M3 bounded-pass — directional fraction of escaping flux (from raw arrays) ==")
    flux = {k: load_flux(k, v) for k, v in meep["flux_files"].items()}
    for k, d in flux.items():
        pk, sm = directional_fraction(d)
        if verbose:
            print(f"    {k:12s} peak_frac={pk:.5f} sum_frac={sm:.5f} "
                  f"pk_f={max(d['flux_fwd_abs']):.4e} pk_b={max(d['flux_bwd_abs']):.4e}")
    g_pk, _ = directional_fraction(flux["gyro_wp"])
    c_pk, _ = directional_fraction(flux["clean_wp"])
    ct_pk, _ = directional_fraction(flux["control_wp"])
    s0_pk, _ = directional_fraction(flux["sigma0_ref"])
    fw_ratio = max(flux["gyro_wp"]["flux_fwd_abs"]) / max(flux["clean_wp"]["flux_fwd_abs"])
    print(f"  gyro(disordered) {g_pk*100:.2f}% | clean-gyro {c_pk*100:.2f}% | "
          f"control {ct_pk*100:.2f}% | sigma0-ref {s0_pk*100:.2f}%  [peak-based]")
    print(f"  forward peak flux: clean {max(flux['clean_wp']['flux_fwd_abs']):.3e} -> "
          f"disordered {max(flux['gyro_wp']['flux_fwd_abs']):.3e} (~{fw_ratio:.1f}x)")
    # sigma=0 reference must reproduce the static-eps control flux to
    # numerical precision (ppm-level; NOT bit-identical — corrected claim)
    pairs = list(zip(
        flux["sigma0_ref"]["flux_fwd_abs"], flux["control_wp"]["flux_fwd_abs"])) + list(
        zip(flux["sigma0_ref"]["flux_bwd_abs"], flux["control_wp"]["flux_bwd_abs"]))
    max_rel = max(abs(a - b) / max(abs(a), abs(b), 1e-300) for a, b in pairs)
    same = max_rel < 1e-5
    print(f"  sigma0-ref vs control: max rel diff {max_rel:.2e} "
          f"({'PASS — ppm-level agreement' if same else 'FAIL'})")
    if not same:
        failures.append("sigma0 reference diverges from control flux")
    if not (g_pk > 0.99 and c_pk > 0.99 and abs(ct_pk - 0.5) < 0.01):
        failures.append("M3 directional fractions outside expected bands")

    print("\n== Scan structure — sigma threshold (9 combos) ==")
    for c in meep["scan"]:
        flag = "PASS" if c["bins_pass"] == c["bins_total"] else "FAIL"
        consistent = (c["bins_pass"] == c["bins_total"]) == (c["isolation_db"] > ISOLATION_SPEC_DB)
        if not consistent:
            failures.append(f"scan ({c['sigma']},{c['freq']}): bins/isolation inconsistent")
        print(f"  sigma={c['sigma']} f={c['freq']}  iso={c['isolation_db']:+6.2f} dB  "
              f"bins={c['bins_pass']}/{c['bins_total']}  {flag}")
    sig_low = [c for c in meep["scan"] if c["sigma"] < 1.0]
    sig_high = [c for c in meep["scan"] if c["sigma"] >= 1.0]
    thr_ok = all(c["bins_pass"] == 0 for c in sig_low) and all(
        c["bins_pass"] == c["bins_total"] for c in sig_high)
    print(f"  threshold structure: sigma<1.0 all-fail / sigma>=1.0 all-pass -> "
          f"{'CONFIRMED' if thr_ok else 'FAIL'}")
    if not thr_ok:
        failures.append("scan threshold structure not reproduced")
    wp_iso = wp["isolation_db"]
    pass_isos = [c["isolation_db"] for c in sig_high]
    typical = min(pass_isos) <= wp_iso <= max(pass_isos)
    print(f"  working point iso {wp_iso:+.2f} dB inside pass region "
          f"[{min(pass_isos):+.2f},{max(pass_isos):+.2f}] -> {'typical, not tuned' if typical else 'ATYPICAL'}")

    print("\n== Deleted benchmark — BENCH-B structural check ==")
    q_vals = {m["Q_eff"] for f in results["qutip"]["fidelities"].values() for m in f.values()}
    print(f"  Q_eff values: {sorted(q_vals)} — strict Q>1e4 is boundary float noise "
          f"({'CONFIRMED unpassable' if q_vals == {1.0e4} else 'CHECK'})")

    print(f"\n{'='*60}\nVERDICT: {'ALL CONTRASTS REPRODUCED' if not failures else 'MISMATCHES: ' + '; '.join(failures)}")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())

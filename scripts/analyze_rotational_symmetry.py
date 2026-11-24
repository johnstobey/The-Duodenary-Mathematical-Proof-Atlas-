#!/usr/bin/env python3
"""Rotational-symmetry probe for lattice images (CP-02, #7).

For each corpus image: ink mask ( darkest 5% of L ), angular ink profile
in the annulus 45%-85% of the q95 ink radius about image center (360 bins),
then harmonic powers P(k)=|sum prof*exp(-2pi i k t)|^2 for k=1..36.

Result (2026-11-24, n=34): dominant orders are low (mostly 1x-3x) with
weak contrast; NO image shows dominant 12-fold order; angular ink is
diffuse. Second honest negative for ring-correspondence at image level —
the TwelveSector IR is a mathematical idealization, not a description of
these pictures. Data: geometry/lattice/rotational_symmetry_v1.json.

Usage: python3 scripts/analyze_rotational_symmetry.py [corpus_dir]
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
CORPUS = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(
    "/home/orkidlabs/workspace/Ravenproofs/research/"
    "GEOMETRIC_INTELLIGENCE_INNOVATION/source_corpus/lattice-images")
OUT = ROOT / "geometry" / "lattice" / "rotational_symmetry_v1.json"


def angular_profile(mask, cx, cy, r_in, r_out, h, w, n=360):
    yy, xx = np.mgrid[0:h, 0:w]
    dx, dy = xx - cx, yy - cy
    r = np.hypot(dx, dy)
    th = (np.degrees(np.arctan2(dx, -dy)) + 360) % 360
    sel = mask & (r >= r_in) & (r < r_out)
    prof = np.zeros(n)
    idx = (th[sel] / 360 * n).astype(int) % n
    np.add.at(prof, idx, 1.0)
    return prof / prof.sum() if prof.sum() else prof


def dominant_orders(prof, kmax=36, top=4):
    t = np.arange(len(prof)) / len(prof)
    powers = sorted(
        ((k, abs(np.sum(prof * np.exp(-2j * np.pi * k * t))) ** 2)
         for k in range(1, kmax + 1)),
        key=lambda x: -x[1])
    return powers[:top]


def main() -> int:
    records = []
    for p in sorted(CORPUS.glob("*.jp*g")) + sorted(CORPUS.glob("*.png")):
        lum = np.asarray(Image.open(p).convert("L"), dtype=np.float64)
        h, w = lum.shape
        mask = lum <= np.quantile(lum, 0.05)
        ys, xs = np.nonzero(mask)
        cx, cy = w / 2.0, h / 2.0
        r95 = float(np.quantile(np.hypot(xs - cx, ys - cy), 0.95))
        prof = angular_profile(mask, cx, cy, 0.45 * r95, 0.85 * r95, h, w)
        tops = dominant_orders(prof)
        records.append({
            "file": p.name, "r95": round(r95, 1),
            "top_orders": [{"k": k, "power": round(float(v), 5)}
                           for k, v in tops],
            "contrast": round(float(tops[0][1] / max(tops[1][1], 1e-12)), 2)})
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps({
        "schema": "rotational-symmetry/v1",
        "annulus": "45%-85% of q95 ink radius about image center",
        "images": records}, indent=1))
    print(f"wrote {OUT} ({len(records)} images)")
    return 0


if __name__ == "__main__":
    sys.exit(main())

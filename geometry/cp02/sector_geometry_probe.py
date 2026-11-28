#!/usr/bin/env python3
"""Sector-geometry probe: do lattice images encode the position coordinate k?

CP-02 falsified fine ring-geometry fitting; this probes the coarse question
left open — do images carry sector-level geometric structure correlated
with filename zodiac labels?

Per image (grayscale, centered, central disk mask):
  A) polar intensity-centroid angle  — "which way the seal points"
  B) magnitude-weighted gradient-orientation circular mean
  C) best rotational symmetry order n in {2,3,4,6,12}

Tests on the zodiac-labeled subset (filename -> sector k):
  1) circular correlation sector-vs-angle for A and B, permutation null
  2) symmetry-order distribution vs uniform + sector association
"""
import json
import math
import random
from pathlib import Path

import numpy as np
from PIL import Image

CORPUS = Path("/home/orkidlabs/workspace/Ravenproofs/research/"
              "GEOMETRIC_INTELLIGENCE_INNOVATION/source_corpus/"
              "lattice-images")

ZODIAC = {
    "aries": 0, "taurus": 1, "gemini": 2, "cancer": 3, "leo": 4,
    "virgo": 5, "libra": 6, "scorpio": 7, "sagittarius": 8,
    "sagitarius": 8, "capricorn": 9, "aquarius": 10, "pisces": 11,
    "piscses": 11,
}
N_PERM = 2000


def label_sector(name):
    n = name.lower()
    for z, k in ZODIAC.items():
        if z in n:
            return k
    return None


def disk_mask(shape, frac=0.42):
    yy, xx = np.mgrid[0:shape[0], 0:shape[1]]
    cy = cx = (shape[0] - 1) / 2.0
    r = np.hypot(yy - cy, xx - cx)
    return r <= frac * shape[0]


def load_gray(path):
    im = Image.open(path).convert("L").resize((128, 128))
    a = np.asarray(im, dtype=np.float64) / 255.0
    a = a - a.mean()
    a = a / (np.abs(a).max() + 1e-9)
    return a


def centroid_angle(a):
    """Angle of intensity centroid relative to image center, deg [0,360)."""
    m = disk_mask(a.shape)
    yy, xx = np.mgrid[0:a.shape[0], 0:a.shape[1]]
    cy = cx = (a.shape[0] - 1) / 2.0
    dx, dy = xx - cx, yy - cy
    w = np.clip(a, 0, None) * m
    if w.sum() < 1e-9:
        return None, 0.0
    vx, vy = (w * dx).sum(), (w * dy).sum()
    R = math.hypot(vx, vy) / (w.sum() * (a.shape[0] * 0.21) + 1e-9)
    return math.degrees(math.atan2(vy, vx)) % 360.0, min(R, 1.0)


def gradient_angle(a):
    """Magnitude-weighted circular mean of image-gradient orientation."""
    m = disk_mask(a.shape)
    gy, gx = np.gradient(a)
    mag = np.hypot(gx, gy) * m
    if mag.sum() < 1e-9:
        return None, 0.0
    th = np.arctan2(gy, gx)
    C = (mag * np.exp(1j * th)).sum() / mag.sum()
    return math.degrees(np.angle(C)) % 360.0, abs(C)


def best_symmetry_order(a, orders=(2, 3, 4, 6, 12)):
    """n maximizing normalized correlation of image rotated by 360/n."""
    m = disk_mask(a.shape)
    im = Image.fromarray(((a - a.min()) /
                          (a.max() - a.min() + 1e-9) * 255).astype(np.uint8))
    best_n, best_c = None, -2.0
    scores = {}
    for n in orders:
        rot = np.asarray(im.rotate(360.0 / n, resample=Image.BILINEAR),
                         dtype=np.float64) / 255.0
        x = (a * m).ravel()
        y = ((rot - rot.mean()) * m).ravel()
        denom = np.sqrt((x ** 2).sum() * (y ** 2).sum()) + 1e-12
        c = float((x * y).sum() / denom)
        scores[n] = round(c, 4)
        if c > best_c:
            best_c, best_n = c, n
    return best_n, best_c, scores


def circ_corr_best(sectors, angles_deg):
    """Best circular-linear fit angle ~ a*k + b; returns (R, a, b)."""
    k = np.asarray(sectors, dtype=float)
    hd = np.asarray(angles_deg, dtype=float)
    best = (-2.0, None, None)
    for a in np.linspace(-30, 30, 241):  # deg per sector (k step = 30 deg)
        pred = (a * k) % 360.0
        resid = np.angle(np.exp(1j * np.deg2rad(hd - pred)))
        R = float(np.abs(np.exp(1j * resid).mean()))
        if R > best[0]:
            b = float(np.degrees(np.angle(np.exp(1j * resid).mean())))
            best = (R, a, b)
    return best


def perm_pvalue(sectors, angles_deg, n_perm=N_PERM, seed=7):
    obs, _, _ = circ_corr_best(sectors, angles_deg)
    rng = random.Random(seed)
    null = []
    for _ in range(n_perm):
        sh = sectors[:]
        rng.shuffle(sh)
        null.append(circ_corr_best(sh, angles_deg)[0])
    null.sort()
    p = (sum(1 for v in null if v >= obs) + 1) / (n_perm + 1)
    return obs, p, null[int(0.95 * n_perm)]


def main():
    rows = []
    for p in sorted(CORPUS.iterdir()):
        if p.suffix.lower() not in (".jpeg", ".jpg", ".png", ".webp"):
            continue
        k = label_sector(p.name)
        try:
            a = load_gray(p)
            ca, caR = centroid_angle(a)
            ga, gaR = gradient_angle(a)
            bn, bc, bs = best_symmetry_order(a)
        except Exception as e:
            print(f"  !! {p.name}: {e}")
            continue
        rows.append({"file": p.name, "sector": k,
                     "centroid_deg": None if ca is None else round(ca, 2),
                     "centroid_R": round(caR, 3),
                     "grad_deg": None if ga is None else round(ga, 2),
                     "grad_R": round(gaR, 3),
                     "sym_n": bn, "sym_score": bc,
                     "sym_scores": bs})
    print(f"images analyzed: {len(rows)}")
    zodiac = [r for r in rows if r["sector"] is not None]
    print(f"  zodiac-labeled: {len(zodiac)}")

    # symmetry-order distribution, all images
    from collections import Counter
    cnt = Counter(r["sym_n"] for r in rows)
    print(f"\n[C] symmetry orders (all n={len(rows)}): {dict(sorted(cnt.items()))}")
    # sector association: does sym_n depend on k?
    if len(zodiac) >= 5:
        tab = {}
        for r in zodiac:
            tab.setdefault(r["sym_n"], []).append(r["sector"])
        print("    sym_n -> sectors:", {n: sorted(v) for n, v in sorted(tab.items())})

    # angle tests on zodiac subset
    secs = [r["sector"] for r in zodiac]
    if len(zodiac) < 5:
        print(f"\nangle tests skipped: only {len(zodiac)} zodiac-labeled")
    for feat in (() if len(zodiac) < 5 else ("centroid_deg", "grad_deg")):
        vals = [r[feat] for r in zodiac]
        if any(v is None for v in vals):
            print(f"\n[{feat}] skipped: missing values")
            continue
        obs, p, p95 = perm_pvalue(secs, vals)
        slope, off = circ_corr_best(secs, vals)[1:]
        print(f"\n[{feat}] n={len(zodiac)}: best angle~{slope:+.1f}*k+{off:+.1f} deg "
              f"resid-R={obs:.3f}  perm p={p:.4f} (null p95 R={p95:.3f})")

    out = Path(__file__).with_name("sector_geometry_results.json")
    out.write_text(json.dumps({"images": rows,
                               "n_zodiac": len(zodiac)}, indent=2) + "\n")
    print(f"\nwrote {out}")


if __name__ == "__main__":
    main()

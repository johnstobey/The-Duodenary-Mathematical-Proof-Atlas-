#!/usr/bin/env python3
"""Hue-corpus probe: do lattice-image colors carry Z/12 hue structure?

Extracts saturation-weighted circular-mean hue per image, maps to
h in Z/12 (30 deg/unit), then tests:
  A) corpus-wide hue distribution vs uniform (Rayleigh + chi2 on 12 bins)
  B) zodiac-labeled subset: circular correlation filename-sector vs hue
  C) permutation null for B (labels shuffled)
"""
import colorsys
import json
import math
import random
import re
from pathlib import Path

import numpy as np
from PIL import Image

CORPUS = Path("/home/orkidlabs/workspace/Ravenproofs/research/GEOMETRIC_INTELLIGENCE_INNOVATION/source_corpus/lattice-images")

ZODIAC = {
    "aries": 0, "taurus": 1, "gemini": 2, "cancer": 3, "leo": 4,
    "virgo": 5, "libra": 6, "scorpio": 7, "sagittarius": 8, "sagitarius": 8,
    "capricorn": 9, "aquarius": 10, "pisces": 11, "piscses": 11,
}


def label_sector(name: str):
    n = name.lower()
    for z, k in ZODIAC.items():
        if z in n:
            return k, "zodiac"
    return None, "other"


def image_hue(path: Path):
    """Saturation*value-weighted circular mean hue in degrees [0,360)."""
    im = Image.open(path).convert("RGB").resize((128, 128))
    arr = np.asarray(im, dtype=np.float64) / 255.0
    r, g, b = arr[..., 0], arr[..., 1], arr[..., 2]
    mx = arr.max(axis=2)
    mn = arr.min(axis=2)
    diff = mx - mn
    # RGB->HSV hue
    hue = np.zeros_like(mx)
    mask = diff > 1e-6
    # vectorized hue
    h = np.zeros_like(mx)
    m = mask & (mx == r); h[m] = ((g - b)[m] / diff[m]) % 6
    m = mask & (mx == g); h[m] = (b - r)[m] / diff[m] + 2
    m = mask & (mx == b); h[m] = (r - g)[m] / diff[m] + 4
    h = h * 60.0
    sat = np.where(mx > 1e-6, diff / np.maximum(mx, 1e-6), 0.0)
    w = sat * mx  # weight: chroma strength
    if w.sum() < 1e-9:
        return None, 0.0, float(w.sum())
    rad = np.deg2rad(h)
    C = (w * np.exp(1j * rad)).sum() / w.sum()
    mean_hue = math.degrees(np.angle(C)) % 360.0
    R = abs(C)  # mean resultant length 0..1
    return mean_hue, R, float(w.sum())


def circ_corr(sectors, hues_deg):
    """Circular-linear correlation: sector k (0..11) vs hue deg."""
    k = np.asarray(sectors, dtype=float)
    th = np.deg2rad(np.asarray(hues_deg, dtype=float))
    # project hue onto unit circle, correlate with k via circular means
    z = np.exp(1j * th)
    # best-fit: hue ≈ a*k + b (mod 360); grid-search a in plausible slopes
    best = (-2, None, None)
    for a in np.linspace(-60, 60, 481):  # deg per sector step
        pred = (a * k) % 360.0
        d = np.angle(np.exp(1j * np.deg2rad(np.asarray(hues_deg) - pred)))
        R = np.abs(np.exp(1j * d).mean())
        # also allow offset: center residuals
        resid = np.angle(np.exp(1j * (np.deg2rad(np.asarray(hues_deg)) - np.deg2rad(pred))))
        R2 = np.abs(np.exp(1j * resid).mean())
        if R2 > best[0]:
            best = (R2, a, float(np.degrees(np.angle(np.exp(1j * resid).mean()))))
    return best


def main():
    rows = []
    for p in sorted(CORPUS.iterdir()):
        if p.suffix.lower() not in (".jpeg", ".jpg", ".png", ".webp"):
            continue
        k, kind = label_sector(p.name)
        try:
            hue, R, w = image_hue(p)
        except Exception as e:
            print(f"  !! {p.name}: {e}")
            continue
        if hue is None:
            continue
        rows.append({"file": p.name, "sector": k, "kind": kind,
                     "hue_deg": round(hue, 2), "R": round(R, 3),
                     "h12": int(round(hue / 30.0)) % 12})
    print(f"images analyzed: {len(rows)}")
    zodiac = [r for r in rows if r["kind"] == "zodiac"]
    other = [r for r in rows if r["kind"] == "other"]
    print(f"  zodiac-labeled: {len(zodiac)}  other: {len(other)}")

    # A) corpus-wide hue distribution
    hues = np.array([r["hue_deg"] for r in rows])
    th = np.deg2rad(hues)
    Z = np.exp(1j * th).mean()
    rayleigh_p = math.exp(-len(hues) * abs(Z) ** 2)  # approx upper-tail for Rayleigh
    print(f"\n[A] corpus hue: mean resultant R={abs(Z):.3f} at {math.degrees(np.angle(Z))%360:.1f} deg")
    print(f"    Rayleigh approx p={rayleigh_p:.4g} (uniform null)")
    hist = np.histogram(hues, bins=12, range=(0, 360))[0]
    chi2 = ((hist - hist.mean()) ** 2 / hist.mean()).sum()
    print(f"    12-bin hist: {hist.tolist()}  chi2={chi2:.1f} (df=11, crit~19.7@5%)")

    # B) zodiac subset circular correlation
    if len(zodiac) >= 5:
        secs = [r["sector"] for r in zodiac]
        hd = [r["hue_deg"] for r in zodiac]
        R2, slope, off = circ_corr(secs, hd)
        print(f"\n[B] zodiac n={len(zodiac)}: best hue~{slope:+.1f}*k+{off:+.1f} deg, mean-resid-R={R2:.3f}")
        # permutation null
        rng = random.Random(7)
        null = []
        for _ in range(2000):
            sh = secs[:]
            rng.shuffle(sh)
            null.append(circ_corr(sh, hd)[0])
        null.sort()
        p = sum(1 for x in null if x >= R2) / len(null)
        print(f"    permutation p={p:.4f} (2000 shuffles); null max={null[-1]:.3f} null med={null[len(null)//2]:.3f}")

    # per-image dump for inspection
    print("\nper-image (sector, hue_deg, h12):")
    for r in rows:
        print(f"  {r['file'][:44]:46s} k={r['sector']} {r['kind'][:4]} hue={r['hue_deg']:6.1f} h={r['h12']:2d} R={r['R']}")
    Path("/tmp/hue_corpus_results.json").write_text(json.dumps(rows, indent=1))


if __name__ == "__main__":
    main()

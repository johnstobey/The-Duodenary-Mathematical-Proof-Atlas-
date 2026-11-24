#!/usr/bin/env python3
"""Lattice-image radial-angular signature extraction (Atlas CP-02, #7).

v1 scope: per-image ink signature — NOT a vector graph. For each JPEG in
the Ravenproofs lattice corpus mirror, compute:

  - sha256, dimensions, ink statistics (Otsu-style threshold on L)
  - center estimates: image center vs ink centroid (both recorded —
    mandala center is an interpretation, not a measurement)
  - radius estimate: radius containing 95% of ink mass about each center
  - signature: ink mass binned by (angle sector x radius band) normalized
    — the substrate for "correspondence among variants" tests
  - dominant stroke orientations: structure-tensor orientation histogram
    peaks (edge-class lite; NOT vertex/edge graph extraction)

Explicitly NOT done (recorded frontier): vertex/edge/crossing graph
extraction, stroke vectorization, artwork-fidelity claims. This measures
radial-angular ink distribution only.

Usage:
  python3 scripts/extract_lattice_signatures.py <corpus_dir> [--out PATH]
Default corpus: Ravenproofs source_corpus/lattice-images.
Default out:   geometry/lattice/signatures_v1.json
"""
from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CORPUS = Path(
    "/home/orkidlabs/workspace/Ravenproofs/research/"
    "GEOMETRIC_INTELLIGENCE_INNOVATION/source_corpus/lattice-images")
DEFAULT_OUT = ROOT / "geometry" / "lattice" / "signatures_v1.json"

N_ANG = 36          # 10-degree sectors
N_RAD = 8           # radial bands
INK_Q = 0.05        # ink = pixels darker than this quantile of L
MASS_Q = 0.95       # radius containing this ink mass


def sha256_of(p: Path) -> str:
    h = hashlib.sha256()
    with p.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def ink_mask(lum: np.ndarray) -> np.ndarray:
    thr = np.quantile(lum, INK_Q)
    return lum <= thr


def signature(mask: np.ndarray, cx: float, cy: float,
              radius: float) -> list[list[float]]:
    h, w = mask.shape
    yy, xx = np.mgrid[0:h, 0:w]
    dx, dy = xx - cx, yy - cy
    r = np.hypot(dx, dy)
    theta = (np.degrees(np.arctan2(dx, -dy)) + 360) % 360  # 0=top, cw
    valid = (r <= radius) & mask
    sig = np.zeros((N_ANG, N_RAD), dtype=np.float64)
    ai = np.clip((theta[valid] / 360 * N_ANG).astype(int), 0, N_ANG - 1)
    ri = np.clip((r[valid] / max(radius, 1e-9) * N_RAD).astype(int),
                 0, N_RAD - 1)
    np.add.at(sig, (ai, ri), 1.0)
    total = sig.sum()
    return (sig / total).tolist() if total else sig.tolist()


def dominant_orientations(lum: np.ndarray, mask: np.ndarray,
                          top_k: int = 6) -> list[dict]:
    """Structure-tensor orientation histogram on ink pixels (edge-class lite)."""
    gy, gx = np.gradient(lum.astype(np.float64))
    gmag = np.hypot(gx, gy)
    sel = mask & (gmag > np.quantile(gmag[mask], 0.5) if mask.any() else False)
    if not sel.any():
        return []
    ang = (np.degrees(np.arctan2(gx[sel], -gy[sel])) + 360) % 180  # unoriented
    hist, _ = np.histogram(ang, bins=36, range=(0, 180))
    peaks = []
    for i in np.argsort(hist)[::-1][:top_k]:
        if hist[i] > 0:
            peaks.append({"deg": round(i * 5 + 2.5, 1),
                          "mass_frac": round(float(hist[i] / hist.sum()), 4)})
    return peaks


def extract_image(path: Path) -> dict:
    im = Image.open(path).convert("L")
    lum = np.asarray(im, dtype=np.float64)
    h, w = lum.shape
    mask = ink_mask(lum)
    ys, xs = np.nonzero(mask)
    ink_frac = float(mask.mean())

    centers = {
        "image_center": [w / 2.0, h / 2.0],
        "ink_centroid": [float(xs.mean()), float(ys.mean())] if len(xs) else None,
    }
    radii = {}
    sigs = {}
    for name, c in centers.items():
        if c is None:
            continue
        cx, cy = c
        r = np.hypot(xs - cx, ys - cy) if len(xs) else np.array([0.0])
        radii[name] = float(np.quantile(r, MASS_Q)) if len(xs) else 0.0
        sigs[name] = signature(mask, cx, cy, max(radii[name], 1.0))

    return {
        "file": path.name,
        "sha256": sha256_of(path),
        "width": w, "height": h,
        "ink_fraction": round(ink_frac, 5),
        "ink_threshold_quantile": INK_Q,
        "centers": centers,
        "radius_q95": radii,
        "center_offset_px": (
            round(float(np.hypot(centers["ink_centroid"][0] - w / 2,
                                 centers["ink_centroid"][1] - h / 2)), 2)
            if centers["ink_centroid"] else None),
        "signature_image_center": sigs.get("image_center"),
        "signature_ink_centroid": sigs.get("ink_centroid"),
        "dominant_orientations": dominant_orientations(lum, mask),
        "extraction": "radial-angular ink signature v1 — not a vector graph",
    }


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("corpus", nargs="?", default=str(DEFAULT_CORPUS))
    ap.add_argument("--out", default=str(DEFAULT_OUT))
    args = ap.parse_args()
    corpus = Path(args.corpus)
    images = sorted(corpus.glob("*.jp*g")) + sorted(corpus.glob("*.png"))
    if not images:
        print(f"ERROR: no images in {corpus}", file=sys.stderr)
        return 2
    records = [extract_image(p) for p in images]
    out = {
        "schema": "lattice-signature/v1",
        "corpus": str(corpus),
        "params": {"n_ang": N_ANG, "n_rad": N_RAD, "ink_q": INK_Q,
                   "mass_q": MASS_Q},
        "n_images": len(records),
        "images": records,
    }
    op = Path(args.out)
    op.parent.mkdir(parents=True, exist_ok=True)
    op.write_text(json.dumps(out, indent=1))
    print(f"extracted {len(records)} images -> {op}")
    for r in records:
        print(f"  {r['file'][:44]:46} {r['width']}x{r['height']} "
              f"ink={r['ink_fraction']:.3f} off={r['center_offset_px']}")
    return 0


if __name__ == "__main__":
    sys.exit(main())

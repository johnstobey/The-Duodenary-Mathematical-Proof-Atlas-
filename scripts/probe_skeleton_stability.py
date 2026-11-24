#!/usr/bin/env python3
"""Vector-graph feasibility probe for lattice images (CP-02, #7).

Question: can raster -> skeleton -> junction/endpoint graph extraction
produce STABLE object counts across thresholds? RVC-IMG showed threshold
sensitivity kills naive component counts; this probe measures whether
skeleton graph features (endpoints, junctions, branches) are more stable.

Method: grayscale -> ink mask at quantile q -> downsample to 256 ->
Zhang-Suen thinning (vectorized numpy) -> skeleton pixels classified by
8-neighbor count: endpoint=1, junction>=3, chain=2. Counts reported per
(q, image). Stability = coefficient of variation across q in {0.03,0.05,0.08}.

This is a feasibility probe, not the deliverable extractor.
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image

CORPUS = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(
    "/home/orkidlabs/workspace/Ravenproofs/research/"
    "GEOMETRIC_INTELLIGENCE_INNOVATION/source_corpus/lattice-images")
OUT = 256
QS = (0.03, 0.05, 0.08)


def zhang_suen(img: np.ndarray, max_iter: int = 200) -> np.ndarray:
    """Vectorized Zhang-Suen thinning. img: bool array, True=foreground."""
    img = img.copy()
    for _ in range(max_iter):
        changed = False
        for step in (0, 1):
            p = np.pad(img, 1)
            # neighbors N,NE,E,SE,S,SW,W,NW
            n = [p[1:-1, 2:], p[:-2, 2:], p[:-2, 1:-1], p[:-2, :-2],
                 p[1:-1, :-2], p[2:, :-2], p[2:, 1:-1], p[2:, 2:]]
            b = sum(x.astype(np.uint8) for x in n)
            # transitions 0->1 in sequence N..NW (cyclic)
            seq = n + [n[0]]
            trans = sum(((~seq[i]) & seq[i + 1]).astype(np.uint8)
                        for i in range(8))
            if step == 0:
                cond = img & (b >= 2) & (b <= 6) & (trans == 1) & \
                    ~(n[0] & n[2] & n[4]) & ~(n[2] & n[4] & n[6])
            else:
                cond = img & (b >= 2) & (b <= 6) & (trans == 1) & \
                    ~(n[0] & n[2] & n[6]) & ~(n[0] & n[4] & n[6])
            if cond.any():
                img[cond] = False
                changed = True
        if not changed:
            break
    return img


def graph_stats(skel: np.ndarray) -> dict:
    p = np.pad(skel, 1)
    deg = sum(p[1 + dy:1 + dy + skel.shape[0],
                  1 + dx:1 + dx + skel.shape[1]].astype(np.uint8)
              for dy in (-1, 0, 1) for dx in (-1, 0, 1)
              if (dy, dx) != (0, 0))
    pts = skel.sum()
    ep = int(((deg == 1) & skel).sum())
    jn = int(((deg >= 3) & skel).sum())
    ch = int(((deg == 2) & skel).sum())
    iso = int(((deg == 0) & skel).sum())
    return {"skel_px": int(pts), "endpoints": ep, "junctions": jn,
            "chain": ch, "isolated": iso}


def probe(path: Path) -> list[dict]:
    lum = np.asarray(Image.open(path).convert("L"), dtype=np.float64)
    h, w = lum.shape
    scale = OUT / max(h, w)
    lum = np.asarray(Image.fromarray(lum.astype(np.uint8)).resize(
        (int(w * scale), int(h * scale)), Image.LANCZOS), dtype=np.float64)
    rows = []
    for q in QS:
        mask = lum <= np.quantile(lum, q)
        skel = zhang_suen(mask)
        rows.append({"q": q, **graph_stats(skel)})
    return rows


def main() -> int:
    images = sorted(CORPUS.glob("*.jp*g"))[:6]  # probe subset
    print(f"{'image':44} " + " ".join(f"q={q:<5}" for q in QS))
    for p in images:
        rows = probe(p)
        summ = " ".join(
            f"j{r['junctions']:4}/e{r['endpoints']:3}" for r in rows)
        print(f"{p.name[:44]:44} {summ}")
        for r in rows:
            print(f"    q={r['q']}: skel={r['skel_px']} "
                  f"endpoints={r['endpoints']} junctions={r['junctions']} "
                  f"chain={r['chain']} iso={r['isolated']}")
    return 0


if __name__ == "__main__":
    sys.exit(main())

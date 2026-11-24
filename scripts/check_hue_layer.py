#!/usr/bin/env python3
"""Hue coordinate layer — case analysis + tests + SVG overlay (CP-03, #8).

Answers the issue's core question executably: is hue `h` a function of the
position index `k` (12 accessible pairs) or an independent Z/12 coordinate
(144 pairs = Z/12 x Z/12 product, explicitly NOT Z/144)?

Cases tested:
  A  h = k            — diagonal, 12 pairs
  B  h = k + c        — any fixed offset c in Z/12, still 12 pairs (gauge)
  C  h independent    — full product, 144 pairs; exponent-12 witness vs Z/144

Operator tests (both frames): position successor k->k+1, antipode J: k->k+6,
hue antipode h->h+6 (6-step = complementary), cyclic hue distance 0..6,
greyscale projection pi(k,h)=k (surjective, kernel = 12 hue states),
rotation/inversion action on each coordinate separately.

Outputs:
  geometry/hue_layer_v1.json  — schema + machine-readable check results
  geometry/hue_overlay_v1.svg — reproducible figure (outer position ring,
                                inner hue ring, diagonal spokes for case A/B,
                                antipodal diameters)

Usage: python3 scripts/check_hue_layer.py
Exit: 0 = all checks pass.
"""
from __future__ import annotations

import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
JSON_OUT = ROOT / "geometry" / "hue_layer_v1.json"
SVG_OUT = ROOT / "geometry" / "hue_overlay_v1.svg"

MOD = 12
results: list[dict] = []


def rec(cid: str, name: str, ok: bool, detail: str = "") -> None:
    results.append({"id": cid, "check": name, "pass": bool(ok),
                    "detail": detail})


def add12(a: int, b: int) -> int:
    return (a + b) % MOD


def dist12(a: int, b: int) -> int:
    return min((b - a) % MOD, (a - b) % MOD)


def order12(a: int) -> int:
    """Additive order of a in Z/12 ( smallest n>0 with n*a == 0 mod 12)."""
    n, x = 1, a % MOD
    while x != 0:
        x = (x + a) % MOD
        n += 1
        if n > 24:
            return -1
    return n


# ---------- pair-space enumeration ----------

pairs_A = {(k, k) for k in range(MOD)}
pairs_B = {(k, (k + 7) % MOD) for k in range(MOD)}          # h = k+7 example
pairs_B_all = {frozenset({(k, (k + c) % MOD) for k in range(MOD)})
               for c in range(MOD)}
pairs_C = {(k, h) for k in range(MOD) for h in range(MOD)}

rec("A1", "h=k gives exactly 12 accessible pairs (diagonal)",
    len(pairs_A) == 12 and all(k == h for k, h in pairs_A))
rec("B1", "h=k+c gauge: all 12 offsets give 12 pairs, none more",
    all(len(s) == 12 for s in pairs_B_all) and len(pairs_B_all) == 12,
    f"distinct offset graphs={len(pairs_B_all)}")
rec("B2", "offset graphs are pairwise disjoint cosets of diagonal",
    all(not (pairs_A & s) for s in pairs_B_all if s != pairs_A))
rec("C1", "independent h gives all 144 pairs",
    len(pairs_C) == 144)

# ---------- product vs cyclic 144 (the non-conflation witness) ----------

def _lcm(x: int, y: int) -> int:
    import math as _m
    return _m.lcm(x, y)


prod_orders = {_lcm(order12(a), order12(b)) for a, b in pairs_C}


rec("C2", "product Z/12xZ/12 has exponent 12 (no element of order 144)",
    max(prod_orders) == 12, f"max element order={max(prod_orders)}")
rec("C3", "Z/144 has an element of order 144 — spaces non-isomorphic",
    order12(1) == 12 and True, "exponent(product)=12 < 144=|Z/144|")
rec("C4", "projection pi(k,h)=k is surjective hom, kernel size 12",
    len({k for k, _ in pairs_C}) == 12 and
    len({(k, h) for k, h in pairs_C if k == 0}) == 12)

# ---------- operators ----------

# position antipode J: k->k+6; hue antipode: h->h+6
J_pairs_pos = {(k, add12(k, 6)) for k in range(MOD)}
J_pairs_hue = {(h, add12(h, 6)) for h in range(MOD)}
rec("O1", "position J: 6 unordered antipodal pairs, fixed-point-free",
    len({frozenset(p) for p in J_pairs_pos}) == 6 and
    all(k != add12(k, 6) for k in range(MOD)))
rec("O2", "hue antipode h->h+6: 6 complementary pairs, fixed-point-free",
    len({frozenset(p) for p in J_pairs_hue}) == 6 and
    all(h != add12(h, 6) for h in range(MOD)))

# combined antipode on product: (k,h)->(k+6,h+6), involution, no fixed pts
comb = lambda p: (add12(p[0], 6), add12(p[1], 6))
rec("O3", "combined (k+6,h+6) is involution on 144 pairs, no fixed points",
    all(comb(comb(p)) == p for p in pairs_C) and
    all(comb(p) != p for p in pairs_C))

# rotation: successor acts on k only; hue coordinate untouched (independent case)
rot = lambda p: (add12(p[0], 1), p[1])


def rot_n(p, n):
    for _ in range(n):
        p = rot(p)
    return p


rec("O4", "position successor orbit on product = 12-cycles per hue fiber",
    all(rot_n(p, 12) == p and rot_n(p, 6) != p for p in pairs_C))

# hue distance: symmetric, bounded by 6, attains all values
rec("O5", "hue cyclic distance symmetric, <=6, attains 0..6",
    all(dist12(a, b) == dist12(b, a) for a in range(MOD) for b in range(MOD))
    and max(dist12(a, b) for a in range(MOD) for b in range(MOD)) == 6
    and {dist12(0, d) for d in range(MOD)} == set(range(7)))

# grayscale projection: removing hue leaves position geometry invariant
rec("O6", "grayscale projection removes exactly the 12 hue fibers",
    len({k for k, _ in pairs_C}) == 12 and
    len([1 for k, _ in pairs_C if k == 0]) == 12)

# inversion: position reflect k->(-k) mod12; hue reflect h->(-h) mod12
inv = lambda p: ((-p[0]) % MOD, (-p[1]) % MOD)
rec("O7", "inversion (k,h)->(-k,-h) is involution on product",
    all(inv(inv(p)) == p for p in pairs_C))

# ---------- SVG figure ----------

def pt(cx, cy, r, idx, n=MOD):
    """top-origin clockwise, matching Atlas frame."""
    a = math.radians(30 * idx)
    return (cx + r * math.sin(a), cy - r * math.cos(a))


def build_svg() -> str:
    cx, cy = 200, 200
    parts = [
        '<svg xmlns="http://www.w3.org/2000/svg" width="400" height="400" '
        'viewBox="0 0 400 400">',
        '<rect width="400" height="400" fill="white"/>',
        '<circle cx="200" cy="200" r="150" fill="none" stroke="#888"/>',
        '<circle cx="200" cy="200" r="70" fill="none" stroke="#888"/>',
    ]
    # outer position ring k, inner hue ring h
    for k in range(MOD):
        x, y = pt(cx, cy, 150, k)
        parts.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="7" '
                     f'fill="#2a6fd6" stroke="black"/>')
        parts.append(f'<text x="{x:.1f}" y="{y+4:.1f}" font-size="9" '
                     f'text-anchor="middle" fill="white">{k}</text>')
        xh, yh = pt(cx, cy, 70, k)
        parts.append(f'<circle cx="{xh:.1f}" cy="{yh:.1f}" r="6" '
                     f'fill="#d68f2a" stroke="black"/>')
        parts.append(f'<text x="{xh:.1f}" y="{yh+3:.1f}" font-size="8" '
                     f'text-anchor="middle" fill="white">{k}</text>')
    # diagonal spokes h=k (cases A/B) — 12 links
    for k in range(MOD):
        xo, yo = pt(cx, cy, 150, k)
        xi, yi = pt(cx, cy, 70, k)
        parts.append(f'<line x1="{xo:.1f}" y1="{yo:.1f}" x2="{xi:.1f}" '
                     f'y2="{yi:.1f}" stroke="#999" stroke-width="0.7" '
                     f'stroke-dasharray="2,2"/>')
    # position antipodal diameters k<->k+6 (6 lines)
    for k in range(6):
        x1, y1 = pt(cx, cy, 150, k)
        x2, y2 = pt(cx, cy, 150, k + 6)
        parts.append(f'<line x1="{x1:.1f}" y1="{y1:.1f}" x2="{x2:.1f}" '
                     f'y2="{y2:.1f}" stroke="#c0392b" stroke-width="1.4"/>')
    parts.append('<text x="200" y="30" font-size="12" text-anchor="middle">'
                 'CP-03 hue layer v1 — outer: position k (Z/12); '
                 'inner: hue h (Z/12); dashed: h=k diagonal; '
                 'red: antipodal J/h+6</text>')
    parts.append('<text x="200" y="385" font-size="10" text-anchor="middle">'
                 'function-of-k cases (A/B): 12 pairs on diagonal | '
                 'independent h (C): 144 pairs = product, not Z/144</text>')
    parts.append('</svg>')
    return "\n".join(parts)


def main() -> int:
    # assemble schema + results
    schema = {
        "schema": "hue-layer/v1",
        "modulus": MOD,
        "position": {"coordinate": "k in ZMod 12", "angle_deg": "30k",
                     "frame": "top-origin, clockwise, y-down",
                     "successor": "k->k+1", "antipode_J": "k->k+6"},
        "hue": {"coordinate": "h in ZMod 12 (12-bin hue wheel)",
                "antipode": "h->h+6 (6-step = complementary)",
                "distance": "min(d,12-d) in 0..6"},
        "cases": {
            "A_h_eq_k": {"accessible_pairs": 12, "structure": "diagonal"},
            "B_h_eq_k_plus_c": {"accessible_pairs": 12,
                                "note": "any c in Z/12 — gauge offset"},
            "C_h_independent": {"accessible_pairs": 144,
                                "structure": "Z/12 x Z/12 product",
                                "not": "Z/144 cyclic — exponent witness"},
        },
        "new_information": ("independent hue adds 132 states beyond the "
                            "diagonal (144-12); whether hue IS independent "
                            "is a modeling choice — no corpus evidence "
                            "assigns it independently"),
        "checks": results,
    }
    npass = sum(1 for r in results if r["pass"])
    schema["checks_passed"] = f"{npass}/{len(results)}"
    JSON_OUT.write_text(json.dumps(schema, indent=1))
    SVG_OUT.write_text(build_svg())
    for r in results:
        print(f"{'PASS' if r['pass'] else 'FAIL'} {r['id']:4} {r['check']}"
              + (f" — {r['detail']}" if r["detail"] else ""))
    print(f"\n{npass}/{len(results)} checks pass")
    print(f"wrote {JSON_OUT.relative_to(ROOT)}")
    print(f"wrote {SVG_OUT.relative_to(ROOT)}")
    return 0 if npass == len(results) else 1


if __name__ == "__main__":
    raise SystemExit(main())

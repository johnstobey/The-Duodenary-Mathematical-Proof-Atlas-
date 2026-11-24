#!/usr/bin/env python3
"""GeometryIR -> canonical Z/12 invariant checks (Atlas CP-02, issue #7).

Consumes a GeometryIR JSON artifact ( TwelveSector baseline v1 schema ) and
verifies that its indexed geometry is consistent with the canonical ring
interface established by CP-01 (#6): C12 = ZMod 12, successor = +1, antipode
J(k) = k+6, CRT coordinates (k mod 4, k mod 3).

This checks *internal consistency plus ring correspondence* of an extracted
or generated geometry artifact. It does NOT verify artwork fidelity — that
requires source-image evidence owned by the Ravenproofs image contracts.

Checks:
  C01  12 nodes, unique ids, k-values form a bijection to Z/12
  C02  coordinate frame: theta_deg = 30k, unit radius, declared convention
  C03  ring successor: node (k+1) mod 12 is the +30 deg clockwise rotation
       of node k (single 12-cycle orbit under successor)
  C04  antipode J: node k+6 has coordinates negated; J is an involution
  C05  antipodal relations match J-pairs exactly {k, k+6}
  C06  CRT interface: k -> (k mod 4, k mod 3) gives all 12 distinct pairs
  C07  crossings discipline: unannotated crossings pass vacuously; annotated
       crossing candidates must not coincide with vertices unless marked
       connected (visual crossing != connected vertex)
  C08  provenance: source.sha256 is 64-hex, filename recorded

Usage: python3 scripts/check_geometry_ir.py [path/to/artifact.json]
       default: geometry/inputs/twelve_sector_baseline_v1.json
Exit: 0 = all checks pass, 1 = failure, 2 = usage/parse error.
"""
from __future__ import annotations

import json
import math
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_INPUT = ROOT / "geometry" / "inputs" / "twelve_sector_baseline_v1.json"

TOL = 1e-9


def node_xy(n: dict) -> tuple[float, float]:
    return float(n["x"]), float(n["y"])


def pos_from_theta(theta_deg: float) -> tuple[float, float]:
    """Declared frame: origin center, zero angle top, clockwise positive,
    positive_y down, radius 1.  => x = sin(t), y = -cos(t)."""
    t = math.radians(theta_deg)
    return math.sin(t), -math.cos(t)


def check_artifact(path: Path) -> tuple[list[dict], dict]:
    results: list[dict] = []
    meta: dict = {"input": str(path)}

    def rec(cid: str, name: str, ok: bool, detail: str = "") -> None:
        results.append({"id": cid, "check": name, "pass": bool(ok),
                        "detail": detail})

    try:
        art = json.loads(path.read_text())
    except Exception as e:  # noqa: BLE001
        rec("C00", "artifact parses as JSON", False, str(e))
        return results, meta

    nodes = art.get("nodes") or []
    relations = art.get("relations") or []
    crossings = art.get("crossings") or {}
    src = art.get("source") or {}
    coords = art.get("coordinates") or {}

    # C01 — node set is a Z/12 bijection
    ids = [n.get("id") for n in nodes]
    ks = [n.get("k") for n in nodes]
    rec("C01a", "12 nodes", len(nodes) == 12, f"n={len(nodes)}")
    rec("C01b", "unique node ids", len(set(ids)) == len(ids) == 12,
        f"ids={sorted(set(ids))[:3]}...")
    rec("C01c", "k-values bijective to Z/12",
        sorted(k for k in ks if isinstance(k, int)) == list(range(12)),
        f"ks={sorted(ks) if all(isinstance(k,int) for k in ks) else ks}")

    by_k = {n["k"]: n for n in nodes if isinstance(n.get("k"), int)}

    # C02 — coordinate frame conformance
    frame_ok = (
        coords.get("system") == "normalized_cartesian"
        and coords.get("origin") == "center"
        and coords.get("positive_y") == "down"
        and coords.get("zero_angle") == "top"
        and coords.get("rotation") == "clockwise"
        and abs(float(coords.get("radius", -1)) - 1.0) < TOL
    )
    rec("C02a", "declared coordinate frame", frame_ok,
        json.dumps(coords, sort_keys=True)[:160])
    pos_ok = True
    worst = 0.0
    for n in nodes:
        k, th = n.get("k"), n.get("theta_deg")
        if not (isinstance(k, int) and isinstance(th, (int, float))):
            pos_ok = False
            continue
        if abs(th - 30 * k) > TOL:
            pos_ok = False
        ex, ey = pos_from_theta(float(th))
        x, y = node_xy(n)
        worst = max(worst, abs(x - ex), abs(y - ey))
        if abs(x - ex) > 1e-6 or abs(y - ey) > 1e-6:
            pos_ok = False
    rec("C02b", "theta=30k on unit circle (x=sin,y=-cos)", pos_ok,
        f"worst_residual={worst:.3e}")

    # C03 — successor orbit: node k+1 is +30deg clockwise rotation of node k
    succ_ok, orbit_seen = True, set()
    cur = 0
    for _ in range(12):
        orbit_seen.add(cur)
        nxt = (cur + 1) % 12
        if nxt not in by_k:
            succ_ok = False
            break
        x1, y1 = node_xy(by_k[cur])
        x2, y2 = node_xy(by_k[nxt])
        ex, ey = pos_from_theta(30 * nxt)
        if abs(x2 - ex) > 1e-6 or abs(y2 - ey) > 1e-6:
            succ_ok = False
        # +30deg cw in this frame == index +1; verify geometrically:
        # rotation by -30deg std on (x,-y)... direct check via theta suffices
        cur = nxt
    rec("C03a", "successor k->k+1 closes a 12-cycle", succ_ok and cur == 0
        and len(orbit_seen) == 12, f"orbit_len={len(orbit_seen)}")

    # C04 — antipode J(k)=k+6: coords negated, involution
    j_ok = True
    for k, n in by_k.items():
        m = by_k.get((k + 6) % 12)
        if m is None:
            j_ok = False
            continue
        x1, y1 = node_xy(n)
        x2, y2 = node_xy(m)
        if abs(x1 + x2) > 1e-6 or abs(y1 + y2) > 1e-6:
            j_ok = False
    rec("C04a", "antipode coords negated (k,k+6)", j_ok)
    rec("C04b", "J involution", all(((k + 6) % 12 + 6) % 12 == k for k in by_k))

    # C05 — antipodal relations are exactly the J-pairs (both directions)
    anti = [r for r in relations if r.get("type") == "antipodal"]
    id2k = {n["id"]: n["k"] for n in nodes}
    pair_set = set()
    rel_ok = True
    for r in anti:
        a, b = id2k.get(r.get("from")), id2k.get(r.get("to"))
        if a is None or b is None or (b - a) % 12 != 6:
            rel_ok = False
        else:
            pair_set.add(frozenset((a, b)))
    rec("C05a", "antipodal relations == J-pairs", rel_ok
        and len(pair_set) == 6 and len(anti) == 12,
        f"relations={len(anti)} pairs={len(pair_set)}")
    other = [r for r in relations if r.get("type") != "antipodal"]
    rec("C05b", "no non-antipodal relation types present",
        len(other) == 0, f"other_types={sorted({r.get('type') for r in other})}")

    # C06 — CRT interface: k -> (k%4, k%3) distinct on all 12
    crt_pairs = [(k % 4, k % 3) for k in sorted(by_k)]
    rec("C06", "CRT coords (k%4,k%3) all 12 distinct",
        len(set(crt_pairs)) == 12, f"pairs={crt_pairs[:4]}...")

    # C07 — crossings discipline
    cstatus = crossings.get("status")
    cands = crossings.get("candidates") or []
    if cstatus == "not_annotated" or not cands:
        rec("C07", "crossings unannotated -> vacuous pass", True,
            f"status={cstatus}")
    else:
        node_pts = [node_xy(n) for n in nodes]
        viol = []
        for c in cands:
            pt = (float(c.get("x", "nan")), float(c.get("y", "nan")))
            connected = bool(c.get("connected"))
            coincident = any(
                abs(pt[0] - q[0]) < 1e-6 and abs(pt[1] - q[1]) < 1e-6
                for q in node_pts)
            if coincident and not connected:
                viol.append(c.get("id", pt))
        rec("C07", "crossing candidates distinct from unconnected vertices",
            not viol, f"violations={viol[:3]}")

    # C08 — provenance
    sha = src.get("sha256") or ""
    rec("C08a", "source.sha256 is 64-hex",
        len(sha) == 64 and all(c in "0123456789abcdef" for c in sha.lower()),
        f"sha256={sha[:16]}...")
    rec("C08b", "source.filename recorded",
        bool(src.get("filename")), f"file={src.get('filename')}")
    meta["source"] = src
    meta["coordinate_frame"] = coords
    meta["counts"] = {"nodes": len(nodes), "relations": len(relations),
                      "crossing_candidates": len(cands)}
    return results, meta


def main() -> int:
    path = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_INPUT
    if not path.is_file():
        print(f"ERROR: input not found: {path}", file=sys.stderr)
        return 2
    results, meta = check_artifact(path)
    npass = sum(1 for r in results if r["pass"])
    for r in results:
        print(f"{'PASS' if r['pass'] else 'FAIL'} {r['id']:4} {r['check']}"
              + (f"  — {r['detail']}" if r["detail"] else ""))
    print(f"\n{npass}/{len(results)} checks pass — {path.name}")
    print(json.dumps({"input": meta.get("input"),
                      "counts": meta.get("counts"),
                      "passed": npass, "total": len(results)}, indent=1))
    return 0 if npass == len(results) else 1


if __name__ == "__main__":
    sys.exit(main())

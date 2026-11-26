#!/usr/bin/env python3
"""CP-04 end-to-end fixture generator.

Runs the real merged consumer pipeline and emits a shared fixture that
three independent native implementations must agree on:

    geometry_ir_baseline.z12x
      -> Recursiverse-Suite artifacts/geometry_ir/z12x_reader.py
         (read_geometry_ir + node_envelopes + antipode_envelopes)
      -> artifacts/coordinate_envelope.py::convert (aries_zero -> cancer_zero)
      -> cp04_e2e_fixture.json

Consumers under test (each asserts against this fixture's expected
values):
  - Recursiverse-Suite Python reader/convert (this script IS its run)
  - Machine driver geomframe.rs        (image sector/angle -> machine frame)
  - z12z-Memory-Module coordinate_envelope.rs + provenance.rs

The fixture is byte-identical across repos; each consumer test pins its
SHA-256. Source artifact (the .z12x document) is vendored alongside for
z12z verify_source checks.

Usage: python3 geometry/cp04_e2e_fixture.py [--check]
  default: write geometry/cp04_e2e_fixture.json
  --check: recompute and compare against the committed fixture (exit 1 on drift)
"""
from __future__ import annotations

import hashlib
import importlib.util
import json
import sys
from pathlib import Path

ATLAS = Path(__file__).resolve().parents[1]
REC = Path.home() / "workspace" / "Recursiverse-Suite"
Z12X = REC / "artifacts" / "geometry_ir" / "fixtures" / "geometry_ir_baseline.z12x"
READER = REC / "artifacts" / "geometry_ir" / "z12x_reader.py"
ENVELOPE_PY = REC / "artifacts" / "coordinate_envelope.py"
HUE_JSON = ATLAS / "geometry" / "hue_layer_v1.json"
OUT = ATLAS / "geometry" / "cp04_e2e_fixture.json"

FIXTURE_SCHEMA = "CP04-E2E/1"


def _load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def build_fixture():
    reader = _load("z12x_reader", READER)
    envelope_mod = _load("coordinate_envelope", ENVELOPE_PY)

    z12x_bytes = Z12X.read_bytes()
    doc = reader.read_geometry_ir(z12x_bytes.decode())

    cases = []
    for rec in reader.node_envelopes(doc):
        env = rec["envelope"]
        s = env["value"]
        expected = envelope_mod.convert(env, "cancer_zero")
        cases.append({
            "id": f"GIR-K{s:02d}-node-sector",
            "kind": "canonical_sector",
            "node": f"k{s}",
            "image_sector": s,
            "input": env,
            "expected_cancer": expected,
            "expected_cancer_sector": expected["value"],
            "expected_cancer_fine": None,
        })
    for rec in reader.antipode_envelopes(doc):
        env = rec["envelope"]
        q = env["value"]
        t = q // 12
        expected = envelope_mod.convert(env, "cancer_zero")
        cases.append({
            "id": f"GIR-J{int(rec['relation'][1:]):02d}-antipode-target",
            "kind": "fine_144",
            "relation": rec["relation"],
            "source_node": f"k{(t + 6) % 12}",
            "target_node": rec["target_node"],
            "image_sector": t,
            "input": env,
            "expected_cancer": expected,
            "expected_cancer_sector": expected["value"] // 12,
            "expected_cancer_fine": expected["value"],
        })

    antipodes = [
        {"source": s, "target": (s + 6) % 12}
        for s in range(12)
    ]

    hue = build_hue_section(envelope_mod)

    return {
        "schema": FIXTURE_SCHEMA,
        "generated_by": "geometry/cp04_e2e_fixture.py",
        "sources": {
            "z12x_path": "Recursiverse-Suite/artifacts/geometry_ir/fixtures/geometry_ir_baseline.z12x",
            "z12x_sha256": hashlib.sha256(z12x_bytes).hexdigest(),
            "schema_id": doc["schema"],
            "hue_spec": "geometry/hue_layer_v1.json",
            "hue_spec_sha256": hashlib.sha256(HUE_JSON.read_bytes()).hexdigest(),
        },
        "node_angle_degrees_clockwise_from_top": {f"k{k}": k * 30 for k in range(12)},
        "antipodes": antipodes,
        "cases": cases,
        "hue": hue,
    }


def hue_envelope(k, h, anchor="aries_zero"):
    return {"anchor": anchor, "frame_type": "hue_pair",
            "value": {"k": k, "h": h}}


def build_hue_section(envelope_mod):
    """CP-03 hue layer propagated through the CP-04 interchange.

    ``hue_pair`` frame: ``k`` is the position sector and anchor-converts
    exactly like ``canonical_sector``; ``h`` is the independent hue
    coordinate in Z/12 and is anchor-invariant (the anchors are ecliptic
    position frames; hue has no position anchor). The pair space is the
    product Z/12 x Z/12 — explicitly NOT Z/144 (exponent witness in
    hue_layer_v1.json).

    ``conversion_cases``: all 144 pairs, expected values produced by the
    real ``coordinate_envelope.convert`` (requires the ``hue_pair``
    frame — added in Recursiverse-Suite).
    ``relation_cases``: the hue-layer operators as pure Z/12xZ/12
    algebra, frame-agnostic (anchor shift commutes with every op).
    """
    conversion_cases = []
    for k in range(12):
        for h in range(12):
            env = hue_envelope(k, h)
            expected = envelope_mod.convert(env, "cancer_zero")
            conversion_cases.append({
                "id": f"HUE-K{k:02d}-H{h:02d}",
                "k": k, "h": h,
                "input": env,
                "expected_cancer": expected,
            })

    ops = {
        "position_antipode": lambda k, h: ((k + 6) % 12, h),
        "hue_antipode": lambda k, h: (k, (h + 6) % 12),
        "combined_antipode": lambda k, h: ((k + 6) % 12, (h + 6) % 12),
        "position_successor": lambda k, h: ((k + 1) % 12, h),
        "hue_successor": lambda k, h: (k, (h + 1) % 12),
        "inversion": lambda k, h: ((-k) % 12, (-h) % 12),
        "grayscale_projection": lambda k, h: (k, None),
    }
    relation_cases = []
    for op, fn in ops.items():
        for k in range(12):
            for h in range(12):
                tk, th = fn(k, h)
                relation_cases.append({
                    "id": f"HUE-{op.upper()}-K{k:02d}-H{h:02d}",
                    "op": op, "k": k, "h": h,
                    "target_k": tk, "target_h": th,
                })

    return {
        "spec": "hue-layer/v1",
        "semantics": ("hue_pair envelope {anchor, frame_type, value:{k,h}}; "
                      "k anchor-converts per canonical_sector rules, "
                      "h is anchor-invariant; pair space is Z/12 x Z/12 "
                      "product, not Z/144"),
        "conversion_cases": conversion_cases,
        "relation_cases": relation_cases,
    }


def main():
    fixture = build_fixture()
    payload = json.dumps(fixture, indent=2) + "\n"
    digest = hashlib.sha256(payload.encode()).hexdigest()

    if "--check" in sys.argv:
        if not OUT.exists():
            print(f"FAIL: {OUT} missing")
            return 1
        committed = OUT.read_text()
        if committed != payload:
            print("FAIL: fixture drift — regenerate and re-vendor")
            return 1
        print(f"fixture check: PASS ({len(fixture['cases'])} cases, sha256 {digest})")
        return 0

    OUT.write_text(payload)
    n_sector = sum(1 for c in fixture["cases"] if c["kind"] == "canonical_sector")
    n_fine = len(fixture["cases"]) - n_sector
    print(f"wrote {OUT}")
    print(f"cases: {len(fixture['cases'])} ({n_sector} canonical_sector, {n_fine} fine_144)")
    print(f"z12x sha256: {fixture['sources']['z12x_sha256']}")
    print(f"fixture sha256: {digest}")
    return 0


if __name__ == "__main__":
    sys.exit(main())

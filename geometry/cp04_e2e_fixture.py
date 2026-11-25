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

    return {
        "schema": FIXTURE_SCHEMA,
        "generated_by": "geometry/cp04_e2e_fixture.py",
        "sources": {
            "z12x_path": "Recursiverse-Suite/artifacts/geometry_ir/fixtures/geometry_ir_baseline.z12x",
            "z12x_sha256": hashlib.sha256(z12x_bytes).hexdigest(),
            "schema_id": doc["schema"],
        },
        "node_angle_degrees_clockwise_from_top": {f"k{k}": k * 30 for k in range(12)},
        "antipodes": antipodes,
        "cases": cases,
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

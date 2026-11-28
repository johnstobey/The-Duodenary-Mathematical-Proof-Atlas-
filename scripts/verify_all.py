#!/usr/bin/env python3
"""Executable acceptance layer — run every Atlas verification gate, emit a receipt.

Mirrors .github/workflows/verify.yml plus the local-only checkers, so a
fresh clone can re-verify all committed evidence without trusting any
single reviewer. Writes .lake/verify-all/RECEIPT.json recording git HEAD,
per-gate commands, exit codes, durations and log hashes.

Usage: python3 scripts/verify_all.py [--with-mathlib] [--with-receipts]
       [--only NAME] [--list] [--out DIR]

Exit 0 iff every required gate passes. Advisory gates (live-state or
credential-dependent) report WARN and do not fail the run.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PY = sys.executable


class Gate:
    def __init__(self, name, cmd, cwd=ROOT, required=True, advisory=False,
                 special=None, precondition=None):
        self.name = name
        self.cmd = cmd
        self.cwd = Path(cwd)
        self.required = required and not advisory
        self.advisory = advisory
        self.special = special  # callable(outdir, ctx) -> (rc, note)
        self.precondition = precondition  # callable() -> bool; False => SKIP


def _git(*args):
    return subprocess.run(["git", *args], cwd=ROOT, capture_output=True,
                          text=True).stdout.strip()


def _emit_vectors(outdir, ctx):
    tmp = outdir / "riv-vectors.json"
    r = subprocess.run(["lake", "exe", "emit-vectors", str(tmp)], cwd=ROOT,
                       capture_output=True, text=True)
    if r.returncode != 0:
        return r.returncode, r.stderr[-2000:]
    ref = ROOT / "contracts" / "coordinate_vectors.json"
    same = tmp.read_bytes() == ref.read_bytes()
    return (0 if same else 1), ("byte-identical" if same else "DIFFERS")


def _queue_drift(outdir, ctx):
    """Regenerate QUEUE_STATUS.md, compare to committed, restore."""
    target = ROOT / "roadmap" / "QUEUE_STATUS.md"
    committed = target.read_bytes() if target.exists() else b""
    r = subprocess.run([PY, "scripts/queue_status.py", "--write"], cwd=ROOT,
                       capture_output=True, text=True)
    if r.returncode != 0:
        return r.returncode, r.stderr[-2000:]
    now = target.read_bytes() if target.exists() else b""
    target.write_bytes(committed)  # always restore; drift is the signal
    if now == committed:
        return 0, "snapshot current"
    return 1, "snapshot drift (live issue state changed; cron regenerates)"


def _tree_clean(outdir, ctx):
    """Fail only on modifications the gates introduced (baseline-aware)."""
    now = set(_git("status", "--porcelain").splitlines())
    new = sorted(now - ctx["baseline"])
    return (0 if not new else 1), ("clean" if not new else
                                   "new modifications: " + ",".join(new))


def build_gates(with_mathlib=False, with_receipts=False):
    gates = [
        Gate("reproduce", [PY, "scripts/reproduce.py",
                           "--out", ".lake/verify-all/reproduce"]),
        Gate("emit-vectors", None, special=_emit_vectors),
        Gate("source-integrity", [PY, "scripts/source_integrity.py"]),
        Gate("issue-deps", [PY, "scripts/check_issue_deps.py"], advisory=True),
        Gate("cp05-contrasts", [PY, "engineering/cp05_contrasts.py"]),
        Gate("hue-layer", [PY, "scripts/check_hue_layer.py"]),
        Gate("geometry-ir", [PY, "scripts/check_geometry_ir.py"]),
        Gate("cp04-fixture", [PY, "geometry/cp04_e2e_fixture.py", "--check"],
             precondition=lambda: (Path.home() / "workspace" /
                                   "Recursiverse-Suite").is_dir()),
        Gate("queue-drift", None, special=_queue_drift, advisory=True),
        Gate("tree-clean", None, special=_tree_clean),
    ]
    if with_mathlib:
        gates.insert(2, Gate(
            "mathlib-bridge",
            ["sh", "-c",
             "cd closed_ring_z12_mathlib && lake update && "
             "lake exe cache get && lake build && "
             "for f in VerifyAxioms VerifyC12 VerifyTransport VerifyPairSpace; "
             "do lake env lean $f.lean | tee /tmp/vf-$f.log; "
             "! grep -q sorryAx /tmp/vf-$f.log || exit 1; done"]))
    if with_receipts:
        gates.append(Gate("cross-repo-receipts",
                          [PY, "scripts/cross_repo_status.py"], advisory=True))
    return gates


def run_gate(g, outdir, ctx):
    log = outdir / f"{g.name}.log"
    t0 = time.time()
    if g.precondition is not None and not g.precondition():
        log.write_text("skipped: precondition unmet\n")
        return {"name": g.name, "command": g.cmd if g.cmd else
                g.special.__name__, "cwd": str(g.cwd),
                "required": g.required, "advisory": g.advisory,
                "returncode": 0, "note": "SKIPPED (dependency absent)",
                "skipped": True, "seconds": 0.0, "log": log.name,
                "log_sha256": hashlib.sha256(log.read_bytes()).hexdigest()}
    if g.special:
        rc, note = g.special(outdir, ctx)
        log.write_text(f"special gate: rc={rc} note={note}\n")
    else:
        with log.open("w") as stream:
            r = subprocess.run(g.cmd, cwd=g.cwd, stdout=stream,
                               stderr=subprocess.STDOUT)
        rc, note = r.returncode, " ".join(g.cmd)
    return {"name": g.name, "command": g.cmd if g.cmd else g.special.__name__,
            "cwd": str(g.cwd), "required": g.required, "advisory": g.advisory,
            "returncode": rc, "note": note,
            "seconds": round(time.time() - t0, 2),
            "log": log.name,
            "log_sha256": hashlib.sha256(log.read_bytes()).hexdigest()}


def _have(cmd):
    import shutil
    return shutil.which(cmd) is not None


def _gh_login():
    r = subprocess.run(["gh", "api", "user", "--jq", ".login"],
                       capture_output=True, text=True)
    return r.stdout.strip() if r.returncode == 0 else None


def preflight(gates):
    """Report which gates this environment can run, without running them."""
    probes = {
        "python3": _have("python3"),
        "lake": _have("lake"),
        "gh": _have("gh"),
        "git-repo": (ROOT / ".git").exists(),
        "jsonschema": True,
        "recursiverse": (Path.home() / "workspace" /
                         "Recursiverse-Suite").is_dir(),
        "gh-login": _gh_login(),
    }
    try:
        import jsonschema  # noqa: F401
    except ImportError:
        probes["jsonschema"] = False

    needs = {
        "reproduce": ["lake", "jsonschema"],
        "emit-vectors": ["lake"],
        "source-integrity": ["python3"],
        "issue-deps": ["gh", "gh-login"],
        "cp05-contrasts": ["python3"],
        "hue-layer": ["python3"],
        "geometry-ir": ["python3"],
        "cp04-fixture": ["python3", "recursiverse"],
        "queue-drift": ["gh", "gh-login"],
        "cross-repo-receipts": ["gh", "gh-login"],
        "tree-clean": ["git-repo"],
        "mathlib-bridge": ["lake"],
    }
    rows = []
    for g in gates:
        missing = [n for n in needs.get(g.name, [])
                   if probes.get(n) in (False, None)]
        if g.precondition is not None and not g.precondition():
            missing.append("precondition")
        state = "READY" if not missing else "UNAVAILABLE"
        detail = ("missing: " + ",".join(missing)) if missing else "ok"
        if g.name == "mathlib-bridge":
            detail += " (also needs network for mathlib cache)"
        rows.append((g.name, "ADV" if g.advisory else "REQ", state, detail))

    print(f"{'gate':22} {'kind':4} {'state':12} detail")
    for name, kind, state, detail in rows:
        print(f"{name:22} {kind:4} {state:12} {detail}")
    blocked = [n for n, k, s, _ in rows if s == "UNAVAILABLE" and k == "REQ"]
    print(f"\nprobes: lake={'ok' if probes['lake'] else 'MISSING'} "
          f"gh={'ok' if probes['gh'] else 'MISSING'} "
          f"gh-login={probes['gh-login'] or 'none'} "
          f"recursiverse={'ok' if probes['recursiverse'] else 'absent'} "
          f"jsonschema={'ok' if probes['jsonschema'] else 'MISSING'}")
    if blocked:
        print(f"required gates unavailable here: {', '.join(blocked)}",
              file=sys.stderr)
        return 1
    return 0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--with-mathlib", action="store_true",
                    help="include heavy mathlib-bridge package checks")
    ap.add_argument("--with-receipts", action="store_true",
                    help="include cross-repo consumer receipts (advisory)")
    ap.add_argument("--only", help="run a single gate by name")
    ap.add_argument("--list", action="store_true")
    ap.add_argument("--preflight", action="store_true",
                    help="report which gates this environment can run")
    ap.add_argument("--out", type=Path, default=ROOT / ".lake/verify-all")
    args = ap.parse_args()

    gates = build_gates(args.with_mathlib, args.with_receipts)
    if args.preflight:
        return preflight(gates)
    if args.list:
        for g in gates:
            print(f"{'REQ' if g.required else 'ADV'} {g.name}")
        return 0
    if args.only:
        gates = [g for g in gates if g.name == args.only]
        if not gates:
            print(f"unknown gate: {args.only}", file=sys.stderr)
            return 2

    args.out.mkdir(parents=True, exist_ok=True)
    ctx = {"baseline": set(_git("status", "--porcelain").splitlines())}
    rows = [run_gate(g, args.out, ctx) for g in gates]

    required_fail = [r for r in rows if r["required"] and r["returncode"] != 0]
    advisory_fail = [r for r in rows if r["advisory"] and r["returncode"] != 0]
    status = "PASS" if not required_fail else "FAILED"

    receipt = {
        "schema": "atlas-verify-all/v1",
        "status": status,
        "warnings": [r["name"] for r in advisory_fail],
        "git": {"head": _git("rev-parse", "HEAD"),
                "branch": _git("rev-parse", "--abbrev-ref", "HEAD"),
                "dirty": bool(_git("status", "--porcelain"))},
        "started_at": datetime.now(timezone.utc).isoformat(),
        "gates": rows,
        "scope": ("local executable verification of committed evidence; "
                  "not a substitute for owner review or external audit"),
    }
    (args.out / "RECEIPT.json").write_text(json.dumps(receipt, indent=2) + "\n")

    for r in rows:
        tag = ("SKIP" if r.get("skipped") else
               "PASS" if r["returncode"] == 0 else
               "WARN" if r["advisory"] else "FAIL")
        print(f"{tag} {r['name']:22} rc={r['returncode']} "
              f"{r['seconds']}s {r.get('note', '')}")
    print(f"\n{status} — receipt: {args.out / 'RECEIPT.json'}")
    return 0 if status == "PASS" else 1


if __name__ == "__main__":
    sys.exit(main())

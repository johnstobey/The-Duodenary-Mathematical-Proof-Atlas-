#!/usr/bin/env python3
"""Interchange end-to-end chain (CP-04): emit -> sign -> verify -> consume.

Runs the full production path the adoption audit wired, as one receipt-
linked pipeline:

  L1  Recursiverse ``envelope_emit.py``  : z12x doc -> geometry-ir-envelopes/1
  L2  z12z ``prov-sign``                 : envelope + source -> Z12MEM-PROVENANCE/1
  L3  z12z ``prov-verify``               : record + source -> VERIFIED/REJECTED
  L4  Machine ``coord-house``            : envelope -> coord-house/1 receipt

Coverage: every envelope the emitter produces for the pinned z12x fixture
(24: 12 node canonical_sector + 12 antipode fine_144), plus every hue_pair
conversion case in the Atlas CP04-E2E fixture (144) — the complete
interchange surface for all three fixture-validated frame types.

The hue envelopes derive from ``geometry/hue_layer_v1.json`` (Atlas spec),
not z12x, so they are signed against that spec file; the z12x envelopes
are signed against the z12x document itself. A tamper leg verifies one
record against the wrong source and must come back REJECTED.

Rust legs execute on the mini build host over ssh (project rule: write on
dell, build on mini). The whole remote side is one staged directory and
one ``run.sh`` — a single ssh round-trip for compute.

Usage::

    python3 scripts/interchange_e2e.py [--check engineering/interchange_e2e_results.json]

Exit 0 = chain verified (or --check matched); 1 = verification failure or
--check drift; 2 = usage/prerequisite error.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WORKSPACE = Path.home() / "workspace"
RECURSIVERSE = WORKSPACE / "Recursiverse-Suite"
Z12X_DOC = (RECURSIVERSE / "artifacts" / "geometry_ir" / "fixtures" /
            "geometry_ir_baseline.z12x")
EMIT = RECURSIVERSE / "artifacts" / "geometry_ir" / "envelope_emit.py"
FIXTURE = ROOT / "geometry" / "cp04_e2e_fixture.json"
HUE_SPEC = ROOT / "geometry" / "hue_layer_v1.json"
SNAPSHOT = ROOT / "engineering" / "interchange_e2e_results.json"

SSH_HOST = "mini"
# Binary paths on the build host (debug builds; release may differ).
# $HOME (not ~) so the paths expand inside the generated run.sh quotes.
Z12MEM_BIN = "$HOME/builds/z12mem/target/debug/z12mem"
MACHINE_BIN = "$HOME/builds/machine-driver/driver/target/debug/tobey_recursive"
REMOTE_DIR = "/tmp/atlas-interchange-e2e"
# Pinned signing timestamp — determinism requires the module never read a
# clock, so the caller supplies it. Fixed value keeps receipts reproducible.
DEFAULT_AT = 1764000000


def sha256(b: bytes) -> str:
    return hashlib.sha256(b).hexdigest()


def run(cmd, **kw):
    return subprocess.run(cmd, capture_output=True, text=True, **kw)


def die(msg):
    print(f"interchange_e2e: {msg}", file=sys.stderr)
    sys.exit(2)


def prereqs(args):
    missing = []
    if not (RECURSIVERSE / "artifacts" / "geometry_ir").is_dir():
        missing.append(f"Recursiverse sibling checkout at {RECURSIVERSE}")
    if not Z12X_DOC.is_file():
        missing.append(f"z12x fixture doc {Z12X_DOC}")
    if not EMIT.is_file():
        missing.append(f"emitter {EMIT}")
    if not FIXTURE.is_file():
        missing.append(f"Atlas fixture {FIXTURE}")
    if not HUE_SPEC.is_file():
        missing.append(f"hue spec {HUE_SPEC}")
    if missing:
        die("missing prerequisites:\n  - " + "\n  - ".join(missing))
    probe = run(["ssh", args.ssh_host,
                 f"test -x {Z12MEM_BIN} && test -x {MACHINE_BIN} && echo OK"])
    if probe.returncode != 0 or "OK" not in probe.stdout:
        die(f"remote binaries unreachable on {args.ssh_host}:\n"
            f"{probe.stderr.strip() or probe.stdout.strip()}\n"
            f"expected {Z12MEM_BIN} and {MACHINE_BIN}")


def git_head(path):
    r = run(["git", "-C", str(path), "rev-parse", "HEAD"])
    return r.stdout.strip() if r.returncode == 0 else None


def stage_remote(work: Path, emit_artifact: dict, z12x_bytes: bytes,
                  fixture: dict, at: int):
    """Lay out the remote workdir: envs/, sources, run.sh."""
    remote = work / "remote"
    (remote / "envs" / "z12x").mkdir(parents=True, exist_ok=True)
    (remote / "envs" / "hue").mkdir(parents=True, exist_ok=True)
    (remote / "src").mkdir(parents=True, exist_ok=True)
    (remote / "out").mkdir(parents=True, exist_ok=True)

    manifest = {"z12x": [], "hue": []}
    for env in emit_artifact["envelopes"]:
        eid = env["id"]
        (remote / "envs" / "z12x" / f"{eid}.json").write_text(
            json.dumps(env["input"], indent=2) + "\n")
        manifest["z12x"].append(eid)
    for case in fixture["hue"]["conversion_cases"]:
        cid = case["id"]
        (remote / "envs" / "hue" / f"{cid}.json").write_text(
            json.dumps(case["input"], indent=2) + "\n")
        manifest["hue"].append(cid)

    (remote / "src" / "source.z12x").write_bytes(z12x_bytes)
    (remote / "src" / "hue_layer_v1.json").write_bytes(HUE_SPEC.read_bytes())
    # Wrong-source for the tamper leg: the emit artifact itself.
    (remote / "src" / "wrong_source.json").write_text(
        json.dumps(emit_artifact, indent=2) + "\n")
    (remote / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")

    run_sh = f"""#!/usr/bin/env bash
# Generated by scripts/interchange_e2e.py — do not edit.
set -u
Z12="{Z12MEM_BIN}"
MACH="{MACHINE_BIN}"
AT="{at}"
cd "$(dirname "$0")"

run_one() {{
  local envfile="$1" src="$2" srcid="$3"
  local id; id=$(basename "$envfile" .json)
  local d="out/$id"; mkdir -p "$d"
  "$Z12" prov-sign "$envfile" --source "$src" --source-id "$srcid" \\
      --at "$AT" > "$d/record.json" 2> "$d/sign.err"
  echo $? > "$d/sign.rc"
  "$Z12" prov-verify "$d/record.json" --source "$src" \\
      > "$d/verify.txt" 2> "$d/verify.err"
  echo $? > "$d/verify.rc"
  "$MACH" coord-house "$envfile" > "$d/house.json" 2> "$d/house.err"
  echo $? > "$d/house.rc"
}}

for f in envs/z12x/*.json; do
  run_one "$f" src/source.z12x geometry_ir_baseline.z12x
done
for f in envs/hue/*.json; do
  run_one "$f" src/hue_layer_v1.json hue_layer_v1.json
done

# Tamper leg: first z12x record verified against the wrong source must
# come back REJECTED (exit 1), proving prov-verify is not vacuous.
first=$(ls envs/z12x/*.json | head -1)
tid=$(basename "$first" .json)
"$Z12" prov-verify "out/$tid/record.json" --source src/wrong_source.json \\
    > out/tamper_verify.txt 2> out/tamper_verify.err
echo $? > out/tamper_verify.rc
"""
    (remote / "run.sh").write_text(run_sh)
    return remote


def sync_and_run(remote: Path, host: str):
    # Ship the staged dir, run it, pull outputs back. Clear the remote
    # dir first so scp lands contents at REMOTE_DIR/* (not nested).
    run(["ssh", host, f"rm -rf {REMOTE_DIR}"])
    r = run(["scp", "-q", "-r", str(remote), f"{host}:{REMOTE_DIR}"])
    if r.returncode != 0:
        die(f"scp to {host} failed: {r.stderr.strip()}")
    r = run(["ssh", host, f"bash {REMOTE_DIR}/run.sh"])
    if r.returncode != 0:
        die(f"remote run.sh failed rc={r.returncode}: {r.stderr.strip()}")
    out_local = remote / "results"
    out_local.mkdir(exist_ok=True)
    r = run(["scp", "-q", "-r", f"{host}:{REMOTE_DIR}/out", str(out_local)])
    if r.returncode != 0:
        die(f"scp back from {host} failed: {r.stderr.strip()}")
    run(["ssh", host, f"rm -rf {REMOTE_DIR}"])
    return out_local / "out"


def collect(work: Path, emit_artifact: dict, outdir: Path):
    """Parse remote outputs into per-envelope result entries."""
    results = []
    failures = []
    groups = {"z12x": [], "hue": []}
    for env in emit_artifact["envelopes"]:
        groups["z12x"].append((env["id"], env["input"]["frame_type"]))
    fixture = json.loads(FIXTURE.read_text())
    for case in fixture["hue"]["conversion_cases"]:
        groups["hue"].append((case["id"], case["input"]["frame_type"]))

    for group, entries in groups.items():
        for eid, kind in entries:
            d = outdir / eid
            entry = {"id": eid, "group": group, "frame": kind}
            ok = True
            for leg, rc_name, expect in (
                    ("sign", "sign.rc", 0),
                    ("verify", "verify.rc", 0),
                    ("house", "house.rc", 0)):
                rc_file = d / rc_name
                rc = int(rc_file.read_text().strip()) if rc_file.is_file() else -1
                entry[f"{leg}_rc"] = rc
                if rc != expect:
                    ok = False
                    err = d / f"{leg}.err"
                    failures.append(
                        f"{eid}/{leg} rc={rc}: "
                        f"{err.read_text().strip()[:200] if err.is_file() else ''}")
            entry["verify_verdict"] = (
                (d / "verify.txt").read_text().strip()
                if (d / "verify.txt").is_file() else None)
            for fname, key in (("record.json", "record_sha256"),
                               ("house.json", "house_sha256")):
                p = d / fname
                entry[key] = sha256(p.read_bytes()) if p.is_file() else None
            env_file = (work / "remote" / "envs" / group / f"{eid}.json")
            entry["input_sha256"] = (
                sha256(env_file.read_bytes()) if env_file.is_file() else None)
            if (d / "house.json").is_file():
                try:
                    house = json.loads((d / "house.json").read_text())
                    entry["sign_house"] = house.get("houses", {}).get(
                        "sign_house")
                    entry["machine_sector"] = house.get("machine", {}).get(
                        "sector")
                except json.JSONDecodeError:
                    pass
            entry["ok"] = ok
            results.append(entry)

    tamper_rc_file = outdir / "tamper_verify.rc"
    tamper_rc = (int(tamper_rc_file.read_text().strip())
                 if tamper_rc_file.is_file() else -1)
    tamper_txt = ((outdir / "tamper_verify.txt").read_text().strip()
                  if (outdir / "tamper_verify.txt").is_file() else "")
    tamper_ok = tamper_rc == 1 and "REJECTED" in tamper_txt
    if not tamper_ok:
        failures.append(f"tamper leg rc={tamper_rc} verdict={tamper_txt!r}")
    return results, {"rc": tamper_rc, "verdict": tamper_txt,
                     "ok": tamper_ok}, failures


def environment_block(host):
    env = {"ssh_host": host,
           "z12mem_bin": Z12MEM_BIN, "machine_bin": MACHINE_BIN,
           "atlas_head": git_head(ROOT),
           "recursiverse_head": git_head(RECURSIVERSE)}
    for name, path in (("z12mem", Z12MEM_BIN), ("tobey_recursive", MACHINE_BIN)):
        r = run(["ssh", host, f"sha256sum {path} | cut -d' ' -f1"])
        env[f"{name}_sha256"] = r.stdout.strip() if r.returncode == 0 else None
    return env


def build_receipt(work, emit_artifact, results, tamper, env, args):
    n_ok = sum(1 for r in results if r["ok"])
    return {
        "schema": "interchange-e2e/1",
        "generated_by": "scripts/interchange_e2e.py",
        "sources": {
            "z12x": {"path": str(Z12X_DOC),
                     "sha256": emit_artifact["source"]["sha256"]},
            "hue_spec": {"path": str(HUE_SPEC),
                         "sha256": sha256(HUE_SPEC.read_bytes())},
        },
        "parameters": {"at": args.at, "ssh_host": args.ssh_host},
        "environment": env,
        "emit": {"envelopes": len(emit_artifact["envelopes"]),
                 "artifact_sha256": sha256(
                     (work / "envelopes_emit.json").read_bytes())},
        "coverage": {"z12x_envelopes": sum(
                          1 for r in results if r["group"] == "z12x"),
                     "hue_pairs": sum(
                         1 for r in results if r["group"] == "hue")},
        "tamper_leg": tamper,
        "results": results,
        "summary": {"envelopes": len(results), "ok": n_ok,
                    "failed": len(results) - n_ok,
                    "all_ok": n_ok == len(results) and tamper["ok"]},
    }


def check_drift(fresh, snapshot_path):
    snap = json.loads(Path(snapshot_path).read_text())

    def norm_sources(rcpt):
        # Paths are machine-local; the sha256 pins are the invariant.
        return {k: v.get("sha256") for k, v in
                rcpt.get("sources", {}).items()}

    diffs = []
    for key in ("emit", "coverage", "tamper_leg", "results"):
        if fresh.get(key) != snap.get(key):
            diffs.append(key)
    if norm_sources(fresh) != norm_sources(snap):
        diffs.append("sources")
    if fresh["summary"] != snap["summary"]:
        diffs.append("summary")
    return diffs


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--workdir", default=str(ROOT / ".lake" / "interchange-e2e"))
    ap.add_argument("--out", default=None,
                    help="receipt path (default <workdir>/RECEIPT.json)")
    ap.add_argument("--at", type=int, default=DEFAULT_AT,
                    help="signing timestamp pinned into provenance records")
    ap.add_argument("--ssh-host", default=SSH_HOST)
    ap.add_argument("--check", metavar="SNAPSHOT",
                    help="after running, diff deterministic results vs snapshot")
    args = ap.parse_args()

    prereqs(args)
    work = Path(args.workdir)
    work.mkdir(parents=True, exist_ok=True)

    # L1: emit (local, Recursiverse).
    z12x_bytes = Z12X_DOC.read_bytes()
    emit_out = work / "envelopes_emit.json"
    r = run([sys.executable, str(EMIT), str(Z12X_DOC), "--out", str(emit_out)])
    if r.returncode != 0:
        die(f"envelope_emit failed rc={r.returncode}: {r.stderr.strip()}")
    emit_artifact = json.loads(emit_out.read_text())

    # Stage + run remote legs (L2 sign, L3 verify, L4 consume, tamper).
    remote = stage_remote(work, emit_artifact, z12x_bytes,
                          json.loads(FIXTURE.read_text()), args.at)
    outdir = sync_and_run(remote, args.ssh_host)

    results, tamper, failures = collect(work, emit_artifact, outdir)
    env = environment_block(args.ssh_host)
    receipt = build_receipt(work, emit_artifact, results, tamper, env, args)

    out_path = Path(args.out) if args.out else work / "RECEIPT.json"
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(receipt, indent=2) + "\n")

    s = receipt["summary"]
    print(f"interchange-e2e: {s['ok']}/{s['envelopes']} envelopes ok, "
          f"tamper={'REJECTED' if tamper['ok'] else 'FAILED'} "
          f"({tamper['verdict']})")
    for f in failures[:10]:
        print(f"  FAIL {f}", file=sys.stderr)
    if failures:
        sys.exit(1)
    if args.check:
        diffs = check_drift(receipt, args.check)
        if diffs:
            print(f"DRIFT vs {args.check}: {', '.join(diffs)}", file=sys.stderr)
            sys.exit(1)
        print(f"check: matches {args.check}")
    print(f"receipt: {out_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())

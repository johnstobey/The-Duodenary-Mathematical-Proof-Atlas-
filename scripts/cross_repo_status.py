#!/usr/bin/env python3
# tier: T2
"""Cross-repo consumer-receipt verification for the Atlas ledger (CP-06).

Verifies every receipt in ``roadmap/consumer_receipts.json`` live via
``gh``: PR receipts must be MERGED; commit receipts must resolve. Drift
(reopened/unmerged PRs, missing SHAs, unreachable repos) is reported —
never silently assumed.

Usage:
  python3 scripts/cross_repo_status.py            # markdown to stdout
  python3 scripts/cross_repo_status.py --write    # rewrite roadmap/CROSS_REPO_STATUS.md
  python3 scripts/cross_repo_status.py --json     # machine-readable
  python3 scripts/cross_repo_status.py --strict   # exit 1 on any drift

Env: GH_TOKEN or GITHUB_TOKEN must permit read access to the consumer
repos (all are under the same token scope as Atlas).
"""
from __future__ import annotations

import argparse
import json
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RECEIPTS = ROOT / "roadmap" / "consumer_receipts.json"
OUT = ROOT / "roadmap" / "CROSS_REPO_STATUS.md"


def sh(args: list[str]) -> str:
    proc = subprocess.run(args, capture_output=True, text=True)
    if proc.returncode != 0:
        raise RuntimeError(f"{' '.join(args)} failed: {proc.stderr.strip()}")
    return proc.stdout


def verify(receipt: dict) -> dict:
    """Return receipt + live state. Never raises on drift — reports it."""
    r = dict(receipt)
    repo, ref = receipt["repo"], receipt["ref"]
    try:
        if ref.startswith("PR#"):
            num = ref[3:]
            info = json.loads(sh([
                "gh", "pr", "view", num, "-R", repo,
                "--json", "number,state,mergedAt,mergeCommit,headRefName",
            ]))
            r["live_state"] = info["state"]
            r["merged_at"] = info.get("mergedAt") or ""
            r["merge_sha"] = (info.get("mergeCommit") or {}).get("oid", "")[:12]
            ok = info["state"] == "MERGED"
            r["status"] = "OK" if ok else "DRIFT"
            if not ok:
                r["drift"] = f"PR state is {info['state']}, expected MERGED"
        elif ref.startswith("commit:"):
            sha = ref.split(":", 1)[1]
            sh(["gh", "api", f"repos/{repo}/commits/{sha}", "-q", ".sha"])
            r["live_state"] = "PRESENT"
            r["status"] = "OK"
        else:
            r["status"] = "BADREF"
            r["drift"] = f"unrecognized ref {ref}"
    except RuntimeError as e:
        r["status"] = "UNREACHABLE"
        r["drift"] = str(e)[:160]
    return r


def build() -> list[dict]:
    receipts = json.loads(RECEIPTS.read_text())["receipts"]
    return [verify(r) for r in receipts]


def render_md(rows: list[dict]) -> str:
    now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    ok = sum(1 for r in rows if r["status"] == "OK")
    drift = [r for r in rows if r["status"] != "OK"]
    lines = [
        "# Cross-repo consumer receipts — generated snapshot",
        "",
        f"Generated: {now} by `scripts/cross_repo_status.py` — do not edit by hand;",
        "regenerate with `python3 scripts/cross_repo_status.py --write`.",
        "Receipts: `roadmap/consumer_receipts.json` · verified live via `gh`.",
        "",
        f"Receipts: {len(rows)} · OK: {ok} · drift/unreachable: {len(drift)}",
        "",
        "| Atlas issue | CP | Consumer | Repo | Ref | Live state | Status | Note |",
        "|---|---|---|---|---|---|---|---|",
    ]
    for r in rows:
        repo = r["repo"].split("/")[-1]
        note = r.get("note", "").replace("|", "\\|")[:60]
        status = r["status"]
        if status != "OK":
            status += f" ({r.get('drift', '')[:60]})"
        lines.append(
            f"| #{r['atlas_issue']} | {r['cp']} | {r['consumer']} | {repo} "
            f"| {r['ref']} | {r.get('live_state', '?')} | {status} | {note} |")
    lines += [
        "",
        "## Reading",
        "",
        "- `OK` = receipt verified live this run (PR MERGED / commit present).",
        "- `DRIFT` = the consumer-side claim no longer holds (PR reopened/",
        "  unmerged, force-push removed the merge). `UNREACHABLE` = repo or",
        "  token cannot be read — treated as unverified, not failed.",
        "- This ledger tracks *receipts*, not scientific truth; Atlas issues",
        "  remain the canonical task queue (CP-06).",
        "",
    ]
    return "\n".join(lines)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--write", action="store_true")
    ap.add_argument("--json", action="store_true")
    ap.add_argument("--strict", action="store_true")
    args = ap.parse_args()

    try:
        rows = build()
    except RuntimeError as e:
        print(f"cross_repo_status: tooling error — {e}", file=sys.stderr)
        return 2

    drift = [r for r in rows if r["status"] != "OK"]
    if args.json:
        print(json.dumps({"receipts": rows, "drift": len(drift)}, indent=2))
    else:
        md = render_md(rows)
        if args.write:
            OUT.write_text(md)
            print(f"wrote {OUT}")
        else:
            print(md)
    return 1 if (args.strict and drift) else 0


if __name__ == "__main__":
    sys.exit(main())

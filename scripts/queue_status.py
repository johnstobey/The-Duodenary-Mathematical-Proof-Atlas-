#!/usr/bin/env python3
"""Canonical queue-status snapshot for the Atlas issue ledger (CP-06).

Generates the live critical-path index: every issue's state, activity
status, and resolved dependency edges — the data the static
roadmap/CRITICAL_PATH_2026-11-22.md issue table cannot keep current.

Reuses check_issue_deps.py's dep parsing and activity detection so the
snapshot and the CI gate can never disagree about what "blocked" means.

Usage:
  python3 scripts/queue_status.py            # markdown to stdout
  python3 scripts/queue_status.py --write    # rewrite roadmap/QUEUE_STATUS.md
  python3 scripts/queue_status.py --json     # machine-readable

Env: GH_TOKEN or GITHUB_TOKEN must permit `issues: read`.
"""
from __future__ import annotations

import argparse
import json
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import check_issue_deps as deps_mod

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "roadmap" / "QUEUE_STATUS.md"


def sh(args: list[str]) -> str:
    proc = subprocess.run(args, capture_output=True, text=True)
    if proc.returncode != 0:
        raise RuntimeError(f"{' '.join(args)} failed: {proc.stderr.strip()}")
    return proc.stdout


def fetch_issues(repo: str) -> list[dict]:
    raw = sh([
        "gh", "issue", "list", "-R", repo, "--state", "all",
        "--limit", "100",
        "--json", "number,title,state,body,assignees,comments,updatedAt",
    ])
    return json.loads(raw)


def dep_state(d: dict, issues: dict[int, dict]) -> str:
    tgt = issues.get(d["issue"])
    if tgt is None:
        return "MISSING"
    return tgt["state"] + (" (soft)" if d["soft"] else "")


def build_rows(repo: str) -> tuple[list[dict], dict[str, int]]:
    cp_map = deps_mod.load_cp_map()
    issues = {i["number"]: i for i in fetch_issues(repo)}
    rows = []
    for num in sorted(issues):
        iss = issues[num]
        deps = [d for d in deps_mod.parse_deps(iss.get("body") or "", cp_map)
                if d["issue"] != num]
        merged: dict[int, dict] = {}
        for d in deps:
            cur = merged.get(d["issue"])
            if cur is None or (cur["soft"] and not d["soft"]):
                merged[d["issue"]] = d
        active, why = deps_mod.is_active(iss)
        open_hard = [d for d in merged.values()
                     if not d["soft"]
                     and issues.get(d["issue"], {}).get("state") == "OPEN"]
        rows.append({
            "issue": num,
            "cp": next((k for k, v in cp_map.items() if v == num), "-"),
            "title": iss["title"],
            "state": iss["state"],
            "active": active,
            "active_reason": why,
            "deps": [f"{d['ref']}→{dep_state(d, issues)}" for d in sorted(merged.values(), key=lambda x: x['issue'] or 0)],
            "blocked": bool(iss["state"] == "OPEN" and open_hard),
            "updated": iss.get("updatedAt", ""),
        })
    return rows, cp_map


def render_md(rows: list[dict], repo: str, cp_map: dict[str, int]) -> str:
    now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    open_rows = [r for r in rows if r["state"] == "OPEN"]
    closed = len(rows) - len(open_rows)
    lines = [
        "# Atlas queue status — generated snapshot",
        "",
        f"Generated: {now} by `scripts/queue_status.py` — do not edit by hand;",
        "regenerate with `python3 scripts/queue_status.py --write`.",
        "States follow the CP-06 protocol (OPEN→CLAIMED→IN PROGRESS→VERIFY→ACCEPTED);",
        "dependency edges parsed by `scripts/check_issue_deps.py` (same rules as CI).",
        "",
        f"Repo: `{repo}` · open: {len(open_rows)} · closed: {closed}",
        "",
        "| Issue | CP | State | Active | Blocked by open hard deps | Deps | Title |",
        "|---|---|---|---|---|---|---|",
    ]
    for r in rows:
        flag = "ACTIVE" if r["active"] else ("idle" if r["state"] == "OPEN" else "—")
        blocked = "YES" if r["blocked"] else ""
        deps = "; ".join(r["deps"]) or "—"
        title = r["title"].replace("|", "\\|")[:70]
        lines.append(f"| #{r['issue']} | {r['cp']} | {r['state']} | {flag} | {blocked} | {deps} | {title} |")
    lines += [
        "",
        "## Reading",
        "",
        "- `ACTIVE` = assigned or latest protocol comment says CLAIMED/IN PROGRESS/VERIFY.",
        "- `Blocked` counts only OPEN hard dependencies (soft edges never block).",
        "- Closed rows are retained for history; acceptance is the owner's call.",
        "",
    ]
    return "\n".join(lines)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", default="johnstobey/The-Duodenary-Mathematical-Proof-Atlas-")
    ap.add_argument("--write", action="store_true")
    ap.add_argument("--json", action="store_true")
    args = ap.parse_args()

    try:
        rows, cp_map = build_rows(args.repo)
    except RuntimeError as e:
        print(f"queue_status: tooling error — {e}", file=sys.stderr)
        return 2

    if args.json:
        print(json.dumps({"repo": args.repo, "rows": rows}, indent=2))
        return 0

    md = render_md(rows, args.repo, cp_map)
    if args.write:
        OUT.write_text(md)
        print(f"wrote {OUT}")
    else:
        print(md)
    return 0


if __name__ == "__main__":
    sys.exit(main())

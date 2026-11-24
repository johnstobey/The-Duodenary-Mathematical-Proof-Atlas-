#!/usr/bin/env python3
"""Unresolved-dependency check for the Atlas GitHub-Issue task queue (CP-06).

Parses declared dependency edges from open issue bodies (`#N` refs and
`CP-NN` tokens mapped through roadmap/CRITICAL_PATH_2026-11-22.md),
queries live issue states, and reports issues that are CLAIMED-or-later
while a hard blocker remains OPEN.

State detection (v1, comment-protocol convention — no status labels exist):
  - assigned  -> active
  - latest protocol comment containing CLAIMED / IN PROGRESS / VERIFY
    (case-insensitive, word-boundary) -> active
Soft/conditional edges ("optional", "if", "only if", "unless", "where",
"when") are reported but never fail the check.

Exit codes: 0 = no violations, 1 = violations found, 2 = tooling error.

Usage:
  python3 scripts/check_issue_deps.py [--repo OWNER/NAME] [--json]
Env: GH_TOKEN or GITHUB_TOKEN must permit `issues: read`.
"""
from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CP_DOC = ROOT / "roadmap" / "CRITICAL_PATH_2026-11-22.md"

SOFT_MARKERS = (
    "optional", "if ", "only if", "unless", "where ", "when ",
    "not a prerequisite", "remains optional", "where color",
)
ACTIVE_RE = re.compile(
    r"\b(CLAIMED|IN PROGRESS|VERIFY|ACCEPTED)\b", re.IGNORECASE
)
CP_MAP_RE = re.compile(r"CP-(\d+)\s*#(\d+)")
REF_RE = re.compile(r"#(\d+)\b|CP-(\d+)\b")


def sh(args: list[str]) -> str:
    proc = subprocess.run(args, capture_output=True, text=True)
    if proc.returncode != 0:
        raise RuntimeError(f"{' '.join(args)} failed: {proc.stderr.strip()}")
    return proc.stdout


def load_cp_map() -> dict[str, int]:
    """CP-NN -> issue number, from the canonical critical-path doc."""
    if not CP_DOC.is_file():
        return {}
    out: dict[str, int] = {}
    for cp, num in CP_MAP_RE.findall(CP_DOC.read_text()):
        out[f"CP-{cp.zfill(2)}"] = int(num)
    return out


def clause_around(text: str, start: int, end: int) -> str:
    """Over-approximate the clause containing [start,end) by sentence split."""
    left = max(text.rfind(".", 0, start), text.rfind("\n", 0, start)) + 1
    rights = [i for i in (text.find(".", end), text.find("\n", end)) if i != -1]
    right = min(rights) if rights else len(text)
    return text[left:right].lower()


def parse_deps(body: str, cp_map: dict[str, int]) -> list[dict]:
    deps = []
    for m in REF_RE.finditer(body):
        if m.group(1):
            num, label = int(m.group(1)), f"#{m.group(1)}"
        else:
            label = f"CP-{m.group(2).zfill(2)}"
            num = cp_map.get(label)
            if num is None:
                continue
        clause = clause_around(body, m.start(), m.end())
        soft = any(s in clause for s in SOFT_MARKERS)
        deps.append({"ref": label, "issue": num, "soft": soft,
                     "clause": clause.strip()[:160]})
    return deps


def is_active(issue: dict) -> tuple[bool, str]:
    if issue.get("assignees"):
        return True, "assigned:" + ",".join(a["login"] for a in issue["assignees"])
    comments = issue.get("comments") or []
    for c in reversed(comments):
        body = c.get("body", "")
        if ACTIVE_RE.search(body):
            return True, f"comment:{c.get('author',{}).get('login','?')}"
    return False, "open-unclaimed"


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", default="johnstobey/The-Duodenary-Mathematical-Proof-Atlas-")
    ap.add_argument("--json", action="store_true")
    args = ap.parse_args()

    cp_map = load_cp_map()
    try:
        raw = sh([
            "gh", "issue", "list", "-R", args.repo, "--state", "all",
            "--limit", "100",
            "--json", "number,title,state,body,assignees,comments",
        ])
    except RuntimeError as e:
        print(f"check_issue_deps: tooling error — {e}", file=sys.stderr)
        return 2
    issues = {i["number"]: i for i in json.loads(raw)}

    rows = []
    violations = []
    for num, iss in sorted(issues.items()):
        if iss["state"] != "OPEN":
            continue
        deps = [d for d in parse_deps(iss.get("body") or "", cp_map)
                if d["issue"] != num]
        # dedupe by issue number: hard edge wins over soft
        merged: dict[int, dict] = {}
        for d in deps:
            cur = merged.get(d["issue"])
            if cur is None or (cur["soft"] and not d["soft"]):
                merged[d["issue"]] = d
        deps = sorted(merged.values(), key=lambda d: d["issue"] or 0)
        active, why = is_active(iss)
        hard_open = []
        for d in deps:
            tgt = issues.get(d["issue"])
            state = tgt["state"] if tgt else "MISSING"
            if state == "OPEN" and not d["soft"]:
                hard_open.append((d, state))
        row = {
            "issue": num, "title": iss["title"][:80], "active": active,
            "active_reason": why, "deps": deps,
            "open_hard_blockers": [d["ref"] for d, _ in hard_open],
        }
        rows.append(row)
        if active and hard_open:
            violations.append(row)

    report = {
        "repo": args.repo,
        "cp_map": cp_map,
        "open_issues": len(rows),
        "violations": violations,
        "rows": rows,
    }
    if args.json:
        print(json.dumps(report, indent=2))
    else:
        print(f"Atlas issue dependency check — {args.repo}")
        print(f"CP map: {cp_map}")
        for r in rows:
            flag = "ACTIVE" if r["active"] else "idle  "
            deps = ", ".join(
                f"{d['ref']}={'open' if issues.get(d['issue'],{}).get('state')=='OPEN' else issues.get(d['issue'],{}).get('state','?')}{'(soft)' if d['soft'] else ''}"
                for d in r["deps"]) or "-"
            print(f"  #{r['issue']:<3} {flag} {r['title'][:58]:<58} deps: {deps}")
        if violations:
            print("VIOLATIONS (active with open hard blockers):")
            for v in violations:
                print(f"  #{v['issue']} {v['title']} blocked by {v['open_hard_blockers']}")
        else:
            print("No active issue has an open hard blocker.")
    return 1 if violations else 0


if __name__ == "__main__":
    sys.exit(main())

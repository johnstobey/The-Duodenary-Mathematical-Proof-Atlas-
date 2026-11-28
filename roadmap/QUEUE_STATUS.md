# Atlas queue status — generated snapshot

Generated: 2026-11-28 03:50 UTC by `scripts/queue_status.py` — do not edit by hand;
regenerate with `python3 scripts/queue_status.py --write`.
States follow the CP-06 protocol (OPEN→CLAIMED→IN PROGRESS→VERIFY→ACCEPTED);
dependency edges parsed by `scripts/check_issue_deps.py` (same rules as CI).

Repo: `johnstobey/The-Duodenary-Mathematical-Proof-Atlas-` · open: 1 · closed: 6

| Issue | CP | State | Active | Blocked by open hard deps | Deps | Title |
|---|---|---|---|---|---|---|
| #5 | CP-00 | CLOSED | ACTIVE |  | — | CP-00 \| Mathlib CRT ring-equivalence closure (P0) |
| #6 | CP-01 | CLOSED | ACTIVE |  | CP-00→CLOSED | CP-01 \| Canonical ring, involution, and 144-coordinate interface (P1) |
| #7 | CP-02 | CLOSED | ACTIVE |  | CP-00→CLOSED (soft); CP-01→CLOSED (soft) | CP-02 \| Geometric artifact graph extraction and invariant tests (P1 p |
| #8 | CP-03 | CLOSED | ACTIVE |  | CP-01→CLOSED; CP-02→CLOSED | CP-03 \| Color-wheel overlay as an independent coordinate layer (P2) |
| #9 | CP-04 | CLOSED | ACTIVE |  | CP-01→CLOSED (soft); CP-02→CLOSED (soft); CP-03→CLOSED (soft) | CP-04 \| Cross-repo certified interface adoption (P2) |
| #10 | CP-05 | CLOSED | ACTIVE |  | CP-02→CLOSED (soft); CP-03→CLOSED (soft); CP-04→CLOSED (soft) | CP-05 \| Geometric-blueprint simulation and engineering triage (P3) |
| #11 | CP-06 | OPEN | ACTIVE |  | CP-00→CLOSED | CP-06 \| Cross-repo evidence and task-ledger synchronization (P1 opera |

## Reading

- `ACTIVE` = assigned or latest protocol comment says CLAIMED/IN PROGRESS/VERIFY.
- `Blocked` counts only OPEN hard dependencies (soft edges never block).
- Closed rows are retained for history; acceptance is the owner's call.

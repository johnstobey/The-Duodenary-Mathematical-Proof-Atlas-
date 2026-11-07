# ATLAS-WORKBENCH-01 delivery

Target: `johnstobey/The-Duodenary-Mathematical-Proof-Atlas-`, branch `atlas-workbench-01` only.
Baseline: `9f2f4c4421831bcb9ca3da7199a4d3bb0a0f3b8c`. No main branch update or merge is part of this delivery.

The complete workbench is at repository root. Run `python3 03_ENGINE/serve_atlas.py`
and open `http://localhost:8765/02_ATLAS/index.html`.
Read WORKBENCH_README.md and 03_ENGINE/adapters/README.md for implementation and typed-subset scope.

Canonical register SHA-256 (unchanged):
`f4615587891cf5ca5823a8b64e18a4f268c36de280e7bfd0055b30a7a92e32bc`.
All 80 entries of the original delivery manifest match. The complete original
08_RECEIPTS folder and ATLAS_WORKBENCH_01_CHECKPOINT.json are copied verbatim.
That checkpoint records the earlier failed private-repository publication; it is
historical, not a claim about this public-branch delivery.

## Delivery verification commands and actual exit codes

Working directory for commands below: `/workspace/The-Duodenary-Mathematical-Proof-Atlas-`.
For Lake, PATH was prepended with `/workspace/cprx-runtime/toolchain/lean-4.14.0-linux/bin`;
no Lean source, pinned dependency, or proof statement was changed.
The initial Lake build ran in the restricted sandbox; the retry used reviewed
network access to fetch the already-pinned dependencies.

| Exact command | Exit code | Receipt name |
|---|---:|---|
| `python3 04_TESTS/verify_canonical.py` | 0 | `canonical` |
| `python3 04_TESTS/test_engine.py` | 0 | `engine` |
| `python3 04_TESTS/test_adapter.py` | 0 | `adapter` |
| `python3 scripts/validate.py` | 0 | `atlas-validate` |
| `python3 scripts/finite_checks.py` | 0 | `atlas-finite` |
| `python3 scripts/roadmap.py --check` | 0 | `atlas-roadmap` |
| `lake build` | 1 | `atlas-lean` |
| `python3 /tmp/atlas-workbench-01-public-browser-check/04_TESTS/test_browser.py` | 0 | `browser` |

Raw new stdout/stderr are in verification/atlas-workbench-01-delivery/.
The browser was run on a byte-identical project copy so the original screenshots,
observations and verbatim failure receipts were not overwritten. Chromium used
/usr/bin/chromium, a loopback HTTP server, and blocked all nonlocal page requests.
The browser suite checks 25 scenes in both directions, 84 directed arcs, 144
addresses, all 157 rendered records, keyboard/mobile/reduced-motion behavior,
operator history, images and source links. Four adapter tests include 84 supported
programs and 924 inconsistent endpoint cases. The original engine reports 333 assertions.

## Original workbench execution commands, preserved verbatim in receipt ledger

These are historical runs; their original cwd is recorded in 08_RECEIPTS/COMMAND_RECEIPTS.jsonl.
Failed runs remain evidence and are not relabeled successful. Harness transport,
SVGPoint serialization and keyboard-test context corrections are documented in
08_RECEIPTS/TRANSPORT_AMENDMENT.md with prior harness versions retained.
The original acceptance contract and original tests are unchanged.

| Exact command | Exit code | Receipt |
|---|---:|---|
| `python3 04_TESTS/verify_canonical.py` | 0 | `canonical-final.stderr` |
| `python3 04_TESTS/test_engine.py` | 0 | `engine-final.stderr` |
| `python3 04_TESTS/test_adapter.py` | 0 | `adapter-final.stderr` |
| `python3 03_ENGINE/adapters/fulgurite.py '☉♈ □ ☉♋'` | 0 | `adapter-example.stderr` |
| `python3 04_TESTS/test_browser.py` | 5 | `browser-run-01.stderr` |
| `python3 04_TESTS/test_browser.py` | 1 | `browser-run-02.stderr` |
| `python3 04_TESTS/test_browser.py` | 1 | `browser-run-03.stderr` |
| `python3 04_TESTS/test_browser.py` | 1 | `browser-run-04.stderr` |
| `python3 04_TESTS/test_browser.py` | 0 | `browser-run-05.stderr` |

## Branch preparation

Executed successfully (exit 0):

```sh
git fetch origin main
git ls-remote origin refs/heads/atlas-workbench-01
git switch -c atlas-workbench-01 origin/main
```

Project files were copied without overwriting existing Atlas files; hashes were
compared with DELIVERY_MANIFEST.json and the original checkpoint bytes. Results:
verification/atlas-workbench-01-delivery/PRESERVATION_CHECK.json.
No canonical record, score, English/math/Dewey field, source asset or lock was modified.
The adapter implements one explicitly documented source-preserving finite subset;
it does not claim complete Fulgurite language execution or new canonical opcodes.

The implementing agent reports execution results. Verification and merge remain
with the principal. No independent approval or merge is claimed here.

## Publication checkpoint

**Workbench gates: GREEN.** Canonical verifier, original engine, typed adapter,
browser suite, Atlas validate/finite/roadmap checks all exited 0.
**Lean: EXECUTION_PENDING — build in progress.** The initial sandbox dependency
fetch failed (exit 1); reviewed network retry fetched pinned Mathlib and is
compiling. This is an independent inherited Atlas component, not a failed
workbench gate. The principal explicitly instructed that it must not block
branch delivery. No adoption of a proposed constitution is implied.

The original failed log is `verification/atlas-workbench-01-delivery/atlas-lean.stderr`.
The pending retry snapshot is `atlas-lean-retry-in-progress.stdout` / `.stderr`
in that same directory. Pending execution has no final exit code yet. Active
unsnapshotted retry logs are excluded from the first commit so receipts are stable.

Additional successful delivery operations (exit 0):

```sh
git push --dry-run origin HEAD:refs/heads/atlas-workbench-01
python3 --version
/usr/bin/chromium --version
/workspace/cprx-runtime/toolchain/lean-4.14.0-linux/bin/lake --version
git ls-remote origin refs/heads/main
```

## Successful branch publication receipt

Executed `git push origin HEAD:refs/heads/atlas-workbench-01` — exit **0**.
Published implementation commit: `7c130b60fce7efac9efc46b650801725c87c1f35`.
Executed `git ls-remote origin refs/heads/main refs/heads/atlas-workbench-01` — exit **0**.
The remote main ref remains `9f2f4c4421831bcb9ca3da7199a4d3bb0a0f3b8c`.
No merge was performed and no main ref was pushed. This follow-up commit adds
publication evidence only; the same branch-only push command publishes it.

`git diff --cached --check` reported inherited source whitespace (exit 2);
`git show --format= --check HEAD` reproduced it (exit 2). The complete report is
`verification/atlas-workbench-01-delivery/source-whitespace.stdout`.
Protected source bytes were preserved rather than normalized. This formatting
observation does not change the canonical hash or the green execution gates.

## Invariant legibility increment — current execution evidence

The front-door README, INVARIANT.md, explicit bindings, complete finite tables and
interactive inspector now expose preservation of defined geometric identity.
No canonical source/lock bytes or historical receipts changed. The original
DELIVERY_MANIFEST.json remains historical; this increment has its own manifest
under verification/invariant-legibility/. No tests were changed after execution.

The earlier pending Lean retry finished successfully (exit 0); its full logs and
exit code are now preserved alongside the failed attempt. The current rerun
also exited 0. The implementation adds a computed structural admission bridge,
not new BB component equations or altered locked scores.

Exact final verification commands and exit codes:

| Command | Exit |
|---|---:|
| `python3 04_TESTS/verify_canonical.py` | 0 |
| `python3 04_TESTS/test_engine.py` | 0 |
| `python3 04_TESTS/test_adapter.py` | 0 |
| `python3 03_ENGINE/invariant.py` | 0 |
| `python3 04_TESTS/test_invariant.py` | 0 |
| `python3 scripts/validate.py` | 0 |
| `python3 scripts/finite_checks.py` | 0 |
| `python3 scripts/roadmap.py --check` | 0 |
| `lake build` | 0 |
| `python3 04_TESTS/test_invariant_browser.py` | 0 |
| `python3 /tmp/invariant-original-browser-regression/04_TESTS/test_browser.py` | 0 |

Full stdout/stderr: verification/invariant-legibility/. Five unit tests,
two new browser tests and eight original browser tests are green. The 84
valid UI cases and 84 broken endpoint counterparts are exercised in Chromium.
Linked repository changes are documentation-only review branches; their
existing runtime histories are preserved and no main branch is changed.

## Relational organization increment

The primary specification is INVARIANT.md: one invariant relational whole.
STRUCTURE.md, Duodenary/Relational/, schemas/relational/ and docs/relational/
articulate succession, opposition, reversal and return co-presently. The new
structural account is self-contained and uses no external attribution.
Earlier operational text and the earlier theorem inventory/log remain preserved
in the corresponding history directories. Existing theorem IDs are unchanged.
Seventeen new declarations bring the total to 121. The canonical register and
lock remain unchanged. AGENTS.md records the current architectural instruction.

The following commands are maintenance records, not the definition of the
architecture. Full output, the initial failed Lean attempt and its corrected
articulation are preserved in verification/relational-organization/.

| Command | Exit |
|---|---:|
| `lake build` | 0 |
| `lake env lean Duodenary/Relational/AxiomScope.lean` | 0 |
| `python3 04_TESTS/verify_canonical.py` | 0 |
| `python3 scripts/validate.py` | 0 |
| `python3 scripts/finite_checks.py` | 0 |
| `python3 scripts/roadmap.py --check` | 0 |
| `python3 scripts/audit_lean.py` | 0 |
| `python3 scripts/audit_lean.py --check` | 0 |
| `python3 /tmp/relational-ui-regression/04_TESTS/test_browser.py` | 0 |
| `python3 /tmp/relational-ui-regression/04_TESTS/test_invariant_browser.py` | 0 |

## Structural closure and dual-register synchronization increment

Closure.lean articulates explicit permutation conjugation, opposition, grid
integrity and arbitrary compositional closure. Registers.lean supplies true
two-way equivalences of typed structural states and their canonical semantic
JSON image, lifted cellwise to indexed 4×3 matrices. Admission.lean supplies
constitutive matrix uniqueness, exact path admission and endpoint coherence.
These are co-present expressions of the primary whole, not causal precedence
between media. The JSON boundary is scripts/structural_gate.py; the native
semantic core is built with lake build relationalGate.

The increment adds 33 declarations, giving 154 in the audited library. Existing
theorem IDs and the complete canonical algorithm register/lock are unchanged.
All 2,906 frozen cases match their expectations; 13 invalid declarations reject.
The 257-relation witness is supplemental to the arbitrary-length proof.
No claim equates proof terms or arbitrary text bytes with twelve structural states.

Exact final commands and exit codes (full output in verification/relational-synchronization):

| Command | Exit |
|---|---:|
| `lake build` | 0 |
| `lake build relationalGate` | 0 |
| `python3 scripts/audit_lean.py` | 0 |
| `python3 scripts/audit_lean.py --check` | 0 |
| `lake env lean Duodenary/Relational/AxiomScope.lean` | 0 |
| `python3 04_TESTS/test_structural_synchronization.py` | 0 |
| `python3 scripts/structural_gate.py schemas/relational/synchronized-example.json` | 0 |
| `python3 04_TESTS/verify_canonical.py` | 0 |
| `python3 scripts/validate.py` | 0 |
| `python3 scripts/finite_checks.py` | 0 |
| `python3 scripts/roadmap.py --check` | 0 |

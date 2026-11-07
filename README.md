# Duodenary Mathematical Proof Atlas

**Organizing invariant: preservation of geometric identity across representations and execution.**
Read [the exact invariant and worked example](INVARIANT.md), inspect
[the binding table](INVARIANT_BINDINGS.json), or run `python3 03_ENGINE/invariant.py`.
The example checks recoverability and operation correspondence across station,
glyph, exact angle and lattice views, including deliberately broken controls.

A reproducible mathematical research foundation published under DPA-BUILD-04. The constitution is **proposed, not adopted**. The latest successful remote publication is recorded separately from local verification.

The Lean library now has **104 checked theorem declarations**: 32 foundation declarations, 53 repaired/reused Machine declarations, and 19 further declarations. These are declaration counts, not novelty claims. It defines cyclic twelve-state operations, antipodal and reflection involutions, a 4×3 coordinate equivalence, seven undirected distances, the 48 affine permutations with composition and inverses, and a 144-state finite encoding. It distinguishes the product group from the cyclic group of order 144. Three infinite families give positive natural-number witnesses for the Erdős–Straus equation: positive multiples of three, positive even numbers, and numbers congruent to two modulo three. These do not solve the full conjecture. The calendar bridge excludes surjective additive maps from Z/260Z to Z/12Z, and explicit proofs reconcile the Machine affine action with the Atlas representation. Exact checked statements, source hashes and axioms appear in [the theorem registry](registry/theorems/theorems.json).

The [current execution report](verification/BUILD04_REPORT.md) and preserved [BUILD-03 checkpoint](verification/EXECUTION_REPORT.md) records implemented work, passed checks and remaining obligations. [Source metadata](sources/metadata/) pins the supplied documents, ten privately preserved DPA-FRONTIER-01 files and external catalogues. [Frontier records](registry/problems/frontier.json) retain all 42 baseline entries and their original limitations. Keyword cross-links are not exact-statement deduplication or validation of claimed external proofs.

The [artifact registry](registry/artifacts/index.json) links nine source-report dossiers plus Pyramid and Mexica calendar controls. Source-native, historical and ontological claims remain distinct. Mathematical finite checks do not certify an artifact interpretation, physical phenomenon or consciousness claim. Original documents, private code, full source extracts and Git histories are outside this candidate.

## Reproduce

Install the pinned Lean toolchain with elan and Python 3.12 with uv, then:

```sh
uv venv .venv
uv pip sync --python .venv/bin/python requirements.lock
. .venv/bin/activate
lake build
python scripts/reproduce.py
python scripts/source_integrity.py
```

The committed manifest locks mathlib and its transitive Git dependencies. `lake exe cache get` is optional acceleration. Routine development must preserve the lock; do not run `lake update` as a build step. The environment prepared in this session also supports `source /workspace/.setup/activate.sh`.

`python scripts/reproduce.py` writes logs and actual exit codes under ignored `.lake/reproduce`. `python scripts/audit_lean.py --check` checks existing theorem records without rewriting tracked evidence. To intentionally record changed proofs in a coding task, run the audit without `--check`, review its updated registry, and rerun acceptance checks. [Recorded reproduction](verification/builds/reproduction/RUN.json) describes the verified current instance, not a fresh GitHub runner.

## Research and release boundaries

[The generated roadmap](roadmap/ROADMAP.md) sorts only REQUIRES edges and keeps discovery feedback separate. [The requirements matrix](REQUIREMENTS_MATRIX.md) honestly records missing original atomic wording. [Publication instructions](PUBLICATION.md) identify approval and licensing gates. New Atlas code uses Apache-2.0; third-party terms and individual source exclusions are documented separately.

Read [AGENTS.md](AGENTS.md) before changing source or evidence. Original mistakes, counterexamples and historical statuses must remain reviewable.

## Execute a research increment

```sh
python scripts/execute_obligation.py --task T-AZTEC-MAP
python scripts/research_cycle.py
python scripts/roadmap.py
```

The obligation runner executes registered local proof targets and saves real exit codes, expected symbols and logs. It returns a blocked result for an unregistered source/research task. New proofs require actual Lean source and an axiom audit before a task becomes kernel verified. The queue's “runnable” flag means its next source/audit action is available, not that an open conjecture is solved automatically.

The pinned primary inventory contains 721 manuscripts in 373 families. Proof-source availability, formalization metadata and independent verification remain separate. See [catalogue reconciliation](registry/external/openai/RECONCILIATION.json), [Machine reconciliation](registry/reconciliation/MACHINE_RECONCILIATION.json), and the [execution target registry](registry/execution_targets.json). The first published version is tagged `dpa-v0.1.0`; successive releases retain exact verification scope.

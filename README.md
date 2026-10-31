# Duodenary Mathematical Proof Atlas

A reproducible mathematical research foundation published under DPA-BUILD-04. The constitution is **proposed, not adopted**. The latest successful remote publication is recorded separately from local verification.

The freshly authored Lean library defines cyclic twelve-state operations, antipodal and reflection involutions, a 4×3 coordinate equivalence, seven undirected distances, the 48 affine permutations with composition and inverses, and a 144-state finite encoding. It distinguishes the product group from the cyclic group of order 144. A separate theorem gives positive natural-number witnesses for the Erdős–Straus equation when n is a positive multiple of three; it does not solve the full conjecture. Exact checked statements, source hashes and axioms appear in [the theorem registry](registry/theorems/theorems.json).

The [execution report](verification/EXECUTION_REPORT.md) records implemented work, passed checks and remaining obligations. [Source metadata](sources/metadata/) pins the supplied documents, ten privately preserved DPA-FRONTIER-01 files and external catalogues. [Frontier records](registry/problems/frontier.json) retain all 42 baseline entries and their original limitations. Keyword cross-links are not exact-statement deduplication or validation of claimed external proofs.

The [artifact registry](registry/artifacts/index.json) links nine source-report dossiers plus Pyramid and Mexica calendar controls. Source-native, historical and ontological claims remain distinct. Mathematical finite checks do not certify an artifact interpretation, physical phenomenon or consciousness claim. Original documents, private code, full source extracts and Git histories are outside this candidate.

## Reproduce

Install the pinned Lean toolchain with elan and Python 3.12 with uv, then:

```sh
uv venv .venv
uv pip sync --python .venv/bin/python requirements.lock
. .venv/bin/activate
lake build
python scripts/reproduce.py
```

The committed manifest locks mathlib and its transitive Git dependencies. `lake exe cache get` is optional acceleration. Routine development must preserve the lock; do not run `lake update` as a build step. The environment prepared in this session also supports `source /workspace/.setup/activate.sh`.

`python scripts/reproduce.py` writes logs and actual exit codes under ignored `.lake/reproduce`. `python scripts/audit_lean.py --check` checks existing theorem records without rewriting tracked evidence. To intentionally record changed proofs in a coding task, run the audit without `--check`, review its updated registry, and rerun acceptance checks. [Recorded reproduction](verification/builds/reproduction/RUN.json) describes the verified current instance, not a fresh GitHub runner.

## Research and release boundaries

[The generated roadmap](roadmap/ROADMAP.md) sorts only REQUIRES edges and keeps discovery feedback separate. [The requirements matrix](REQUIREMENTS_MATRIX.md) honestly records missing original atomic wording. [Publication instructions](PUBLICATION.md) identify approval and licensing gates. New Atlas code uses Apache-2.0; third-party terms and individual source exclusions are documented separately.

Read [AGENTS.md](AGENTS.md) before changing source or evidence. Original mistakes, counterexamples and historical statuses must remain reviewable.

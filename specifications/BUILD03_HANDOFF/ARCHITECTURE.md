# Repository architecture and migration

## Public repository, clean history
`duodenary-proof-atlas` (already created by owner) is the publication and verification authority. Do not fork/copy private Git history, use submodules pointing to private research, or embed authentication credentials. `alien-math-decoded`, `Alien-math-decoded-2`, and private `Machine` are separately sourced, rights-reviewed inputs; they remain private archival/execution systems as instructed by owner. Do not change their visibility without explicit credentials/authorization.

## Directory plan
```
CONSTITUTION.md
README.md
AGENTS.md
lakefile.toml
lean-toolchain
Duodenary/Core/
Duodenary/Partitions/
Duodenary/Symmetry/
Duodenary/Affine/
Duodenary/Bridges/
Duodenary/Acausal/
Duodenary/Problems/
formalization/
registry/{problems,theorems,claims,artifacts,recognitions,dependencies}/
research/{clearing,alignment,geometric-imperative,institutions,history}/
artifacts/ontological/{phaedrus,book-of-the-dead,iliad,odyssey,gruppen,synergetics,bartok-lendvai,eclipse,alice,pyramid,aztec-calendar}/
engineering/{encoding,transmission,temporal-continuity,adversarial-tests}/
verification/{builds,negative-controls,source-audits,disclosure-audits}/
publications/{papers,releases}/
roadmap/{graph,queue,checkpoints}/
sources/metadata/
```
Never place original private binaries/docs in `sources/` without release authorization. This handoff's `baseline_DPA_FRONTIER_01` is a staging source for consideration, not automatically a public repo directory.

## Import logic
Source register → licensing/PII and IP scan → theorem/claim extraction → normalize IDs and formal semantics → preserve source provenance → dedupe → proof compilation → dependency edges → published curated outputs. Do not blindly concatenate two Lean projects or substitute one affine 48-element family for an unrelated 48-operation set.

## Formal build
Pin `lean-toolchain` and Mathlib lock; set a clean-room build with `lake exe cache get` if appropriate; use `lake build` and save full logs/sha/exit status. No claim of passing build before a real local run.

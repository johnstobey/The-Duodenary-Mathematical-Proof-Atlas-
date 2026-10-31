# Dependency-driven research roadmap engine

## Three rings
I. Existing/claimed: recovered formal mathematics, extant Lean proofs, external manuscripts, historical known solutions, proof claims.
II. Identified outstanding: exact open conjectures, partial results, proof gaps, source reconciliations, formalization missing lemmas, experimental unexecuted protocols.
III. Not-yet-identified: candidate invariants, structural obstructions, new theorems from composition, proof transport, cross-domain relation failures, original problem statements.

## Node and edge model
Nodes: SOURCE, RECOGNITION, CLAIM, DEFINITION, OBJECT, TRANSFORM, INVARIANT, LEMMA, CONJECTURE, THEOREM, PROOF, COUNTEREXAMPLE, EXPERIMENT, DOSSIER, RELEASE, TASK.
Edges: REQUIRES, DERIVES_FROM, ISOMORPHIC_TO, PRESERVES, HOMOMORPHIC_TO, SPECIALIZES, GENERALIZES, CONTRADICTS, TESTED_BY, VERIFIED_BY, TRANSPORTS_TO, GENERATES, SUPERSEDES, DOCUMENTED_IN.
Only REQUIRES edges are topologically sorted; recursively generated discovery edges may cycle without concealing unsatisfied proof prerequisites.

## Priority scoring (document weights and input records)
20% mathematical significance, 20% structural bridge specificity, 15% formalization tractability, 15% original discovery upside, 15% downstream unlock leverage, 10% missing verification, 5% publication feasibility. Also mark estimated cost, available source, IP risk, solver/tool requirements and verification method.

## Task lifecycle
DISCOVERED → SOURCE_GROUNDED → SPECIFIED → COUNTEREXAMPLE_CHECKED → IMPLEMENTED → KERNEL_VERIFIED → PUBLICATION_READY → RELEASED; parallel BLOCKED, FAILED, DISPUTED, REFUTED. Every task includes id, exact theorem/claim, prerequisites, corpus locator, next atomic action, validation, evidence path, output path, new nodes unlocked. Task status changes require evidence.

## Initial portfolio
- Existing Tobey/Alien-Math proven pieces: recompile independent of private repos, audit claimed 93 Lean theorems, 24 regression tests, 16078 comparisons if original source available; do not assert verified until run.
- Core: ZMod12, 4×3 CRT decomposition, seven undirected distances, antipodal involution, 48 affine action permutations and distinction from separately named 48 processors, Z144 constructions.
- DPA-FRONTIER-01: 42 research entries, including 35 beyond Clay; source verification and 3 original specifications as separate initial targets.
- OpenAI: acquire latest primary official catalogue, family/manuscript IDs, formalization YAML, announced results (including 2026 Navier-Stokes, Kakeya, ETH/complexity), record claims vs independent results.
- Clay: all seven Millennium entries (six open + solved Poincare as test), official prize rules and eligibility evidence, no presumption of exclusive membership.
- Independent: formal conjectures, Mathlib, Erdős/OEIS, group actions, geometric/topological problem records.
- Artifact program: source-native geometry, acausal correspondence, source evidence, an independent negative-control case (Aztec 13/20, not base-12).
- Clearing: locate Zcode frozen work; second agent real qwen3:4b smoke success but 0 scored; keep 84 trial plan blocked until frozen inputs recovered.

## Recursive algorithm
Inventory → deduplicate by exact formal statements → identify minimal shared prerequisites → compute unlock centrality and risk → choose 3–5 runnable tasks in parallel → attempt formal proof and negative controls → append results and corrections → regenerate graph/priority → release only once gates met. Preserve every task and dead end. An automated discovery candidate is a conjecture until formally proved.

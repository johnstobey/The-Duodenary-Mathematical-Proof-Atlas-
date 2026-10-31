# Frontier opportunity report

Research cutoff 2026-10-31. Screening not a claim of mathematical discovery or proof. Weighted rating: significance 20 percent, structural evidence 20 percent, incremental formalization 15 percent, originality 15 percent, cross-leverage 15 percent, verification gap 10 percent, independent public suitability 5 percent. Component 1–5; total 0–100. Scores are intentionally exploratory.

**Registry size:** 42 distinct problems; seven Clay subjects separately included (one solved).

## Ranked priorities (ten dossiers)

### DPA-011 — Collatz conjecture (87.0/100)

**Statement:** For every n∈ℕ with n>0, iteration T(n)=n/2 if n even, (3n+1)/2 if n odd eventually reaches 1.

**Status:** open; **provenance tier:** statement_needs_primary_problem_locator; **source:** https://github.com/google-deepmind/formal-conjectures.

**Structure:** 12-state quotient of accelerated maps.

**Required bridge:** 12-state quotient of accelerated maps.

**Formal obligation:** Establish a strictly descending well-founded invariant not lost under quotienting..

**Lean action:** Formalize finite C12 invariant and test against explicit counterexamples. **Limitation:** No Lean implementation or general theorem verified.

**Score components:** {'significance': 4, 'structural_evidence': 4, 'incremental_formalization': 5, 'original_discovery': 4, 'cross_problem_leverage': 5, 'verification_gap': 4, 'public_suitability': 5}.

### DPA-013 — Perfect cuboid (87.0/100)

**Statement:** Do positive integers a,b,c exist for which a²+b²,a²+c²,b²+c²,a²+b²+c² are all perfect squares?

**Status:** open; **provenance tier:** statement_needs_primary_problem_locator; **source:** https://github.com/google-deepmind/formal-conjectures.

**Structure:** four-by-three quadratic compatibility.

**Required bridge:** four-by-three quadratic compatibility.

**Formal obligation:** Build obstruction via a finite parity and mod-12 covering combined with higher local data..

**Lean action:** Formalize finite C12 invariant and test against explicit counterexamples. **Limitation:** No Lean implementation or general theorem verified.

**Score components:** {'significance': 4, 'structural_evidence': 4, 'incremental_formalization': 5, 'original_discovery': 4, 'cross_problem_leverage': 5, 'verification_gap': 4, 'public_suitability': 5}.

### DPA-016 — Graceful tree labeling (87.0/100)

**Statement:** For every tree T with m edges, is there an injective f:V(T)→{0,…,m} such that {|f(u)−f(v)|:uv∈E(T)}={1,…,m}?

**Status:** open; **provenance tier:** statement_needs_primary_problem_locator; **source:** https://github.com/google-deepmind/formal-conjectures.

**Structure:** cyclic edge-difference designs.

**Required bridge:** cyclic edge-difference designs.

**Formal obligation:** Prove an extendable C12-equivariant graceful labeling theorem for a new infinite tree family..

**Lean action:** Formalize finite C12 invariant and test against explicit counterexamples. **Limitation:** No Lean implementation or general theorem verified.

**Score components:** {'significance': 4, 'structural_evidence': 4, 'incremental_formalization': 5, 'original_discovery': 4, 'cross_problem_leverage': 5, 'verification_gap': 4, 'public_suitability': 5}.

### DPA-018 — Union-closed sets conjecture (87.0/100)

**Statement:** For every finite nonempty union-closed family F of distinct finite sets, some element belongs to at least |F|/2 members.

**Status:** open; **provenance tier:** statement_needs_primary_problem_locator; **source:** https://github.com/google-deepmind/formal-conjectures.

**Structure:** finite lattice actions and orbit counting.

**Required bridge:** finite lattice actions and orbit counting.

**Formal obligation:** Establish orbit-weight inequality that is not already implied by known averaging methods..

**Lean action:** Formalize finite C12 invariant and test against explicit counterexamples. **Limitation:** No Lean implementation or general theorem verified.

**Score components:** {'significance': 4, 'structural_evidence': 4, 'incremental_formalization': 5, 'original_discovery': 4, 'cross_problem_leverage': 5, 'verification_gap': 4, 'public_suitability': 5}.

### DPA-019 — Caccetta–Häggkvist (87.0/100)

**Statement:** Every directed graph on n vertices of minimum outdegree ≥r contains a directed cycle of length at most ⌈n/r⌉.

**Status:** open; **provenance tier:** statement_needs_primary_problem_locator; **source:** https://github.com/google-deepmind/formal-conjectures.

**Structure:** cyclic walk and antipodal relation.

**Required bridge:** cyclic walk and antipodal relation.

**Formal obligation:** Construct a short-cycle witness from an invariant orbit decomposition..

**Lean action:** Formalize finite C12 invariant and test against explicit counterexamples. **Limitation:** No Lean implementation or general theorem verified.

**Score components:** {'significance': 4, 'structural_evidence': 4, 'incremental_formalization': 5, 'original_discovery': 4, 'cross_problem_leverage': 5, 'verification_gap': 4, 'public_suitability': 5}.

### DPA-020 — Reconstruction conjecture (87.0/100)

**Statement:** Every finite simple graph with at least three vertices is determined up to isomorphism by its multiset of vertex-deleted subgraphs.

**Status:** open; **provenance tier:** statement_needs_primary_problem_locator; **source:** https://github.com/google-deepmind/formal-conjectures.

**Structure:** reconstruction under C12 actions.

**Required bridge:** reconstruction under C12 actions.

**Formal obligation:** Prove reconstruction for a novel class of graphs with faithful C12 symmetry..

**Lean action:** Formalize finite C12 invariant and test against explicit counterexamples. **Limitation:** No Lean implementation or general theorem verified.

**Score components:** {'significance': 4, 'structural_evidence': 4, 'incremental_formalization': 5, 'original_discovery': 4, 'cross_problem_leverage': 5, 'verification_gap': 4, 'public_suitability': 5}.

### DPA-038 — Rota basis conjecture (87.0/100)

**Statement:** Given n disjoint bases of an n-rank matroid, can their elements be arranged in an n×n array with each row the given basis and each column also a basis?

**Status:** open; **provenance tier:** statement_needs_primary_problem_locator; **source:** https://github.com/google-deepmind/formal-conjectures.

**Structure:** 4×3 array transversal maps.

**Required bridge:** 4×3 array transversal maps.

**Formal obligation:** Prove a new rank-12 restricted matroid class, then lift..

**Lean action:** Formalize finite C12 invariant and test against explicit counterexamples. **Limitation:** No Lean implementation or general theorem verified.

**Score components:** {'significance': 4, 'structural_evidence': 4, 'incremental_formalization': 5, 'original_discovery': 4, 'cross_problem_leverage': 5, 'verification_gap': 4, 'public_suitability': 5}.

### DPA-039 — Alon–Tarsi Latin square conjecture (87.0/100)

**Statement:** For every even n, the number of even Latin squares of order n differs from the number of odd Latin squares of order n.

**Status:** open; **provenance tier:** statement_needs_primary_problem_locator; **source:** https://github.com/google-deepmind/formal-conjectures.

**Structure:** order-12 parity involutions.

**Required bridge:** order-12 parity involutions.

**Formal obligation:** Construct non-canceling orbit counts under an explicit C12 action..

**Lean action:** Formalize finite C12 invariant and test against explicit counterexamples. **Limitation:** No Lean implementation or general theorem verified.

**Score components:** {'significance': 4, 'structural_evidence': 4, 'incremental_formalization': 5, 'original_discovery': 4, 'cross_problem_leverage': 5, 'verification_gap': 4, 'public_suitability': 5}.

### DPA-040 — Hadamard matrix conjecture (87.0/100)

**Statement:** For every positive integer n, a Hadamard matrix of order 4n exists: H∈{−1,1}^{4n×4n} and HHᵀ=4nI.

**Status:** open; **provenance tier:** statement_needs_primary_problem_locator; **source:** https://github.com/google-deepmind/formal-conjectures.

**Structure:** 4×3 decompositions and Kronecker products.

**Required bridge:** 4×3 decompositions and Kronecker products.

**Formal obligation:** Establish a new family of Hadamard designs from compatible C12 difference sets..

**Lean action:** Formalize finite C12 invariant and test against explicit counterexamples. **Limitation:** No Lean implementation or general theorem verified.

**Score components:** {'significance': 4, 'structural_evidence': 4, 'incremental_formalization': 5, 'original_discovery': 4, 'cross_problem_leverage': 5, 'verification_gap': 4, 'public_suitability': 5}.

### DPA-041 — Lonely runner conjecture (87.0/100)

**Statement:** For k runners with distinct nonzero integer speeds starting together on a unit circle, each runner at some time has distance at least 1/k from every other runner.

**Status:** open; **provenance tier:** statement_needs_primary_problem_locator; **source:** https://github.com/google-deepmind/formal-conjectures.

**Structure:** circle translations and group quotients.

**Required bridge:** circle translations and group quotients.

**Formal obligation:** Establish an exact finite cyclic approximation with uniform lift to real time..

**Lean action:** Formalize finite C12 invariant and test against explicit counterexamples. **Limitation:** No Lean implementation or general theorem verified.

**Score components:** {'significance': 4, 'structural_evidence': 4, 'incremental_formalization': 5, 'original_discovery': 4, 'cross_problem_leverage': 5, 'verification_gap': 4, 'public_suitability': 5}.

## First three execution targets

1. Finite cyclic action invariant algebra: prove fixed-point behavior under the C12 action and compute orbit multiset with decidable finite cases. Tests: 12 elements; rotation order; orbit-stabilizer; explicit counterexamples to naive quotient inference.
2. Residue admissibility for Erdős–Straus: systematically enumerate n mod 12 and certify symbolic rational identities only when valid for every positive integer in a class. Tests: exact rational identity and positivity with algebraic normalization, no finite-sample extrapolation.
3. C12 graph automorphism invariant: formalize an automorphism of a finite simple graph and prove graph invariants preserved under genuine isomorphism; then investigate genuinely new restricted cases of graph reconstruction or graceful labeling. Tests: proof obligations with explicit graph isomorphism maps; ensure quotient claims not substituted for isomorphism.

**Non-discovery warning:** These are starting formalization specifications, not assertions of novel results.

## Clay problems evaluated
- DPA-001 Riemann hypothesis: open; proposed bridge spectral cyclic character decomposition; obstacle Construct a trace-compatible representation whose spectral criterion implies Re(ρ)=1/2.
- DPA-002 P versus NP: open; proposed bridge cyclic finite gadgets and reductions; obstacle Prove a complexity-preserving reduction or lower bound; finite twelvefold symmetry alone is insufficient.
- DPA-003 Birch and Swinnerton-Dyer: open; proposed bridge 12-torsion actions on elliptic curves; obstacle Prove compatibility of selected torsion actions with Selmer and L-series invariants.
- DPA-004 Hodge conjecture: open; proposed bridge equivariant cycle class maps; obstacle Construct a nontrivial C12-equivariant Hodge-to-cycle lifting criterion.
- DPA-005 Navier–Stokes existence and smoothness: claimed_solution_pending_acceptance; proposed bridge cyclic spatial symmetry and invariant PDE subspaces; obstacle Prove a C12-equivariant flow reduction preserving all required PDE hypotheses and singularity criteria.
- DPA-006 Yang–Mills existence and mass gap: open; proposed bridge finite cyclic symmetry of gauge configurations; obstacle Show covariance of observables and establish a positive mass-gap implication.
- DPA-007 Poincaré conjecture: solved; proposed bridge equivariant triangulations as formalization exercises; obstacle Formalize a restricted equivariant 3-manifold lemma, not a new proof of Perelman.

## Method

Structural equivalence must be explicitly typed f : A → B with domain, codomain, action, preservation proof, inverse (where claimed), and demonstrable theorem consequence. An acausal isomorphism concerns structure, not temporal causation. Shared numerical patterns are weak evidence.

## Acquisition gaps

Full OpenAI catalogue indexing and individual sources for non-Clay candidates were NOT completed. See verification/REGISTRY_SOURCE_AUDIT.md. The record is usable for triage but not yet eligible for a pass on every completion condition.

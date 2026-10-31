# Initial Lean 4 proof obligations (not compiled)

## C12 orbit action
Import Mathlib. Define `C12 := ZMod 12`; construct addition action `a • x := a + x`. Prove `(0 : C12) • x = x`, `(a+b) • x = a • (b • x)`, and action preserves pairwise modular difference. Then define orbit and stabilizer, test orbit cardinalities by finite enumeration.

## Erdős–Straus residue certificates
Define `ES (n : ℕ) := ∃ x y z : ℕ, 0<x ∧ 0<y ∧ 0<z ∧ (4:ℚ)/n = 1/x + 1/y + 1/z`. For each proposed residue family, provide explicit positive integer functions x(n), y(n), z(n) and verify the rational identity. No universal claim until residue coverage is proved.

## Graph equivariance
For a simple graph G on a finite vertex type and an equivalence φ, prove adjacency preservation under a `SimpleGraph.Iso`, and invariance of an explicitly defined matching or coloring predicate under that isomorphism. An automorphism/quotient is not automatically an isomorphism.

import PairSpace144

/-!
CP-01 remainder axiom gate + versioned interface vectors.
CI gate: FAILS if any line reports `sorryAx`. `decide` proofs contribute no
extra axioms; expected set ⊆ `{propext, Classical.choice, Quot.sound}`.
-/

#print axioms ClosedRingZ12.PairSpace144.t9_t4_eq_sigma
#print axioms ClosedRingZ12.PairSpace144.t9_t4_commute
#print axioms ClosedRingZ12.PairSpace144.sigma_iterate_full
#print axioms ClosedRingZ12.PairSpace144.t9_coords
#print axioms ClosedRingZ12.PairSpace144.t4_coords
#print axioms ClosedRingZ12.PairSpace144.antipode_eq_t9_iterate
#print axioms ClosedRingZ12.PairSpace144.t4_orbit_size
#print axioms ClosedRingZ12.PairSpace144.t9_orbit_size
#print axioms ClosedRingZ12.PairSpace144.t4_orbit_partition
#print axioms ClosedRingZ12.PairSpace144.t9_orbit_partition
#print axioms ClosedRingZ12.PairSpace144.orbit_unique_intersection
#print axioms ClosedRingZ12.PairSpace144.crt_cell_unique
#print axioms ClosedRingZ12.PairSpace144.decode144_encode144
#print axioms ClosedRingZ12.PairSpace144.encode144_decode144
#print axioms ClosedRingZ12.PairSpace144.pair_card
#print axioms ClosedRingZ12.PairSpace144.encode144_agrees_core
#print axioms ClosedRingZ12.PairSpace144.pair_units_card
#print axioms ClosedRingZ12.PairSpace144.pair_product_not_zmod144

/-! Versioned interface vectors v1 — compile-time checked against the
certified declarations. Each row pins one contract fact. -/

section VectorsV1

open ClosedRingZ12.PairSpace144
open ClosedRingZ12.MathlibCRT

-- Generator composition: σ = T₉∘T₄ and commutation, all 12 residues.
example : ∀ k : ZMod 12, t9 (t4 k) = sigma k := t9_t4_eq_sigma
example : ∀ k : ZMod 12, t4 (t9 k) = t9 (t4 k) := by
  intro k; rw [t9_t4_commute]

-- Coordinate action spot rows: T₉ advances u only, T₄ advances v only.
example : crt12 (t9 (0 : ZMod 12)) = ((1 : ZMod 4), (0 : ZMod 3)) := by decide
example : crt12 (t4 (0 : ZMod 12)) = ((0 : ZMod 4), (1 : ZMod 3)) := by decide
example : t9 (t9 (t9 (t9 (0 : ZMod 12)))) = 0 := by decide
example : t4 (t4 (t4 (0 : ZMod 12))) = 0 := by decide

-- Antipode as two T₉ steps: k + 6 = T₉²(k), spot rows.
example : (6 : ZMod 12) = t9 (t9 (0 : ZMod 12)) := by decide
example : (0 : ZMod 12) = t9 (t9 (6 : ZMod 12)) := by decide

-- Serialization spot rows: index = 12a + b.
example : encode144 ((0 : ZMod 12), (0 : ZMod 12)) = ⟨0, by decide⟩ := by decide
example : encode144 ((1 : ZMod 12), (0 : ZMod 12)) = ⟨12, by decide⟩ := by decide
example : encode144 ((11 : ZMod 12), (11 : ZMod 12)) = ⟨143, by decide⟩ := by decide
example : decode144 ⟨143, by decide⟩ = ((11 : ZMod 12), (11 : ZMod 12)) := by decide

end VectorsV1

#eval IO.println "PAIR144 VERIFIED: generators, orbit/incidence structure, serialization, and the not-ZMod-144 distinction are kernel-checked and axiom-clean."

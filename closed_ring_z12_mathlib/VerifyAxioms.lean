import CRTMathlib

/-! CP-00 axiom gate + versioned test vectors v1.
CI gate: FAILS if any line reports `sorryAx`. -/

#print axioms ClosedRingZ12.MathlibCRT.crt12
#print axioms ClosedRingZ12.MathlibCRT.crt12_apply_lt
#print axioms ClosedRingZ12.MathlibCRT.crt12_eq_phi
#print axioms ClosedRingZ12.MathlibCRT.crt12_symm_eq_casterm
#print axioms ClosedRingZ12.MathlibCRT.crt12_symm_apply_lt
#print axioms ClosedRingZ12.MathlibCRT.crt12_symm_val_eq_phiInv
#print axioms ClosedRingZ12.MathlibCRT.crt12_symm_phi_roundtrip
#print axioms ClosedRingZ12.MathlibCRT.inv_formula_mod4
#print axioms ClosedRingZ12.MathlibCRT.inv_formula_mod3
#print axioms ClosedRingZ12.MathlibCRT.bridge_add
#print axioms ClosedRingZ12.MathlibCRT.bridge_mul
#print axioms ClosedRingZ12.MathlibCRT.bridge_one
#print axioms ClosedRingZ12.MathlibCRT.bridge_one_eq_phi_one
#print axioms ClosedRingZ12.MathlibCRT.bridge_J

/-! Versioned test vectors v1 — the full 12-element correspondence table,
compile-time checked. Each row reuses the kernel-checked bridge theorems. -/

section TestVectors

open ClosedRingZ12.MathlibCRT

-- Forward rows: crt12 k = (k mod 4, k mod 3).
example : crt12 (0 : ZMod 12) = ((0 : ZMod 4), (0 : ZMod 3)) := crt12_apply_lt 0 (by omega)
example : crt12 (1 : ZMod 12) = ((1 : ZMod 4), (1 : ZMod 3)) := crt12_apply_lt 1 (by omega)
example : crt12 (2 : ZMod 12) = ((2 : ZMod 4), (2 : ZMod 3)) := crt12_apply_lt 2 (by omega)
example : crt12 (3 : ZMod 12) = ((3 : ZMod 4), (0 : ZMod 3)) := crt12_apply_lt 3 (by omega)
example : crt12 (4 : ZMod 12) = ((0 : ZMod 4), (1 : ZMod 3)) := crt12_apply_lt 4 (by omega)
example : crt12 (5 : ZMod 12) = ((1 : ZMod 4), (2 : ZMod 3)) := crt12_apply_lt 5 (by omega)
example : crt12 (6 : ZMod 12) = ((2 : ZMod 4), (0 : ZMod 3)) := crt12_apply_lt 6 (by omega)
example : crt12 (7 : ZMod 12) = ((3 : ZMod 4), (1 : ZMod 3)) := crt12_apply_lt 7 (by omega)
example : crt12 (8 : ZMod 12) = ((0 : ZMod 4), (2 : ZMod 3)) := crt12_apply_lt 8 (by omega)
example : crt12 (9 : ZMod 12) = ((1 : ZMod 4), (0 : ZMod 3)) := crt12_apply_lt 9 (by omega)
example : crt12 (10 : ZMod 12) = ((2 : ZMod 4), (1 : ZMod 3)) := crt12_apply_lt 10 (by omega)
example : crt12 (11 : ZMod 12) = ((3 : ZMod 4), (2 : ZMod 3)) := crt12_apply_lt 11 (by omega)

-- Inverse rows: crt12.symm (k mod 4, k mod 3) = k (the (9u+4v) closure).
example : crt12.symm ((0 : ZMod 4), (0 : ZMod 3)) = (0 : ZMod 12) := crt12_symm_eq_casterm 0 (by omega)
example : crt12.symm ((1 : ZMod 4), (1 : ZMod 3)) = (1 : ZMod 12) := crt12_symm_eq_casterm 1 (by omega)
example : crt12.symm ((2 : ZMod 4), (2 : ZMod 3)) = (2 : ZMod 12) := crt12_symm_eq_casterm 2 (by omega)
example : crt12.symm ((3 : ZMod 4), (0 : ZMod 3)) = (3 : ZMod 12) := crt12_symm_eq_casterm 3 (by omega)
example : crt12.symm ((0 : ZMod 4), (1 : ZMod 3)) = (4 : ZMod 12) := crt12_symm_eq_casterm 4 (by omega)
example : crt12.symm ((1 : ZMod 4), (2 : ZMod 3)) = (5 : ZMod 12) := crt12_symm_eq_casterm 5 (by omega)
example : crt12.symm ((2 : ZMod 4), (0 : ZMod 3)) = (6 : ZMod 12) := crt12_symm_eq_casterm 6 (by omega)
example : crt12.symm ((3 : ZMod 4), (1 : ZMod 3)) = (7 : ZMod 12) := crt12_symm_eq_casterm 7 (by omega)
example : crt12.symm ((0 : ZMod 4), (2 : ZMod 3)) = (8 : ZMod 12) := crt12_symm_eq_casterm 8 (by omega)
example : crt12.symm ((1 : ZMod 4), (0 : ZMod 3)) = (9 : ZMod 12) := crt12_symm_eq_casterm 9 (by omega)
example : crt12.symm ((2 : ZMod 4), (1 : ZMod 3)) = (10 : ZMod 12) := crt12_symm_eq_casterm 10 (by omega)
example : crt12.symm ((3 : ZMod 4), (2 : ZMod 3)) = (11 : ZMod 12) := crt12_symm_eq_casterm 11 (by omega)

end TestVectors

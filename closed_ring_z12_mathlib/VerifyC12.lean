import C12ZModBridge

/-! CP-01 axiom gate + versioned test vectors v1 for the `C12` ↔ `ZMod 12`
bridge. CI gate: FAILS if any line reports `sorryAx`. -/

#print axioms Duodenary.C12Mathlib.toZMod
#print axioms Duodenary.C12Mathlib.ofZMod
#print axioms Duodenary.C12Mathlib.c12EquivZMod
#print axioms Duodenary.C12Mathlib.c12CommRing
#print axioms Duodenary.C12Mathlib.c12ToZModRingHom
#print axioms Duodenary.C12Mathlib.c12RingEquivZMod
#print axioms Duodenary.C12Mathlib.c12CrtEquiv
#print axioms Duodenary.C12Mathlib.c12CrtEquiv_apply
#print axioms Duodenary.C12Mathlib.crt_eq_zmod_crt
#print axioms Duodenary.C12Mathlib.crt_eq_c12CrtEquiv
#print axioms Duodenary.C12Mathlib.uncrt_zmod
#print axioms Duodenary.C12Mathlib.opposite_transport
#print axioms Duodenary.C12Mathlib.unitSlope_isUnit

/-! Versioned test vectors v1 — compile-time checked rows reusing the
kernel-checked bridge theorems. `ofNatC12 k` is the core canonical literal
`k mod 12`; `c12CrtEquiv` lands in `ZMod 4 × ZMod 3`. -/

section TestVectors

open Duodenary
open Duodenary.C12Mathlib

-- Forward rows: c12CrtEquiv k = (k mod 4, k mod 3).
example : c12CrtEquiv (ofNatC12 0) = ((0 : ZMod 4), (0 : ZMod 3)) := by
  rw [c12CrtEquiv_apply]; decide
example : c12CrtEquiv (ofNatC12 1) = ((1 : ZMod 4), (1 : ZMod 3)) := by
  rw [c12CrtEquiv_apply]; decide
example : c12CrtEquiv (ofNatC12 5) = ((1 : ZMod 4), (2 : ZMod 3)) := by
  rw [c12CrtEquiv_apply]; decide
example : c12CrtEquiv (ofNatC12 7) = ((3 : ZMod 4), (1 : ZMod 3)) := by
  rw [c12CrtEquiv_apply]; decide
example : c12CrtEquiv (ofNatC12 11) = ((3 : ZMod 4), (2 : ZMod 3)) := by
  rw [c12CrtEquiv_apply]; decide

-- Inverse rows: uncrt (u mod 4, v mod 3) = (9u + 4v) mod 12.
example : c12CrtEquiv (uncrt (⟨1, by decide⟩, ⟨2, by decide⟩))
    = ((1 : ZMod 4), (2 : ZMod 3)) := uncrt_zmod _
example : c12CrtEquiv (uncrt (⟨3, by decide⟩, ⟨1, by decide⟩))
    = ((3 : ZMod 4), (1 : ZMod 3)) := uncrt_zmod _

-- Antipode rows: opposite k = k + 6 lands at (+2, +0) coordinates.
example : c12CrtEquiv (opposite (ofNatC12 1))
    = ((3 : ZMod 4), (1 : ZMod 3)) := by
  rw [c12CrtEquiv_apply]; decide
example : c12CrtEquiv (opposite (opposite (ofNatC12 5)))
    = ((1 : ZMod 4), (2 : ZMod 3)) := by
  rw [c12CrtEquiv_apply]; decide

end TestVectors

import Duodenary.Imported.CyclicKernel
/-! The 144-element product space and uniform-rotation invariants. -/
namespace Duodenary.MachineProduct
open Duodenary.MachineCore

abbrev V := Z12 × Z12

-- Oriented modular displacement, not absolute or Euclidean distance.
def displacement (p q : Z12) : Z12 := add q (neg p)
def shift1 (s x : Z12) : Z12 := add x s

def shift (s : V) (p : V) : V :=
  (shift1 s.1 p.1, shift1 s.2 p.2)

def delta (p q : V) : V :=
  (displacement p.1 q.1, displacement p.2 q.2)

def opposite1 (x : Z12) : Z12 := add x 6
def antipode (p : V) : V := (opposite1 p.1, opposite1 p.2)

theorem opposite_involution : ∀ x : Z12,
    opposite1 (opposite1 x) = x := by decide

theorem antipode_involution (p : V) : antipode (antipode p) = p := by
  apply Prod.ext
  · exact opposite_involution p.1
  · exact opposite_involution p.2

-- Modular displacement is unchanged by the same rotation on both ends.
theorem displacement_shift_invariant : ∀ s p q : Z12,
    displacement (shift1 s p) (shift1 s q) = displacement p q := by decide

theorem shift_invariance (s p q : V) :
    delta (shift s p) (shift s q) = delta p q := by
  apply Prod.ext
  · exact displacement_shift_invariant s.1 p.1 q.1
  · exact displacement_shift_invariant s.2 p.2 q.2

-- Simultaneously taking antipodes preserves displacement.
theorem antipodal_distance_invariance (p q : V) :
    delta (antipode p) (antipode q) = delta p q := by
  apply Prod.ext
  · exact displacement_shift_invariant 6 p.1 q.1
  · exact displacement_shift_invariant 6 p.2 q.2

-- Undirected cyclic distance on one twelve-position circle.
def circularDistance (x y : Z12) : Nat :=
  min ((displacement x y).val) ((displacement y x).val)

theorem circularDistance_symm : ∀ x y : Z12,
    circularDistance x y = circularDistance y x := by
  intro x y
  unfold circularDistance
  exact Nat.min_comm _ _

theorem circularDistance_shift_invariant : ∀ s x y : Z12,
    circularDistance (shift1 s x) (shift1 s y) = circularDistance x y := by
  intro s x y
  unfold circularDistance
  rw [displacement_shift_invariant, displacement_shift_invariant]

def productDistance (p q : V) : Nat :=
  circularDistance p.1 q.1 + circularDistance p.2 q.2

theorem productDistance_shift_invariant (s p q : V) :
    productDistance (shift s p) (shift s q) = productDistance p q := by
  unfold productDistance shift
  rw [circularDistance_shift_invariant, circularDistance_shift_invariant]

theorem productDistance_antipode_invariant (p q : V) :
    productDistance (antipode p) (antipode q) = productDistance p q := by
  unfold productDistance antipode opposite1
  rw [← circularDistance_shift_invariant (6 : Z12) p.1 q.1]
  rw [← circularDistance_shift_invariant (6 : Z12) p.2 q.2]
  rfl

end Duodenary.MachineProduct

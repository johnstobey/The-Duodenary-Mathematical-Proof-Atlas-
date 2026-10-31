import Mathlib.Data.ZMod.Basic
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring

/-! Fresh structural definitions. No private proof source imported. -/
namespace Duodenary
set_option maxRecDepth 100000
set_option maxHeartbeats 2000000
abbrev C12 := ZMod 12

def rotate (a x : C12) : C12 := a + x
def opposite (x : C12) : C12 := x + 6
def reflect (a x : C12) : C12 := a - x

theorem rotate_zero (x : C12) : rotate 0 x = x := zero_add x
theorem rotate_comp (a b x : C12) : rotate a (rotate b x) = rotate (a+b) x :=
  (add_assoc a b x).symm
theorem difference_preserved (a x y : C12) : rotate a x - rotate a y = x-y := by
  unfold rotate
  ring
theorem opposite_involution (x : C12) : opposite (opposite x) = x := by
  unfold opposite
  have h : (6 : C12) + 6 = 0 := by decide
  rw [add_assoc, h, add_zero]
theorem opposite_has_no_fixed_point (x : C12) : opposite x ≠ x := by
  intro h
  have h6 : (6 : C12) = 0 := (add_left_cancel (show x + 6 = x + 0 by simpa [opposite] using h))
  exact (by decide : (6 : C12) ≠ 0) h6
theorem reflection_involution (a x : C12) : reflect a (reflect a x) = x := by
  unfold reflect
  ring
theorem reflection_rotation (a b x : C12) :
    reflect a (rotate b x) = rotate (-b) (reflect a x) := by
  unfold reflect rotate
  ring

def crt (x : C12) : Fin 4 × Fin 3 :=
  (⟨x.val % 4, Nat.mod_lt _ (by decide)⟩, ⟨x.val % 3, Nat.mod_lt _ (by decide)⟩)
def uncrt (p : Fin 4 × Fin 3) : C12 := (9 * p.1.val + 4 * p.2.val : Nat)
theorem crt_left_inverse : ∀ x : C12, uncrt (crt x) = x := by decide
theorem crt_right_inverse : ∀ p : Fin 4 × Fin 3, crt (uncrt p) = p := by decide
theorem crt_preserves_addition : ∀ x y : C12,
    crt (x+y) = ((crt x).1 + (crt y).1, (crt x).2 + (crt y).2) := by decide
theorem crt_preserves_multiplication : ∀ x y : C12,
    crt (x*y) = ((crt x).1 * (crt y).1, (crt x).2 * (crt y).2) := by decide
def crtEquiv : C12 ≃ Fin 4 × Fin 3 where
  toFun := crt
  invFun := uncrt
  left_inv := crt_left_inverse
  right_inv := crt_right_inverse

def cyclicDistance (x y : C12) : Nat := min (x-y).val (y-x).val
theorem distance_symmetric (x y : C12) : cyclicDistance x y = cyclicDistance y x :=
  min_comm _ _
theorem distance_bound : ∀ x y : C12, cyclicDistance x y ≤ 6 := by decide
theorem seven_distance_values :
    ∀ d : Fin 7, ∃ x : C12, cyclicDistance x 0 = d.val := by decide

def unitSlope (i : Fin 4) : C12 := ![1,5,7,11] i
abbrev Affine := Fin 4 × C12
def affineApply (f : Affine) (x : C12) : C12 := unitSlope f.1 * x + f.2
theorem slope_square : ∀ i : Fin 4, unitSlope i * unitSlope i = 1 := by decide
def inverseApply (f : Affine) (x : C12) : C12 := unitSlope f.1 * (x-f.2)
theorem affine_inverse (f : Affine) (x : C12) : inverseApply f (affineApply f x) = x := by
  unfold inverseApply affineApply
  rw [add_sub_cancel_right, ← mul_assoc, slope_square, one_mul]
theorem affine_reverse_inverse (f : Affine) (x : C12) : affineApply f (inverseApply f x) = x := by
  unfold inverseApply affineApply
  rw [← mul_assoc, slope_square, one_mul, sub_add_cancel]
theorem affine_faithful : ∀ f g : Affine,
    affineApply f 0 = affineApply g 0 → affineApply f 1 = affineApply g 1 → f = g := by decide
theorem affine_cardinality : Fintype.card Affine = 48 := by decide
def slopeProduct (i j : Fin 4) : Fin 4 :=
  (![![0,1,2,3], ![1,0,3,2], ![2,3,0,1], ![3,2,1,0]] i) j
theorem slope_product_correct : ∀ i j : Fin 4,
    unitSlope (slopeProduct i j) = unitSlope i * unitSlope j := by decide
def affineCompose (f g : Affine) : Affine :=
  (slopeProduct f.1 g.1, unitSlope f.1 * g.2 + f.2)
theorem affine_composition (f g : Affine) (x : C12) :
    affineApply (affineCompose f g) x = affineApply f (affineApply g x) := by
  simp only [affineApply, affineCompose, slope_product_correct]
  ring
theorem affine_associative (f g h : Affine) :
    affineCompose (affineCompose f g) h = affineCompose f (affineCompose g h) := by
  apply affine_faithful <;> simp only [affine_composition]

theorem affine_identity : ∀ f : Affine,
    affineCompose (0,0) f = f ∧ affineCompose f (0,0) = f := by decide
def affineInverse (f : Affine) : Affine := (f.1, -unitSlope f.1 * f.2)
theorem affine_two_sided_inverse : ∀ f : Affine,
    affineCompose f (affineInverse f) = (0,0) ∧
    affineCompose (affineInverse f) f = (0,0) := by decide

abbrev Product144 := C12 × C12
def encode144 (x : Product144) : Fin 144 :=
  ⟨12*x.1.val+x.2.val, by have := x.1.val_lt; have := x.2.val_lt; omega⟩
def decode144 (x : Fin 144) : Product144 :=
  (((x.val / 12 : Nat) : C12), ((x.val % 12 : Nat) : C12))
theorem product144_left_inverse : ∀ x : Product144, decode144 (encode144 x) = x := by decide
theorem product144_right_inverse : ∀ x : Fin 144, encode144 (decode144 x) = x := by decide
theorem product144_cardinality : Fintype.card Product144 = 144 := by decide
-- The encoding is an equivalence of finite sets, not an additive isomorphism with ZMod 144.
theorem product_exponent : ∀ x : Product144, (12 : Nat) • x = 0 := by decide
theorem cyclic144_not_exponent12 : (12 : Nat) • (1 : ZMod 144) ≠ 0 := by decide
end Duodenary

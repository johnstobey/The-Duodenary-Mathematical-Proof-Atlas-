import Duodenary.Core.Cyclic
import Mathlib.Algebra.Group.Hom.Basic

namespace Duodenary
set_option maxRecDepth 100000
set_option maxHeartbeats 2000000

/-- The exact annihilator condition for the calendar comparison. -/
theorem calendar_annihilator_classification : ∀ y : C12,
    (4 : C12) * y = 0 ↔ y = 0 ∨ y = 3 ∨ y = 6 ∨ y = 9 := by decide

/-- A homomorphism respects the order-260 relation in its domain. -/
theorem calendar_image_annihilated (f : ZMod 260 →+ C12) (x : ZMod 260) :
    (4 : C12) * f x = 0 := by
  have h260 : (260 : Nat) • f x = 0 := by
    rw [← f.map_nsmul]
    have hx : (260 : Nat) • x = 0 := by
      rw [nsmul_eq_mul]
      change (260 : ZMod 260) * x = 0
      rw [show (260 : ZMod 260) = 0 by decide, zero_mul]
    rw [hx, f.map_zero]
  have h8 : (8 : C12) * f x = 0 := by simpa [nsmul_eq_mul] using h260
  have hc : (4 : C12) = -(8 : C12) := by decide
  rw [hc, neg_mul, h8, neg_zero]

theorem calendar_image_classification (f : ZMod 260 →+ C12) (x : ZMod 260) :
    f x = 0 ∨ f x = 3 ∨ f x = 6 ∨ f x = 9 :=
  (calendar_annihilator_classification (f x)).mp (calendar_image_annihilated f x)

theorem calendar_image_card_bound (f : ZMod 260 →+ C12) :
    (Finset.univ.image f).card ≤ 4 := by
  have hsub : Finset.univ.image f ⊆ ({0,3,6,9} : Finset C12) := by
    intro y hy
    obtain ⟨x, _, rfl⟩ := Finset.mem_image.mp hy
    simpa only [Finset.mem_insert, Finset.mem_singleton] using calendar_image_classification f x
  have bound := Finset.card_le_card hsub
  have hc : ({0,3,6,9} : Finset C12).card = 4 := by decide
  rwa [hc] at bound

theorem calendar_no_surjective_hom (f : ZMod 260 →+ C12) :
    ¬ Function.Surjective f := by
  intro h
  obtain ⟨x, hx⟩ := h 1
  have impossible := calendar_image_classification f x
  rw [hx] at impossible
  exact (by decide : ¬ ((1 : C12) = 0 ∨ (1 : C12) = 3 ∨ (1 : C12) = 6 ∨ (1 : C12) = 9)) impossible

-- This is an algebraic obstruction, not a claim about historical influence.
end Duodenary

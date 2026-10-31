import Mathlib.Data.Rat.Defs
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.Tactic.NormNum

namespace Duodenary
/-- A classical Erdős–Straus residue family, not a solution of the conjecture.
The parameter is positive rational; positive integer k yields integer denominators. -/
theorem unit_fraction_multiple_three (k : ℚ) (hk : 0 < k) :
    4 / (3*k) = 1/k + 1/(4*k) + 1/(12*k) := by
  have h : k ≠ 0 := ne_of_gt hk
  field_simp
  ring

theorem positive_integer_denominators (k : Nat) (hk : 0 < k) :
    0 < k ∧ 0 < 4*k ∧ 0 < 12*k := by omega

def ThreeUnitFractions (n : Nat) : Prop :=
  ∃ x y z : Nat, 0 < x ∧ 0 < y ∧ 0 < z ∧
    (4 : ℚ) / n = 1 / (x : ℚ) + 1 / (y : ℚ) + 1 / (z : ℚ)

/-- An infinite residue family with positive natural witnesses. -/
theorem multiple_three_certificate (k : Nat) (hk : 0 < k) :
    ThreeUnitFractions (3*k) := by
  refine ⟨k, 4*k, 12*k, hk, by omega, by omega, ?_⟩
  have hq : (0 : ℚ) < (k : ℚ) := by exact_mod_cast hk
  simpa only [Nat.cast_mul, Nat.cast_ofNat] using unit_fraction_multiple_three (k : ℚ) hq
end Duodenary

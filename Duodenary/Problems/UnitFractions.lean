import Duodenary.Core.Cyclic
namespace Duodenary
set_option maxHeartbeats 2000000

def ThreeUnitFractions (n : Nat) : Prop :=
  ∃ x y z : Nat, 0 < x ∧ 0 < y ∧ 0 < z ∧
    4 * x * y * z = n * (y * z + x * z + x * y)

theorem positive_integer_denominators (k : Nat) (hk : 0 < k) :
    0 < k ∧ 0 < 4*k ∧ 0 < 12*k := by
  refine ⟨hk, ?_, ?_⟩
  · exact Nat.mul_pos (Nat.succ_pos 3) hk
  · exact Nat.mul_pos (Nat.succ_pos 11) hk

/- Monomial-normalization helpers: each product of a k-form and a literal-scaled
k-form is rewritten to a literal-scaled monomial with matching atom shapes, so
`omega` closes the final goal by treating `k*k`, `k*(k*k)`, `k*(k*(k*k))` as
shared opaque atoms. -/

private theorem coefs (c1 c2 k : Nat) : (c1 * k) * (c2 * k) = (c1 * c2) * (k * k) := by
  rw [Nat.mul_assoc, Nat.mul_left_comm k c2 k, ← Nat.mul_assoc]

private theorem coef3 (c1 c2 k : Nat) :
    (c1 * k) * (c2 * (k * k)) = (c1 * c2) * (k * (k * k)) := by
  rw [Nat.mul_comm (c1 * k) (c2 * (k * k)), Nat.mul_assoc,
    Nat.mul_comm (k * k) (c1 * k), Nat.mul_assoc, ← Nat.mul_assoc, Nat.mul_comm c2 c1]

private theorem coef4 (c1 c2 k : Nat) :
    (c1 * k) * (c2 * (k * (k * k))) = (c1 * c2) * (k * (k * (k * k))) := by
  rw [Nat.mul_comm (c1 * k) (c2 * (k * (k * k))), Nat.mul_assoc,
    Nat.mul_comm (k * (k * k)) (c1 * k), Nat.mul_assoc, ← Nat.mul_assoc,
    Nat.mul_comm c2 c1]

private theorem coef3r (c1 c2 k : Nat) :
    (c1 * (k * k)) * (c2 * k) = (c1 * c2) * (k * (k * k)) := by
  rw [Nat.mul_comm (c1 * (k * k)) (c2 * k), Nat.mul_assoc,
    Nat.mul_left_comm k c1 (k * k), ← Nat.mul_assoc, Nat.mul_comm c2 c1]

private theorem coef4r (c1 c2 k : Nat) :
    (c1 * (k * (k * k))) * (c2 * k) = (c1 * c2) * (k * (k * (k * k))) := by
  rw [Nat.mul_comm (c1 * (k * (k * k))) (c2 * k), Nat.mul_assoc,
    Nat.mul_left_comm k c1 (k * (k * k)), ← Nat.mul_assoc, Nat.mul_comm c2 c1]

/-- Core-only normalization: 4*k*(4*k)*(12*k) = 192*(k*k*k). -/
theorem cert1_norm (k : Nat) : 4 * k * (4 * k) * (12 * k) = 192 * (k * k * k) := by
  have h1 : (4*k)*(4*k) = 16*(k*k) := by
    rw [Nat.mul_assoc, Nat.mul_left_comm k 4 k, ← Nat.mul_assoc]
  rw [h1, coef3r 16 12 k, Nat.mul_comm (k*k) k]

theorem cert1_id (k : Nat) :
    (3 * k) * ((4*k) * (12*k) + k * (12*k) + k * (4*k)) = 192 * (k * k * k) := by
  have h1 : (4*k)*(12*k) = 48*(k*k) := by
    rw [Nat.mul_assoc, Nat.mul_left_comm k 12 k, ← Nat.mul_assoc]
  have h2 : k*(12*k) = 12*(k*k) := by rw [Nat.mul_left_comm k 12 k]
  have h3 : k*(4*k) = 4*(k*k) := by rw [Nat.mul_left_comm k 4 k]
  rw [h1, h2, h3, Nat.mul_add, Nat.mul_add,
    coef3 3 48 k, coef3 3 12 k, coef3 3 4 k, Nat.mul_comm (k*k) k]
  omega

theorem multiple_three_certificate (k : Nat) (hk : 0 < k) :
    ThreeUnitFractions (3*k) :=
  ⟨k, 4*k, 12*k, hk, by omega, by omega,
   by rw [cert1_norm, cert1_id]⟩

theorem even_certificate (k : Nat) (hk : 0 < k) : ThreeUnitFractions (2*k) := by
  refine ⟨k, 2*k, 2*k, hk, ?_, ?_, ?_⟩
  · omega
  · omega
  · rw [coefs 4 2 k, coefs 2 2 k, Nat.mul_left_comm k 2 k,
      Nat.mul_add, Nat.mul_add, coef3 2 (2*2) k, coef3 2 2 k, coef3r (4*2) 2 k]
    omega

theorem cert2_id (k : Nat) :
    4 * (k+1) * ((3*k+2)*(k+1)) * (3*k+2)
    = (3*k+2) * (((3*k+2)*(k+1))*(3*k+2) + (k+1)*(3*k+2) + (k+1)*((3*k+2)*(k+1))) := by
  have h1 : (3*k+2)*(k+1) = 3*(k*k) + 5*k + 2 := by
    rw [Nat.add_mul, Nat.mul_add, Nat.mul_add, Nat.mul_comm (3*k) k, Nat.mul_left_comm k 3 k]
    omega
  have h2 : (k+1)*(3*k+2) = 3*(k*k) + 5*k + 2 := by
    rw [Nat.mul_comm (k+1) (3*k+2)]
    exact h1
  have h3 : ((3*k+2)*(k+1))*(3*k+2) = 9*(k*(k*k)) + 21*(k*k) + 16*k + 4 := by
    rw [h1]
    simp only [Nat.add_mul, Nat.mul_add]
    rw [coef3r 3 3 k, coefs 5 3 k]
    omega
  have h4 : (k+1)*((3*k+2)*(k+1)) = 3*(k*(k*k)) + 8*(k*k) + 7*k + 2 := by
    rw [h1, Nat.mul_add, Nat.mul_add, Nat.add_mul, Nat.add_mul, Nat.add_mul,
      Nat.mul_left_comm k 3 (k*k), Nat.mul_left_comm k 5 k]
    simp only [Nat.one_mul]
    omega
  have hL4 : (4*(k+1))*((3*k+2)*(k+1)) = 4*(3*(k*(k*k)) + 8*(k*k) + 7*k + 2) := by
    rw [Nat.mul_assoc, h4]
  rw [h3, h4, h2, hL4, Nat.mul_assoc]
  simp only [Nat.add_mul, Nat.mul_add]
  rw [coef4r 3 3 k, coef3r 8 3 k, coefs 7 3 k,
    coef4 3 9 k, coef3 3 21 k, coefs 3 16 k, coef3 3 3 k, coefs 3 5 k,
    coef4 3 3 k, coef3 3 8 k, coefs 3 7 k]
  omega

theorem two_mod_three_certificate (k : Nat) :
    ThreeUnitFractions (3*k+2) :=
  ⟨k+1, (3*k+2)*(k+1), 3*k+2, by omega, Nat.mul_pos (by omega) (by omega), by omega,
   cert2_id k⟩

/-- Original rational identity restated as the equivalent cross-multiplied form. -/
theorem unit_fraction_multiple_three (k : Nat) (hk : 0 < k) :
    4 * k * (4 * k) * (12 * k) = (3 * k) * ((4*k)*(12*k) + k*(12*k) + k*(4*k)) :=
  (cert1_norm k).trans (cert1_id k |>.symm)
end Duodenary

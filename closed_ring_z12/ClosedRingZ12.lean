/-! Z/12Z closed-ring module, core Lean only (no Mathlib).
    Z/12Z is represented by Nat residues; every operation reduces mod 12.
    Quantifiers are bounded (`∀ x < 12`) so `decide` applies. -/
namespace ClosedRingZ12

def add (x y : Nat) : Nat := (x + y) % 12
def mul (x y : Nat) : Nat := (x * y) % 12
def sub (x y : Nat) : Nat := (x + (12 - y % 12)) % 12

-- Section 1: CRT, Z/12Z -> Z/4Z x Z/3Z
def phi (x : Nat) : Nat × Nat := (x % 4, x % 3)
def phiInv (p : Nat × Nat) : Nat := (9 * p.1 + 4 * p.2) % 12

theorem phi_left_inv : ∀ x < 12, phiInv (phi x) = x := by decide
theorem phi_right_inv : ∀ a < 4, ∀ b < 3, phi (phiInv (a, b)) = (a, b) := by decide
theorem phi_add : ∀ x < 12, ∀ y < 12,
    phi (add x y) = (((phi x).1 + (phi y).1) % 4, ((phi x).2 + (phi y).2) % 3) := by
  decide
theorem phi_mul : ∀ x < 12, ∀ y < 12,
    phi (mul x y) = (((phi x).1 * (phi y).1) % 4, ((phi x).2 * (phi y).2) % 3) := by
  decide
theorem phi_one : phi 1 = (1, 1) := by decide

-- Section 2: fixed-point-free antipodal involution
def J (x : Nat) : Nat := (x + 6) % 12

theorem J_involution : ∀ x < 12, J (J x) = x := by decide
theorem J_no_fixed_points : ∀ x < 12, J x ≠ x := by decide

-- Section 3: geodesic metric and 144-pair partition
def dist (x y : Nat) : Nat := min (sub x y) (sub y x)

theorem dist_eq_zero_iff : ∀ x < 12, ∀ y < 12, (dist x y = 0 ↔ x = y) := by decide
theorem dist_symm : ∀ x < 12, ∀ y < 12, dist x y = dist y x := by decide
theorem dist_triangle : ∀ x < 12, ∀ y < 12, ∀ z < 12,
    dist x z ≤ dist x y + dist y z := by decide
theorem dist_J_isometry : ∀ x < 12, ∀ y < 12, dist (J x) (J y) = dist x y := by decide

def N (d : Nat) : Nat :=
  ((List.range 12).map (fun x => ((List.range 12).filter (fun y => dist x y == d)).length)).foldl
    (· + ·) 0

theorem N_values :
    N 0 = 12 ∧ N 1 = 24 ∧ N 2 = 24 ∧ N 3 = 24 ∧
    N 4 = 24 ∧ N 5 = 24 ∧ N 6 = 12 := by
  decide

theorem metric_partition_sum :
    ((List.range 7).map N).foldl (· + ·) 0 = 144 := by
  decide

-- Section 4: unit group
def isUnit (u : Nat) : Bool := u == 1 || u == 5 || u == 7 || u == 11

theorem unit_self_inverse : ∀ u < 12, isUnit u = true → mul u u = 1 := by decide

theorem unit_commutes_with_J : ∀ u < 12, ∀ x < 12,
    isUnit u = true → mul u (J x) = J (mul u x) := by decide

-- Section 5: master invariant
theorem closed_ring_invariant :
    (∀ x < 12, phiInv (phi x) = x) ∧
    (∀ a < 4, ∀ b < 3, phi (phiInv (a, b)) = (a, b)) ∧
    (∀ x < 12, J (J x) = x) ∧
    (∀ x < 12, ∀ y < 12, (dist x y = 0 ↔ x = y)) ∧
    (∀ x < 12, ∀ y < 12, dist x y = dist y x) ∧
    (∀ x < 12, ∀ y < 12, ∀ z < 12, dist x z ≤ dist x y + dist y z) ∧
    ((List.range 7).map N).foldl (· + ·) 0 = 144 :=
  ⟨phi_left_inv, phi_right_inv, J_involution,
   dist_eq_zero_iff, dist_symm, dist_triangle, metric_partition_sum⟩

-- Corrected unit action (replaces the false isometry claim for all units).
-- u in {1,11}: strict isometry. u in {5,7}: fixes distances 0,2,3,4,6 and swaps 1 <-> 5.
theorem unit_isometry : ∀ u < 12, isUnit u = true → (u = 1 ∨ u = 11) →
    ∀ x < 12, ∀ y < 12, dist (mul u x) (mul u y) = dist x y := by decide
theorem unit_duality : ∀ u < 12, isUnit u = true → (u = 5 ∨ u = 7) →
    ∀ x < 12, ∀ y < 12,
      dist (mul u x) (mul u y) =
        (if dist x y = 1 ∨ dist x y = 5 then 6 - dist x y else dist x y) := by decide

end ClosedRingZ12

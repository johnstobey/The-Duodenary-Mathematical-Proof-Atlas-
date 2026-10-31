import Mathlib.Data.Fin.Basic

/-! A twelve-element ring, using only Lean's bundled finite naturals. -/
namespace Duodenary.MachineCore

abbrev Z12 := Fin 12

-- Fin's arithmetic instances reduce modulo the bound.
def add (x y : Z12) : Z12 := x + y
def mul (x y : Z12) : Z12 := x * y
def neg (x : Z12) : Z12 := -x
def scale (n : Nat) (x : Z12) : Z12 := (n : Z12) * x

theorem add_comm : ∀ x y : Z12, add x y = add y x := by decide
theorem add_assoc : ∀ x y z : Z12, add (add x y) z = add x (add y z) := by decide
theorem add_zero : ∀ x : Z12, add x 0 = x := by decide
theorem zero_add : ∀ x : Z12, add 0 x = x := by decide
theorem add_neg : ∀ x : Z12, add x (neg x) = 0 := by decide
theorem neg_add : ∀ x : Z12, add (neg x) x = 0 := by decide

theorem mul_comm : ∀ x y : Z12, mul x y = mul y x := by decide
theorem mul_assoc : ∀ x y z : Z12, mul (mul x y) z = mul x (mul y z) := by decide
theorem mul_one : ∀ x : Z12, mul x 1 = x := by decide
theorem one_mul : ∀ x : Z12, mul 1 x = x := by decide
theorem mul_add : ∀ x y z : Z12,
    mul x (add y z) = add (mul x y) (mul x z) := by decide
theorem add_mul : ∀ x y z : Z12,
    mul (add x y) z = add (mul x z) (mul y z) := by decide

theorem scale_def (n : Nat) (x : Z12) : scale n x = mul (n : Z12) x := rfl
theorem scale_one : ∀ x : Z12, scale 1 x = x := by decide
theorem scale_zero : ∀ x : Z12, scale 0 x = 0 := by decide
theorem scale_add : ∀ m n : Fin 12, ∀ x : Z12,
    mul (add m n) x = add (mul m x) (mul n x) := add_mul

-- A numeral in Fin 12 is reduced modulo 12, so (12 : Z12) = 0.
theorem twelve_eq_zero : (12 : Z12) = 0 := by decide
theorem twelvefold_periodicity : ∀ x : Z12, add x (12 : Z12) = x := by decide

-- The stronger statement: twelve successive unit rotations are identity.
def rotate (n : Nat) (x : Z12) : Z12 := add x (n : Z12)
theorem rotate_twelve : ∀ x : Z12, rotate 12 x = x := by decide

end Duodenary.MachineCore

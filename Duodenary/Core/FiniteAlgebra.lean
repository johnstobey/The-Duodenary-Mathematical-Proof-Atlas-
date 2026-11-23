import Init.Omega
import Init.Data.Fin.Lemmas

/-!
# Native finite algebra: Z/nZ on `Fin n`, vendored for Fin 12 / Fin 144

Self-contained modular arithmetic on core `Fin n` (Init core; no mathlib).

Contents:
* ring laws (commutative ring axioms) for `Fin n` with wraparound
  addition/multiplication, bundled in `CRingLaws`;
* instances and concrete corollaries for `Fin 12` and `Fin 144`;
* the exponent separation: every element of `Fin 12 × Fin 12` is killed by
  `12`, while `12` does not kill `1` in `Fin 144`;
* the structural theorem: there is no bijective additive homomorphism
  `Z/144Z → Z/12Z × Z/12Z` (hence the rings are not isomorphic — any ring
  isomorphism is in particular a bijective additive homomorphism).
-/

namespace Duodenary

/-! ## Mod-arithmetic helpers on `Nat` -/

theorem mod_add_shift2 (x y n : Nat) : (x + y % n) % n = (x + y) % n := by
  rw [Nat.add_comm x (y % n), Nat.mod_add_mod, Nat.add_comm y x]

theorem mod_mul_shift (x y n : Nat) : (x * y % n) % n = (x % n * y) % n := by
  rw [Nat.mod_mod_of_dvd (x * y) (Nat.dvd_refl n), Nat.mod_mul_mod]

theorem mod_mul_right_shift (k s n : Nat) : (k * (s % n)) % n = (k * s) % n := by
  rw [Nat.mul_mod k (s % n) n, Nat.mul_mod k s n, Nat.mod_mod_of_dvd s (Nat.dvd_refl n)]

/-! ## Native Z/nZ operations on `Fin n` -/

/-- Negation in Z/nZ. -/
def Zneg {n : Nat} (a : Fin n) : Fin n :=
  ⟨(n - a.val) % n, Nat.mod_lt _ (by have := a.isLt; omega)⟩

/-- Scalar multiple `k • x` in Z/nZ. -/
def Zsmul {n : Nat} (k : Nat) (x : Fin n) : Fin n :=
  ⟨(k * x.val) % n, Nat.mod_lt _ (by have := x.isLt; omega)⟩

theorem Zval_add {n : Nat} (a b : Fin n) : (a + b).val = (a.val + b.val) % n :=
  Fin.val_add a b

theorem Zval_mul {n : Nat} (a b : Fin n) : (a * b).val = (a.val * b.val) % n := by
  rw [Fin.mul_def]

@[simp] theorem Zsmul_zero {n : Nat} [NeZero n] (x : Fin n) : Zsmul 0 x = 0 := by
  ext
  show ((0 : Nat) * x.val) % n = (0 : Fin n).val
  rw [Nat.zero_mul, Nat.zero_mod, Fin.val_zero]

theorem Zsmul_succ {n : Nat} (k : Nat) (x : Fin n) : Zsmul (k + 1) x = Zsmul k x + x := by
  ext
  show ((k + 1) * x.val) % n = ((k * x.val) % n + x.val) % n
  rw [Nat.succ_mul, ← Nat.mod_add_mod]

theorem Zsmul_add {n : Nat} (k : Nat) (x y : Fin n) :
    Zsmul k (x + y) = Zsmul k x + Zsmul k y := by
  ext
  show (k * (x + y).val) % n = ((k * x.val) % n + (k * y.val) % n) % n
  rw [Fin.val_add, mod_mul_right_shift, ← Nat.add_mod, Nat.mul_add]

/-! ## Additive and multiplicative laws -/

theorem Zadd_assoc {n : Nat} (a b c : Fin n) : a + b + c = a + (b + c) := by
  ext
  show ((a.val + b.val) % n + c.val) % n = (a.val + (b.val + c.val) % n) % n
  rw [Nat.mod_add_mod, mod_add_shift2, Nat.add_assoc]

theorem Zadd_comm {n : Nat} (a b : Fin n) : a + b = b + a := by
  ext
  show (a.val + b.val) % n = (b.val + a.val) % n
  rw [Nat.add_comm]

theorem Zadd_zero_left {n : Nat} [NeZero n] (x : Fin n) : (0 : Fin n) + x = x := by
  ext
  show ((0 : Fin n).val + x.val) % n = x.val
  rw [Fin.val_zero, Nat.zero_add, Nat.mod_eq_of_lt x.isLt]

theorem Zadd_zero_right {n : Nat} [NeZero n] (x : Fin n) : x + (0 : Fin n) = x := by
  ext
  show (x.val + (0 : Fin n).val) % n = x.val
  rw [Fin.val_zero, Nat.add_zero, Nat.mod_eq_of_lt x.isLt]

theorem Zneg_add_self {n : Nat} [NeZero n] (a : Fin n) : Zneg a + a = 0 := by
  ext
  show ((n - a.val) % n + a.val) % n = (0 : Fin n).val
  rcases Nat.eq_zero_or_pos a.val with h | h
  · rw [h, Nat.sub_zero, Nat.mod_self, Nat.zero_add, Nat.zero_mod, Fin.val_zero]
  · have hle : a.val ≤ n := Nat.le_of_lt a.isLt
    have hlt : n - a.val < n := by omega
    rw [Nat.mod_eq_of_lt hlt, Nat.sub_add_cancel hle, Nat.mod_self, Fin.val_zero]

theorem Zmul_one {n : Nat} [NeZero n] (a : Fin n) : (1 : Fin n) * a = a := by
  have hval : (1 : Fin n).val = 1 % n := rfl
  ext
  show ((1 : Fin n).val * a.val) % n = a.val
  rw [hval]
  rcases Nat.eq_zero_or_pos a.val with h | h
  · rw [h, Nat.mul_zero, Nat.zero_mod]
  · have hn : 1 < n := Nat.lt_of_le_of_lt (Nat.succ_le_of_lt h) a.isLt
    rw [Nat.mod_eq_of_lt hn, Nat.one_mul, Nat.mod_eq_of_lt a.isLt]

theorem Zmul_comm {n : Nat} (a b : Fin n) : a * b = b * a := by
  ext
  show (a.val * b.val) % n = (b.val * a.val) % n
  rw [Nat.mul_comm]

theorem Zmul_assoc {n : Nat} (a b c : Fin n) : a * b * c = a * (b * c) := by
  ext
  show ((a.val * b.val) % n * c.val) % n = (a.val * ((b.val * c.val) % n)) % n
  rw [Nat.mod_mul_mod, mod_mul_right_shift, Nat.mul_assoc]

theorem Zmul_add {n : Nat} (a b c : Fin n) : (a + b) * c = a * c + b * c := by
  ext
  show ((a.val + b.val) % n * c.val) % n = ((a.val * c.val) % n + (b.val * c.val) % n) % n
  rw [Nat.mod_mul_mod, Nat.add_mul, ← Nat.add_mod]

theorem Zadd_mul {n : Nat} (a b c : Fin n) : c * (a + b) = c * a + c * b := by
  ext
  show (c.val * ((a.val + b.val) % n)) % n = ((c.val * a.val) % n + (c.val * b.val) % n) % n
  rw [mod_mul_right_shift, Nat.mul_add, Nat.add_mod]

/-! ## Bundled commutative ring laws -/

/-- Bundled commutative ring laws (native, no mathlib classes). -/
structure CRingLaws (R : Type) [Add R] [Mul R] [Zero R] [OfNat R 1] where
  /-- Addition is commutative. -/
  add_comm : ∀ a b : R, a + b = b + a
  /-- Addition is associative. -/
  add_assoc : ∀ a b c : R, a + b + c = a + (b + c)
  /-- Zero is the additive identity (on the left). -/
  zero_add : ∀ a : R, 0 + a = a
  /-- Multiplication is commutative. -/
  mul_comm : ∀ a b : R, a * b = b * a
  /-- Multiplication is associative. -/
  mul_assoc : ∀ a b c : R, a * b * c = a * (b * c)
  /-- One is the multiplicative identity (on the left). -/
  one_mul : ∀ a : R, 1 * a = a
  /-- Multiplication left-distributes over addition. -/
  left_distrib : ∀ a b c : R, (a + b) * c = a * c + b * c
  /-- Multiplication right-distributes over addition. -/
  right_distrib : ∀ a b c : R, a * (b + c) = a * b + a * c

instance {n : Nat} [NeZero n] : CRingLaws (Fin n) where
  add_comm := Zadd_comm
  add_assoc := Zadd_assoc
  zero_add := Zadd_zero_left
  mul_comm := Zmul_comm
  mul_assoc := Zmul_assoc
  one_mul := Zmul_one
  left_distrib := Zmul_add
  right_distrib := fun a b c => Zadd_mul b c a

/-- `Fin 12` carries the vendored ring laws of Z/12Z. -/
theorem zmod12_ring_laws : CRingLaws (Fin 12) := inferInstance

/-- `Fin 144` carries the vendored ring laws of Z/144Z. -/
theorem zmod144_ring_laws : CRingLaws (Fin 144) := inferInstance

/-! ## Product group Z/12 × Z/12 -/

/-- Componentwise addition on the product. -/
def Padd {m n : Nat} (p q : Fin m × Fin n) : Fin m × Fin n := (p.1 + q.1, p.2 + q.2)

/-- Componentwise scalar multiple. -/
def Psmul {m n : Nat} (k : Nat) (p : Fin m × Fin n) : Fin m × Fin n :=
  (Zsmul k p.1, Zsmul k p.2)

theorem Psmul_zero {m n : Nat} [NeZero m] [NeZero n] (p : Fin m × Fin n) :
    Psmul 0 p = (0, 0) := by
  show (Zsmul 0 p.1, Zsmul 0 p.2) = (0, 0)
  rw [Zsmul_zero, Zsmul_zero]

theorem Psmul_succ {m n : Nat} (k : Nat) (p : Fin m × Fin n) :
    Psmul (k + 1) p = Padd (Psmul k p) p := by
  show (Zsmul (k + 1) p.1, Zsmul (k + 1) p.2) = (Zsmul k p.1 + p.1, Zsmul k p.2 + p.2)
  rw [Zsmul_succ, Zsmul_succ]

/-- Every element of Z/12 is killed by 12 (exponent 12). -/
theorem Zsmul_12_eq_zero_Fin12 (x : Fin 12) : Zsmul 12 x = 0 := by
  ext
  show ((12 : Nat) * x.val) % 12 = (0 : Fin 12).val
  rw [Fin.val_zero, Nat.mul_mod_right]

/-- 12 does not kill 1 in Z/144 (the additive exponent of Z/144Z is not 12). -/
theorem Zsmul_12_one_Z144_ne_zero : Zsmul 12 (1 : Fin 144) ≠ 0 := by
  intro h
  have hv : (Zsmul 12 (1 : Fin 144)).val = 12 := by
    show ((12 : Nat) * (1 : Fin 144).val) % 144 = 12
    rw [Fin.val_one, Nat.mul_one, Nat.mod_eq_of_lt (by omega)]
  rw [h, Fin.val_zero] at hv
  omega

theorem Psmul_12_eq_zero (p : Fin 12 × Fin 12) : Psmul 12 p = (0, 0) := by
  cases p with
  | mk a b =>
    show (Zsmul 12 a, Zsmul 12 b) = (0, 0)
    rw [Zsmul_12_eq_zero_Fin12 a, Zsmul_12_eq_zero_Fin12 b]

/-- Componentwise negation. -/
def Pneg {m n : Nat} (p : Fin m × Fin n) : Fin m × Fin n := (Zneg p.1, Zneg p.2)

theorem Padd_assoc {m n : Nat} (a b c : Fin m × Fin n) :
    Padd (Padd a b) c = Padd a (Padd b c) := by
  show ((a.1 + b.1) + c.1, (a.2 + b.2) + c.2) = (a.1 + (b.1 + c.1), a.2 + (b.2 + c.2))
  rw [Zadd_assoc, Zadd_assoc]

theorem Padd_zero {m n : Nat} [NeZero m] [NeZero n] (p : Fin m × Fin n) :
    Padd p (0, 0) = p := by
  show (p.1 + (0 : Fin m), p.2 + (0 : Fin n)) = (p.1, p.2)
  rw [Zadd_zero_right, Zadd_zero_right]

theorem Pneg_add_self {m n : Nat} [NeZero m] [NeZero n] (p : Fin m × Fin n) :
    Padd p (Pneg p) = (0, 0) := by
  show (p.1 + Zneg p.1, p.2 + Zneg p.2) = ((0 : Fin m), (0 : Fin n))
  rw [Zadd_comm, Zneg_add_self, Zadd_comm, Zneg_add_self]

/-! ## The isomorphism obstruction -/

/-- Any additive map respects `Zsmul`. -/
theorem hom_Zsmul {f : Fin 144 → Fin 12 × Fin 12}
    (hadd : ∀ x y : Fin 144, f (x + y) = Padd (f x) (f y))
    (hf0 : f 0 = (0, 0)) (k : Nat) (x : Fin 144) :
    f (Zsmul k x) = Psmul k (f x) := by
  induction k with
  | zero => rw [Zsmul_zero, hf0, Psmul_zero]
  | succ k ih => rw [Zsmul_succ, hadd, ih, Psmul_succ]

/-- There is no bijective additive homomorphism Z/144Z → Z/12Z × Z/12Z.

Exponent obstruction: additivity forces `f 0 = (0,0)` and
`f (12 • 1) = 12 • (f 1) = (0,0) = f 0`, so injectivity would give
`12 • 1 = 0` in Z/144Z — false, since `12 • 1 = 12 ≠ 0`. Every ring
isomorphism is a bijective additive homomorphism, so Z/144Z is not
isomorphic to Z/12Z × Z/12Z. -/
theorem no_bij_add_hom_Z144_prodZ12
    (f : Fin 144 → Fin 12 × Fin 12)
    (hadd : ∀ x y : Fin 144, f (x + y) = Padd (f x) (f y))
    (hinj : ∀ x y : Fin 144, f x = f y → x = y) : False := by
  have h1 : f 0 = Padd (f 0) (f 0) := by
    rw [← hadd 0 0, Zadd_zero_left]
  have h2 : Padd (f 0) (Pneg (f 0)) = (0, 0) := Pneg_add_self (f 0)
  have h4 : Padd (Padd (f 0) (f 0)) (Pneg (f 0)) = Padd (f 0) ((0, 0) : Fin 12 × Fin 12) := by
    rw [Padd_assoc, h2]
  have h5 : ((0, 0) : Fin 12 × Fin 12) = Padd (f 0) ((0, 0) : Fin 12 × Fin 12) := by
    rw [← h2, ← Padd_assoc, ← h1]
  have hf0 : f 0 = ((0, 0) : Fin 12 × Fin 12) :=
    (h5.trans (Padd_zero (f 0))).symm
  have hkey : f (Zsmul 12 (1 : Fin 144)) = f 0 := by
    rw [hom_Zsmul hadd hf0, Psmul_12_eq_zero, hf0]
  exact Zsmul_12_one_Z144_ne_zero (hinj _ _ hkey)

end Duodenary

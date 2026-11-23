import Init.Omega
import Init.Data.Nat.Gcd
import Init.Data.Nat.Dvd
import Init.Data.Int.Basic
import Init.Data.Int.DivModLemmas
import Init.Data.Int.Order

/-!
# Native rational numbers and their order

A self-contained rational number type `Duodenary.Q` built from `Nat`/`Int`
primitives only (Init core; no mathlib).

Design: a rational is a fraction `num / den` with `den > 0`, stored in lowest
terms (enforced by the smart constructor `Q.mkRat`, which divides out
`num.natAbs.gcd den`). Because representatives are canonical, equality is
field equality and the order relations are defined by cross-multiplication.

Contents: `<` and `≤` with the standard laws, `Nat`/`Int` casts, and the
positivity lemmas (`Q.pos_iff`, `Q.mul_pos`, `Q.add_pos`, `Q.neg_pos`, ...).
-/

namespace Duodenary

/-! ## Auxiliary number theory on `Nat` -/

/-- Positivity of division by a divisor of a positive number (native `Nat.div_pos`). -/
private theorem natDivPos {a b : Nat} (hba : b ∣ a) (ha : 0 < a) : 0 < a / b := by
  obtain ⟨k, hk⟩ := hba
  rcases Nat.eq_zero_or_pos b with hb0 | hbp
  · subst hb0
    simp at hk
    omega
  · rw [hk, Nat.mul_div_cancel_left k hbp]
    rcases Nat.eq_zero_or_pos k with hk0 | hkp
    · subst hk0
      simp at hk
      omega
    · exact hkp

/-- Euclid's lemma (native): a common divisor coprime to `a` divides `b`. -/
theorem natEuclid {a b c : Nat} (hab : c ∣ a * b) (hcop : a.gcd c = 1) : c ∣ b := by
  have h1 : c ∣ c * b := ⟨b, rfl⟩
  have h3 : c ∣ (c * b).gcd (a * b) := Nat.dvd_gcd h1 hab
  have key : (c * b).gcd (a * b) = c.gcd a * b := Nat.gcd_mul_right c b a
  rw [key, Nat.gcd_comm c a, hcop, Nat.one_mul] at h3
  exact h3

/-- Dividing by the gcd leaves a coprime pair. -/
theorem gcd_div_gcd (a b : Nat) (h : 0 < b) : (a / a.gcd b).gcd (b / a.gcd b) = 1 := by
  have hgpos : 0 < a.gcd b := Nat.gcd_pos_of_pos_right a h
  have hd1 : a.gcd b ∣ a := Nat.gcd_dvd_left a b
  have hd2 : a.gcd b ∣ b := Nat.gcd_dvd_right a b
  have ha : a.gcd b * (a / a.gcd b) = a := Nat.mul_div_cancel' hd1
  have hb : a.gcd b * (b / a.gcd b) = b := Nat.mul_div_cancel' hd2
  have hq2 : 0 < b / a.gcd b := natDivPos hd2 h
  have hgd1 : a.gcd b * ((a / a.gcd b).gcd (b / a.gcd b)) ∣ a := by
    have hh := Nat.mul_dvd_mul_left (a.gcd b)
      (Nat.gcd_dvd_left (a / a.gcd b) (b / a.gcd b))
    rw [ha] at hh
    exact hh
  have hgd2 : a.gcd b * ((a / a.gcd b).gcd (b / a.gcd b)) ∣ b := by
    have hh := Nat.mul_dvd_mul_left (a.gcd b)
      (Nat.gcd_dvd_right (a / a.gcd b) (b / a.gcd b))
    rw [hb] at hh
    exact hh
  have hgdg : a.gcd b * ((a / a.gcd b).gcd (b / a.gcd b)) ∣ a.gcd b := Nat.dvd_gcd hgd1 hgd2
  have hdpos : 0 < (a / a.gcd b).gcd (b / a.gcd b) :=
    Nat.gcd_pos_of_pos_right _ hq2
  have hle : a.gcd b * ((a / a.gcd b).gcd (b / a.gcd b)) ≤ a.gcd b * 1 := by
    rw [Nat.mul_one]; exact Nat.le_of_dvd hgpos hgdg
  have hdle : (a / a.gcd b).gcd (b / a.gcd b) ≤ 1 :=
    Nat.le_of_mul_le_mul_left hle hgpos
  omega

/-! ## The type of rationals -/

/-- A rational number: a reduced fraction with positive denominator. -/
structure Q where
  /-- Numerator (carries the sign). -/
  num : Int
  /-- Denominator (positive). -/
  den : Nat
  /-- The denominator is positive. -/
  den_pos : 0 < den
  /-- The fraction is in lowest terms. -/
  reduced : num.natAbs.gcd den = 1

/-- Smart constructor: reduce `num / den` to lowest terms (`den > 0`). -/
def Q.mkRat (num : Int) (den : Nat) (hden : 0 < den) : Q where
  num := num.tdiv ↑(num.natAbs.gcd den)
  den := den / num.natAbs.gcd den
  den_pos := natDivPos (Nat.gcd_dvd_right num.natAbs den) hden
  reduced := by
    have h := gcd_div_gcd num.natAbs den hden
    rwa [Int.natAbs_tdiv, Int.natAbs_ofNat]

@[simp] theorem Q.num_mkRat (n : Int) (d : Nat) (h : 0 < d) :
    (Q.mkRat n d h).num = n.tdiv ↑(n.natAbs.gcd d) := rfl

@[simp] theorem Q.den_mkRat (n : Int) (d : Nat) (h : 0 < d) :
    (Q.mkRat n d h).den = d / n.natAbs.gcd d := rfl

theorem Q.eq_of_num_eq_of_den_eq {a b : Q} (h1 : a.num = b.num) (h2 : a.den = b.den) :
    a = b := by
  cases a with | mk an ad _ _ =>
  cases b with | mk bn bd _ _ =>
  simp_all [Q.mk.injEq]

/-! ## Canonical uniqueness (cross-multiplication determines the fraction) -/

/-- Two reduced fractions with equal cross products are equal. -/
theorem Q.eq_of_cross_eq (a b : Q) (h : a.num * ↑b.den = b.num * ↑a.den) : a = b := by
  have hdm : b.den ∣ a.den := by
    have hint : (↑b.den : Int) ∣ b.num * ↑a.den := by
      refine ⟨a.num, ?_⟩
      simp [h, Int.mul_comm]
    have hnat : b.den ∣ b.num.natAbs * a.den := by
      have h := Int.ofNat_dvd_left.mp hint
      rw [Int.natAbs_mul, Int.natAbs_ofNat] at h
      exact h
    exact natEuclid hnat b.reduced
  have hdm' : a.den ∣ b.den := by
    have hint : (↑a.den : Int) ∣ a.num * ↑b.den := by
      refine ⟨b.num, ?_⟩
      simp [← h, Int.mul_comm]
    have hnat : a.den ∣ a.num.natAbs * b.den := by
      have h := Int.ofNat_dvd_left.mp hint
      rw [Int.natAbs_mul, Int.natAbs_ofNat] at h
      exact h
    exact natEuclid hnat a.reduced
  have hden : a.den = b.den := Nat.dvd_antisymm hdm' hdm
  have hnum : a.num = b.num := by
    rw [← hden] at h
    rcases Int.lt_trichotomy a.num b.num with hc | hc | hc
    · exact absurd h (by
        have hlt : a.num * ↑a.den < b.num * ↑a.den :=
          Int.mul_lt_mul_of_pos_right hc (Int.ofNat_pos.mpr a.den_pos)
        omega)
    · exact hc
    · exact absurd h (by
        have hlt : b.num * ↑a.den < a.num * ↑a.den :=
          Int.mul_lt_mul_of_pos_right hc (Int.ofNat_pos.mpr a.den_pos)
        omega)
  exact Q.eq_of_num_eq_of_den_eq hnum hden

/-! ## Arithmetic operations -/

instance : Zero Q := ⟨Q.mkRat 0 1 (by omega)⟩
instance : OfNat Q 0 := ⟨Q.mkRat 0 1 (by omega)⟩
instance : OfNat Q 1 := ⟨Q.mkRat 1 1 (by omega)⟩
instance : Neg Q := ⟨fun a => Q.mkRat (-a.num) a.den a.den_pos⟩
instance : Add Q := ⟨fun a b =>
  Q.mkRat (a.num * ↑b.den + b.num * ↑a.den) (a.den * b.den)
    (Nat.mul_pos a.den_pos b.den_pos)⟩
instance : Sub Q := ⟨fun a b => a + -b⟩
instance : Mul Q := ⟨fun a b =>
  Q.mkRat (a.num * b.num) (a.den * b.den) (Nat.mul_pos a.den_pos b.den_pos)⟩

@[simp] theorem Q.zero_num : (0 : Q).num = 0 := by
  rw [show (0 : Q) = Q.mkRat 0 1 (by omega) from rfl, Q.num_mkRat, Nat.gcd_one_right]
  exact Int.tdiv_one 0

@[simp] theorem Q.zero_den : (0 : Q).den = 1 := by
  rw [show (0 : Q) = Q.mkRat 0 1 (by omega) from rfl, Q.den_mkRat, Nat.gcd_one_right,
    Nat.div_one]

@[simp] theorem Q.one_num : (1 : Q).num = 1 := by
  rw [show (1 : Q) = Q.mkRat 1 1 (by omega) from rfl, Q.num_mkRat, Nat.gcd_one_right]
  exact Int.tdiv_one 1

@[simp] theorem Q.one_den : (1 : Q).den = 1 := by
  rw [show (1 : Q) = Q.mkRat 1 1 (by omega) from rfl, Q.den_mkRat, Nat.gcd_one_right,
    Nat.div_one]

@[simp] theorem Q.num_neg (a : Q) : (-a).num = -a.num := by
  have h : (-a) = Q.mkRat (-a.num) a.den a.den_pos := rfl
  rw [h, Q.num_mkRat, Int.natAbs_neg, a.reduced]
  exact Int.tdiv_one (-a.num)

@[simp] theorem Q.den_neg (a : Q) : (-a).den = a.den := by
  have h : (-a) = Q.mkRat (-a.num) a.den a.den_pos := rfl
  rw [h, Q.den_mkRat, Int.natAbs_neg, a.reduced, Nat.div_one]

/-! ## Casts from Nat and Int -/

/-- Cast a natural number to a rational. -/
def ofNat (n : Nat) : Q := Q.mkRat n 1 (by omega)

/-- Cast an integer to a rational. -/
def ofInt (i : Int) : Q := Q.mkRat i 1 (by omega)

instance : NatCast Q := ⟨ofNat⟩
instance : IntCast Q := ⟨ofInt⟩

@[simp] theorem Q.natCast_num (n : Nat) : (n : Q).num = n := by
  rw [show (n : Q) = Q.mkRat n 1 (by omega) from rfl, Q.num_mkRat, Nat.gcd_one_right]
  exact Int.tdiv_one n

@[simp] theorem Q.natCast_den (n : Nat) : (n : Q).den = 1 := by
  rw [show (n : Q) = Q.mkRat n 1 (by omega) from rfl, Q.den_mkRat, Nat.gcd_one_right,
    Nat.div_one]

@[simp] theorem Q.intCast_num (i : Int) : (i : Q).num = i := by
  rw [show (i : Q) = Q.mkRat i 1 (by omega) from rfl, Q.num_mkRat, Nat.gcd_one_right]
  exact Int.tdiv_one i

@[simp] theorem Q.intCast_den (i : Int) : (i : Q).den = 1 := by
  rw [show (i : Q) = Q.mkRat i 1 (by omega) from rfl, Q.den_mkRat, Nat.gcd_one_right,
    Nat.div_one]

theorem Q.natCast_inj {m n : Nat} : (m : Q) = n ↔ m = n := by
  constructor
  · intro h
    have h2 := congrArg Q.num h
    rwa [natCast_num, natCast_num, Int.ofNat_inj] at h2
  · intro h
    subst h
    rfl

theorem Q.intCast_inj {i j : Int} : (i : Q) = j ↔ i = j := by
  constructor
  · intro h
    have h2 := congrArg Q.num h
    rwa [intCast_num, intCast_num] at h2
  · intro h
    subst h
    rfl

theorem Q.intCast_eq_natCast (i : Int) (n : Nat) : (i : Q) = n ↔ i = n := by
  constructor
  · intro h
    have h2 := congrArg Q.num h
    rwa [intCast_num, natCast_num] at h2
  · intro h
    subst h
    rfl

/-! ## Order relations -/

instance : LE Q := ⟨fun a b => a.num * ↑b.den ≤ b.num * ↑a.den⟩
instance : LT Q := ⟨fun a b => a.num * ↑b.den < b.num * ↑a.den⟩

instance (a b : Q) : Decidable (a ≤ b) :=
  inferInstanceAs (Decidable (a.num * ↑b.den ≤ b.num * ↑a.den))
instance (a b : Q) : Decidable (a < b) :=
  inferInstanceAs (Decidable (a.num * ↑b.den < b.num * ↑a.den))

theorem Q.le_def (a b : Q) : a ≤ b ↔ a.num * ↑b.den ≤ b.num * ↑a.den := Iff.rfl
theorem Q.lt_def (a b : Q) : a < b ↔ a.num * ↑b.den < b.num * ↑a.den := Iff.rfl

@[simp] theorem Q.le_refl (a : Q) : a ≤ a := Int.le_refl _

/-- Rearrangement simp set for cross-product associativity/commutativity. -/
private theorem Q.mulCommAux (a b : Int) : a * b = b * a := Int.mul_comm a b

theorem Q.le_trans {a b c : Q} (h1 : a ≤ b) (h2 : b ≤ c) : a ≤ c := by
  rw [le_def] at h1 h2 ⊢
  have e1 : a.num * ↑b.den * ↑c.den ≤ b.num * ↑a.den * ↑c.den :=
    Int.mul_le_mul_of_nonneg_right h1 (Int.ofNat_nonneg _)
  have e2 : b.num * ↑c.den * ↑a.den ≤ c.num * ↑b.den * ↑a.den :=
    Int.mul_le_mul_of_nonneg_right h2 (Int.ofNat_nonneg _)
  have br : b.num * ↑a.den * ↑c.den = b.num * ↑c.den * ↑a.den := by
    rw [Int.mul_assoc, Int.mul_comm (↑a.den) (↑c.den), ← Int.mul_assoc]
  rw [br] at e1
  have chain : a.num * ↑b.den * ↑c.den ≤ c.num * ↑b.den * ↑a.den :=
    Int.le_trans e1 e2
  refine Int.le_of_mul_le_mul_right ?_ (Int.ofNat_pos.mpr b.den_pos)
  simpa [Int.mul_comm, Int.mul_assoc, Int.mul_left_comm] using chain

theorem Q.le_antisym {a b : Q} (h1 : a ≤ b) (h2 : b ≤ a) : a = b :=
  Q.eq_of_cross_eq a b (Int.le_antisymm h1 h2)

theorem Q.le_total (a b : Q) : a ≤ b ∨ b ≤ a := Int.le_total _ _

theorem Q.le_of_lt {a b : Q} (h : a < b) : a ≤ b := Int.le_of_lt h

theorem Q.lt_irrefl (a : Q) : ¬ a < a := Int.lt_irrefl _

theorem Q.lt_iff_le_not_le {a b : Q} : a < b ↔ a ≤ b ∧ ¬ b ≤ a := Int.lt_iff_le_not_le

theorem Q.lt_trans {a b c : Q} (h1 : a < b) (h2 : b < c) : a < c := by
  rw [lt_def] at h1 h2 ⊢
  have e1 : a.num * ↑b.den * ↑c.den < b.num * ↑a.den * ↑c.den :=
    Int.mul_lt_mul_of_pos_right h1 (Int.ofNat_pos.mpr c.den_pos)
  have e2 : b.num * ↑c.den * ↑a.den < c.num * ↑b.den * ↑a.den :=
    Int.mul_lt_mul_of_pos_right h2 (Int.ofNat_pos.mpr a.den_pos)
  have br : b.num * ↑a.den * ↑c.den = b.num * ↑c.den * ↑a.den := by
    rw [Int.mul_assoc, Int.mul_comm (↑a.den) (↑c.den), ← Int.mul_assoc]
  rw [br] at e1
  have chain : a.num * ↑b.den * ↑c.den < c.num * ↑b.den * ↑a.den :=
    Int.lt_trans e1 e2
  refine Int.lt_of_mul_lt_mul_right ?_ (Int.ofNat_nonneg b.den)
  simpa [Int.mul_comm, Int.mul_assoc, Int.mul_left_comm] using chain

theorem Q.lt_of_le_of_lt {a b c : Q} (h1 : a ≤ b) (h2 : b < c) : a < c := by
  rw [le_def] at h1
  rw [lt_def] at h2 ⊢
  have e1 : a.num * ↑b.den * ↑c.den ≤ b.num * ↑a.den * ↑c.den :=
    Int.mul_le_mul_of_nonneg_right h1 (Int.ofNat_nonneg _)
  have e2 : b.num * ↑c.den * ↑a.den < c.num * ↑b.den * ↑a.den :=
    Int.mul_lt_mul_of_pos_right h2 (Int.ofNat_pos.mpr a.den_pos)
  have br : b.num * ↑a.den * ↑c.den = b.num * ↑c.den * ↑a.den := by
    rw [Int.mul_assoc, Int.mul_comm (↑a.den) (↑c.den), ← Int.mul_assoc]
  rw [br] at e1
  have chain : a.num * ↑b.den * ↑c.den < c.num * ↑b.den * ↑a.den :=
    Int.lt_of_le_of_lt e1 e2
  refine Int.lt_of_mul_lt_mul_right ?_ (Int.ofNat_nonneg b.den)
  simpa [Int.mul_comm, Int.mul_assoc, Int.mul_left_comm] using chain

theorem Q.lt_of_lt_of_le {a b c : Q} (h1 : a < b) (h2 : b ≤ c) : a < c := by
  rw [lt_def] at h1
  rw [le_def] at h2
  rw [lt_def]
  have e1 : a.num * ↑b.den * ↑c.den < b.num * ↑a.den * ↑c.den :=
    Int.mul_lt_mul_of_pos_right h1 (Int.ofNat_pos.mpr c.den_pos)
  have e2 : b.num * ↑c.den * ↑a.den ≤ c.num * ↑b.den * ↑a.den :=
    Int.mul_le_mul_of_nonneg_right h2 (Int.ofNat_nonneg _)
  have br : b.num * ↑a.den * ↑c.den = b.num * ↑c.den * ↑a.den := by
    rw [Int.mul_assoc, Int.mul_comm (↑a.den) (↑c.den), ← Int.mul_assoc]
  rw [br] at e1
  have chain : a.num * ↑b.den * ↑c.den < c.num * ↑b.den * ↑a.den :=
    Int.lt_of_lt_of_le e1 e2
  refine Int.lt_of_mul_lt_mul_right ?_ (Int.ofNat_nonneg b.den)
  simpa [Int.mul_comm, Int.mul_assoc, Int.mul_left_comm] using chain

/-! ## Positivity lemmas -/

/-- The numerator of `Q.mkRat` is positive when the input numerator is. -/
private theorem Q.mkRat_num_pos {n : Int} {d : Nat} (hn : 0 < n) (hden : 0 < d) :
    0 < (Q.mkRat n d hden).num := by
  rw [Q.num_mkRat]
  have hg : (0 : Int) < ↑(n.natAbs.gcd d) :=
    Int.ofNat_pos.mpr (Nat.gcd_pos_of_pos_right _ hden)
  have hdvd : ↑(n.natAbs.gcd d) ∣ n :=
    Int.natAbs_dvd_natAbs.mp (by rw [Int.natAbs_ofNat]; exact Nat.gcd_dvd_left _ _)
  have hq : n.tdiv ↑(n.natAbs.gcd d) * ↑(n.natAbs.gcd d) = n :=
    Int.tdiv_mul_cancel hdvd
  rcases Int.lt_trichotomy (n.tdiv ↑(n.natAbs.gcd d)) 0 with hc | hc | hc
  · exfalso
    have hlt := Int.mul_lt_mul_of_pos_right hc hg
    rw [Int.zero_mul, hq] at hlt
    omega
  · exfalso
    rw [hc, Int.zero_mul] at hq
    omega
  · exact hc

/-- The numerator of `Q.mkRat` is nonnegative when the input numerator is. -/
private theorem Q.mkRat_num_nonneg {n : Int} {d : Nat} (hn : 0 ≤ n) (hden : 0 < d) :
    0 ≤ (Q.mkRat n d hden).num := by
  rw [Q.num_mkRat]
  exact Int.tdiv_nonneg hn (Int.ofNat_nonneg _)

/-- Positivity of a rational is positivity of its numerator. -/
@[simp] theorem Q.pos_iff (a : Q) : 0 < a ↔ 0 < a.num := by
  constructor
  · intro h
    rw [lt_def, zero_num, zero_den, Int.zero_mul, Int.ofNat_one, Int.mul_one] at h
    exact h
  · intro h
    rw [lt_def, zero_num, zero_den, Int.zero_mul, Int.ofNat_one, Int.mul_one]
    exact h

/-- Nonnegativity of a rational is nonnegativity of its numerator. -/
@[simp] theorem Q.nonneg_iff (a : Q) : 0 ≤ a ↔ 0 ≤ a.num := by
  constructor
  · intro h
    rw [le_def, zero_num, zero_den, Int.zero_mul, Int.ofNat_one, Int.mul_one] at h
    exact h
  · intro h
    rw [le_def, zero_num, zero_den, Int.zero_mul, Int.ofNat_one, Int.mul_one]
    exact h

/-- A rational is negative exactly when its numerator is. -/
@[simp] theorem Q.neg_iff (a : Q) : a < 0 ↔ a.num < 0 := by
  constructor
  · intro h
    rw [lt_def, zero_num, zero_den, Int.zero_mul, Int.ofNat_one, Int.mul_one] at h
    exact h
  · intro h
    rw [lt_def, zero_num, zero_den, Int.zero_mul, Int.ofNat_one, Int.mul_one]
    exact h

/-- Positivity of the cast of a natural number. -/
theorem Q.natCast_pos (n : Nat) : 0 < (n : Q) ↔ 0 < n := by
  rw [lt_def, natCast_num, natCast_den, zero_num, zero_den, Int.zero_mul, Int.ofNat_one,
    Int.mul_one]
  exact Int.ofNat_lt

/-- The cast of a natural number is nonnegative. -/
theorem Q.natCast_nonneg (n : Nat) : 0 ≤ (n : Q) := by
  rw [le_def, natCast_num, natCast_den, zero_num, zero_den, Int.zero_mul, Int.ofNat_one,
    Int.mul_one]
  exact Int.ofNat_nonneg n

/-- Positivity of the cast of an integer. -/
theorem Q.intCast_pos (i : Int) : 0 < (i : Q) ↔ 0 < i := by
  rw [lt_def, intCast_num, intCast_den, zero_num, zero_den, Int.zero_mul, Int.ofNat_one,
    Int.mul_one]

theorem Q.mul_pos {a b : Q} (ha : 0 < a) (hb : 0 < b) : 0 < a * b := by
  have key : (0 : Int) < a.num * b.num :=
    Int.mul_pos ((Q.pos_iff _).mp ha) ((Q.pos_iff _).mp hb)
  rw [lt_def, zero_num, zero_den, Int.zero_mul, Int.ofNat_one, Int.mul_one]
  exact Q.mkRat_num_pos key (Nat.mul_pos a.den_pos b.den_pos)

theorem Q.mul_nonneg {a b : Q} (ha : 0 ≤ a) (hb : 0 ≤ b) : 0 ≤ a * b := by
  have key : (0 : Int) ≤ a.num * b.num :=
    Int.mul_nonneg ((Q.nonneg_iff _).mp ha) ((Q.nonneg_iff _).mp hb)
  rw [le_def, zero_num, zero_den, Int.zero_mul, Int.ofNat_one, Int.mul_one]
  exact Q.mkRat_num_nonneg key (Nat.mul_pos a.den_pos b.den_pos)

theorem Q.add_pos {a b : Q} (ha : 0 < a) (hb : 0 < b) : 0 < a + b := by
  have e1 : (0 : Int) < a.num * ↑b.den :=
    Int.mul_pos ((Q.pos_iff _).mp ha) (Int.ofNat_pos.mpr b.den_pos)
  have e2 : (0 : Int) < b.num * ↑a.den :=
    Int.mul_pos ((Q.pos_iff _).mp hb) (Int.ofNat_pos.mpr a.den_pos)
  have key : (0 : Int) < a.num * ↑b.den + b.num * ↑a.den := by omega
  rw [lt_def, zero_num, zero_den, Int.zero_mul, Int.ofNat_one, Int.mul_one]
  exact Q.mkRat_num_pos key (Nat.mul_pos a.den_pos b.den_pos)

theorem Q.add_nonneg {a b : Q} (ha : 0 ≤ a) (hb : 0 ≤ b) : 0 ≤ a + b := by
  have e1 : (0 : Int) ≤ a.num * ↑b.den :=
    Int.mul_nonneg ((Q.nonneg_iff _).mp ha) (Int.ofNat_nonneg _)
  have e2 : (0 : Int) ≤ b.num * ↑a.den :=
    Int.mul_nonneg ((Q.nonneg_iff _).mp hb) (Int.ofNat_nonneg _)
  have key : (0 : Int) ≤ a.num * ↑b.den + b.num * ↑a.den := by omega
  rw [le_def, zero_num, zero_den, Int.zero_mul, Int.ofNat_one, Int.mul_one]
  exact Q.mkRat_num_nonneg key (Nat.mul_pos a.den_pos b.den_pos)

theorem Q.neg_pos {a : Q} (h : a < 0) : 0 < -a := by
  rw [pos_iff, num_neg]
  have han : a.num < 0 := (Q.neg_iff a).mp h
  omega

theorem Q.neg_neg {a : Q} (h : 0 < a) : -a < 0 := by
  rw [neg_iff, num_neg]
  have hap : 0 < a.num := (Q.pos_iff a).mp h
  omega

end Duodenary

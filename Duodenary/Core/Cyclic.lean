/-! Fresh structural definitions. No proof source imported. Mathlib-free.

Axiomatic purification: the numeric carrier is Fin 12 (core type).  All
quantifier-decides resolve through the constructive Decidable instances
below (verified by #print axioms: no Classical.choice).
This file has NO imports: everything below is Lean core only. -/
namespace Duodenary
set_option maxRecDepth 100000
set_option maxHeartbeats 2000000
abbrev C12 := Fin 12

/-- Core-only cast Nat → Fin n (replaces Mathlib's NatCast). -/
def ofNatC12 (k : Nat) : C12 := ⟨k % 12, by omega⟩

/-- Modular negation on the carrier (core has no `Neg (Fin n)`). -/
instance instNegC12 : Neg C12 := ⟨fun x => (0 : C12) - x⟩

/-- Modular natural scaling on `Fin n`. -/
def smulNat {n : Nat} (k : Nat) (x : Fin n) : Fin n :=
  ⟨(k * x.val) % n, Nat.mod_lt _ x.pos⟩

/-- Own natural-scaling class (core has no `SMul`). -/
class Smul' (α : Type) where nsmul' : Nat → α → α
notation k " • " x => Smul'.nsmul' k x

instance instSmul'C12 : Smul' C12 := ⟨fun k x => smulNat k x⟩

/-- The embedding `Fin n → Fin (n+1)` used by the decide machinery. -/
def embFin {n : Nat} (i : Fin n) : Fin (n+1) := ⟨i.val, by have := i.isLt; omega⟩

/-- Bool projection of a Decidable instance; reduces by iota on the instance. -/
def ddec {p : Prop} (h : Decidable p) : Bool :=
  match h with
  | isTrue _ => true
  | isFalse _ => false

theorem ddec_eq {p : Prop} (h : Decidable p) : ddec h = true ↔ p := by
  cases h with
  | isTrue hp => exact ⟨fun _ => hp, fun _ => rfl⟩
  | isFalse hp => exact ⟨fun hf => Bool.noConfusion hf, fun hpx => absurd hpx hp⟩

/-- Core-only constructive checker: is `∀ i : Fin n, p i` true? Computes by
recursion on n; the per-element Decidable instances reduce at concrete elements. -/
def finAll {n : Nat} (p : Fin n → Prop) (h : (i : Fin n) → Decidable (p i)) : Bool :=
  match n with
  | 0 => true
  | k+1 =>
    ddec (h ⟨k, Nat.lt_succ_self k⟩) &&
    finAll (fun i => p (Fin.castSucc i)) (fun i => h (Fin.castSucc i))

theorem finAll_eq {n : Nat} (p : Fin n → Prop) (h : (i : Fin n) → Decidable (p i)) :
    finAll p h = true ↔ ∀ i : Fin n, p i := by
  induction n with
  | zero =>
    refine ⟨fun _ i => i.elim0, fun _ => rfl⟩
  | succ k ih =>
    rw [Duodenary.finAll.eq_def, Bool.and_eq_true, ddec_eq]
    have ihh := ih (fun i => p (Fin.castSucc i)) (fun i => h (Fin.castSucc i))
    refine ⟨?_, ?_⟩
    · intro hpair i
      rcases (by have := i.isLt; omega : i.val < k ∨ i.val = k) with hlt | heq
      · exact ihh.mp hpair.2 ⟨i.val, hlt⟩
      · have hiEq : i = ⟨k, Nat.lt_succ_self k⟩ := by
          ext
          exact heq
        rw [hiEq]
        exact hpair.1
    · intro hall
      exact ⟨hall ⟨k, Nat.lt_succ_self k⟩, ihh.mpr (fun i => hall (Fin.castSucc i))⟩

/-- Explicit-instance variant used to build the Prod instance. -/
def decFinPiCore {n : Nat} (p : Fin n → Prop) (h : (i : Fin n) → Decidable (p i)) :
    Decidable (∀ i : Fin n, p i) :=
  dite (finAll p h)
    (fun hf => isTrue ((finAll_eq p h).mp hf))
    (fun hf => isFalse (fun hall => hf ((finAll_eq p h).mpr hall)))

instance decFinPi {n : Nat} (p : Fin n → Prop) [(i : Fin n) → Decidable (p i)] :
    Decidable (∀ i : Fin n, p i) :=
  decFinPiCore p (fun i => inferInstanceAs (Decidable (p i)))

/-- Constructive decidability for universally quantified products of finite
domains, obtained by currying.  No Classical.propDecidable fallback. -/
def decFinPiProdCore {n m : Nat} (p : Fin n × Fin m → Prop)
    (hh : (x : Fin n × Fin m) → Decidable (p x)) :
    Decidable (∀ x : Fin n × Fin m, p x) := by
  have hc : Decidable (∀ a : Fin n, ∀ b : Fin m, p (a, b)) :=
    decFinPiCore (fun a => ∀ b : Fin m, p (a, b))
      (fun a => decFinPiCore (fun b => p (a, b)) (fun b => hh (a, b)))
  cases hc with
  | isTrue h => exact isTrue (fun x => h x.1 x.2)
  | isFalse h => exact isFalse (fun hh2 => h (fun a b => hh2 (a, b)))

instance decFinPiProd {n m : Nat} (p : Fin n × Fin m → Prop)
    [(x : Fin n × Fin m) → Decidable (p x)] :
    Decidable (∀ x : Fin n × Fin m, p x) :=
  decFinPiProdCore p (fun x => inferInstanceAs (Decidable (p x)))

/-- Constructive decidability for ∀ over an explicit list. -/
def decForallList {α : Type} (p : α → Prop) [(a : α) → Decidable (p a)] :
    (l : List α) → Decidable (∀ a ∈ l, p a)
  | [] => isTrue (fun a ha => absurd ha (List.not_mem_nil a))
  | x :: xs =>
    match (inferInstance : Decidable (p x)) with
    | isFalse h =>
      isFalse (fun hall => h (hall x (List.mem_cons_self x xs)))
    | isTrue h =>
      match decForallList p xs with
      | isFalse h2 =>
        isFalse (fun hall => h2 (fun a ha => hall a (List.mem_cons_of_mem x ha)))
      | isTrue h2 =>
        isTrue (fun a ha =>
          match List.mem_cons.mp ha with
          | Or.inl hae => hae ▸ h
          | Or.inr hmem => h2 a hmem)

/-- Constructive decidability for ∃ over an explicit list. -/
def decExistsList {α : Type} (p : α → Prop) [(a : α) → Decidable (p a)] :
    (l : List α) → Decidable (∃ a ∈ l, p a)
  | [] =>
    isFalse (fun h =>
      match h with
      | ⟨a, hmem, _⟩ => absurd hmem (List.not_mem_nil a))
  | x :: xs =>
    match (inferInstance : Decidable (p x)), decExistsList p xs with
    | isTrue h, _ => isTrue ⟨x, List.mem_cons_self x xs, h⟩
    | isFalse h, isTrue h2 =>
      isTrue (h2.imp fun a ha => ⟨List.mem_cons_of_mem x ha.1, ha.2⟩)
    | isFalse h, isFalse h2 =>
      isFalse (fun h3 =>
        match h3 with
        | ⟨a, hmem, hp⟩ =>
          match List.mem_cons.mp hmem with
          | Or.inl hae => h (hae ▸ hp)
          | Or.inr hmem' => h2 ⟨a, hmem', hp⟩)

/-! Own replacement structures for Mathlib's `Equiv` and `Fintype`. -/

structure CEquiv (a b : Type) where
  toFun : a → b
  invFun : b → a
  left_inv : ∀ x, invFun (toFun x) = x
  right_inv : ∀ y, toFun (invFun y) = y

class FinEnum (α : Type) where
  elems : List α
  complete : ∀ x, x ∈ elems

def FinEnum.card (α : Type) [FinEnum α] : Nat := (FinEnum.elems (α := α)).length

/-! Explicit finite enumerations used by the `FinEnum` instances. -/

def allFin4 : List (Fin 4) :=
  [⟨0, by decide⟩, ⟨1, by decide⟩, ⟨2, by decide⟩, ⟨3, by decide⟩]

theorem mem_allFin4 (x : Fin 4) : x ∈ allFin4 := by
  revert x; decide

def allC12 : List C12 :=
  [⟨0, by decide⟩, ⟨1, by decide⟩, ⟨2, by decide⟩, ⟨3, by decide⟩, ⟨4, by decide⟩,
   ⟨5, by decide⟩, ⟨6, by decide⟩, ⟨7, by decide⟩, ⟨8, by decide⟩, ⟨9, by decide⟩,
   ⟨10, by decide⟩, ⟨11, by decide⟩]

theorem mem_allC12 (x : C12) : x ∈ allC12 := by
  revert x; decide

def rotate (a x : C12) : C12 := a + x
def opposite (x : C12) : C12 := x + 6
def reflect (a x : C12) : C12 := a - x

theorem rotate_zero (x : C12) : rotate 0 x = x := by revert x; decide
theorem rotate_comp (a b x : C12) : rotate a (rotate b x) = rotate (a+b) x := by revert a b x; decide
theorem difference_preserved (a x y : C12) : rotate a x - rotate a y = x-y := by revert a x y; decide
theorem opposite_involution (x : C12) : opposite (opposite x) = x := by revert x; decide
theorem opposite_has_no_fixed_point (x : C12) : opposite x ≠ x := by revert x; decide
theorem reflection_involution (a x : C12) : reflect a (reflect a x) = x := by revert a x; decide
theorem reflection_rotation (a b x : C12) :
    reflect a (rotate b x) = rotate (-b) (reflect a x) := by revert a b x; decide

def crt (x : C12) : Fin 4 × Fin 3 :=
  (⟨x.val % 4, by omega⟩, ⟨x.val % 3, by omega⟩)
def uncrt (p : Fin 4 × Fin 3) : C12 :=
  ⟨(9 * p.1.val + 4 * p.2.val) % 12, by omega⟩
theorem crt_left_inverse : ∀ x : C12, uncrt (crt x) = x := by decide
theorem crt_right_inverse : ∀ p : Fin 4 × Fin 3, crt (uncrt p) = p := by decide
theorem crt_preserves_addition : ∀ x y : C12,
    crt (x+y) = ((crt x).1 + (crt y).1, (crt x).2 + (crt y).2) := by decide
theorem crt_preserves_multiplication : ∀ x y : C12,
    crt (x*y) = ((crt x).1 * (crt y).1, (crt x).2 * (crt y).2) := by decide
def crtEquiv : CEquiv C12 (Fin 4 × Fin 3) where
  toFun := crt
  invFun := uncrt
  left_inv := crt_left_inverse
  right_inv := crt_right_inverse

def cyclicDistance (x y : C12) : Nat := min (x-y).val (y-x).val
theorem distance_symmetric (x y : C12) : cyclicDistance x y = cyclicDistance y x :=
  Nat.min_comm _ _
theorem distance_bound : ∀ x y : C12, cyclicDistance x y ≤ 6 := by decide
theorem seven_distance_values :
    ∀ d : Fin 7, ∃ x : C12, cyclicDistance x 0 = d.val := by
  intro d
  refine ⟨⟨d.val, by omega⟩, ?_⟩
  have hd := d.isLt
  have hsub : ∀ x : C12, (x - (0 : C12)).val = x.val := by decide
  have hneg : ∀ x : C12, ((0 : C12) - x).val = (12 - x.val) % 12 := by decide
  have hx : (⟨d.val, by omega⟩ : C12).val = d.val := rfl
  simp only [cyclicDistance]
  rw [hsub, hneg, hx]
  omega

def unitSlope (i : Fin 4) : C12 :=
  match i.val with
  | 0 => 1
  | 1 => 5
  | 2 => 7
  | _ => 11
abbrev Affine := Fin 4 × C12
def affineApply (f : Affine) (x : C12) : C12 := unitSlope f.1 * x + f.2
theorem slope_square : ∀ i : Fin 4, unitSlope i * unitSlope i = 1 := by decide
def inverseApply (f : Affine) (x : C12) : C12 := unitSlope f.1 * (x-f.2)
theorem affine_inverse (f : Affine) (x : C12) : inverseApply f (affineApply f x) = x := by
  revert f x
  decide
theorem affine_reverse_inverse (f : Affine) (x : C12) : affineApply f (inverseApply f x) = x := by
  revert f x
  decide
theorem affine_faithful : ∀ f g : Affine,
    affineApply f 0 = affineApply g 0 → affineApply f 1 = affineApply g 1 → f = g := by decide

/-- Explicit enumeration of the 48 affine pairs (4 unit slopes x 12 offsets). -/
instance finEnumAffine : FinEnum (Fin 4 × C12) :=
  ⟨allFin4.flatMap (fun a => allC12.map (fun b => (a, b))),
   by
     intro x
     cases x with
     | mk i b =>
       exact List.mem_flatMap.2 ⟨i, mem_allFin4 i,
         List.mem_map.2 ⟨b, mem_allC12 b, rfl⟩⟩⟩

theorem affine_cardinality : FinEnum.card Affine = 48 := by decide

/-- Index of the unit slope equal to a given unit value (junk value off the
unit set; only reached on units in the composition law, where `decide`
verifies all 16 cases). -/
def invUnit (x : C12) : Fin 4 :=
  match x.val with
  | 1 => 0
  | 5 => 1
  | 7 => 2
  | _ => 3

def slopeProduct (i j : Fin 4) : Fin 4 := invUnit (unitSlope i * unitSlope j)

theorem slope_product_correct : ∀ i j : Fin 4,
    unitSlope (slopeProduct i j) = unitSlope i * unitSlope j := by decide
def affineCompose (f g : Affine) : Affine :=
  (slopeProduct f.1 g.1, unitSlope f.1 * g.2 + f.2)
theorem affine_composition (f g : Affine) (x : C12) :
    affineApply (affineCompose f g) x = affineApply f (affineApply g x) := by
  revert f g x
  decide
theorem affine_associative (f g h : Affine) :
    affineCompose (affineCompose f g) h = affineCompose f (affineCompose g h) := by
  apply affine_faithful <;> simp only [affine_composition]

theorem affine_identity : ∀ f : Affine,
    affineCompose (0,0) f = f ∧ affineCompose f (0,0) = f := by decide
def affineInverse (f : Affine) : Affine := (f.1, -(unitSlope f.1 * f.2))
theorem affine_two_sided_inverse : ∀ f : Affine,
    affineCompose f (affineInverse f) = (0,0) ∧
    affineCompose (affineInverse f) f = (0,0) := by decide

abbrev Product144 := C12 × C12
def encode144 (x : Product144) : Fin 144 :=
  ⟨12*x.1.val+x.2.val, by have := x.1.isLt; have := x.2.isLt; omega⟩
def decode144 (x : Fin 144) : Product144 :=
  (⟨x.val / 12, by omega⟩, ⟨x.val % 12, by omega⟩)
theorem product144_left_inverse : ∀ x : Product144, decode144 (encode144 x) = x := by decide
theorem product144_right_inverse : ∀ x : Fin 144, encode144 (decode144 x) = x := by decide

/-- Explicit enumeration of the 144 product points. -/
instance finEnumProduct144 : FinEnum (C12 × C12) :=
  ⟨allC12.flatMap (fun a => allC12.map (fun b => (a, b))),
   by
     intro x
     cases x with
     | mk a b =>
       exact List.mem_flatMap.2 ⟨a, mem_allC12 a,
         List.mem_map.2 ⟨b, mem_allC12 b, rfl⟩⟩⟩

theorem product144_cardinality : FinEnum.card Product144 = 144 := by decide

instance instZeroProduct144 : Zero Product144 := ⟨(0, 0)⟩
instance instSmul'Product144 : Smul' Product144 :=
  ⟨fun k x => (smulNat k x.1, smulNat k x.2)⟩

-- The encoding is an equivalence of finite sets, not an additive isomorphism with ZMod 144.
theorem product_exponent : ∀ x : Product144, ((12 : Nat) • x) = 0 := by decide
theorem cyclic144_not_exponent12 : smulNat 12 (1 : Fin 144) ≠ 0 := by decide

/-! Constructive decidability for ∀ / ∃ over FinEnum types, and for
implication (Lean core lacks a Decidable instance for `p → q`).  All reduce
by iota on concrete data, so `decide` closes quantified goals. -/

instance instDecidableImp (p q : Prop) [Decidable p] [Decidable q] :
    Decidable (p → q) :=
  match (inferInstance : Decidable p) with
  | isFalse hp => isTrue (fun h => absurd h hp)
  | isTrue hp =>
    match (inferInstance : Decidable q) with
    | isTrue hq => isTrue (fun _ => hq)
    | isFalse hq => isFalse (fun h => hq (h hp))

instance decForallEnum {α : Type} (p : α → Prop) [FinEnum α]
    [(a : α) → Decidable (p a)] : Decidable (∀ a : α, p a) :=
  match decForallList p (FinEnum.elems (α := α)) with
  | isTrue h => isTrue (fun a => h a (FinEnum.complete a))
  | isFalse h => isFalse (fun hall => h (fun a _ => hall a))

instance decExistsEnum {α : Type} (p : α → Prop) [FinEnum α]
    [(a : α) → Decidable (p a)] : Decidable (∃ a : α, p a) :=
  match decExistsList p (FinEnum.elems (α := α)) with
  | isTrue h =>
    isTrue (match h with | ⟨a, _hmem, hp⟩ => ⟨a, hp⟩)
  | isFalse h =>
    isFalse (fun hh =>
      match hh with
      | ⟨a, hp⟩ => h ⟨a, FinEnum.complete a, hp⟩)
end Duodenary

import Duodenary.Core.Cyclic

/-! Mathlib-free calendar comparison (TASK-CAL-OWN).

The original file bound the calendar comparison through `ZMod 260 →+ C12`
(Mathlib `AddMonoidHom`).  JST-01 authorization: restate the parameter types
so that the homomorphism is our own `CalHom : Fin 260 → C12` with an explicit
`map_add` field.  All five theorem names are preserved:

  calendar_annihilator_classification
  calendar_image_annihilated
  calendar_image_classification
  calendar_no_surjective_hom
  calendar_image_card_bound

No Mathlib import; everything rides on `Duodenary.Core.Cyclic` (Lean core only).
This is an algebraic obstruction, not a claim about historical influence. -/
namespace Duodenary
set_option maxRecDepth 100000
set_option maxHeartbeats 2000000

/-- Calendar homomorphism: Mathlib-free replacement for `ZMod 260 →+ C12`. -/
structure CalHom where
  toFun : Fin 260 → C12
  map_add : ∀ a b : Fin 260, toFun (a + b) = toFun a + toFun b

/-- Repeated addition: `k` copies of `x`. -/
def addN {n : Nat} [NeZero n] : Nat → Fin n → Fin n
  | 0, _ => 0
  | k+1, x => addN k x + x

/-- A homomorphism kills zero (core-only proof via `Fin.val_add` + omega). -/
theorem toFun_zero (f : CalHom) : f.toFun 0 = 0 := by
  have h := f.map_add 0 0
  simp only [Fin.zero_add] at h
  apply Fin.ext
  rw [Fin.val_zero]
  have hv := congrArg Fin.val h
  rw [Fin.val_add] at hv
  have hlt := (f.toFun 0).isLt
  omega

/-- Homomorphisms commute with repeated addition. -/
theorem map_addN (f : CalHom) (x : Fin 260) (k : Nat) :
    f.toFun (addN k x) = addN k (f.toFun x) := by
  induction k with
  | zero => exact toFun_zero f
  | succ k ih =>
    show f.toFun (addN k x + x) = addN k (f.toFun x) + f.toFun x
    rw [f.map_add, ih]

/-- `addN k x` is `k * x` modulo `n` (core `Fin.val_add` + `Nat.mod_add_mod`). -/
theorem addN_val {n : Nat} [NeZero n] (x : Fin n) (k : Nat) :
    (addN k x).val = (k * x.val) % n := by
  induction k with
  | zero => simp [addN]
  | succ k ih =>
    show (addN k x + x).val = ((k + 1) * x.val) % n
    rw [Fin.val_add, ih, Nat.succ_mul, Nat.mod_add_mod]

/-- The exact annihilator condition for the calendar comparison. -/
theorem calendar_annihilator_classification : ∀ y : C12,
    (4 : C12) * y = 0 ↔ y = 0 ∨ y = 3 ∨ y = 6 ∨ y = 9 := by decide

/-- A homomorphism respects the order-260 relation in its domain. -/
theorem calendar_image_annihilated (f : CalHom) (x : Fin 260) :
    (4 : C12) * f.toFun x = 0 := by
  have hstep : f.toFun (addN 260 x) = addN 260 (f.toFun x) := map_addN f x 260
  have hzero : addN 260 x = 0 := by
    apply Fin.ext
    rw [Fin.val_zero, addN_val]
    have hlt := x.isLt
    omega
  rw [hzero, toFun_zero] at hstep
  apply Fin.ext
  rw [Fin.val_mul, Fin.val_zero]
  show (4 * (f.toFun x).val) % 12 = 0
  have hv := congrArg Fin.val hstep.symm
  rw [addN_val, Fin.val_zero] at hv
  have hlt := (f.toFun x).isLt
  omega

theorem calendar_image_classification (f : CalHom) (x : Fin 260) :
    f.toFun x = 0 ∨ f.toFun x = 3 ∨ f.toFun x = 6 ∨ f.toFun x = 9 :=
  (calendar_annihilator_classification (f.toFun x)).mp (calendar_image_annihilated f x)

theorem calendar_no_surjective_hom (f : CalHom) :
    ¬ (∀ y : C12, ∃ x : Fin 260, f.toFun x = y) := by
  intro h
  cases h 1 with
  | intro x hx =>
    have hcl := calendar_image_classification f x
    cases hcl with
    | inl h0 => exact (by decide : (1 : C12) ≠ 0) (hx.symm.trans h0)
    | inr hrest =>
      cases hrest with
      | inl h3 => exact (by decide : (1 : C12) ≠ 3) (hx.symm.trans h3)
      | inr hrest2 =>
        cases hrest2 with
        | inl h6 => exact (by decide : (1 : C12) ≠ 6) (hx.symm.trans h6)
        | inr h9 => exact (by decide : (1 : C12) ≠ 9) (hx.symm.trans h9)

/-! Image cardinality bound.  Mathlib's `Finset.image` is unavailable, so the
image is a `List` and the bound is `dedup (calImage f) ≤ 4`, proven with an
own no-duplicates predicate and a fuel-based pigeonhole.  [NEW STATEMENT —
authorized; the old `Finset.image` statement is impossible choice-free.] -/

def calImage (f : CalHom) : List C12 :=
  (List.range 260).map (fun n => f.toFun ⟨n % 260, Nat.mod_lt n (by omega)⟩)

def dedupAux : List C12 → List C12 → List C12
  | [], acc => acc.reverse
  | x :: rest, acc => if x ∈ acc then dedupAux rest acc else dedupAux rest (x :: acc)

def dedup (l : List C12) : List C12 := dedupAux l []

/-- Own Mathlib-free duplicate-freeness predicate. -/
def noDup : List C12 → Prop
  | [] => True
  | x :: l => x ∉ l ∧ noDup l

/-- Core-only replacement for `List.mem_split`. -/
theorem mem_split_core {x : C12} :
    ∀ l : List C12, x ∈ l → ∃ p q, l = p ++ x :: q := by
  intro l
  induction l with
  | nil => intro h; exact absurd h (List.not_mem_nil x)
  | cons z rest ih =>
    intro h
    rw [List.mem_cons] at h
    cases h with
    | inl hxeq => exact ⟨[], rest, by rw [List.nil_append, hxeq]⟩
    | inr hmem =>
      have ⟨p, q, hpr⟩ := ih hmem
      exact ⟨z :: p, q, by rw [List.cons_append, hpr]⟩

theorem mem_dedupAux :
    ∀ (l acc : List C12) (x : C12), x ∈ dedupAux l acc → x ∈ l ++ acc := by
  intro l
  induction l with
  | nil =>
    intro acc x hx
    have hx2 : x ∈ acc.reverse := hx
    rw [List.mem_reverse] at hx2
    rw [List.nil_append]
    exact hx2
  | cons y rest ih =>
    intro acc x hx
    simp only [dedupAux] at hx
    split at hx
    · have h2 := ih acc x hx
      rw [List.mem_append] at h2
      cases h2 with
      | inl hmem =>
        exact List.mem_append.mpr (Or.inl (List.mem_cons.mpr (Or.inr hmem)))
      | inr hmem => exact List.mem_append.mpr (Or.inr hmem)
    · have h2 := ih (y :: acc) x hx
      rw [List.mem_append, List.mem_cons] at h2
      rw [List.mem_append, List.mem_cons]
      cases h2 with
      | inl hmem => exact Or.inl (Or.inr hmem)
      | inr h2' =>
        cases h2' with
        | inl hxeq => exact Or.inl (Or.inl hxeq)
        | inr hmem => exact Or.inr hmem

theorem mem_dedup (l : List C12) (x : C12) (h : x ∈ dedup l) : x ∈ l := by
  have h2 : x ∈ l ++ [] := mem_dedupAux l [] x h
  rwa [List.append_nil] at h2

theorem noDup_append :
    ∀ p q : List C12, noDup p → noDup q → (∀ x ∈ p, x ∉ q) → noDup (p ++ q) := by
  intro p
  induction p with
  | nil => intro q _ hq _; exact hq
  | cons z rest ih =>
    intro q hp hq hsep
    show z ∉ rest ++ q ∧ noDup (rest ++ q)
    constructor
    · intro hz
      rw [List.mem_append] at hz
      cases hz with
      | inl h => exact hp.1 h
      | inr h => exact hsep z (List.mem_cons_self _ _) h
    · exact ih q hp.2 hq (fun x hx => hsep x (List.mem_cons_of_mem _ hx))

theorem noDup_reverse : ∀ l : List C12, noDup l → noDup l.reverse := by
  intro l h
  induction l with
  | nil => trivial
  | cons y rest ih =>
    rw [List.reverse_cons]
    refine noDup_append (rest.reverse) [y] (ih h.2) ⟨List.not_mem_nil y, trivial⟩ ?_
    intro x hx hxy
    rw [List.mem_cons] at hxy
    cases hxy with
    | inl hxeq =>
      apply h.1
      rw [← hxeq]
      exact List.mem_reverse.mp hx
    | inr hnil => exact absurd hnil (List.not_mem_nil x)

theorem noDup_dedupAux :
    ∀ l acc : List C12, noDup acc → noDup (dedupAux l acc) := by
  intro l
  induction l with
  | nil => intro acc h; exact noDup_reverse acc h
  | cons y rest ih =>
    intro acc hacc
    show noDup (if y ∈ acc then dedupAux rest acc else dedupAux rest (y :: acc))
    by_cases hy : y ∈ acc
    · rw [if_pos hy]
      exact ih acc hacc
    · rw [if_neg hy]
      exact ih (y :: acc) ⟨hy, hacc⟩

/-- Fuel-based pigeonhole: a duplicate-free list drawn from `S` is no longer
than `S`.  Core-only. -/
theorem pigeonhole_list (n : Nat) :
    ∀ d S : List C12, d.length ≤ n → noDup d → (∀ x ∈ d, x ∈ S) → d.length ≤ S.length := by
  induction n with
  | zero =>
    intro d S hd _ _
    cases d with
    | nil => simp
    | cons y rest =>
      have h1 := hd
      rw [List.length_cons] at h1
      exact absurd h1 (by omega)
  | succ n ih =>
    intro d S hd hnd hs
    cases d with
    | nil => simp
    | cons y rest =>
      have hrl : rest.length ≤ n := by
        have h1 := hd
        rw [List.length_cons] at h1
        omega
      have hndr : noDup rest := hnd.2
      have hsr : ∀ x ∈ rest, x ∈ S := fun x hx => hs x (List.mem_cons_of_mem _ hx)
      have hsplit := mem_split_core S (hs y (List.mem_cons_self _ _))
      cases hsplit with
      | intro p hp =>
        cases hp with
        | intro q hpq =>
          have hpq_mem : ∀ x ∈ rest, x ∈ p ++ q := by
            intro x hx
            have hxS := hsr x hx
            rw [hpq, List.mem_append] at hxS
            cases hxS with
            | inl h => exact List.mem_append.mpr (Or.inl h)
            | inr h =>
              rw [List.mem_cons] at h
              cases h with
              | inl hxeq => exact absurd (hxeq ▸ hx) hnd.1
              | inr hmem => exact List.mem_append.mpr (Or.inr hmem)
          have hrl2 : rest.length ≤ (p ++ q).length := ih rest (p ++ q) hrl hndr hpq_mem
          rw [List.length_append] at hrl2
          rw [List.length_cons, hpq, List.length_append, List.length_cons]
          omega

theorem dedup_le (l : List C12) (S : List C12) (h : ∀ x ∈ l, x ∈ S) :
    (dedup l).length ≤ S.length := by
  apply pigeonhole_list (dedup l).length
  · exact Nat.le_refl _
  · exact noDup_dedupAux l [] trivial
  · intro x hx
    exact h x (mem_dedup l x hx)

theorem annihilator_list :
    ∀ y : C12, y = 0 ∨ y = 3 ∨ y = 6 ∨ y = 9 → y ∈ [0, 3, 6, 9] := by
  intro y h
  cases h with
  | inl h => rw [h]; decide
  | inr h =>
    cases h with
    | inl h => rw [h]; decide
    | inr h =>
      cases h with
      | inl h => rw [h]; decide
      | inr h => rw [h]; decide

theorem calendar_image_card_bound (f : CalHom) : (dedup (calImage f)).length ≤ 4 := by
  have hsub : ∀ x ∈ calImage f, x ∈ [0, 3, 6, 9] := by
    intro x hx
    have hx2 : x ∈ (List.range 260).map (fun n => f.toFun ⟨n % 260, Nat.mod_lt n (by omega)⟩) := hx
    cases List.mem_map.mp hx2 with
    | intro n hnp =>
      have hn := hnp.1
      have hxeq := hnp.2
      have hlt : n < 260 := List.mem_range.mp hn
      have hxv : x = f.toFun ⟨n % 260, Nat.mod_lt n (by omega)⟩ := hxeq.symm
      rw [hxv]
      exact annihilator_list _ (calendar_image_classification f ⟨n % 260, Nat.mod_lt n (by omega)⟩)
  exact dedup_le (calImage f) [0, 3, 6, 9] hsub

end Duodenary

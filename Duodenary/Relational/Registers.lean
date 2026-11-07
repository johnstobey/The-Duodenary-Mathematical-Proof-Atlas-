import Duodenary.Relational.Closure
import Lean

namespace Duodenary.Relational
open Lean

/-- Declarative and operational registers articulate the same crossing. -/
structure Obsidian where
  crossing : Fin 4 × Fin 3
  deriving DecidableEq

structure Fulgurite where
  station : C12
  deriving DecidableEq

def registerEquiv : Obsidian ≃ Fulgurite where
  toFun := fun o => ⟨uncrt o.crossing⟩
  invFun := fun f => ⟨crt f.station⟩
  left_inv := by intro o; cases o; simp only [crt_right_inverse]
  right_inv := by intro f; cases f; simp only [crt_left_inverse]

theorem obsidian_round_trip (o : Obsidian) : registerEquiv.symm (registerEquiv o) = o :=
  registerEquiv.symm_apply_apply o

theorem fulgurite_round_trip (f : Fulgurite) : registerEquiv (registerEquiv.symm f) = f :=
  registerEquiv.apply_symm_apply f

def synchronized (o : Obsidian) (f : Fulgurite) : Prop := o.crossing = crt f.station

instance (o : Obsidian) (f : Fulgurite) : Decidable (synchronized o f) :=
  inferInstanceAs (Decidable (o.crossing = crt f.station))

theorem synchronization_iff_isomorphism (o : Obsidian) (f : Fulgurite) :
    synchronized o f ↔ registerEquiv o = f := by
  constructor
  · intro h
    cases o with
    | mk c =>
      cases f with
      | mk x =>
        change c = crt x at h
        change Fulgurite.mk (uncrt c) = Fulgurite.mk x
        rw [h, crt_left_inverse]
  · intro h
    rw [← h]
    change o.crossing = crt (uncrt o.crossing)
    exact (crt_right_inverse o.crossing).symm

/-- JSON row has no independent state identity: station and crossing must agree. -/
def rowJson (f : Fulgurite) : Json :=
  Json.arr #[toJson f.station.val, toJson (crt f.station).1.val, toJson (crt f.station).2.val]

def rowFromJson (j : Json) : Except String Fulgurite := do
  let a ← j.getArr?
  if a.size != 3 then throw "row must have exactly station, fourfold, mode"
  let n ← (a[0]!).getNat?
  let kind ← (a[1]!).getNat?
  let mode ← (a[2]!).getNat?
  if n ≥ 12 || kind ≥ 4 || mode ≥ 3 then throw "row is outside constitutive crossing"
  let x : C12 := n
  if (crt x).1.val != kind || (crt x).2.val != mode then throw "registers disagree at constitutive crossing"
  return ⟨x⟩

/-- Exact semantic JSON round trip for every admissible station, kernel-reduced. -/
theorem json_row_round_trip : ∀ x : C12, rowFromJson (rowJson ⟨x⟩) = .ok ⟨x⟩ := by
  intro x
  fin_cases x <;> rfl

/-- The JSON image of a declared crossing is recoverable in both registers. -/
theorem obsidian_json_round_trip (o : Obsidian) :
    rowFromJson (rowJson (registerEquiv o)) = .ok (registerEquiv o) :=
  json_row_round_trip (registerEquiv o).station

/-- Two declarations sharing their whole-state image are the same declaration. -/
theorem register_identity_reflected (a b : Obsidian) :
    registerEquiv a = registerEquiv b ↔ a = b := registerEquiv.injective.eq_iff

theorem json_image_injective (a b : Fulgurite) (h : rowJson a = rowJson b) : a = b := by
  have same := congrArg rowFromJson h
  rw [json_row_round_trip a.station, json_row_round_trip b.station] at same
  exact Except.ok.inj same

/-- Only canonical admissible JSON states belong to this image. -/
def JsonState := {j : Json // ∃ f : Fulgurite, rowJson f = j}

noncomputable def jsonStateEquiv : Fulgurite ≃ JsonState where
  toFun := fun f => ⟨rowJson f, f, rfl⟩
  invFun := fun j => Classical.choose j.property
  left_inv := by
    intro f
    apply json_image_injective
    exact Classical.choose_spec (show ∃ g : Fulgurite, rowJson g = rowJson f from ⟨f,rfl⟩)
  right_inv := by
    intro j
    apply Subtype.ext
    exact Classical.choose_spec j.property

noncomputable def obsidianJsonEquiv : Obsidian ≃ JsonState := registerEquiv.trans jsonStateEquiv

theorem obsidian_json_isomorphism (o : Obsidian) :
    obsidianJsonEquiv.symm (obsidianJsonEquiv o) = o := obsidianJsonEquiv.symm_apply_apply o

theorem json_obsidian_isomorphism (j : JsonState) :
    obsidianJsonEquiv (obsidianJsonEquiv.symm j) = j := obsidianJsonEquiv.apply_symm_apply j

def obsidianAction (e : Equiv.Perm C12) (o : Obsidian) : Obsidian :=
  registerEquiv.symm ⟨e (registerEquiv o).station⟩

def fulguriteAction (e : Equiv.Perm C12) (f : Fulgurite) : Fulgurite := ⟨e f.station⟩

theorem register_actions_coherent (e : Equiv.Perm C12) (o : Obsidian) :
    registerEquiv (obsidianAction e o) = fulguriteAction e (registerEquiv o) :=
  registerEquiv.apply_symm_apply _

theorem synchronization_closed (e : Equiv.Perm C12) (o : Obsidian) (f : Fulgurite)
    (h : synchronized o f) : synchronized (obsidianAction e o) (fulguriteAction e f) := by
  apply (synchronization_iff_isomorphism _ _).mpr
  rw [register_actions_coherent, (synchronization_iff_isomorphism o f).mp h]

/-- Register unity holds cellwise for complete 4×3 indexed matrices. -/
def registerMatrixEquiv :
    (Fin 4 → Fin 3 → Obsidian) ≃ (Fin 4 → Fin 3 → Fulgurite) where
  toFun := fun m a b => registerEquiv (m a b)
  invFun := fun m a b => registerEquiv.symm (m a b)
  left_inv := by intro m; funext a b; exact registerEquiv.symm_apply_apply _
  right_inv := by intro m; funext a b; exact registerEquiv.apply_symm_apply _

noncomputable def jsonMatrixEquiv :
    (Fin 4 → Fin 3 → Fulgurite) ≃ (Fin 4 → Fin 3 → JsonState) where
  toFun := fun m a b => jsonStateEquiv (m a b)
  invFun := fun m a b => jsonStateEquiv.symm (m a b)
  left_inv := by intro m; funext a b; exact jsonStateEquiv.symm_apply_apply _
  right_inv := by intro m; funext a b; exact jsonStateEquiv.apply_symm_apply _

noncomputable def obsidianJsonMatrixEquiv :
    (Fin 4 → Fin 3 → Obsidian) ≃ (Fin 4 → Fin 3 → JsonState) :=
  registerMatrixEquiv.trans jsonMatrixEquiv

end Duodenary.Relational

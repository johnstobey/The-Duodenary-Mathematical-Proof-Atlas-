import Duodenary.Core.Cyclic

/-! The whole is primary. A frame names its internal places; it is not a
privileged point in the whole or a process producing its positions. -/
namespace Duodenary.Relational

structure Whole where
  Position : Type
  nonempty : Nonempty Position
  succession : Equiv.Perm Position
  cyclic : ∀ p : Position, ∃ e : C12 ≃ Position,
    e 0 = p ∧ ∀ x : C12, succession (e x) = e (x + 1)

structure Frame (w : Whole) where
  places : C12 ≃ w.Position
  coherence : ∀ x : C12, w.succession (places x) = places (x + 1)

theorem frame_at_every_position (w : Whole) (p : w.Position) :
    ∃ f : Frame w, f.places 0 = p := by
  obtain ⟨e, h, hc⟩ := w.cyclic p
  exact ⟨⟨e, hc⟩, h⟩

/-- Fourfold and three-mode determinations of one relational position. -/
def differentiation {w : Whole} (f : Frame w) (p : w.Position) : Fin 4 × Fin 3 :=
  crt (f.places.symm p)

/-- Every conjunction belongs to exactly one position in the whole. -/
def constitutiveEquiv {w : Whole} (f : Frame w) : w.Position ≃ Fin 4 × Fin 3 :=
  f.places.symm.trans crtEquiv

theorem differentiation_is_constitutive {w : Whole} (f : Frame w)
    (p q : w.Position) : differentiation f p = differentiation f q ↔ p = q := by
  constructor
  · intro h
    exact (constitutiveEquiv f).injective h
  · intro h
    rw [h]

theorem every_conjunction_unique {w : Whole} (f : Frame w) (a : Fin 4) (b : Fin 3) :
    ∃! p : w.Position, differentiation f p = (a,b) := by
  refine ⟨(constitutiveEquiv f).symm (a,b), ?_, ?_⟩
  · exact (constitutiveEquiv f).apply_symm_apply (a,b)
  · intro p hp
    exact (constitutiveEquiv f).injective (hp.trans ((constitutiveEquiv f).apply_symm_apply (a,b)).symm)

/-- A concrete articulation ensures that the abstract whole is inhabited. -/
def duodenaryWhole : Whole where
  Position := C12
  nonempty := ⟨0⟩
  succession :=
    { toFun := fun x => x + 1
      invFun := fun x => x - 1
      left_inv := by intro x; simp
      right_inv := by intro x; simp }
  cyclic := by
    intro p
    refine ⟨{ toFun := fun x => x + p
              invFun := fun x => x - p
              left_inv := by intro x; simp
              right_inv := by intro x; simp }, ?_, ?_⟩
    · simp
    · intro x
      change (x + p) + 1 = (x + 1) + p
      ring

end Duodenary.Relational

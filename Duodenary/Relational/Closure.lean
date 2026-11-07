import Duodenary.Relational.Manifestations

namespace Duodenary.Relational
variable {w : Whole}

def reversalPerm (f : Frame w) (c : C12) : Equiv.Perm w.Position :=
  { toFun := reversal f c
    invFun := reversal f c
    left_inv := reversal_involutive f c
    right_inv := reversal_involutive f c }

theorem reversal_conjugation (f : Frame w) (c : C12) :
    reversalPerm f c * w.succession * reversalPerm f c = w.succession⁻¹ := by
  ext p
  change reversal f c (w.succession (reversal f c p)) = w.succession.symm p
  rw [reversal_exchanges_orientation, reversal_involutive f c]

theorem opposition_conjugation (f : Frame w) :
    opposition w * w.succession * opposition w = w.succession := by
  ext p
  obtain ⟨x, rfl⟩ := f.places.surjective p
  change opposition w (w.succession (opposition w (f.places x))) = w.succession (f.places x)
  rw [opposition_incidence f, f.coherence, opposition_incidence f, f.coherence]
  congr 1
  have h : (6 : C12) + 6 = 0 := by decide
  calc
    x + 6 + 1 + 6 = (x + 1) + (6 + 6) := by ring
    _ = x + 1 := by rw [h, add_zero]

def gridDistance (f : Frame w) (p q : w.Position) : Nat :=
  cyclicDistance (f.places.symm p) (f.places.symm q)

def GridIntegrity (f : Frame w) (e : Equiv.Perm w.Position) : Prop :=
  (∀ p q, gridDistance f (e p) (e q) = gridDistance f p q) ∧
  (∀ a : Fin 4, ∀ b : Fin 3, ∃! p, differentiation f (e p) = (a,b))

theorem crossing_under_equivalence (f : Frame w) (e : Equiv.Perm w.Position)
    (a : Fin 4) (b : Fin 3) : ∃! p, differentiation f (e p) = (a,b) := by
  obtain ⟨q, hq, unique⟩ := every_conjunction_unique f a b
  refine ⟨e.symm q, ?_, ?_⟩
  · simpa using hq
  · intro p hp
    apply e.injective
    simpa using unique (e p) hp

theorem succession_grid_integrity (f : Frame w) : GridIntegrity f w.succession := by
  constructor
  · intro p q
    obtain ⟨x, rfl⟩ := f.places.surjective p
    obtain ⟨y, rfl⟩ := f.places.surjective q
    rw [f.coherence, f.coherence]
    simp only [gridDistance, Equiv.symm_apply_apply, cyclicDistance]
    rw [show x + 1 - (y + 1) = x - y by ring,
        show y + 1 - (x + 1) = y - x by ring]
  · exact crossing_under_equivalence f w.succession

theorem opposition_grid_integrity (f : Frame w) : GridIntegrity f (opposition w) := by
  constructor
  · intro p q
    obtain ⟨x, rfl⟩ := f.places.surjective p
    obtain ⟨y, rfl⟩ := f.places.surjective q
    rw [opposition_incidence f, opposition_incidence f]
    simp only [gridDistance, Equiv.symm_apply_apply, cyclicDistance]
    rw [show x + 6 - (y + 6) = x - y by ring,
        show y + 6 - (x + 6) = y - x by ring]
  · exact crossing_under_equivalence f (opposition w)

theorem reversal_grid_integrity (f : Frame w) (c : C12) :
    GridIntegrity f (reversalPerm f c) := by
  constructor
  · intro p q
    change cyclicDistance (f.places.symm (reversal f c p))
      (f.places.symm (reversal f c q)) = gridDistance f p q
    simp only [reversal, Equiv.symm_apply_apply, gridDistance, cyclicDistance]
    rw [show c - f.places.symm p - (c - f.places.symm q) =
        f.places.symm q - f.places.symm p by ring,
        show c - f.places.symm q - (c - f.places.symm p) =
        f.places.symm p - f.places.symm q by ring]
    exact min_comm _ _
  · exact crossing_under_equivalence f (reversalPerm f c)

theorem identity_grid_integrity (f : Frame w) : GridIntegrity f 1 :=
  ⟨fun _ _ => rfl, crossing_under_equivalence f 1⟩

theorem composition_grid_integrity (f : Frame w) (e d : Equiv.Perm w.Position)
    (he : GridIntegrity f e) (hd : GridIntegrity f d) : GridIntegrity f (e*d) := by
  constructor
  · intro p q
    change gridDistance f (e (d p)) (e (d q)) = gridDistance f p q
    exact (he.1 (d p) (d q)).trans (hd.1 p q)
  · exact crossing_under_equivalence f (e*d)

/-- A compositional expression articulates relations; it need not denote elapsed time. -/
def relationComposite : List (Equiv.Perm w.Position) → Equiv.Perm w.Position
  | [] => 1
  | e :: es => e * relationComposite es

theorem arbitrary_composition_grid_integrity (f : Frame w)
    (es : List (Equiv.Perm w.Position))
    (h : ∀ e ∈ es, GridIntegrity f e) : GridIntegrity f (relationComposite es) := by
  induction es with
  | nil => exact identity_grid_integrity f
  | cons e es ih =>
    apply composition_grid_integrity f e (relationComposite es)
    · exact h e (List.mem_cons_self e es)
    · exact ih (fun d hd => h d (List.mem_cons_of_mem e hd))

theorem return_is_identity (f : Frame w) : w.succession ^ 12 = 1 := by
  ext p
  exact complete_return f p

end Duodenary.Relational

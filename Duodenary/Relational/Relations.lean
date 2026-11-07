import Duodenary.Relational.Whole

/-! Succession, opposition, reversal and return are simultaneous relations
of one arrangement. Powers express cyclic incidence, not elapsed time. -/
namespace Duodenary.Relational

variable {w : Whole}

def opposition (w : Whole) : Equiv.Perm w.Position := w.succession ^ 6

def reversal (f : Frame w) (c : C12) (p : w.Position) : w.Position :=
  f.places (c - f.places.symm p)

theorem succession_incidence (f : Frame w) (n : Nat) (x : C12) :
    (w.succession ^ n) (f.places x) = f.places (x + n) := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [pow_succ', Equiv.Perm.mul_apply, ih, f.coherence]
    congr 1
    push_cast
    ring

theorem opposition_incidence (f : Frame w) (x : C12) :
    opposition w (f.places x) = f.places (x + 6) := by
  exact succession_incidence f 6 x

theorem opposition_involutive (f : Frame w) :
    Function.Involutive (opposition w) := by
  intro p
  obtain ⟨x, rfl⟩ := f.places.surjective p
  rw [opposition_incidence f, opposition_incidence f]
  have h : x + 6 + 6 = x := by
    rw [add_assoc, show (6 : C12) + 6 = 0 by decide, add_zero]
  rw [h]

theorem opposition_distinct (f : Frame w) (p : w.Position) : opposition w p ≠ p := by
  obtain ⟨x, rfl⟩ := f.places.surjective p
  rw [opposition_incidence f]
  intro h
  exact Duodenary.opposite_has_no_fixed_point x (f.places.injective h)

theorem reversal_involutive (f : Frame w) (c : C12) :
    Function.Involutive (reversal f c) := by
  intro p
  simp only [reversal, Equiv.symm_apply_apply]
  have h : c - (c - f.places.symm p) = f.places.symm p := by ring
  rw [h, Equiv.apply_symm_apply]

theorem reversal_exchanges_orientation (f : Frame w) (c : C12) (p : w.Position) :
    reversal f c (w.succession p) = w.succession.symm (reversal f c p) := by
  obtain ⟨x, rfl⟩ := f.places.surjective p
  apply w.succession.injective
  simp only [Equiv.apply_symm_apply]
  rw [f.coherence]
  simp only [reversal, Equiv.symm_apply_apply]
  rw [f.coherence]
  congr 1
  ring

theorem reversal_retains_opposition (f : Frame w) (c : C12) (p : w.Position) :
    reversal f c (opposition w p) = opposition w (reversal f c p) := by
  obtain ⟨x, rfl⟩ := f.places.surjective p
  rw [opposition_incidence f]
  simp only [reversal, Equiv.symm_apply_apply]
  rw [opposition_incidence f]
  congr 1
  have h6 : (6 : C12) = -6 := by decide
  calc
    c - (x + 6) = (c - x) + (-6) := by ring
    _ = c - x + 6 := by rw [← h6]

/-- Closure is intrinsic to the whole, independent of the chosen frame. -/
theorem complete_return (f : Frame w) (p : w.Position) :
    (w.succession ^ 12) p = p := by
  obtain ⟨x, rfl⟩ := f.places.surjective p
  rw [succession_incidence f]
  change f.places (x + (12 : C12)) = f.places x
  rw [show (12 : C12) = 0 by decide, add_zero]

theorem no_premature_return (f : Frame w) (p : w.Position)
    (n : Fin 12) (hn : n ≠ 0) : (w.succession ^ n.val) p ≠ p := by
  obtain ⟨x, rfl⟩ := f.places.surjective p
  rw [succession_incidence f]
  intro h
  have hz : (n.val : C12) = 0 := by
    have hh := f.places.injective h
    exact add_left_cancel (show x + (n.val : C12) = x + 0 by simpa using hh)
  have impossible : ∀ k : Fin 12, (k.val : C12) = 0 → k = 0 := by decide
  exact hn (impossible n hz)

theorem succession_fourfold_three_mode : ∀ x : C12,
    crt (x + 1) = ((crt x).1 + 1, (crt x).2 + 1) := by decide

theorem opposition_complements_fourfold_retains_mode : ∀ x : C12,
    crt (x + 6) = ((crt x).1 + 2, (crt x).2) := by decide

theorem reversal_rearticulates_both : ∀ x : C12,
    crt (-x) = (-(crt x).1, -(crt x).2) := by decide

end Duodenary.Relational

import Duodenary.Core.Cyclic
import Duodenary.Imported.ProductKernel
import Duodenary.Acausal.Calendar

/-! # Duodenary.Spacetime — TASK-SPACETIME-01 (G1–G5 formalization)

Mathlib-free, choice-free (no `Classical.choice`, no `sorryAx`).

G1 (primary, owner decision 11): state space = Z/12 position x Nat time,
metric = cyclic distance on position + time distance (truncated Nat sub pair,
which equals |m - n| constructively — core has no `Nat.dist`).
G2: evolution advances position (rotation by 1) and time (+1); isometry.
G3: antipodal shift rotates position by 6 and leaves time FIXED.
    Justification: on Z/12 the antipodal map is rotation by 6; the time axis
    is Nat, whose order-2 distance-preserving self-map is the identity.
    Time-unchanged is therefore the lift of the antipode that is an
    isometry and an involution.
G4: first finite difference of a trajectory, `x (n+1) - x n` (Fin sub, modular).
G5: calendar connection — every `CalHom : Fin 260 → C12` factors through the
    order-4 subgroup {0,3,6,9}; reuses `calendar_image_classification` verbatim.
-/

namespace Duodenary.Spacetime

/-! ## G1 — carrier and metric -/

/-- G1 state space: Z/12 position x Nat time. -/
def State : Type := C12 × Nat

/-- Constructive absolute difference on Nat: `m - n + (n - m) = |m - n|`. -/
def timeDist (m n : Nat) : Nat := m - n + (n - m)

theorem timeDist_symm (m n : Nat) : timeDist m n = timeDist n m := by
  unfold timeDist; omega

theorem timeDist_succ_invariant (m n : Nat) :
    timeDist (m + 1) (n + 1) = timeDist m n := by
  unfold timeDist; omega

/-- G1 metric: cyclic distance on the position coordinate plus time distance. -/
def stMetric (p q : State) : Nat :=
  cyclicDistance p.1 q.1 + timeDist p.2 q.2

theorem stMetric_nonneg (p q : State) : 0 ≤ stMetric p q := Nat.zero_le _

theorem stMetric_symm (p q : State) : stMetric p q = stMetric q p := by
  unfold stMetric
  rw [distance_symmetric, timeDist_symm]

/-- Cyclic distance is invariant under a common rotation. -/
theorem cyclicDistance_rotate_invariant (a x y : C12) :
    cyclicDistance (rotate a x) (rotate a y) = cyclicDistance x y := by
  revert a x y
  decide

/-! ## G2 — evolution -/

/-- G2 evolution: rotate the position by one and advance time by one. -/
def evolve (p : State) : State := (rotate 1 p.1, p.2 + 1)

theorem evolve_isometry (p q : State) :
    stMetric (evolve p) (evolve q) = stMetric p q := by
  unfold stMetric evolve
  rw [cyclicDistance_rotate_invariant, timeDist_succ_invariant]

/-! ## G3 — antipodal shift (time unchanged) -/

/-- Rotation by 6 agrees with `opposite`. -/
theorem opposite_eq_rotate6 (x : C12) : opposite x = rotate 6 x := by
  revert x
  decide

/-- G3 antipodal shift: position ↦ antipode, time unchanged (justified above). -/
def antipodalShift (p : State) : State := (opposite p.1, p.2)

theorem antipodalShift_isometry (p q : State) :
    stMetric (antipodalShift p) (antipodalShift q) = stMetric p q := by
  unfold stMetric antipodalShift
  rw [opposite_eq_rotate6, opposite_eq_rotate6, cyclicDistance_rotate_invariant]

/-- G3 is an involution on the state space. -/
theorem antipodalShift_involutive (p : State) :
    antipodalShift (antipodalShift p) = p := by
  unfold antipodalShift
  have h := opposite_involution p.1
  cases p with
  | mk pos t => simp only [Prod.mk.injEq, h, and_true]

/-! ## G4 — finite difference -/

/-- G4 first finite difference of a trajectory (Fin subtraction is modular). -/
def fdiff (x : Nat → C12) (n : Nat) : C12 := x (n+1) - x n

theorem fdiff_const (c : C12) (n : Nat) : fdiff (fun _ => c) n = 0 := by
  unfold fdiff
  simp

/-- G4 of the unit-rotation trajectory is the constant unit. -/
theorem fdiff_rotate_one (n : Nat) :
    fdiff (fun k => rotate (ofNatC12 k) (0 : C12)) n = (1 : C12) := by
  have h0 : ∀ x : C12, x + (0 : C12) = x := by decide
  have hinv : ∀ x : C12, x + (1 : C12) - x = (1 : C12) := by decide
  have k1 : ∀ c : Nat, ofNatC12 (c + 1) = ofNatC12 c + (1 : C12) := by
    intro c
    show (⟨(c + 1) % 12, by omega⟩ : C12) = ⟨(c % 12 + 1) % 12, by omega⟩
    simp only [Fin.mk.injEq, Nat.mod_add_mod]
  unfold fdiff rotate
  dsimp only
  rw [h0, k1 n, h0]
  exact hinv (ofNatC12 n)

/-! ## G5 — calendar factorization through {0,3,6,9} -/

/-- The factor map on C12 (identity; the constraint is on its image). -/
def calendarFactor (f : CalHom) : C12 → C12 := fun y => y

/-- G5: every `CalHom` factors as `calendarFactor f ∘ f.toFun` with the factor
landing in the order-4 subgroup {0,3,6,9}; reuses
`calendar_image_classification` verbatim. -/
theorem cal_factorization (f : CalHom) :
    (fun x : Fin 260 => calendarFactor f (f.toFun x)) = f.toFun
      ∧ ∀ x : Fin 260,
          calendarFactor f (f.toFun x) = 0
            ∨ calendarFactor f (f.toFun x) = 3
            ∨ calendarFactor f (f.toFun x) = 6
            ∨ calendarFactor f (f.toFun x) = 9 := by
  refine ⟨funext fun _ => rfl, fun x => ?_⟩
  exact calendar_image_classification f x

end Duodenary.Spacetime

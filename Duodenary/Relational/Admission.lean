import Duodenary.Relational.Registers

namespace Duodenary.Relational
open Lean

def constitutiveFrame : Frame duodenaryWhole where
  places := Equiv.refl C12
  coherence := by intro x; rfl

inductive StructuralRelation where
  | succession
  | opposition
  | reversal (axis : C12)
  | return
  deriving DecidableEq

def relationMeaning : StructuralRelation → Equiv.Perm C12
  | .succession => duodenaryWhole.succession
  | .opposition => opposition duodenaryWhole
  | .reversal c => reversalPerm constitutiveFrame c
  | .return => 1

theorem every_relation_integrity (r : StructuralRelation) :
    GridIntegrity constitutiveFrame (relationMeaning r) := by
  cases r with
  | succession => exact succession_grid_integrity constitutiveFrame
  | opposition => exact opposition_grid_integrity constitutiveFrame
  | reversal c => exact reversal_grid_integrity constitutiveFrame c
  | «return» => exact identity_grid_integrity constitutiveFrame

/-- Expression order describes adjacency of related states, not a causal ontology. -/
def wordMeaning (rs : List StructuralRelation) : Equiv.Perm C12 :=
  relationComposite (w := duodenaryWhole) (rs.reverse.map relationMeaning)

theorem every_word_integrity (rs : List StructuralRelation) :
    GridIntegrity constitutiveFrame (wordMeaning rs) := by
  unfold wordMeaning
  apply arbitrary_composition_grid_integrity constitutiveFrame
  intro e he
  obtain ⟨r, _, rfl⟩ := List.mem_map.mp he
  exact every_relation_integrity r

def ConstitutivePath : C12 → List StructuralRelation → List C12 → Prop
  | _, [], [] => True
  | x, r::rs, y::ys => y = relationMeaning r x ∧ ConstitutivePath y rs ys
  | _, _, _ => False

def pathGate : C12 → List StructuralRelation → List C12 → Bool
  | _, [], [] => true
  | x, r::rs, y::ys => decide (y = relationMeaning r x) && pathGate y rs ys
  | _, _, _ => false

theorem path_gate_exact (x : C12) (rs : List StructuralRelation) (ys : List C12) :
    pathGate x rs ys = true ↔ ConstitutivePath x rs ys := by
  induction rs generalizing x ys with
  | nil => cases ys <;> simp [pathGate, ConstitutivePath]
  | cons r rs ih =>
    cases ys with
    | nil => simp [pathGate, ConstitutivePath]
    | cons y ys => simp [pathGate, ConstitutivePath, ih]

theorem accepted_path_is_constitutive (x : C12) (rs : List StructuralRelation)
    (ys : List C12) (h : pathGate x rs ys = true) : ConstitutivePath x rs ys :=
  (path_gate_exact x rs ys).mp h

def matrixJson : Json := Json.arr (Array.ofFn fun a : Fin 4 =>
  Json.arr (Array.ofFn fun b : Fin 3 => rowJson (registerEquiv ⟨(a,b)⟩)))

def matrixFromJson (j : Json) : Except String Unit := do
  let rows ← j.getArr?
  if rows.size != 4 then throw "fourfold matrix must have four rows"
  for a in [0:4] do
    let cells ← (rows[a]!).getArr?
    if cells.size != 3 then throw "each fourfold class must contain three modes"
    for b in [0:3] do
      let f ← rowFromJson cells[b]!
      if (crt f.station).1.val != a || (crt f.station).2.val != b then
        throw "matrix cell violates constitutive crossing"
  return ()

theorem canonical_matrix_admitted : matrixFromJson matrixJson = .ok () := by rfl

/-- Every cell is determined by the primary crossing, with no extra cell identity. -/
def ConstitutiveMatrix (cells : Fin 4 → Fin 3 → Fulgurite) : Prop :=
  ∀ a b, crt (cells a b).station = (a,b)

theorem constitutive_matrix_unique (cells : Fin 4 → Fin 3 → Fulgurite)
    (h : ConstitutiveMatrix cells) (a : Fin 4) (b : Fin 3) :
    cells a b = registerEquiv ⟨(a,b)⟩ := by
  have same := congrArg uncrt (h a b)
  rw [crt_left_inverse] at same
  cases hp : cells a b with
  | mk x =>
    have hx : x = uncrt (a,b) := by simpa [hp] using same
    exact congrArg Fulgurite.mk hx

theorem every_word_synchronization (rs : List StructuralRelation) (o : Obsidian)
    (f : Fulgurite) (h : synchronized o f) :
    synchronized (obsidianAction (wordMeaning rs) o) (fulguriteAction (wordMeaning rs) f) :=
  synchronization_closed (wordMeaning rs) o f h

theorem return_is_full_circuit : relationMeaning .return = duodenaryWhole.succession ^ 12 :=
  (return_is_identity constitutiveFrame).symm

theorem composite_append (es ds : List (Equiv.Perm duodenaryWhole.Position)) :
    relationComposite (w := duodenaryWhole) (es ++ ds) =
      relationComposite (w := duodenaryWhole) es * relationComposite (w := duodenaryWhole) ds := by
  induction es with
  | nil => simp [relationComposite]
  | cons e es ih => simp [relationComposite, ih, mul_assoc]

theorem word_cons (r : StructuralRelation) (rs : List StructuralRelation) :
    wordMeaning (r::rs) = wordMeaning rs * relationMeaning r := by
  simp [wordMeaning, List.reverse_cons, List.map_append, composite_append, relationComposite]

def finalPosition : C12 → List C12 → C12
  | x, [] => x
  | _, y::ys => finalPosition y ys

theorem constitutive_path_endpoint (x : C12) (rs : List StructuralRelation)
    (ys : List C12) (h : ConstitutivePath x rs ys) :
    finalPosition x ys = wordMeaning rs x := by
  induction rs generalizing x ys with
  | nil =>
    cases ys with
    | nil => rfl
    | cons y ys => exact False.elim h
  | cons r rs ih =>
    cases ys with
    | nil => exact False.elim h
    | cons y ys =>
      have hy : y = relationMeaning r x := h.1
      calc
        finalPosition x (y::ys) = finalPosition y ys := rfl
        _ = wordMeaning rs y := ih y ys h.2
        _ = wordMeaning rs (relationMeaning r x) := congrArg (wordMeaning rs) hy
        _ = wordMeaning (r::rs) x := by rw [word_cons]; rfl

theorem accepted_path_endpoint (x : C12) (rs : List StructuralRelation)
    (ys : List C12) (h : pathGate x rs ys = true) :
    finalPosition x ys = wordMeaning rs x :=
  constitutive_path_endpoint x rs ys (accepted_path_is_constitutive x rs ys h)

end Duodenary.Relational

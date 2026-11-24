import Mathlib.Data.ZMod.Basic
import Mathlib.Data.Nat.Totient
import CRTMathlib
import C12ZModBridge
import ClosedRingZ12

/-!
# CP-02: Structural transport interface — representations onto `ZMod 12`

Article IV of the certification contract: an artifact, representation or
computational implementation is mapped onto the canonical structure; where
the map preserves the applicable operations, certified properties transport
through it. This module packages that interface for the Duodenary ecosystem
and instantiates it for every remaining representation.

## The interface

Two shapes, distinguished exactly as Article IV requires:

* **Bijective structural equivalence** (`≃+*`): `C12` via
  `c12RingEquivZMod`, and the CRT factors `ZMod 4 × ZMod 3` via `crt12.symm`.
  Full property inheritance — every `ZMod 12` theorem pulls back.
* **Bounded presentation** (`ℕ → ZMod 12`): the `ClosedRingZ12`
  computational implementation. Its carrier is infinite, so operation
  compatibility is stated as equalities in `ZMod 12` (unbounded for the ring
  ops, bounded `decide` for residue predicates like `isUnit`/`dist`).

## What is proved here

* `natResidue_add/mul/sub/J/zero/one` — the core bounded operations are
  *exactly* `ZMod 12` arithmetic under `Nat.cast`, for all inputs (the
  `(m % 12 : ZMod 12) = m` collapse `ZMod.natMod` makes the mod-12 reduction
  definitional).
* `natResidue_isUnit`, `natResidue_dist` — residue-level facts, `decide`-checked.
* `zmod12_units_card`, `c12_units_card` — inherited theorem:
  `ZMod.card_units_eq_totient` (φ 12 = 4) transported to `C12`.
* `zmod12_unit_iff_coprime` — units of `ZMod 12` are exactly the residues
  coprime to 12, matching core `isUnit`'s `{1,5,7,11}`.

Axiom discipline: `VerifyTransport.lean` runs `#print axioms` on every public
declaration and gates on absence of `sorryAx`.
-/

set_option maxRecDepth 100000

namespace ClosedRingZ12.ZMod12Transport

open Duodenary
open Duodenary.C12Mathlib
open ClosedRingZ12.MathlibCRT

/-! ## Section 1: `ℕ`-residue presentation — unbounded ring compatibility

`ClosedRingZ12.add x y = (x + y) % 12` etc. Under `Nat.cast` into `ZMod 12`,
`((m % 12 : ℕ) : ZMod 12)` collapses to `(m : ZMod 12)` (`ZMod.natCast_mod`),
so the core operations satisfy the ring laws *definitionally* — no bounded
quantifier needed. -/

theorem natCast_mod12 (m : Nat) : ((m % 12 : Nat) : ZMod 12) = (m : ZMod 12) :=
  ZMod.natCast_mod m 12

theorem natResidue_zero : (((0 : Nat) : Nat) : ZMod 12) = 0 := by decide

theorem natResidue_one : (((1 : Nat) : Nat) : ZMod 12) = 1 := by decide

theorem natResidue_add (x y : Nat) :
    (((ClosedRingZ12.add x y : Nat) : Nat) : ZMod 12)
      = (x : ZMod 12) + (y : ZMod 12) := by
  show (((x + y) % 12 : Nat) : ZMod 12) = _
  rw [natCast_mod12]
  simp only [Nat.cast_add]

theorem natResidue_mul (x y : Nat) :
    (((ClosedRingZ12.mul x y : Nat) : Nat) : ZMod 12)
      = (x : ZMod 12) * (y : ZMod 12) := by
  show (((x * y) % 12 : Nat) : ZMod 12) = _
  rw [natCast_mod12]
  simp only [Nat.cast_mul]

theorem natResidue_sub (x y : Nat) :
    (((ClosedRingZ12.sub x y : Nat) : Nat) : ZMod 12)
      = (x : ZMod 12) - (y : ZMod 12) := by
  show (((x + (12 - y % 12)) % 12 : Nat) : ZMod 12) = _
  rw [natCast_mod12]
  have hy : y % 12 ≤ 12 := by omega
  rw [Nat.cast_add, Nat.cast_sub hy]
  have h12 : ((12 : Nat) : ZMod 12) = 0 := by decide
  rw [natCast_mod12, h12]
  ring

theorem natResidue_J (x : Nat) :
    (((ClosedRingZ12.J x : Nat) : Nat) : ZMod 12)
      = (x : ZMod 12) + 6 := by
  show (((x + 6) % 12 : Nat) : ZMod 12) = _
  rw [natCast_mod12]
  simp only [Nat.cast_add, Nat.cast_ofNat]

/-! ## Section 2: residue-level facts (`decide` over `< 12`)

`isUnit` and `dist` are predicates on the *residue*, not ring operations —
they are only meaningful on `< 12`, matching the core module's bounded
discipline. -/

theorem natResidue_isUnit : ∀ u < 12,
    (ClosedRingZ12.isUnit u = true ↔ IsUnit ((u : Nat) : ZMod 12)) := by
  decide

/-- `dist x y` is the smaller of the two residues `±(x − y) mod 12`; its
`ZMod 12` image is therefore `x − y` or `y − x`. -/
theorem natResidue_dist : ∀ x < 12, ∀ y < 12,
    (((ClosedRingZ12.dist x y : Nat) : Nat) : ZMod 12)
      = ((x : ZMod 12) - (y : ZMod 12)) ∨
        (((ClosedRingZ12.dist x y : Nat) : Nat) : ZMod 12)
          = ((y : ZMod 12) - (x : ZMod 12)) := by
  decide

/-! ## Section 3: inherited theorems through the canonical tower

These are `ZMod 12` theorems from Mathlib, transported to the
duodenary representations through the bridge — Article IV's "transport the
corresponding certified mathematical properties" in action. -/

/-- Inherited: the unit group of `ZMod 12` has cardinality `φ 12 = 4`
(`ZMod.card_units_eq_totient`, Fermat–Euler totient count). -/
theorem zmod12_units_card : Fintype.card (ZMod 12)ˣ = 4 := by
  rw [ZMod.card_units_eq_totient]
  decide

/-- The same count transports to the Duodenary carrier `C12`: its unit
group is definitionally `(ZMod 12)ˣ`'s carrier (`c12CommRing` *is* the
`ZMod 12` instance), so the inherited count applies verbatim. -/
theorem c12_units_card : Fintype.card C12ˣ = 4 := by
  show Fintype.card (ZMod 12)ˣ = 4
  rw [ZMod.card_units_eq_totient]
  decide

/-- Inherited: units of `ZMod 12` are exactly the residues coprime to 12 —
the characterization behind `ZMod.unitsEquivCoprime`, matching core
`isUnit`'s `{1, 5, 7, 11}`. -/
theorem zmod12_unit_iff_coprime : ∀ u < 12,
    IsUnit ((u : Nat) : ZMod 12) ↔ Nat.Coprime u 12 := by
  decide

/-! ## Section 4: model inventory (the instantiations)

* `C12` — bijective `≃+*` (`c12RingEquivZMod`, CP-01);
* `ZMod 4 × ZMod 3` — bijective `≃+*` (`crt12.symm`, CP-00);
* `ℕ` residues — bounded presentation (Sections 1–2).

The antipodal law is already transported to both finite models:
`opposite_transport` (`C12`) and `bridge_J` (`ClosedRingZ12` via `crt12`). -/

/-- The CRT factors form a model of `ZMod 12` through the inverse of the
canonical decomposition — a second bijective instantiation, free by
`RingEquiv.symm`. -/
def crtFactorModel : (ZMod 4 × ZMod 3) ≃+* ZMod 12 := crt12.symm

/-! ## Section 5: Article III invariant closure

The contract's generating invariants, each discharged as a checked
declaration over the canonical tower. -/

/-- Twelve-element cyclic closure: cardinality of the canonical carrier. -/
theorem zmod12_card : Fintype.card (ZMod 12) = 12 := by
  haveI : NeZero 12 := ⟨by decide⟩
  exact ZMod.card 12

theorem c12_card : Fintype.card C12 = 12 := Fintype.card_fin 12

/-- Cyclic closure is transitive: from any residue `x`, some shift `k`
reaches any `y` — the rotation action on `Z/12Z` is transitive. -/
theorem cyclic_transitive : ∀ x < 12, ∀ y < 12,
    ∃ k < 12, ClosedRingZ12.add x k = y := by
  decide

/-- Seven undirected relational distances: `dist` takes values in
`{0, …, 6}` and attains all of them. -/
theorem dist_lt_seven : ∀ x < 12, ∀ y < 12, ClosedRingZ12.dist x y < 7 := by
  decide

theorem dist_attains_all : ∀ d < 7,
    ∃ x < 12, ∃ y < 12, ClosedRingZ12.dist x y = d := by
  decide

/-- Six antipodal pairs: the explicit pairing, certified complete (every
residue occurs), involutive (`J` swaps the components), and of length 6. -/
def antipodalPairs : List (Nat × Nat) :=
  [(0, 6), (1, 7), (2, 8), (3, 9), (4, 10), (5, 11)]

theorem antipodalPairs_length : antipodalPairs.length = 6 := rfl

theorem antipodalPairs_complete : ∀ x < 12,
    ∃ p ∈ antipodalPairs, p.1 = x ∨ p.2 = x := by
  decide

theorem antipodalPairs_J : ∀ p ∈ antipodalPairs,
    ClosedRingZ12.J p.1 = p.2 ∧ ClosedRingZ12.J p.2 = p.1 := by
  decide

/-- Distinguished reference origin: `0` and `1` map to the canonical
coordinate origin and unit under every presentation. -/
theorem origin_map :
    (((0 : Nat) : Nat) : ZMod 12) = 0 ∧
    (((1 : Nat) : Nat) : ZMod 12) = 1 :=
  ⟨natResidue_zero, natResidue_one⟩

/-- Composition of admissible transformations: the four unit slopes are
closed under multiplication — the certified unit group `(ZMod 12)ˣ`
acts by affine maps `x ↦ ux + b`, and `c12_units_card` fixes its order. -/
theorem unit_slopes_closed : ∀ u ∈ ([1, 5, 7, 11] : List Nat),
    ∀ v ∈ ([1, 5, 7, 11] : List Nat), (u * v) % 12 ∈ ([1, 5, 7, 11] : List Nat) := by
  decide

end ClosedRingZ12.ZMod12Transport

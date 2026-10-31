import Mathlib.Tactic.DeriveFintype
import Duodenary.Imported.AffineKernel
import Duodenary.Imported.ProductKernel
/-! The 24 affine maps with multiplier 1 or 11 preserve cyclic distance.
    This is a subgroup of the full 48-element affine group. -/
namespace Duodenary.MachineMetric
set_option maxRecDepth 100000
set_option maxHeartbeats 2000000
open Duodenary.MachineCore

inductive IsoUnit where
  | plus | minus
  deriving DecidableEq, Repr, Fintype

def toUnit : IsoUnit → Duodenary.MachineAffine.Unit12
  | .plus => .u1
  | .minus => .u11

structure Isometry where
  a : IsoUnit
  b : Z12
  deriving DecidableEq, Repr, Fintype

def toAffine (g : Isometry) : Duodenary.MachineAffine.Affine :=
  ⟨toUnit g.a, g.b⟩

def act (g : Isometry) (x : Z12) : Z12 :=
  Duodenary.MachineAffine.apply (toAffine g) x

-- Both allowed multipliers, including reflection x ↦ -x, preserve
-- the undirected shortest-arc metric on a 12-cycle.
theorem circular_isometry : ∀ g : Isometry, ∀ x y : Z12,
    Duodenary.MachineProduct.circularDistance (act g x) (act g y) =
      Duodenary.MachineProduct.circularDistance x y := by
  decide

-- The same 1D affine isometry, applied coordinatewise, preserves
-- the sum of cyclic distances on (Z/12Z) × (Z/12Z).
def actV (g : Isometry) (p : Duodenary.MachineProduct.V) : Duodenary.MachineProduct.V :=
  (act g p.1, act g p.2)

theorem product_isometry (g : Isometry) (p q : Duodenary.MachineProduct.V) :
    Duodenary.MachineProduct.productDistance (actV g p) (actV g q) =
      Duodenary.MachineProduct.productDistance p q := by
  unfold Duodenary.MachineProduct.productDistance actV
  rw [circular_isometry g p.1 q.1, circular_isometry g p.2 q.2]

-- Closure and inverse explicitly remain inside the 24-element subgroup.
def productUnit : IsoUnit → IsoUnit → IsoUnit
  | .plus, b => b
  | .minus, .plus => .minus
  | .minus, .minus => .plus

theorem unit_product_sound : ∀ a b : IsoUnit,
    toUnit (productUnit a b) = Duodenary.MachineAffine.Unit12.prod (toUnit a) (toUnit b) := by
  decide

def compose (g f : Isometry) : Isometry :=
  ⟨productUnit g.a f.a,
   Duodenary.MachineCore.add (Duodenary.MachineCore.mul (toUnit g.a).val f.b) g.b⟩

theorem compose_sound (g f : Isometry) :
    toAffine (compose g f) =
      Duodenary.MachineAffine.compose (toAffine g) (toAffine f) := by
  cases g with
  | mk ga gb =>
    cases f with
    | mk fa fb =>
      simp only [compose, toAffine, Duodenary.MachineAffine.compose,
        Duodenary.MachineAffine.Affine.mk.injEq]
      exact ⟨unit_product_sound ga fa, True.intro⟩

def identity : Isometry := ⟨.plus, 0⟩

def inverse (g : Isometry) : Isometry :=
  ⟨g.a, Duodenary.MachineCore.neg (Duodenary.MachineCore.mul (toUnit g.a).val g.b)⟩

theorem inverse_sound (g : Isometry) :
    toAffine (inverse g) = Duodenary.MachineAffine.inverse (toAffine g) := by
  rfl

theorem inverse_left (g : Isometry) (x : Z12) :
    Duodenary.MachineAffine.apply (toAffine (compose (inverse g) g)) x = x := by
  rw [compose_sound, inverse_sound]
  exact Duodenary.MachineAffine.inverse_left (toAffine g) x

theorem inverse_right (g : Isometry) (x : Z12) :
    Duodenary.MachineAffine.apply (toAffine (compose g (inverse g))) x = x := by
  rw [compose_sound, inverse_sound]
  exact Duodenary.MachineAffine.inverse_right (toAffine g) x

def allOffsets : List Z12 := (List.range 12).map (fun (n : Nat) => (n : Z12))
def allIsometries : List Isometry :=
  ([IsoUnit.plus, IsoUnit.minus] : List IsoUnit).flatMap
    (fun a => allOffsets.map (fun b => ⟨a, b⟩))

theorem subgroup_cardinality : allIsometries.length = 24 := by decide

end Duodenary.MachineMetric

import Duodenary.Core.Cyclic
import Duodenary.Imported.AffineKernel
import Duodenary.Imported.MetricKernel
namespace Duodenary
set_option maxRecDepth 100000
set_option maxHeartbeats 4000000
def machineUnitIndex : MachineAffine.Unit12 → Fin 4
  | .u1 => 0 | .u5 => 1 | .u7 => 2 | .u11 => 3
def machineAffineBridge (f : MachineAffine.Affine) : Affine :=
  (machineUnitIndex f.a, f.b)
theorem machine_slope_agrees : ∀ a : MachineAffine.Unit12,
    unitSlope (machineUnitIndex a) = a.val := by
  intro a
  cases a <;> decide
theorem machine_action_agrees (f : MachineAffine.Affine) (x : C12) :
    affineApply (machineAffineBridge f) x = MachineAffine.apply f x := by
  cases f with
  | mk a b => cases a <;> rfl
/-- Core-only replacements for Mathlib's Function.Injective/Surjective. -/
@[reducible] def InjectiveOn (f : MachineAffine.Affine → Affine) : Prop :=
  ∀ (a b : MachineAffine.Affine), f a = f b → a = b
@[reducible] def SurjectiveOn (f : MachineAffine.Affine → Affine) : Prop :=
  ∀ (y : Affine), ∃ (x : MachineAffine.Affine), f x = y
theorem machine_bridge_injective : InjectiveOn machineAffineBridge := by decide
theorem machine_bridge_surjective : SurjectiveOn machineAffineBridge := by decide
theorem machine_composition_agrees (f g : MachineAffine.Affine) :
    machineAffineBridge (MachineAffine.compose f g) =
      affineCompose (machineAffineBridge f) (machineAffineBridge g) := by
  apply affine_faithful <;>
    simp only [affine_composition, machine_action_agrees, MachineAffine.compose_apply]
theorem machine_distance_agrees : ∀ x y : C12,
    MachineProduct.circularDistance x y = cyclicDistance x y := by decide
theorem affine_metric_classification : ∀ f : Affine,
    (∀ x y : C12, cyclicDistance (affineApply f x) (affineApply f y) = cyclicDistance x y) ↔
      f.1 = 0 ∨ f.1 = 3 := by decide
abbrev MetricAffine := { f : Affine // f.1 = 0 ∨ f.1 = 3 }
def metricSlopeOk (f : Affine) : Prop := f.1 = 0 ∨ f.1 = 3
theorem metricSlopeOk_iff_val (f : Affine) :
    (f.1.val = 0 ∨ f.1.val = 3) ↔ metricSlopeOk f :=
  ⟨fun h => match h with
    | Or.inl h0 => Or.inl (Fin.ext h0)
    | Or.inr h3 => Or.inr (Fin.ext h3),
   fun h => match h with
    | Or.inl h0 => Or.inl (congrArg Fin.val h0)
    | Or.inr h3 => Or.inr (congrArg Fin.val h3)⟩
/-- Proof-carrying enumeration: both lists directly, no filters or attach. -/
def metricElemsLow : List MetricAffine :=
  (List.range 12).map (fun n =>
    (⟨⟨(0 : Fin 4), MachineCore.castNat n⟩, Or.inl rfl⟩ : MetricAffine))
def metricElemsHigh : List MetricAffine :=
  (List.range 12).map (fun n =>
    (⟨⟨(3 : Fin 4), MachineCore.castNat n⟩, Or.inr rfl⟩ : MetricAffine))
instance finEnumMetricAffine : FinEnum MetricAffine where
  elems := (List.range 12).map (fun n =>
    (⟨⟨(0 : Fin 4), MachineCore.castNat n⟩, Or.inl rfl⟩ : MetricAffine)) ++
  (List.range 12).map (fun n =>
    (⟨⟨(3 : Fin 4), MachineCore.castNat n⟩, Or.inr rfl⟩ : MetricAffine))
  complete := by
    intro x
    cases x with
    | mk f hf =>
      rcases hf with h0 | h3
      · refine List.mem_append.2 (Or.inl (List.mem_map.2 ⟨f.2.val, List.mem_range.mpr f.2.isLt, ?_⟩))
        rw [Subtype.mk.injEq]
        exact Prod.ext (Fin.ext (Eq.symm (congrArg Fin.val h0))) (MachineCore.castNat_val_lt f.2)
      · refine List.mem_append.2 (Or.inr (List.mem_map.2 ⟨f.2.val, List.mem_range.mpr f.2.isLt, ?_⟩))
        rw [Subtype.mk.injEq]
        exact Prod.ext (Fin.ext (Eq.symm (congrArg Fin.val h3))) (MachineCore.castNat_val_lt f.2)
theorem metric_affine_cardinality : FinEnum.card MetricAffine = 24 := by decide
theorem affine_slope_five_not_isometry :
    cyclicDistance (affineApply (1,0) 0) (affineApply (1,0) 1) ≠ cyclicDistance 0 1 := by decide

end Duodenary

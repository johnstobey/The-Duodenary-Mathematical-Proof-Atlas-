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
    unitSlope (machineUnitIndex a) = a.val := by decide

theorem machine_action_agrees (f : MachineAffine.Affine) (x : C12) :
    affineApply (machineAffineBridge f) x = MachineAffine.apply f x := by
  cases f with
  | mk a b => cases a <;> rfl

theorem machine_bridge_injective : Function.Injective machineAffineBridge := by decide
theorem machine_bridge_surjective : Function.Surjective machineAffineBridge := by decide

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
theorem metric_affine_cardinality : Fintype.card MetricAffine = 24 := by decide

theorem affine_slope_five_not_isometry :
    cyclicDistance (affineApply (1,0) 0) (affineApply (1,0) 1) ≠ cyclicDistance 0 1 := by decide
end Duodenary

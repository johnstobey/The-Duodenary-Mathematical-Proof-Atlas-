import Duodenary.Core.Cyclic

namespace Duodenary
set_option maxRecDepth 100000
set_option maxHeartbeats 4000000

/-- A counterexample to this quotient construction, not to Collatz. -/
theorem accelerated_collatz_quotient_counterexample :
    (1 : Nat) % 12 = 13 % 12 ∧
      ((3*1+1)/2 : Nat) % 12 ≠ ((3*13+1)/2 : Nat) % 12 := by decide

def affineIterate (f : Affine) : Nat → C12 → C12
  | 0, x => x
  | n+1, x => affineApply f (affineIterate f n x)

theorem affine_twelve_iterates : ∀ f : Affine, ∀ x : C12,
    affineIterate f 12 x = x := by decide

/-- Large representation cardinality does not imply an orbit of that length. -/
theorem affine_slope_five_has_four_cycle :
    affineIterate (1,1) 4 0 = 0 ∧ affineIterate (1,1) 2 0 ≠ 0 := by decide
end Duodenary

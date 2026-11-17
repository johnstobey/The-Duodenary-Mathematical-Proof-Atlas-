import Duodenary.Core.Cyclic

/-! Lesson 8 jigsaw closure, stated natively in Z/12Z.

Source: C.P. Tobey correspondence course, Lesson 8 (solar system design).
Tobey pairs the twelve bodies numbered by mean distance from Earth:
(1,2), (3,12), (4,11), (5,10), (6,9), (7,8), asserting each pair
"totals 15" via a wraparound in which 1 is read as 13.

Provenance note: the constant 15 is a decimal (base-10) artifact of that
wraparound patch. The native structural fact is k + k' = 3 in Z/12Z,
i.e. the fixed-point-free involution k ↦ 3 - k. Nothing below depends
on the decimal rendering. -/

namespace Duodenary

/-- Lesson 8 jigsaw pairing: each station k is paired with 3 - k. -/
def jigsaw (x : C12) : C12 := reflect 3 x

theorem jigsaw_involution (x : C12) : jigsaw (jigsaw x) = x :=
  reflection_involution 3 x

/-- The decimal claim "pairs total 15" is the shadow of k + (3 - k) = 3,
  since 15 ≡ 3 (mod 12). -/
theorem jigsaw_pair_sum (k k' : C12) (h : jigsaw k = k') : k + k' = 3 := by
  rw [← h]
  unfold jigsaw reflect
  ring

/-- No station pairs with itself: 2k = 3 has no solution in Z/12Z
  (even vs odd), so the involution is exactly six transposition pairs,
  matching Tobey's six pairs. -/
theorem jigsaw_no_fixed_point : ∀ x : C12, jigsaw x ≠ x := by decide

/-- Every station is moved by the pairing (twelve moved points = six pairs). -/
theorem jigsaw_moved_points_card :
    (Finset.univ.filter (fun x => jigsaw x ≠ x)).card = 12 := by decide

end Duodenary

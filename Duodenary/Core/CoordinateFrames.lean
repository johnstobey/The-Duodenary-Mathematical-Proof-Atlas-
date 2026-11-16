import Duodenary.Core.Cyclic

/-! Typed finite coordinate-frame operations. Absolute Aries=0; relative Cancer=0.
    These functions are not a substitute for provenance-bearing source witnesses. -/
namespace Duodenary
namespace CoordinateFrames

def ariesToCancer (k : Nat) : Nat := (k + 9) % 12
def cancerToAries (k : Nat) : Nat := (k + 3) % 12

def reduceInteger (k : Int) : Nat := Int.toNat (k % 12)
def ariesFineToCancer (q : Nat) : Nat :=
  12 * ariesToCancer (q / 12) + q % 12
def cancerFineToAries (q : Nat) : Nat :=
  12 * cancerToAries (q / 12) + q % 12
def ariesCellToCancer (c : Nat) : Nat :=
  144 * ariesToCancer (c / 144) + c % 144
def cancerCellToAries (c : Nat) : Nat :=
  144 * cancerToAries (c / 144) + c % 144

def subsignAries (k j : Nat) : Nat := (7 + 12 - k % 12 + j % 12) % 12
def subsignCancerOfAries (k j : Nat) : Nat := ariesToCancer (subsignAries k j)

theorem sector_roundtrip : ∀ k : Fin 12,
    cancerToAries (ariesToCancer k.val) = k.val := by decide
theorem reverse_sector_roundtrip : ∀ k : Fin 12,
    ariesToCancer (cancerToAries k.val) = k.val := by decide
theorem fine_roundtrip : ∀ q : Fin 144,
    cancerFineToAries (ariesFineToCancer q.val) = q.val := by decide
theorem cell_roundtrip : ∀ c : Fin 1728,
    ariesCellToCancer (cancerCellToAries c.val) = c.val := by decide

end CoordinateFrames
end Duodenary

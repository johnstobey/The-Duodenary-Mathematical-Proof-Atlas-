import Lean
import Duodenary.Core.CoordinateFrames
open Lean
open Duodenary.CoordinateFrames

private def obj (xs : List (String × Json)) : Json := Json.mkObj xs
private def envelope (anchor frame : String) (value : Json) : Json :=
  obj [("anchor", toJson anchor), ("frame_type", toJson frame), ("value", value)]
private def vector (id : String) (input : Json) (target : String)
    (expectation : Option Json) (subsign : Option Nat := none) : Json :=
  obj <| [("id", toJson id), ("input", input), ("target_anchor", toJson target)] ++
    (match subsign with
      | none => []
      | some n => [("subsign", toJson true), ("_subsign_expected", toJson n)]) ++
    (match expectation with
      | some expected => [("expected", expected)]
      | none => [("error", toJson ("invalid" : String))])

private def vectors : List Json := [
  vector "V01-bool-true" (envelope "aries_zero" "unreduced_int" (toJson true)) "cancer_zero" none,
  vector "V02-bool-false" (envelope "cancer_zero" "canonical_sector" (toJson false)) "aries_zero" none,
  vector "V03-negative-one" (envelope "aries_zero" "unreduced_int" (toJson (-1 : Int))) "aries_zero"
    (some <| envelope "aries_zero" "canonical_sector" (toJson (reduceInteger (-1)))),
  vector "V04-negative-thirteen" (envelope "cancer_zero" "unreduced_int" (toJson (-13 : Int))) "cancer_zero"
    (some <| envelope "cancer_zero" "canonical_sector" (toJson (reduceInteger (-13)))),
  vector "V05-aries-origin" (envelope "aries_zero" "canonical_sector" (toJson (0 : Nat))) "cancer_zero"
    (some <| envelope "cancer_zero" "canonical_sector" (toJson (ariesToCancer 0))),
  vector "V06-cancer-origin" (envelope "cancer_zero" "canonical_sector" (toJson (0 : Nat))) "aries_zero"
    (some <| envelope "aries_zero" "canonical_sector" (toJson (cancerToAries 0))),
  vector "V07-canonical-overflow" (envelope "aries_zero" "canonical_sector" (toJson (12 : Nat))) "cancer_zero" none,
  vector "V08-provenance-preserving-pair" (envelope "aries_zero" "paired_kj" (obj [("k", toJson (3 : Nat)), ("j", toJson (0 : Nat))])) "cancer_zero"
    (some <| obj [("anchor", toJson ("cancer_zero" : String)), ("frame_type", toJson ("paired_kj" : String)),
      ("value", obj [("k", toJson (ariesToCancer 3)), ("j", toJson (0 : Nat))]),
      ("subsign", toJson (subsignCancerOfAries 3 0))]),
  vector "V09-fine-coordinate" (envelope "aries_zero" "fine_144" (toJson (37 : Nat))) "cancer_zero"
    (some <| envelope "cancer_zero" "fine_144" (toJson (ariesFineToCancer 37))),
  vector "V10-cell-coordinate" (envelope "cancer_zero" "cell_1728" (toJson (0 : Nat))) "aries_zero"
    (some <| envelope "aries_zero" "cell_1728" (toJson (cancerCellToAries 0)))
]

-- The vector schema is the external contract; no theorem or executable PASS is
-- asserted by merely printing its examples. Consumers must build this module.
def main : IO Unit := do
  let args ← IO.getArgs
  if args.size != 1 then
    throw <| IO.userError "usage: lake exe emit-vectors <output-json-path>"
  let doc := obj [
    ("schema", toJson ("CoordinateEnvelopeVectors-1" : String)),
    ("notes", toJson ("cell_1728 is sector-major packed, not digest-derived" : String)),
    ("vectors", Json.arr vectors.toArray)
  ]
  IO.FS.writeFile args[0]! (doc.compress ++ "\n")

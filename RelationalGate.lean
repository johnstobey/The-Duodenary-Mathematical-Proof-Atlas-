import Duodenary.Relational.Admission

open Lean Duodenary Duodenary.Relational

def exactKeys (j : Json) (keys : List String) : Except String Unit := do
  match j with
  | .obj fields =>
    if fields.fold (fun n _ _ => n+1) 0 != keys.length then throw "unexpected or missing object field"
    for k in keys do
      let _ ← j.getObjVal? k
    return ()
  | _ => throw "object expected"

def relationFromJson (j : Json) : Except String StructuralRelation := do
  let kind ← (← j.getObjVal? "kind").getStr?
  match kind with
  | "succession" => exactKeys j ["kind"]; return .succession
  | "opposition" => exactKeys j ["kind"]; return .opposition
  | "return" => exactKeys j ["kind"]; return .return
  | "reversal" =>
    exactKeys j ["kind","axis"]
    let axis ← (← j.getObjVal? "axis").getNat?
    if axis ≥ 12 then throw "reversal axis outside duodenary whole"
    return .reversal axis
  | _ => throw "unknown structural relation"

def admitManifestation (j : Json) : Except String Json := do
  exactKeys j ["version","matrix","states","relations"]
  let version ← (← j.getObjVal? "version").getStr?
  if version != "relational-register-v1" then throw "unsupported structural signature"
  matrixFromJson (← j.getObjVal? "matrix")
  let rawStates ← (← j.getObjVal? "states").getArr?
  let states ← rawStates.toList.mapM rowFromJson
  let rawRelations ← (← j.getObjVal? "relations").getArr?
  let relations ← rawRelations.toList.mapM relationFromJson
  match states with
  | [] => throw "at least one structurally bound state is required"
  | first :: rest =>
    if !pathGate first.station relations (rest.map Fulgurite.station) then
      throw "state adjacency disagrees with declared relations"
    return Json.mkObj [
      ("admitted", toJson true),
      ("constitutive_crossing", toJson true),
      ("dual_registers_synchronized", toJson true),
      ("relation_count", toJson relations.length),
      ("canonical_states", Json.arr (states.map rowJson).toArray),
      ("matrix", matrixJson)]

def report (result : Except String Json) : IO UInt32 := do
  match result with
  | .ok j => IO.println j.compress; return 0
  | .error message =>
    IO.println (Json.mkObj [("admitted",toJson false),("error",toJson message)]).compress
    return 1

def main (args : List String) : IO UInt32 := do
  match args with
  | ["--matrix"] => IO.println matrixJson.compress; return 0
  | ["--row", n] =>
    match n.toNat? with
    | some x =>
      if x < 12 then IO.println (rowJson ⟨x⟩).compress; return 0
      else return ← report (.error "station outside duodenary whole")
    | none => return ← report (.error "natural station required")
  | ["--batch", path] =>
    try
      let text ← IO.FS.readFile path
      match Json.parse text >>= Json.getArr? with
      | .error message => return ← report (.error message)
      | .ok cases =>
        let results := cases.map fun j =>
          match admitManifestation j with
          | .ok value => value
          | .error message => Json.mkObj [("admitted",toJson false),("error",toJson message)]
        IO.println (Json.arr results).compress
        return 0
    catch error => return ← report (.error error.toString)
  | ["--check", path] =>
    try
      let text ← IO.FS.readFile path
      return ← report (Json.parse text >>= admitManifestation)
    catch error => return ← report (.error error.toString)
  | _ =>
    IO.eprintln "usage: relationalGate --matrix | --row N | --check FILE"
    return 2

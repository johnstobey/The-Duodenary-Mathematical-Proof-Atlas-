# CAL-PROGRESS — TASK-CAL-OWN

Goal: Convert Duodenary/Acausal/Calendar.lean to Mathlib-free, single file,
5 theorem names preserved, CalHom = own `Fin 260 →+ C12` replacement (JST-01 authorized).

## Probe (done, pre-write)
Toolchain leanprover/lean4:v4.14.0. Core-only probe (/tmp/calprobe.lean, run via
`lake env lean` in ~/atlas-optionb-2026-11-09) confirms: Fin.val_add, Fin.val_mul,
Fin.zero_add (NeZero ok), Fin.val_zero, List.mem_append, List.length_append,
List.mem_reverse, List.mem_range, List.mem_map, List.append_nil, List.length_eq_zero,
DecidableEq (Fin 12), Decidable (a ∈ List), Decidable (∀ y : Fin 12, ...), and
`by decide` on the annihilator statement — all OK. MISSING: List.mem_split (proved locally).

## Theorem status
- calendar_annihilator_classification: pending build (design: `by decide` via core ∀-Fin instance)
- calendar_image_annihilated: pending build (route: addN 260 x = 0; val arithmetic via Fin.val_add/mul + omega)
- calendar_image_classification: pending build (mp of annihilator + image_annihilated)
- calendar_no_surjective_hom: pending build (cases on h 1 ∃, core-only, no Classical)
- calendar_image_card_bound: pending build (noDup + pigeonhole over [0,3,6,9])

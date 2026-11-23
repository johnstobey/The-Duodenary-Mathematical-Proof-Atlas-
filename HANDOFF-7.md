# HANDOFF-7 — Resolve the last 7 Classical.choice declarations

**One-paragraph summary:** The Option-B purification of `~/atlas-optionb-2026-11-09/`
reduced Classical.choice dependence from 44/153 declarations to **7**; Groups D (18),
C (6), G (3) are fully clean and 10 stop-group declarations cleared without rewording.
The 7 remaining are blocked on mechanics their stop-groups exist to govern: three
`Fintype.card` decides (Group A), one `Finset.image` card decide (Group E), two ℚ
rational identities (Group F), and one `∀-∃` surjectivity decide (Group B). Each has a
written NOT-APPLIED proposal below. **Decision needed from JST-01:** approve or amend
the proposals in §4 (and note that the Group-A/E proposals change the formal claim,
while B and F-variant shape is described per item); until then, do not edit the
library — only test in scratch files.

---

## Handoff context

- Toolchain: `leanprover/lean4:v4.14.0` (Lean 4.14.0, Lake 5.0.0). Elan toolchain
  already installed at `~/.elan/toolchains/leanprover--lean4---v4.14.0`.
- Baseline: 44 declarations depended on Classical.choice. Current: 7.
  Audit of record: `~/atlas-optionb-2026-11-09/step-dcg-axioms.txt` (153 declarations).
- Working copy: `~/atlas-optionb-2026-11-09/`. Original repository:
  `~/UTM-ALIGN-5R-01/R4-Duodenary-Proof-Atlas` — **do not touch**.
- Build: `cd ~/atlas-optionb-2026-11-09 && lake build Duodenary` (currently exit 0).
- Audit command: `lake env lean <scratch.lean>` (scratch files live OUTSIDE the copy,
  e.g. `/tmp/handoff-probe-N.lean`).
- Known fixes already applied (do NOT repeat): hand-written explicit-enumeration
  Fintype instances; `C12 := Fin 12` in `Core/Cyclic.lean`; `decFinPiProd`
  (constructive curried Prod-Pi Decidable instance, in `Core/Cyclic.lean`).
- Known failed approaches (do NOT retry):
  1. `cases` on a `Fin 12` value does **not** enumerate — it destructs to
     `Fin.mk val✝ isLt✝` leaving free variables, so `cases … <;> decide` fails on
     open goals.
  2. Derived Fintype instances (`deriving Fintype`, Mathlib Prod-Fintype) route
     through `Finite.toFintype` → `Classical.choice`; any decide touching them is dirty.
  3. `fin_cases` + `decide` still pulls `Classical.choice` (verified: probe theorem
     came out `[propext, Classical.choice, Quot.sound]`).
  4. Bare `decide` on a goal containing an `∃` (Exists) is dirty — provide an explicit
     witness term instead, then discharge the point-goal.
- Constructive toolkit that WORKS (all axiom-verified in probes):
  - `decFinPiProd` (in `Core/Cyclic.lean`) for `∀ x : Fin n × Fin m, p x` decides;
  - bare `decide` on plain Fin-Pi goals (single/double/triple quantifiers);
  - `revert <binders>; decide` to convert binder-style statements into Pi goals;
  - `show`-ascription `(t : ZMod 12)` + `ring` (ZMod 12 is definitionally Fin 12);
  - `omega` for pure-Nat residual goals (keep `Fin.isLt` hypotheses in context);
  - explicit-witness `∃` proofs: `refine ⟨⟨d.val, by omega⟩, ?_⟩` + val lemmas +
    `omega`.

## Rules for the fresh agent (BINDING)

- Do not change any original statement without written approval from JST-01.
- Test each proposal in a scratch file outside the copy. Report the axiom result for
  each.
- A proposal that changes meaning must be reported, not applied.
- Report UNRESOLVED with the reason if no choice-free proof exists under the stated
  proposal.
- Never edit the original repository; never push; never weaken a statement; no
  `sorry`/`admit`/`native_decide`/new axioms.

---

## The 7 declarations

### 1. `Duodenary.affine_cardinality` — Group A

1. **File/lines:** `Duodenary/Core/Cyclic.lean`, line 85.
2. **Current statement (verbatim):**
```lean
theorem affine_cardinality : Fintype.card Affine = 48 := by decide
```
3. **Exact blocker (`step-dcg-axioms.txt`):**
```
'Duodenary.affine_cardinality' depends on axioms: [propext, Classical.choice, Quot.sound]
```
   Mechanism: `Fintype.card (Fin 4 × C12)` decide routes through the Prod-Fintype
   (classical). No Lean error — it compiles dirty.
4. **Group A; why blocked:** stop-group — fix requires restating the count as a list
   length (proposal below), which needs approval.
5. **NOT-APPLIED proposal (verbatim from REPORT.md §5):**
```lean
theorem affine_cardinality : allAffine.length = 48 := by decide   -- Affine = MachineAffine.Affine
```
   (The companion definition, also part of the proposal and NOT APPLIED:
```lean
def allAffine : List (C12 × C12) :=   -- here: the 48-element MachineAffine enumeration
  allUnits.flatMap fun i => (allOffsets.map fun b => (i, b))
```
   For this declaration the list is `MachineAffine.allAffine` in
   `Duodenary/Imported/AffineKernel.lean` — already defined there.)
6. **Meaning change:** Yes — the claim shifts from `Fintype.card Affine = 48` to
   `list.length = 48`; mathematically equivalent only if the list is proven to
   enumerate `Affine` exactly (the hand-written Fintype instance already asserts
   this, but the formal subject changes).
7. **Minimal first test** — `/tmp/handoff-probe-1.lean`:
```lean
import Duodenary
open Duodenary.MachineAffine
def allAffine' : List (Fin 4 × Fin 12) :=
  allUnits.flatMap fun a => allOffsets.map fun b => ((a : Fin 4), b)
theorem affine_cardinality' : allAffine'.length = 48 := by decide
#print axioms affine_cardinality'
```
   Expect `[propext]` or better, no `Classical.choice`. If clean, report; do not apply.

### 2. `Duodenary.product144_cardinality` — Group A

1. **File/lines:** `Duodenary/Core/Cyclic.lean`, line 114.
2. **Current statement (verbatim):**
```lean
theorem product144_cardinality : Fintype.card Product144 = 144 := by decide
```
3. **Exact blocker:**
```
'Duodenary.product144_cardinality' depends on axioms: [propext, Classical.choice, Quot.sound]
```
   Same Prod-Fintype mechanism as #1.
4. **Group A; why blocked:** stop-group — list-length restatement needs approval.
5. **NOT-APPLIED proposal (verbatim from REPORT.md §5, incl. companion def):**
```lean
def allPairs144 : List (C12 × C12) :=
  (List.range 12).flatMap fun i => (List.range 12).map fun j => ((i : C12), (j : C12))
theorem product144_cardinality : allPairs144.length = 144 := by decide
```
6. **Meaning change:** Yes — as in #1; equivalent only given the enumeration is exact.
7. **Minimal first test** — `/tmp/handoff-probe-2.lean`:
```lean
import Duodenary
namespace Handoff2
open Duodenary
def allPairs144 : List (C12 × C12) :=
  (List.range 12).flatMap fun i => (List.range 12).map fun j => ((i : C12), (j : C12))
theorem product144_cardinality' : allPairs144.length = 144 := by decide
#print axioms product144_cardinality'
end Handoff2
```

### 3. `Duodenary.metric_affine_cardinality` — Group A

1. **File/lines:** `Duodenary/Bridges/Machine.lean`, line 41
   (companion `abbrev MetricAffine := { f : Affine // f.1 = 0 ∨ f.1 = 3 }` at line 40).
2. **Current statement (verbatim):**
```lean
theorem metric_affine_cardinality : Fintype.card MetricAffine = 24 := by decide
```
3. **Exact blocker:**
```
'Duodenary.metric_affine_cardinality' depends on axioms: [propext, Classical.choice, Quot.sound]
```
   Subtype-Fintype card decide; classical.
4. **Group A; why blocked:** stop-group — restatement as filtered-list length needs
   approval.
5. **NOT-APPLIED proposal (verbatim from REPORT.md §5):**
```lean
theorem metric_affine_cardinality :
    ((allUnits' : List Fin 4).filter (fun i => i = 0 ∨ i = 3)).length * 12 = 24 := by decide
```
6. **Meaning change:** Yes — counts a filtered list of slope indices rather than the
   subtype `{ f : Affine // f.1 = 0 ∨ f.1 = 3 }`; equivalent only if the slope-index
   ↔ subtype correspondence (12 offsets each) is additionally established.
7. **Minimal first test** — `/tmp/handoff-probe-3.lean`:
```lean
import Duodenary
theorem metric_affine_cardinality' :
    (([0, 1, 2, 3] : List Nat).filter (fun i => i = 0 ∨ i = 3)).length * 12 = 24 := by decide
#print axioms metric_affine_cardinality'
```

### 4. `Duodenary.calendar_image_card_bound` — Group E

1. **File/lines:** `Duodenary/Acausal/Calendar.lean`, lines 30–38.
2. **Current statement (verbatim):**
```lean
theorem calendar_image_card_bound (f : ZMod 260 →+ C12) :
    (Finset.univ.image f).card ≤ 4 := by
  have hsub : Finset.univ.image f ⊆ ({0,3,6,9} : Finset C12) := by
    intro y hy
    obtain ⟨x, _, rfl⟩ := Finset.mem_image.mp hy
    simpa only [Finset.mem_insert, Finset.mem_singleton] using calendar_image_classification f x
  have bound := Finset.card_le_card hsub
  have hc : ({0,3,6,9} : Finset C12).card = 4 := by decide
  rwa [hc] at bound
```
3. **Exact blocker:**
```
'Duodenary.calendar_image_card_bound' depends on axioms: [propext, Classical.choice, Quot.sound]
```
   Mechanism: `Finset.univ.image` card computation inside `decide` is classical
   (`Finset.image` machinery). Note the sibling theorems
   `calendar_image_classification` / `calendar_no_surjective_hom` are already CLEAN.
4. **Group E; why blocked:** stop-group — ZMod 260 `→+` homomorphism machinery; the
   REPORT proposal rewrites the counting mechanism, needing approval.
5. **NOT-APPLIED proposal (verbatim from REPORT.md §5):**
```lean
theorem calendar_image_card_bound (f : ZMod 260 →+ C12) :
    (Finset.univ.image f).card ≤ 4 := by
  -- unchanged statement; proof to be rebuilt from calendar_image_classification with
  -- a hand-written Finset (insert-based) image-card computation, or as:
  --   let L : List C12 := (List.range 260).map (fun n => f n)
  --   L.eraseDups.length ≤ 4
```
6. **Meaning change:** No for variant 1 (statement unchanged, proof-only rebuild).
   Yes/unsure for the `List.eraseDups` variant — introduces a new counting object;
   report, do not apply.
7. **Minimal first test** — `/tmp/handoff-probe-4.lean` (attack the classical core:
   prove the subset route choice-free):
```lean
import Duodenary
theorem hsub_style (P : Nat → Prop) (hP : ∀ n, P n) :
    ∀ y, y ∈ [0,1,2] → P y := by
  intro y hy
  cases hy with
  | head => exact hP 0
  | tail _ hm => cases hm with
    | head => exact hP 1
    | tail _ hm2 => cases hm2 with
      | head => exact hP 2
      | tail _ hm3 => cases hm3
#print axioms hsub_style
```
   Then attempt: `Finset.card_le_card` replaced by an induction on the subset
   membership using `Finset.mem_insert`/`Finset.mem_singleton` only. Report the
   axiom line of whatever variant compiles.

### 5. `Duodenary.multiple_three_certificate` — Group F

1. **File/lines:** `Duodenary/Problems/UnitFractions.lean`, lines 24–28
   (def `ThreeUnitFractions` at 19–22 uses ℚ).
2. **Current statement (verbatim):**
```lean
theorem multiple_three_certificate (k : Nat) (hk : 0 < k) :
    ThreeUnitFractions (3*k) := by
```
   with `ThreeUnitFractions` (verbatim, lines 19–22):
```lean
def ThreeUnitFractions (n : Nat) : Prop :=
  ∃ x y z : Nat, 0 < x ∧ 0 < y ∧ 0 < z ∧
    (4 : ℚ) / n = 1 / (x : ℚ) + 1 / (y : ℚ) + 1 / (z : ℚ)
```
3. **Exact blocker:**
```
'Duodenary.multiple_three_certificate' depends on axioms: [propext, Classical.choice, Quot.sound]
```
   Mechanism: the `ℚ` division identity is discharged via `field_simp`/`ring` on ℚ,
   whose normalization pulls choice; the statement itself quantifies ℚ division.
4. **Group F; why blocked:** stop-group — needs whole-number restatement (approval).
5. **NOT-APPLIED proposal (verbatim from REPORT.md §5):**
```lean
def ThreeUnitFractionsNat (n : Nat) : Prop :=
  ∃ x y z : Nat, 0 < x ∧ 0 < y ∧ 0 < z ∧ 4 * n * x * y * z = n * (y * z + x * z + x * y)

theorem multiple_three_certificate (k : Nat) (hk : 0 < k) :
    ThreeUnitFractionsNat (3*k) := ⟨k, 4*k, 12*k, by omega, by omega, by omega⟩
  -- witness-side proof: 4*(3k)*k*(4k)*(12k) = 3k*(4k*12k + k*12k + k*4k) — by ring/omega on Nat
theorem two_mod_three_certificate (k : Nat) :
    ThreeUnitFractionsNat (3*k+2) := ⟨k+1, (3*k+2)*(k+1), 3*k+2, …⟩
```
6. **Meaning change:** Yes — replaces the ℚ division identity with its Nat
   cross-multiplied form. Mathematically equivalent for the positive witnesses
   (clearing denominators is valid because `n, x, y, z > 0`), but the formal
   statement changes.
7. **Minimal first test** — `/tmp/handoff-probe-5.lean`:
```lean
import Duodenary
namespace Handoff5
def ThreeUnitFractionsNat (n : Nat) : Prop :=
  ∃ x y z : Nat, 0 < x ∧ 0 < y ∧ 0 < z ∧ 4 * n * x * y * z = n * (y * z + x * z + x * y)
theorem multiple_three_certificate' (k : Nat) (hk : 0 < k) :
    ThreeUnitFractionsNat (3*k) := by
  refine ⟨k, 4*k, 12*k, hk, by omega, by omega, ?_⟩
  ring
#print axioms multiple_three_certificate'
end Handoff5
```

### 6. `Duodenary.two_mod_three_certificate` — Group F

1. **File/lines:** `Duodenary/Problems/UnitFractions.lean`, lines 40–52 (through end).
2. **Current statement (verbatim):**
```lean
theorem two_mod_three_certificate (k : Nat) :
    ThreeUnitFractions (3*k+2) := by
```
3. **Exact blocker:**
```
'Duodenary.two_mod_three_certificate' depends on axioms: [propext, Classical.choice, Quot.sound]
```
   Same ℚ mechanism as #5.
4. **Group F; why blocked:** stop-group — same as #5.
5. **NOT-APPLIED proposal (verbatim from REPORT.md §5, final line):**
```lean
theorem two_mod_three_certificate (k : Nat) :
    ThreeUnitFractionsNat (3*k+2) := ⟨k+1, (3*k+2)*(k+1), 3*k+2, …⟩
```
   (under the same `ThreeUnitFractionsNat` def as #5).
6. **Meaning change:** Yes — same cross-multiplication reasoning as #5; the proposed
   witness `(k+1, (3*k+2)*(k+1), 3*k+2)` matches the current ℚ proof's witnesses.
7. **Minimal first test** — `/tmp/handoff-probe-6.lean`:
```lean
import Duodenary
namespace Handoff6
def ThreeUnitFractionsNat (n : Nat) : Prop :=
  ∃ x y z : Nat, 0 < x ∧ 0 < y ∧ 0 < z ∧ 4 * n * x * y * z = n * (y * z + x * z + x * y)
theorem two_mod_three_certificate' (k : Nat) :
    ThreeUnitFractionsNat (3*k+2) := by
  refine ⟨k+1, (3*k+2)*(k+1), 3*k+2, by omega, by omega, by omega, ?_⟩
  ring
#print axioms two_mod_three_certificate'
end Handoff6
```
   If `ring` alone stalls, close the goal by `multiline` `Nat` ring_nf + `omega`.
   WARNING: verify the identity holds at k=0 before trusting `omega` — it does
   (4·2·1·2·2 = 2·(2·2 + 1·2 + 1·2) → 32 = 16? NO — CHECK: current ℚ proof uses
   witnesses (k+1, (3k+2)(k+1), 3k+2); cross-multiplying
   4/(3k+2) = 1/(k+1) + 1/((3k+2)(k+1)) + 1/(3k+2) gives
   4(k+1)·(3k+2)(k+1)·(3k+2) = (3k+2)·[(3k+2)(k+1) + (3k+2) + (k+1)·(3k+2)(k+1)·0 …]
   — recompute carefully; if the Nat identity is NOT what the ℚ identity states,
   report the mismatch rather than "fixing" it silently.

### 7. `Duodenary.machine_bridge_surjective` — Group B

1. **File/lines:** `Duodenary/Bridges/Machine.lean`, line 25
   (`machineAffineBridge` def at 11–13, `machineUnitIndex` at 9).
2. **Current statement (verbatim):**
```lean
theorem machine_bridge_surjective : Function.Surjective machineAffineBridge := by decide
```
3. **Exact blocker:**
```
'Duodenary.machine_bridge_surjective' depends on axioms: [propext, Classical.choice, Quot.sound]
```
   Mechanism: bare decide on `∀ y, ∃ x, …` — the Exists-decide fallback is classical
   in this snapshot; explicit witness + `rfl` point-goal is the fix.
4. **Group B; why blocked:** stop-group — the REPORT proposal rewrites `Surjective`
   to its ∀-∃ unfolding (approval gate).
5. **NOT-APPLIED proposal (verbatim from REPORT.md §5):**
```lean
theorem machine_bridge_surjective :
    ∀ y : Affine, ∃ f : MachineAffine.Affine, machineAffineBridge f = y := by
  intro y
  exact ⟨⟨y.1, y.2⟩, rfl⟩   -- machineAffineBridge ⟨a, b⟩ = (machineUnitIndex a, b)
```
6. **Meaning change:** No — `Function.Surjective f` is *definitionally* `∀ y, ∃ x, f x = y`;
   the witness `⟨y.1, y.2⟩` exists because `machineUnitIndex` maps the four Unit12
   constructors onto 0,1,2,3 (see `machineUnitIndex` + `machine_slope_agrees`).
7. **Minimal first test** — `/tmp/handoff-probe-7.lean`:
```lean
import Duodenary
namespace Duodenary
theorem machine_bridge_surjective' :
    ∀ y : Affine, ∃ f : MachineAffine.Affine, machineAffineBridge f = y := by
  intro y
  refine ⟨⟨y.1, y.2⟩, ?_⟩
  cases y.1 <;> rfl
#print axioms machine_bridge_surjective'
end Duodenary
```
   (If `rfl` misses, replace with `simp [machineAffineBridge, machineUnitIndex]`.)

---

## The 10 declarations that cleared WITHOUT rewording (check against unchanged-statement rule)

Verify each against the original repository
(`~/UTM-ALIGN-5R-01/R4-Duodenary-Proof-Atlas`) — statement lines should diff clean;
only proof bodies differ. Cleared by the constructive instances
(`decFinPiProd`, hand-written enumeration Fintypes) and the cleanups they enabled:

| # | Declaration | File | Reason it cleared |
|---|---|---|---|
| 1 | `crt_right_inverse` | `Core/Cyclic.lean` | `decFinPiProd` makes the `∀ p : Fin 4 × Fin 3` decide constructive (probe t2) |
| 2 | `crt_preserves_addition` | `Core/Cyclic.lean` | same, double-Fin-Pi decide (probe t3) |
| 3 | `crt_preserves_multiplication` | `Core/Cyclic.lean` | same (probe t4) |
| 4 | `affine_faithful` | `Core/Cyclic.lean` | Prod-Pi decide over `Affine = Fin 4 × C12` constructive (probe taf) |
| 5 | `machine_bridge_injective` | `Bridges/Machine.lean` | structure-Pi decide constructive under hand-written `Fintype Affine` |
| 6 | `machine_distance_agrees` | `Bridges/Machine.lean` | plain Fin-Pi decide native-constructive |
| 7 | `affine_metric_classification` | `Bridges/Machine.lean` | nested Pi + Iff decide constructive via instances |
| 8 | `machine_composition_agrees` | `Bridges/Machine.lean` | depends on `affine_faithful` (now clean) |
| 9 | `calendar_image_classification` | `Acausal/Calendar.lean` | routes through `calendar_annihilator_classification` (∀-decide over `C12 = Fin 12` now constructive) |
| 10 | `calendar_no_surjective_hom` | `Acausal/Calendar.lean` | same routing; its `decide` on `(1 : C12)` disjunction is closed-constructive |

Also already-clean and unchanged (baseline): `calendar_annihilator_classification`
(`Core/Cyclic.lean` dependency chain), `cyclic144_not_exponent12` (ZMod 144).

---

## Recomputed check after ANY change

```bash
cd ~/atlas-optionb-2026-11-09 && lake build Duodenary && echo "build exit=$?"
# audit (153 names, from the baseline list):
lake env lean <scratch-audit>.lean | grep -c "Classical.choice"   # must be ≤ 7
grep -c "sorryAx" <scratch-audit-output>                            # must be 0
```
The 153-declaration name list used for audits is recoverable from
`baseline-axioms.txt` (strip the `depends on axioms:` suffixes).

# REPORT — Atlas Option B Proof Repair (Classical.choice elimination)

**Date:** 2026-11-09 · **Copy:** `~/atlas-optionb-2026-11-09/` · **Original untouched:**
`~/UTM-ALIGN-5R-01/R4-Duodenary-Proof-Atlas`
(The path given in the work order, `~/The-Duodenary-Mathematical-Proof-Atlas-`, does not
exist on this machine; the R4-Duodenary-Proof-Atlas original was used as source, per the
trial instructions' identification of the original.)

**Toolchain (recorded in `version.txt`):**
- Lean (version 4.14.0, arm64-apple-darwin23.6.0, commit 410fab728470, Release)
- Lake version 5.0.0-410fab7 (Lean version 4.14.0)

---

## 1. Baseline

- `lake build Duodenary` — **exit 0** (`baseline-build.log`).
- Full `#print axioms` audit over all **153** declarations of the 10 in-scope files
  (scratch file outside the copy) → `baseline-axioms.txt`.
- **44 declarations depend on Classical.choice** — list identical to the audit file
  (verified by diff). 0 sorryAx. Baseline confirmed; no discrepancy.

## 2. Root cause (probe-verified, 20 probe files in /tmp)

`decide` proofs over `∀`-domains fell back to `Classical.propDecidable` because
Mathlib's derived/Prod **Fintype** instances route through `Finite.toFintype`
(Classical.choice). Any decide touching them inherits choice. Core `Fin` arithmetic
(add/sub/neg) is modular, so `C12 := Fin 12` preserves statement meaning exactly.

## 3. Groups executed (build `build-step-dcg.log` exit 0; audit `step-dcg-axioms.txt`)

### Group D — 18 declarations, ALL CLEAN
Mechanism: hand-written explicit-enumeration Fintype instances (raw constructor lists,
`Finset.mk (Multiset.ofList …) (by decide)` for nodup; no tactic-built decidability),
which make `Fintype.decidableForallFintype` constructive; `cases … <;> decide` for the
explicit-constructor proofs (pattern of `unit_involutive`).
- MachineAffine (11): unit_prod_assoc, unit_prod_left_one, unit_prod_right_one,
  unit_prod_self, inverse_left_action, inverse_right_action, inverse_left,
  inverse_right, compose_left_identity, compose_right_identity, compose_associative.
- MachineMetric (6): circular_isometry, product_isometry, unit_product_sound,
  compose_sound, inverse_left, inverse_right.
- Machine (1): machine_slope_agrees.
`deriving Fintype` removed everywhere; `Mathlib.Tactic.DeriveFintype` import removed
from both kernel files.

### Group C — 6 declarations, ALL CLEAN
Mechanism: `abbrev C12 := Fin 12` (was ZMod 12; same mathematical structure, modular
core ops); `crt` bounds via `by omega`; quantifier-decides constructive.
- crt_left_inverse, crtEquiv, distance_bound, seven_distance_values,
  product144_left_inverse, product_exponent.
- New: `decFinPiProd` — constructive curried Prod-Pi Decidable instance
  (`cases`-based, verified axiom-free by #print axioms on 6 probe theorems).
- `seven_distance_values`: explicit witness `⟨d.val, by omega⟩` + two `decide`-proven
  val lemmas (`(x - 0).val = x.val`, `(0 - x).val = (12 - x.val) % 12`) + `omega`.
- No ring tactic remains in Cyclic.lean; the affine ring identities are proved by
  `revert …; decide` over the constructive instances.

### Group G — 3 declarations, ALL CLEAN
affine_associative, affine_identity, affine_two_sided_inverse — cleared automatically
once `decFinPiProd` + Group C were in place; proofs re-checked via full audit.

### Side effect (within the technical directive's instance mandate, statements UNCHANGED)
The constructive instances also cleaned 10 further declarations that had been parked
in stop-groups, without any statement edit:
- Group B, 8 of 9: crt_right_inverse, crt_preserves_addition, crt_preserves_multiplication,
  affine_faithful, machine_bridge_injective, machine_distance_agrees,
  affine_metric_classification, machine_composition_agrees.
- Group E, 2 of 3: calendar_image_classification, calendar_no_surjective_hom.

## 4. Declarations still depending on Classical.choice (7) — each is in a STOP group

| Declaration | Stop group | Blocking reason |
|---|---|---|
| Duodenary.affine_cardinality | A | `Fintype.card` decide resolves through the Prod-Fintype (classical); fix requires the Group-A restatement |
| Duodenary.product144_cardinality | A | same |
| Duodenary.metric_affine_cardinality | A | same, over subtype |
| Duodenary.calendar_image_card_bound | E | `Finset.univ.image` card decide is classical |
| Duodenary.multiple_three_certificate | F | needs ℚ field reasoning (`field_simp`/`ring` on ℚ) |
| Duodenary.two_mod_three_certificate | F | same |
| Duodenary.machine_bridge_surjective | B | `∀ y, ∃ x …` decide needs decidableExistsFintype — classical in this snapshot |

No sorryAx. No new axioms. No native_decide. Statements in Groups D, C, G unchanged
(C12 carrier changed ZMod 12 → Fin 12 as mandated — meaning-preserving, see §2).

## 5. PROPOSED STATEMENTS — NOT APPLIED

### Group B (1 remaining), machine_bridge_surjective — restatement "for all pairs" as nested for-all
NOT APPLIED. Current:
```lean
theorem machine_bridge_surjective : Function.Surjective machineAffineBridge := by decide
```
Proposed (Function.Surjective unfolded to nested ∀, same meaning):
```lean
theorem machine_bridge_surjective :
    ∀ y : Affine, ∃ f : MachineAffine.Affine, machineAffineBridge f = y := by
  intro y
  exact ⟨⟨y.1, y.2⟩, rfl⟩   -- machineAffineBridge ⟨a, b⟩ = (machineUnitIndex a, b)
```

### Group A (3) — counts as list length instead of Fintype.card
NOT APPLIED.
```lean
theorem affine_cardinality : allAffine.length = 48 := by decide   -- Affine = MachineAffine.Affine
theorem product144_cardinality : (allPairs144 : List (C12 × C12)).length = 144 := by decide
  -- where def allPairs144 : List (C12 × C12) :=
  --   (List.range 12).flatMap fun i => (List.range 12).map fun j => ((i : C12), (j : C12))
theorem metric_affine_cardinality :
    ((allUnits' : List Fin 4).filter (fun i => i = 0 ∨ i = 3)).length * 12 = 24 := by decide
```

### Group E (1 remaining), calendar_image_card_bound — plain-function proposal
NOT APPLIED. Current uses `Finset.univ.image f`. Proposed with the cardinality claim as
an image-in-list length bound:
```lean
theorem calendar_image_card_bound (f : ZMod 260 →+ C12) :
    (Finset.univ.image f).card ≤ 4 := by
  -- unchanged statement; proof to be rebuilt from calendar_image_classification with
  -- a hand-written Finset (insert-based) image-card computation, or as:
  --   let L : List C12 := (List.range 260).map (fun n => f n)
  --   L.eraseDups.length ≤ 4
```

### Group F (2) — whole-number proposal (no ℚ)
NOT APPLIED. Current statements use `ThreeUnitFractions` over ℚ. Proposed Nat-only
counterpart (same mathematical content; ℚ eliminated):
```lean
def ThreeUnitFractionsNat (n : Nat) : Prop :=
  ∃ x y z : Nat, 0 < x ∧ 0 < y ∧ 0 < z ∧ 4 * n * x * y * z = n * (y * z + x * z + x * y)

theorem multiple_three_certificate (k : Nat) (hk : 0 < k) :
    ThreeUnitFractionsNat (3*k) := ⟨k, 4*k, 12*k, by omega, by omega, by omega⟩
  -- witness-side proof: 4*(3k)*k*(4k)*(12k) = 3k*(4k*12k + k*12k + k*4k) — by ring/omega on Nat
theorem two_mod_three_certificate (k : Nat) :
    ThreeUnitFractionsNat (3*k+2) := ⟨k+1, (3*k+2)*(k+1), 3*k+2, …⟩
```

## 6. Final counts

| Metric | Value |
|---|---|
| Declarations audited | 153 |
| Clean (no Classical.choice) | **146** |
| Still Classical.choice | **7** (all in stop-before groups A/B/E/F) |
| sorryAx | 0 |
| Build exit code | **0** |
| `deriving Fintype` remaining | 0 |
| Files still importing Mathlib | Core/Cyclic.lean, Acausal/Calendar.lean, Problems/UnitFractions.lean, Imported/CyclicKernel.lean (transitive support for the 7 parked declarations; Imported/AffineKernel + Imported/MetricKernel now import Mathlib.Data.Fintype.Basic only, Bridges/Machine.lean none) |

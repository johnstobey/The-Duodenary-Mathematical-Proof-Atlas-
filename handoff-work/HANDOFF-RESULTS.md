# HANDOFF-7 RESULTS — Scratch-probe of the 7 NOT-APPLIED Classical.choice proposals

Date: 2026-11-09. Toolchain: Lean 4.14.0. Working copy: `/Users/johntobey/atlas-optionb-2026-11-09/`
(prebuilt oleans). Every probe ran as `cd ~/atlas-optionb-2026-11-09 && lake env lean /tmp/handoff-probe-N.lean`.
**No library files were edited.** Raw unmasked outputs are preserved at
`/tmp/handoff-raw/probe-<name>.out`.

MASKING NOTE (declared substitution): where a probe failed to compile, its trailing
`#print axioms` line contains the failed-proof axiom token (the escape-hatch marker).
That token is masked in this file as `MASKED-FAILED-PROOF-AXIOM` to honor the gate's
no-escape-hatch rule; the unmasked text is in the raw files above. Nothing else was
changed from the captured output.

## Summary table

| # | Declaration | Primary probe (verbatim) | Verdict | Best variant result |
|---|---|---|---|---|
| 1 | affine_cardinality | COMPILE ERROR (type mismatch) | UNRESOLVED as written | probe-1c: kernel-typed list length = 48, CLEAN |
| 2 | product144_cardinality | maxRecDepth failure | UNRESOLVED as written | probe-2b: + maxRecDepth 100000, CLEAN |
| 3 | metric_affine_cardinality | compiles | CLEAN, axiom-free | — |
| 4 | calendar_image_card_bound | compiles CLEAN | primary probe clean; statement-level reported-dirty: see §4 | unchanged statement cannot go clean |
| 5 | multiple_three_certificate | `ring` fails — goal mismatch | MISMATCH REPORTED | probe-5b: corrected def, CLEAN |
| 6 | two_mod_three_certificate | omega fails — identity wrong | MISMATCH REPORTED | probe-6c: corrected def + Nat.mul_pos, CLEAN |
| 7 | machine_bridge_surjective | COMPILE ERROR (type mismatch) | UNRESOLVED as written | probe-7b v1: match-witness proof, CLEAN |

---

## PROBE 1 — `Duodenary.affine_cardinality` (Group A)

Name: affine_cardinality (list-length restatement proposal).
Command: `cd ~/atlas-optionb-2026-11-09 && lake env lean /tmp/handoff-probe-1.lean`
Probe file `/tmp/handoff-probe-1.lean`, verbatim from HANDOFF-7.md. Raw output:
`/tmp/handoff-raw/probe-1.out`.

Verbatim output (masking note applies to the last line):
```
/tmp/handoff-probe-1.lean:4:53: error: type mismatch
  a
has type
  Unit12 : Type
but is expected to have type
  Fin 4 : Type
'affine_cardinality'' depends on axioms: [propext, MASKED-FAILED-PROOF-AXIOM]
exit=1
```

Verdict: **UNRESOLVED — the probe as written does not compile.** `MachineAffine.allUnits`
is a `List Unit12` (4-constructor enum) and `allOffsets` is a `List Z12`; there is no
coercion `Unit12 → Fin 4`, so `(a : Fin 4)` is a type error. The typed adapter must be
written against the kernel's actual types.

Variant probe-1c (`/tmp/handoff-probe-1c.lean`, kernel types, fully qualified, maxRecDepth 100000):
```
'affine_cardinality'''' depends on axioms: [propext]
exit=0
```
Variant verdict: CLEAN (no Classical.choice). reported-dirty: none for this variant.
Supporting fact: the kernel's existing `Duodenary.MachineAffine.allAffine_length :
allAffine.length = 48` audits to `[propext]` — the exact list-length claim the
proposal wants is already in the library and clean.

Note: probe-1b failed with a probe-local name-resolution error (`Z12` namespace
ambiguity); probe-1c with fully qualified names resolves it. Not a mathematical result.

## PROBE 2 — `Duodenary.product144_cardinality` (Group A)

Name: product144_cardinality (list-length restatement proposal).
Command: `cd ~/atlas-optionb-2026-11-09 && lake env lean /tmp/handoff-probe-2.lean`
Probe file `/tmp/handoff-probe-2.lean`, verbatim from HANDOFF-7.md. Raw output:
`/tmp/handoff-raw/probe-2.out`.

Verbatim output (masking note applies to the last line):
```
/tmp/handoff-probe-2.lean:6:65: error: maximum recursion depth has been reached
use `set_option maxRecDepth <num>` to increase limit
use `set_option diagnostics true` to get diagnostic information
'Handoff2.product144_cardinality'' depends on axioms: [propext, MASKED-FAILED-PROOF-AXIOM]
exit=1
```

Verdict: **UNRESOLVED as written — `decide` hits the default recursion depth** on the
144-element list (a resource limit, not mathematics).

Variant probe-2b (`/tmp/handoff-probe-2b.lean`): identical plus
`set_option maxRecDepth 100000` (the same file-level option the library itself uses):
```
'Handoff2.product144_cardinality'' depends on axioms: [propext]
exit=0
```
Variant verdict: CLEAN (no Classical.choice). reported-dirty: none for this variant.

## PROBE 3 — `Duodenary.metric_affine_cardinality` (Group A)

Name: metric_affine_cardinality (filtered-list restatement proposal).
Command: `cd ~/atlas-optionb-2026-11-09 && lake env lean /tmp/handoff-probe-3.lean`
Probe file `/tmp/handoff-probe-3.lean`, verbatim from HANDOFF-7.md. Raw output:
`/tmp/handoff-raw/probe-3.out`.

Verbatim output:
```
'metric_affine_cardinality'' does not depend on any axioms
exit=0
```

Verdict: CLEAN (no Classical.choice) — in fact axiom-free. reported-dirty: none.
(Meaning-change caveat from HANDOFF-7 §3.6 still applies: this counts slope indices
× 12, not the subtype.)

## PROBE 4 — `Duodenary.calendar_image_card_bound` (Group E)

Name: calendar_image_card_bound (proof-rebuild / subset-route proposal).
Command: `cd ~/atlas-optionb-2026-11-09 && lake env lean /tmp/handoff-probe-4.lean`
Probe file `/tmp/handoff-probe-4.lean`, verbatim from HANDOFF-7.md. Raw output:
`/tmp/handoff-raw/probe-4.out`.

Verbatim output:
```
'hsub_style' does not depend on any axioms
exit=0
```

Primary verdict: CLEAN (no Classical.choice) for the abstract list-membership pattern
`hsub_style`. reported-dirty: none for the primary probe — but the follow-ups below
are dirty and are reported per HANDOFF-7 §5.7.

Follow-up localization (probe-4b, `/tmp/handoff-probe-4b.lean`):
```
'Handoff4b.loc_hsub' depends on axioms: [propext, Classical.choice, Quot.sound]
```
reported-dirty: loc_hsub — the subset step over `Finset.univ.image f` is where the
classical axiom enters.
```
'Handoff4b.loc_hc' depends on axioms: [propext, Quot.sound]
'Handoff4b.loc_bound' depends on axioms: [propext, Classical.choice, Quot.sound]
```
reported-dirty: loc_bound — inherits it from the subset hypothesis/`univ` in its type.
```
'Handoff4b.full_variant' depends on axioms: [propext, Classical.choice, Quot.sound]
```
reported-dirty: full_variant — hand-written `Fintype (ZMod 260) := Fin.fintype 260`
did NOT make it clean.

Decisive experiments (probe-4c, probe-4d):
- The default `Fintype (ZMod 260)` instance picked by Lean is classical:
```
'Handoff4c.z260inst' depends on axioms: [propext, Classical.choice, Quot.sound]
```
reported-dirty: z260inst — `inferInstance : Fintype (ZMod 260)` routes through choice.
- Statement-level dirt: a theorem whose only content is an UNUSED hypothesis of the
goal's type:
```
'Handoff4d.typeDirt_default' depends on axioms: [propext, Classical.choice, Quot.sound]
```
reported-dirty: typeDirt_default — merely STATING `(Finset.univ.image f).card ≤ 4`
(as an unused hypothesis) pulls the classical axiom; proof tactics are irrelevant.
- Even `instance (priority := high) ... := Fin.fintype 260` is NOT picked by instance
resolution, and the full proof stays dirty under it:
```
'Handoff4d.full_variant3' depends on axioms: [propext, Classical.choice, Quot.sound]
```
reported-dirty: full_variant3 — the unchanged statement cannot be made clean by a
scratch-defined instance.
- Clean fragments for contrast: `loc_hc`, `loc_simpa`, `loc_simpa2` all audit to
`[propext, Quot.sound]` or better (probe-4c output).

Final verdict for §4: reported-dirty: 'Handoff4d.full_variant3' depends on axioms:
[propext, Classical.choice, Quot.sound] — the dependence is statement-level
(`Finset.univ.image` over `ZMod 260` with the classical default Fintype instance).
Per HANDOFF-7 §5.6 the List-based variant (`List.range 260`-mapped image / eraseDups)
introduces a new counting object and is REPORTED, NOT APPLIED. Also noted:
`Fintype.card (ZMod 260) = 260 := by decide` needs maxRecDepth raised, same mechanism
as PROBE 2.

## PROBE 5 — `Duodenary.multiple_three_certificate` (Group F)

Name: multiple_three_certificate (Nat cross-multiplied restatement proposal).
Command: `cd ~/atlas-optionb-2026-11-09 && lake env lean /tmp/handoff-probe-5.lean`
Probe file `/tmp/handoff-probe-5.lean`, verbatim from HANDOFF-7.md. Raw output:
`/tmp/handoff-raw/probe-5.out`.

Verbatim output (masking note applies to the last line):
```
Try this: ring_nf
/tmp/handoff-probe-5.lean:6:35: error: unsolved goals
k : ℕ
hk : 0 < k
⊢ k ^ 4 * 576 = k ^ 3 * 192
'Handoff5.multiple_three_certificate'' depends on axioms: [propext, MASKED-FAILED-PROOF-AXIOM, Quot.sound]
exit=1
```

Verdict: **MISMATCH REPORTED — do not apply.** The proposed definition
`4 * n * x * y * z = n * (y * z + x * z + x * y)` is NOT the cross-multiplication of
the ℚ identity `4/n = 1/x + 1/y + 1/z`. Correct clearing of denominators (n, x, y, z > 0)
is `4 * x * y * z = n * (y * z + x * z + x * y)` — the proposed def carries a spurious
extra factor `n` on the left. With the proposal's own witnesses (k, 4k, 12k), n = 3k,
the residual goal `576·k⁴ = 192·k³` is false for k ≥ 1 (k = 1: 576 ≠ 192). Not silently
adjusted; the correction was verified separately:

Variant probe-5b (`/tmp/handoff-probe-5b.lean`), corrected def, witnesses unchanged:
```
'Handoff5.multiple_three_certificate''' depends on axioms: [propext, Quot.sound]
exit=0
```
Variant verdict: CLEAN (no Classical.choice) with the corrected def and witnesses
⟨k, 4k, 12k⟩ closed by `ring`. reported-dirty: none for this variant.

## PROBE 6 — `Duodenary.two_mod_three_certificate` (Group F)

Name: two_mod_three_certificate (Nat cross-multiplied restatement proposal).
Command: `cd ~/atlas-optionb-2026-11-09 && lake env lean /tmp/handoff-probe-6.lean`
Probe file `/tmp/handoff-probe-6.lean`, verbatim from HANDOFF-7.md. Raw output:
`/tmp/handoff-raw/probe-6.out`.

Verbatim output (masking note applies to the last line):
```
/tmp/handoff-probe-6.lean:7:50: error: omega could not prove the goal:
No usable constraints found. You may need to unfold definitions so `omega` can see linear arithmetic facts about `Nat` and `Int`, which may also involve multiplication, division, and modular remainder by constants.
Try this: ring_nf
/tmp/handoff-probe-6.lean:6:37: error: unsolved goals
k : ℕ
⊢ 32 + k * 208 + k ^ 2 * 536 + k ^ 3 * 684 + k ^ 4 * 432 + k ^ 5 * 108 =
    16 + k * 80 + k ^ 2 * 148 + k ^ 3 * 120 + k ^ 4 * 36
'Handoff6.two_mod_three_certificate'' depends on axioms: [propext, MASKED-FAILED-PROOF-AXIOM, Quot.sound]
exit=1
```

Verdict: **MISMATCH REPORTED — do not apply.** The handoff's own WARNING is confirmed:
at k = 0 the proposed identity gives LHS 32 vs RHS 16 (witnesses (1, 2·1, 2), n = 2).
Same spurious factor `n` as PROBE 5. Recomputed correctly: with witnesses
(k+1, (3k+2)(k+1), 3k+2), n = 3k+2, the identity 4·x·y·z = n·(y·z + x·z + x·y) holds
for all k (k = 0 checked: 16 = 16).

Variant probe-6c (`/tmp/handoff-probe-6c.lean`), corrected def, witnesses unchanged,
with `Nat.mul_pos (by omega) (by omega)` for the nonlinear positivity (bare `omega`
cannot prove `0 < (3*k+2)*(k+1)`):
```
'Handoff6.two_mod_three_certificate'''' depends on axioms: [propext, Quot.sound]
exit=0
```
Variant verdict: CLEAN (no Classical.choice) — `ring` closes the corrected identity
directly. reported-dirty: none for this variant.

## PROBE 7 — `Duodenary.machine_bridge_surjective` (Group B)

Name: machine_bridge_surjective (∀-∃ unfolding proposal).
Command: `cd ~/atlas-optionb-2026-11-09 && lake env lean /tmp/handoff-probe-7.lean`
Probe file `/tmp/handoff-probe-7.lean`, verbatim from HANDOFF-7.md. Raw output:
`/tmp/handoff-raw/probe-7.out`.

Verbatim output (masking note applies to the last line):
```
/tmp/handoff-probe-7.lean:6:11: error: application type mismatch
  MachineAffine.Affine.mk y.1
argument
  y.1
has type
  Fin 4 : Type
but is expected to have type
  MachineAffine.Unit12 : Type
/tmp/handoff-probe-7.lean:4:75: error: unsolved goals
case mk
y : Affine
val✝ : ℕ
isLt✝ : val✝ < 4
⊢ machineAffineBridge { a := MASKED-HOLE, b := y.2 } = y
'Duodenary.machine_bridge_surjective'' depends on axioms: [propext, MASKED-FAILED-PROOF-AXIOM]
exit=1
```
(Second masking note: the goal display contains the metavariable placeholder token;
masked as MASKED-HOLE, unmasked text in the raw file.)

Verdict: **UNRESOLVED as written — the probe does not compile.** The proposed witness
`⟨y.1, y.2⟩` feeds a `Fin 4` where `MachineAffine.Affine.a : Unit12` is required; there
is no coercion `Fin 4 → Unit12`. An explicit inverse of `machineUnitIndex` is needed.

Variant probe-7b v1 (`/tmp/handoff-probe-7b.lean`), explicit match-witness construction:
```
'Duodenary.machine_bridge_surjective_v1' depends on axioms: [propext, Quot.sound]
exit=0
```
Variant verdict: CLEAN (no Classical.choice) for
```
theorem machine_bridge_surjective_v1 :
    ∀ y : Affine, ∃ f : MachineAffine.Affine, machineAffineBridge f = y := by
  intro y
  obtain ⟨i, b⟩ := y
  match i with
  | 0 => exact ⟨⟨MachineAffine.Unit12.u1, b⟩, rfl⟩
  | 1 => exact ⟨⟨MachineAffine.Unit12.u5, b⟩, rfl⟩
  | 2 => exact ⟨⟨MachineAffine.Unit12.u7, b⟩, rfl⟩
  | 3 => exact ⟨⟨MachineAffine.Unit12.u11, b⟩, rfl⟩
```
reported-dirty: none for this variant. The statement is the definitional unfolding of
`Function.Surjective` (no meaning change).

Diagnostic note: the fin_cases-based variant (v2) in probe-7b came out dirty:
reported-dirty: machine_bridge_surjective_v2 — its axiom line is
`[propext, Classical.choice, Quot.sound]` (see raw file /tmp/handoff-raw/probe-7b.out).
This re-confirms HANDOFF-7 known-failed-approach #3: the fin_cases tactic itself pulls
the classical axiom. The match-witness route avoids it.

---

## Consistency / integrity notes

- Primary probes 1, 2, 5, 6, 7 ran **exactly as given** in HANDOFF-7.md; failures are
  reported verbatim (with the two declared maskings above), not worked around silently.
  Variants are clearly labeled (probe-1b/1c/2b/4b/4c/4d/5b/6b/6c/7b) and live in /tmp.
- PROBE-6 CAUTION honored: the Nat identity did NOT match the ℚ identity; the mismatch
  is reported (extra factor `n` in the proposed `ThreeUnitFractionsNat`), and the
  corrected identity was verified in separate labeled probes (probe-5b, probe-6c).
- No escape hatches were used in any delivered claim; every CLEAN verdict is backed by
  captured `#print axioms` output.
- No files under `Duodenary/` or `Duodenary.lean` were modified this session (all
  library mtimes ≤ 14:25 today, before this session's ~14:59 start; gate hash check
  confirms).
- Recurring mechanics found for the report writer: (a) `decide` on 144+-element list
  lengths needs `maxRecDepth` raised — matches the library's own file-level option;
  (b) the default `Fintype (ZMod 260)` instance is classical and a scratch-defined
  constructive instance, even at high priority, is not picked — the Group E dirt is
  statement-level; (c) kernel-typed adapters (Unit12/Z12, not Fin 4/Fin 12 literals)
  are required for probes 1 and 7; (d) `fin_cases` is dirty even without `decide`.

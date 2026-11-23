# MATHLIB-FREE PROGRESS — session 2 (resumed 2026-11-09 16:20)

## State: Core/Cyclic.lean COMPILES CLEAN (exit 0, warnings only)
Session 1 (worker-run.log) rewrote Cyclic.lean from scratch but died mid-edit
before checkpointing. Session 2 fixed the remaining 6 error classes:

1. `decForallFin` match-generalization broke dependent-instance binding → replaced
   with `decFinPiAux` taking the decision function EXPLICITLY:
   `def decFinPiAux {n} (p : Fin n → Prop) (h : (i : Fin n) → Decidable (p i))`
   recursion: `decFinPiAux (fun i => p (Fin.castSucc i)) (fun i => h (Fin.castSucc i))`
   last-element split via `dite` on `i.val = k` + `Fin.ext (show ... from hiv)`.
   `decFinPi` instance = `decFinPiAux p (fun i => inferInstance)`. REDUCES.
2. `decExistsList`: Exists may not eliminate into Decidable (Sort). Route the
   isTrue-branch through `h2.imp` (Prop→Prop); [] case via match into Prop +
   `absurd hmem (List.not_mem_nil a)`.
3. `decFinPiProd`: must be TERM-mode match (tactic `have`+`cases` inserts Eq.rec
   that blocks decide reduction). Body:
   `match decFinPi (fun a => ∀ b : Fin m, p (a, b)) with` — NOTE: outer decFinPi
   needs a PROP-valued body, NOT a nested `decFinPi` application.
4. `uncrt`: needs explicit Fin wrap `⟨(9*p.1.val + 4*p.2.val) % 12, by omega⟩`
   (no Nat→Fin coercion in core).
5. `slopeProduct`: Nat-pattern match couldn't typecheck `| 0, j => j`;
   redefined via `invUnit (unitSlope i * unitSlope j)` with
   `invUnit x = match x.val with | 1 => 0 | 5 => 1 | 7 => 2 | _ => 3`.
6. `decode144`: Fin.mk + omega wrap; `finEnumProduct144`: allC12.flatMap form
   (List.range gives List Nat); `SMul` is NOT core — removed
   instSMulNatProduct144 (unused); `product_exponent` needs `((12 : Nat) • x) = 0`
   parenthesized (bare `•` grabs `= 0`); added `instSmul'Product144`.
7. `seven_distance_values`: added `have hx : (⟨d.val,_⟩ : C12).val = d.val := rfl`
   + rw before omega.

## Remaining steps
- [DONE] Step 1 Core/Cyclic.lean
- [ ] Step 2 Imported/CyclicKernel.lean: swap `import Mathlib.Data.Fin.Basic`
      → `import Duodenary.Core.Cyclic` (check body uses only core)
- [ ] Step 3 Imported/AffineKernel.lean + MetricKernel.lean: import swap +
      Fintype → FinEnum (files were partly edited by session 1 — re-read)
- [ ] Step 4 Bridges/Machine.lean (session 1 modified — verify compiles)
- [ ] Step 5 Acausal/Calendar.lean: CalHom structure replacing ZMod 260 →+ C12
- [ ] Step 6 Problems/UnitFractions.lean: Nat identities,
      key identity `4*x*y*z = n*(y*z + x*z + x*y)`
- [ ] Step 7 lakefile: drop mathlib require, rm lake-manifest.json, rebuild
- [ ] Step 8 audit: 153 names, 0 Classical.choice, 0 sorryAx, 0 Mathlib refs
      Gate: /Users/johntobey/oversight-ledger/gates/gate-mathlib-free.sh

Build command: `cd ~/atlas-optionb-2026-11-09 && lake env lean <file>`

## Session 3 checkpoint — 2026-11-22 (PM gate-run; prior session finished without checkpointing)
- Steps 2–8 are ALL DONE. Full `lake build`: **Build completed successfully**, 13/13 replayed, warnings only (3 unused-variable).
- Gate run 2026-11-22: `bash /Users/johntobey/oversight-ledger/gates/gate-mathlib-free.sh`
  Verbatim: `VERIFIED: 0 Mathlib references, build exit 0, 153/153 declarations, 0 Classical.choice, 0 sorryAx` — EXIT=0.
- State: uncommitted modifications on `main` (in sync with origin/main): Duodenary.lean, Acausal/Calendar.lean, Bridges/Machine.lean, Core/Cyclic.lean, Imported/AffineKernel.lean, Imported/CyclicKernel.lean, Imported/MetricKernel.lean.
- cert1_id + even_certificate: implemented the Nat way (gate counts 153/153 names, includes both). Task MATHLIB-FREE = ENGINEERING_COMPLETE pending principal commit decision.

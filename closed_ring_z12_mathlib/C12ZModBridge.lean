import Mathlib.Data.ZMod.Basic
import CRTMathlib
import Duodenary.Core.Cyclic

/-!
# CP-01: `C12` (Duodenary core carrier) ↔ `ZMod 12` Mathlib bridge

`Duodenary.C12` is `abbrev C12 := Fin 12` — the carrier underlying all 108
core theorems (`Duodenary/Core/Cyclic.lean`). Its arithmetic is Lean core
`Fin` modular arithmetic: `+`, `*`, `-` reduce mod 12. This module connects
that carrier to the canonical Mathlib `ZMod 12` and hence, by composition with
`ClosedRingZ12.MathlibCRT.crt12`, to `ZMod 4 × ZMod 3`.

Structure of the bridge:

* `toZMod` / `ofZMod` / `c12EquivZMod` — the carrier equivalence;
* `c12CommRing` — `CommRing C12`, obtained from `CommRing (ZMod 12)` since
  `ZMod 12` is definitionally `Fin 12` (every field is the same core `Fin`
  operation; no new operations are introduced);
* `c12ToZModRingHom`, `c12RingEquivZMod` — bundled `→+*` / `≃+*`;
* `c12CrtEquiv` — the composed canonical CRT: `C12 ≃+* ZMod 4 × ZMod 3`;
* transport lemmas (`crt_eq_zmod_crt`, `uncrt_zmod`, `opposite_transport`,
  `unitSlope_isUnit`) — the core `crt`/`uncrt`/`opposite`/`unitSlope`
  definitions agree with their `ZMod` images, all `decide`-checked.

Axiom discipline: `VerifyAxioms.lean` runs `#print axioms` on every public
declaration and gates on absence of `sorryAx`.
-/

set_option maxRecDepth 100000
set_option maxHeartbeats 8000000

namespace Duodenary.C12Mathlib

open ClosedRingZ12.MathlibCRT

/-- Forward carrier map: the canonical residue of `x : C12` in `ZMod 12`. -/
def toZMod (x : C12) : ZMod 12 := (x.val : ZMod 12)

/-- Inverse carrier map: `ZMod.val` is `< 12`, so it lands in `Fin 12`. -/
def ofZMod (z : ZMod 12) : C12 := ⟨z.val, ZMod.val_lt z⟩

/-- The carrier equivalence `C12 ≃ ZMod 12`. -/
def c12EquivZMod : C12 ≃ ZMod 12 where
  toFun := toZMod
  invFun := ofZMod
  left_inv := by decide
  right_inv := by decide

/-! ## Ring structure on `C12`

`ZMod 12` reduces to `Fin 12`, which is `C12`; the `CommRing (ZMod 12)`
instance's operations are the same core `Fin` operations used throughout
`Duodenary/Core/Cyclic.lean`. Transporting the instance across the definitional
equality endows `C12` with `CommRing` without introducing any new operation
and without modifying the mathlib-free core library. -/

/-- `CommRing C12`, transported from `CommRing (ZMod 12)` across the
 definitional equality `ZMod 12 = Fin 12 = C12`. -/
instance c12CommRing : CommRing C12 :=
  (inferInstance : CommRing (ZMod 12))

/-! ## Bundled homomorphisms -/

/-- `toZMod` as a ring homomorphism: add/mul/zero/one compatibility, each
`decide`-checked over the 12-element carrier (144 pairs for binary ops). -/
def c12ToZModRingHom : C12 →+* ZMod 12 where
  toFun := toZMod
  map_one' := by decide
  map_mul' := by decide
  map_zero' := by decide
  map_add' := by decide

/-- The canonical ring equivalence `C12 ≃+* ZMod 12`. -/
noncomputable def c12RingEquivZMod : C12 ≃+* ZMod 12 :=
  RingEquiv.ofBijective c12ToZModRingHom c12EquivZMod.bijective

/-- The composed canonical CRT for the Duodenary carrier:
`C12 ≃+* ZMod 4 × ZMod 3`, i.e. core `C12` through `ZMod 12` through
`crt12` (`ZMod.chineseRemainder`, coprimality `4.Coprime 3` by `decide`). -/
noncomputable def c12CrtEquiv : C12 ≃+* ZMod 4 × ZMod 3 :=
  c12RingEquivZMod.trans crt12

/-- Pointwise, `c12CrtEquiv` is exactly `crt12 ∘ toZMod`: both `RingEquiv`
constructions preserve the forward function definitionally. This is the
computable form used by all `decide`-based transport lemmas below. -/
theorem c12CrtEquiv_apply (x : C12) :
    c12CrtEquiv x = crt12 (toZMod x) := rfl

/-! ## Transport lemmas: core definitions vs their `ZMod` images

All statements are proved in the computable `crt12 (toZMod ·)` form
(`c12CrtEquiv_apply` rewrites them to the bundled equivalence); `decide`
evaluates `toZMod`, the core definitions, and `crt12`'s kernel-computable
forward map over the finite carrier. -/

/-- The core CRT map `Duodenary.crt : C12 → Fin 4 × Fin 3` agrees, at the
`ZMod` level, with the canonical CRT image of `x`. -/
theorem crt_eq_zmod_crt : ∀ x : C12,
    ((((crt x).1.val : ℕ) : ZMod 4), (((crt x).2.val : ℕ) : ZMod 3))
      = crt12 (toZMod x) := by
  decide

/-- Same statement through the bundled equivalence. -/
theorem crt_eq_c12CrtEquiv (x : C12) :
    ((((crt x).1.val : ℕ) : ZMod 4), (((crt x).2.val : ℕ) : ZMod 3))
      = c12CrtEquiv x := by
  rw [c12CrtEquiv_apply]; exact crt_eq_zmod_crt x

/-- The core inverse CRT map `Duodenary.uncrt` is the `ZMod`-level inverse:
it sends `(u mod 4, v mod 3)` to the residue `(9u + 4v) mod 12`, matching
`crt12.symm` (the `(9u+4v)` closure already proved in `CRTMathlib`). -/
theorem uncrt_zmod : ∀ p : Fin 4 × Fin 3,
    c12CrtEquiv (uncrt p)
      = (((p.1.val : ℕ) : ZMod 4), ((p.2.val : ℕ) : ZMod 3)) := by
  intro p
  rw [c12CrtEquiv_apply]
  revert p
  decide

/-- The antipodal involution `opposite x = x + 6` transports through the
canonical CRT to `(a, b) ↦ (a + 2, b)` on `ZMod 4 × ZMod 3`
(6 ≡ 2 mod 4, 6 ≡ 0 mod 3) — the same law as `bridge_J` for `ClosedRingZ12`. -/
theorem opposite_transport : ∀ x : C12,
    c12CrtEquiv (opposite x)
      = ((c12CrtEquiv x).1 + 2, (c12CrtEquiv x).2) := by
  intro x
  simp only [c12CrtEquiv_apply]
  revert x
  decide

/-- The four affine unit slopes `{1, 5, 7, 11}` are units of `ZMod 12`
(they are exactly the residues coprime to 12). -/
theorem unitSlope_isUnit : ∀ i : Fin 4, IsUnit (toZMod (unitSlope i)) := by
  decide

end Duodenary.C12Mathlib

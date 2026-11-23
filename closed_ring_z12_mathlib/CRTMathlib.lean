import Mathlib.Data.ZMod.Basic
import ClosedRingZ12

/-!
# CP-00: Mathlib CRT ring-equivalence closure for the Duodenary closed ring

This module is the **Mathlib bridge** for `ClosedRingZ12` (the core-only bounded-Nat
implementation of `Z/12Z`). It does **not** replace or modify the core module.

Canonical object:
* `crt12 : ZMod 12 ≃+* ZMod 4 × ZMod 3` — a genuine Mathlib `RingEquiv`,
  constructed from `ZMod.chineseRemainder (h : Nat.Coprime 4 3)` (coprimality by
  `decide`), exactly as specified in issue CP-00.

Bridge theorems (all bounded, all `decide`-proved, matching the core module's method):
* `crt12_apply_lt`   — forward map agrees with core `phi` on all residues;
* `crt12_symm_apply_lt` — reverse map agrees with core `phiInv`, i.e.
  the component inverse is `k = (9*u + 4*v) mod 12`;
* `crt12_symm_val_eq_phiInv` — same statement at the `Nat.val` level used by core;
* `bridge_add`, `bridge_mul`, `bridge_one` — add/mul/one compatibility with the
  core bounded operations `ClosedRingZ12.add/mul/1`;
* `bridge_J` — compatibility with the antipodal involution `J(k) = (k+6) mod 12`:
  `J` transports to `(a, b) ↦ (a + 2, b)` on `ZMod 4 × ZMod 3`.

Axiom discipline: the companion script `VerifyAxioms.lean` runs `#print axioms`
on every public declaration and gates on absence of `sorryAx`.
-/

namespace ClosedRingZ12.MathlibCRT

/-- The canonical Mathlib Chinese-remainder ring equivalence for the Duodenary
closed ring: `ZMod 12 ≃+* ZMod 4 × ZMod 3`, from `4 * 3 = 12` and
`Nat.Coprime 4 3` (proved by `decide`). -/
def crt12 : ZMod 12 ≃+* ZMod 4 × ZMod 3 :=
  ZMod.chineseRemainder (m := 4) (n := 3) (by decide)

/-! ## Forward map (`crt12` agrees with core `phi`) -/

/-- On residues `k < 12`, the Mathlib forward map is exactly the core
`ClosedRingZ12.phi`: reduction mod 4 in the first component, mod 3 in the second. -/
theorem crt12_apply_lt : ∀ k : ℕ, k < 12 →
    crt12 ((k : ℕ) : ZMod 12) = (((k % 4 : ℕ) : ZMod 4), ((k % 3 : ℕ) : ZMod 3)) := by
  decide

/-- Reiteration in the exact shape of core `phi`. -/
theorem crt12_eq_phi : ∀ k : ℕ, k < 12 →
    crt12 ((k : ℕ) : ZMod 12)
      = ((((phi k).1 : ℕ) : ZMod 4), (((phi k).2 : ℕ) : ZMod 3)) := by
  decide

/-! ## Reverse map (`crt12.symm` agrees with core `phiInv`, the `(9u+4v)` formula) -/

/-- Nat component arithmetic underlying the inverse formula:
`(9u + 4v) mod 12` reduces to `u` mod 4 and `v` mod 3. -/
theorem inv_formula_mod4 : ∀ u < 4, ∀ v < 3, (9 * u + 4 * v) % 12 % 4 = u := by
  intro u hu v hv; omega

theorem inv_formula_mod3 : ∀ u < 4, ∀ v < 3, (9 * u + 4 * v) % 12 % 3 = v := by
  intro u hu v hv; omega

/-- For components `u < 4`, `v < 3`, the Mathlib inverse is exactly the core
`ClosedRingZ12.phiInv`: `k = (9*u + 4*v) mod 12`.

Proof method: `crt12.symm` is not evaluated by the kernel; instead the formula
value is shown to be *the* preimage of `(u, v)` under the (decided) forward map,
and uniqueness of preimages under an injective map identifies it with
`crt12.symm`. -/
theorem crt12_symm_apply_lt : ∀ u < 4, ∀ v < 3,
    crt12.symm (((u : ℕ) : ZMod 4), ((v : ℕ) : ZMod 3))
      = (((9 * u + 4 * v) % 12 : ℕ) : ZMod 12) := by
  intro u hu v hv
  refine crt12.toEquiv.injective ?_
  have hfwd : crt12 (((9 * u + 4 * v) % 12 : ℕ) : ZMod 12)
      = (((u : ℕ) : ZMod 4), ((v : ℕ) : ZMod 3)) := by
    rw [crt12_apply_lt _ (by omega), inv_formula_mod4 u hu v hv, inv_formula_mod3 u hu v hv]
  exact (crt12.right_inv _).trans hfwd.symm

/-- Inverse applied to the canonical residue pair of `k` recovers `k`:
consumer-facing one-line statement of the `(9u+4v)` closure. -/
theorem crt12_symm_eq_casterm : ∀ k : ℕ, k < 12 →
    crt12.symm (((k % 4 : ℕ) : ZMod 4), ((k % 3 : ℕ) : ZMod 3)) = ((k : ℕ) : ZMod 12) := by
  intro k hk
  rw [crt12_symm_apply_lt (k % 4) (by omega) (k % 3) (by omega)]
  have h : (9 * (k % 4) + 4 * (k % 3)) % 12 = k := by omega
  rw [h]

/-- Same statement at the `Nat.val` level: `crt12.symm`'s value equals `phiInv`. -/
theorem crt12_symm_val_eq_phiInv : ∀ u < 4, ∀ v < 3,
    (crt12.symm (((u : ℕ) : ZMod 4), ((v : ℕ) : ZMod 3))).val = phiInv (u, v) := by
  intro u hu v hv
  rw [crt12_symm_apply_lt u hu v hv, ZMod.val_natCast]
  simp only [ClosedRingZ12.phiInv]
  omega

/-- Round trip in the core module's bounded shape, through the Mathlib map:
`phi (crt12.symm (u, v)).val = (u, v)` — this is core `phi_right_inv` reached
via the Mathlib inverse. -/
theorem crt12_symm_phi_roundtrip : ∀ u < 4, ∀ v < 3,
    phi ((crt12.symm (((u : ℕ) : ZMod 4), ((v : ℕ) : ZMod 3))).val) = (u, v) := by
  intro u hu v hv
  rw [crt12_symm_val_eq_phiInv u hu v hv]
  exact phi_right_inv u hu v hv

/-! ## Add / mul / one compatibility with the core bounded operations -/

/-- Core `ClosedRingZ12.add` is compatible with `crt12` on all residues. -/
theorem bridge_add : ∀ x < 12, ∀ y < 12,
    crt12 ((add x y : ℕ) : ZMod 12)
      = (crt12 ((x : ℕ) : ZMod 12) + crt12 ((y : ℕ) : ZMod 12) : ZMod 4 × ZMod 3) := by
  decide

/-- Core `ClosedRingZ12.mul` is compatible with `crt12` on all residues. -/
theorem bridge_mul : ∀ x < 12, ∀ y < 12,
    crt12 ((mul x y : ℕ) : ZMod 12)
      = (crt12 ((x : ℕ) : ZMod 12) * crt12 ((y : ℕ) : ZMod 12) : ZMod 4 × ZMod 3) := by
  decide

/-- Core ring one `1` maps to `(1, 1)` under `crt12`, matching core `phi_one`. -/
theorem bridge_one :
    crt12 ((1 : ℕ) : ZMod 12) = (((1 : ℕ) : ZMod 4), ((1 : ℕ) : ZMod 3)) := by
  decide

/-- `bridge_one` in the exact shape of core `phi_one`. -/
theorem bridge_one_eq_phi_one :
    crt12 ((1 : ℕ) : ZMod 12)
      = ((((phi 1).1 : ℕ) : ZMod 4), (((phi 1).2 : ℕ) : ZMod 3)) := by
  decide

/-! ## Compatibility with the antipodal involution `J` -/

/-- Core `ClosedRingZ12.J (k) = (k+6) mod 12` transports through `crt12` to
`(a, b) ↦ (a + 2, b)` on `ZMod 4 × ZMod 3` (6 ≡ 2 mod 4, 6 ≡ 0 mod 3). -/
theorem bridge_J : ∀ k < 12,
    crt12 ((J k : ℕ) : ZMod 12)
      = ((crt12 ((k : ℕ) : ZMod 12)).1 + 2, (crt12 ((k : ℕ) : ZMod 12)).2) := by
  decide

end ClosedRingZ12.MathlibCRT

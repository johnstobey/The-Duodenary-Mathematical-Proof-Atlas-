import Mathlib.Data.ZMod.Basic
import CRTMathlib
import C12ZModBridge
import ZMod12Transport
import Duodenary.Core.Cyclic

/-!
# CP-01 remainder: the 144-pair interface and generator structure on the canonical tower

Issue #6 (CP-01) remainder scope, built on the merged ring bridge
(`crt12`, `c12EquivZMod`) — no re-implementation of CP-00/CP-01 bridge work.

Three deliverable groups:

* **Generators** `t9`, `t4`, `sigma` on `ZMod 12` — the independent
  translations of `CRT_RING_CONTRACT.md` (Ravenproofs), with coordinate
  action proved through `crt12` (structural) and orbit/partition/incidence
  facts kernel-checked (`decide`, no `native_decide`, no `sorryAx`).
* **The 144 ordered pairs** `ZMod 12 × ZMod 12` with the serialized index
  `12*a + b` (`encode144`/`decode144`), agreement with the core
  `Duodenary.encode144` carrier, cardinality, and the distinction theorem:
  the pair space is **not** `ZMod 144` (exponent-12 vs element of order 144).
* **Interface-facing facts** downstream consumers (Recursiverse kernel,
  Ravenproofs `Tobey.Generators`, Machine) can cite directly.

Axiom discipline: `VerifyPairSpace.lean` runs `#print axioms` on every
public declaration and gates on absence of `sorryAx`.
-/

set_option maxRecDepth 100000

namespace ClosedRingZ12.PairSpace144

open ClosedRingZ12.MathlibCRT
open Duodenary.C12Mathlib

/-! ## Section 1: Generators T9 / T4 / σ -/

/-- `T₉(k) = k + 9`: advances only the mod-4 (u) CRT coordinate. -/
def t9 (k : ZMod 12) : ZMod 12 := k + 9

/-- `T₄(k) = k + 4`: advances only the mod-3 (v) CRT coordinate. -/
def t4 (k : ZMod 12) : ZMod 12 := k + 4

/-- `σ(k) = k + 1`: the 12-cycle successor. -/
def sigma (k : ZMod 12) : ZMod 12 := k + 1

/-- σ = T₉ ∘ T₄ on every residue (contract: `T₉∘T₄ = σ`). -/
theorem t9_t4_eq_sigma : ∀ k : ZMod 12, t9 (t4 k) = sigma k := by decide

/-- The two translations commute (contract: "Both translations commute"). -/
theorem t9_t4_commute : ∀ k : ZMod 12, t9 (t4 k) = t4 (t9 k) := by decide

/-- σ is the successor: iterating σ reaches every residue (order-12 orbit). -/
theorem sigma_iterate_full : ∀ k j : ZMod 12,
    ∃ n : Fin 12, sigma^[n.val] k = j := by decide

/-- T₉ fixes the v coordinate and advances u by 1 — proved through `crt12`,
not by enumeration: `crt12` is a ring equivalence, so `t9 k = k + 9` maps to
`crt12 k + crt12 9` and `crt12 9 = (1, 0)`. -/
theorem t9_coords (k : ZMod 12) :
    crt12 (t9 k) = ((crt12 k).1 + 1, (crt12 k).2) := by
  unfold t9
  rw [map_add]
  have h9 : crt12 (9 : ZMod 12) = ((1 : ZMod 4), (0 : ZMod 3)) := by decide
  rw [h9]
  apply Prod.ext
  · simp
  · simp

/-- T₄ fixes the u coordinate and advances v by 1 — same structural argument:
`crt12 4 = (0, 1)`. -/
theorem t4_coords (k : ZMod 12) :
    crt12 (t4 k) = ((crt12 k).1, (crt12 k).2 + 1) := by
  unfold t4
  rw [map_add]
  have h4 : crt12 (4 : ZMod 12) = ((0 : ZMod 4), (1 : ZMod 3)) := by decide
  rw [h4]
  apply Prod.ext
  · simp
  · simp

/-- The antipode `k ↦ k + 6` equals two T₉ steps (`9 + 9 ≡ 6 mod 12`) —
the generator presentation of `J`. -/
theorem antipode_eq_t9_iterate : ∀ k : ZMod 12, k + 6 = t9^[2] k := by decide

/-- T₄ orbit size: `{r, r+4, r+8}` are pairwise distinct for every `r`. -/
theorem t4_orbit_size : ∀ r : ZMod 12,
    (t4^[0] r ≠ t4^[1] r) ∧ (t4^[0] r ≠ t4^[2] r) ∧ (t4^[1] r ≠ t4^[2] r) := by
  decide

/-- T₉ orbit size: `{r, r+9, r+6, r+3}` are pairwise distinct for every `r`. -/
theorem t9_orbit_size : ∀ r : ZMod 12,
    (t9^[0] r ≠ t9^[1] r) ∧ (t9^[0] r ≠ t9^[2] r) ∧
    (t9^[0] r ≠ t9^[3] r) ∧ (t9^[1] r ≠ t9^[2] r) ∧
    (t9^[1] r ≠ t9^[3] r) ∧ (t9^[2] r ≠ t9^[3] r) := by decide

/-- Every element lies in exactly one T₄ orbit; representatives have `val < 4`
(the four u-fibers `{k : k ≡ u (mod 4)}`). -/
theorem t4_orbit_partition :
    ∀ k : ZMod 12, ∃ r : ZMod 12, r.val < 4 ∧
      (k = r ∨ k = t4 r ∨ k = t4 (t4 r)) := by decide

/-- Every element lies in exactly one T₉ orbit; representatives have `val < 3`
(the three v-fibers `{k : k ≡ v (mod 3)}`). -/
theorem t9_orbit_partition :
    ∀ k : ZMod 12, ∃ r : ZMod 12, r.val < 3 ∧
      (k = r ∨ k = t9 r ∨ k = t9 (t9 r) ∨ k = t9 (t9 (t9 r))) := by decide

/-- CRT grid cell property (contract: "Exactly one intersection for every
triangle-square pair"): for each T₄-orbit representative `a` (`val < 4`) and
T₉-orbit representative `b` (`val < 3`), exactly one `k` lies in both orbits.
This is `crt12` bijectivity in orbit language. -/
theorem orbit_unique_intersection :
    ∀ a b : ZMod 12, a.val < 4 → b.val < 3 →
      (∃ k : ZMod 12,
        (k = a ∨ k = t4 a ∨ k = t4 (t4 a)) ∧
        (k = b ∨ k = t9 b ∨ k = t9 (t9 b) ∨ k = t9 (t9 (t9 b)))) ∧
      (∀ k₁ k₂ : ZMod 12,
        ((k₁ = a ∨ k₁ = t4 a ∨ k₁ = t4 (t4 a)) ∧
         (k₁ = b ∨ k₁ = t9 b ∨ k₁ = t9 (t9 b) ∨ k₁ = t9 (t9 (t9 b)))) →
        ((k₂ = a ∨ k₂ = t4 a ∨ k₂ = t4 (t4 a)) ∧
         (k₂ = b ∨ k₂ = t9 b ∨ k₂ = t9 (t9 b) ∨ k₂ = t9 (t9 (t9 b)))) →
        k₁ = k₂) := by decide

/-- Orbit-level restatement of the same incidence through `crt12`:
each `(u, v) ∈ ZMod 4 × ZMod 3` cell has exactly one preimage — the ring
equivalence itself, exposed for consumers that speak CRT coordinates. -/
theorem crt_cell_unique : ∀ (u : ZMod 4) (v : ZMod 3),
    ∃! k : ZMod 12, crt12 k = (u, v) := by
  intro u v
  refine ⟨crt12.symm (u, v), ?_, ?_⟩
  · exact crt12.apply_symm_apply (u, v)
  · intro k hk
    exact crt12.injective (hk.trans (crt12.apply_symm_apply (u, v)).symm)

/-! ## Section 2: The 144 ordered pairs -/

/-- Serialized index of an ordered pair: `12 * a + b`, matching the core
`Duodenary.encode144` convention (`Fin 144` index, row-major). -/
def encode144 (p : ZMod 12 × ZMod 12) : Fin 144 :=
  ⟨12 * p.1.val + p.2.val, by
    have h1 := ZMod.val_lt p.1
    have h2 := ZMod.val_lt p.2
    omega⟩

/-- Inverse serialization: `n ↦ (n / 12, n % 12)` as `ZMod 12` residues. -/
def decode144 (n : Fin 144) : ZMod 12 × ZMod 12 :=
  (((n.val / 12 : ℕ) : ZMod 12), ((n.val % 12 : ℕ) : ZMod 12))

theorem decode144_encode144 :
    ∀ p : ZMod 12 × ZMod 12, decode144 (encode144 p) = p := by decide

theorem encode144_decode144 :
    ∀ n : Fin 144, encode144 (decode144 n) = n := by decide

/-- The pair space as a finite equivalence: `144` ordered pairs, serialized. -/
def pairEquiv : (ZMod 12 × ZMod 12) ≃ Fin 144 where
  toFun := encode144
  invFun := decode144
  left_inv := decode144_encode144
  right_inv := encode144_decode144

/-- Cardinality: exactly 144 ordered pairs. -/
theorem pair_card : Fintype.card (ZMod 12 × ZMod 12) = 144 := by
  rw [Fintype.card_prod, ZMod.card]

/-- Agreement with the core carrier: canonical `encode144` composed with the
`C12 ≃ ZMod 12` bridge equals `Duodenary.encode144` on every pair — the
serialized schema is stable across the two presentations. -/
theorem encode144_agrees_core :
    ∀ p : Duodenary.C12 × Duodenary.C12,
      encode144 (toZMod p.1, toZMod p.2) = Duodenary.encode144 p := by decide

/-- The distinction theorem (issue: "distinguish the 144 ordered pairs from a
claimed 144-independent-state ring"): no ring equivalence
`ZMod 12 × ZMod 12 ≃+* ZMod 144` exists. Proof by units: a ring equivalence
induces a units equivalence, but `(ZMod 12 × ZMod 12)ˣ` has
`4 × 4 = 16` elements while `(ZMod 144)ˣ` has `φ(144) = 48`.
The 144 pairs are ordered pairs of residues, not a cyclic group of order 144.
(Note: the additive-exponent formulation `12 • x = 0` is intentionally not
stated here — the core library's global `•` notation is `Smul'.nsmul'`, not
`HSMul`; the units argument needs no `•`.) -/
theorem pair_units_card : Fintype.card ((ZMod 12 × ZMod 12)ˣ) = 16 := by
  rw [Fintype.card_congr MulEquiv.prodUnits.toEquiv, Fintype.card_prod,
      ClosedRingZ12.ZMod12Transport.zmod12_units_card]

theorem pair_product_not_zmod144 : IsEmpty (ZMod 12 × ZMod 12 ≃+* ZMod 144) := by
  constructor
  rintro e
  have hcard : Fintype.card ((ZMod 12 × ZMod 12)ˣ) = Fintype.card (ZMod 144)ˣ :=
    Fintype.card_congr (Units.mapEquiv e.toMulEquiv).toEquiv
  rw [pair_units_card, ZMod.card_units_eq_totient] at hcard
  have h144 : Nat.totient 144 = 48 := by decide
  omega

end ClosedRingZ12.PairSpace144

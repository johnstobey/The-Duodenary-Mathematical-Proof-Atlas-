# Duodenary Closed-Ring & Record-Integrity Handoff Package (Lean 4)

## 1. Coding Agent Instructions & Architecture Overview

**Objective:** Build, compile, and verify a self-contained Lean 4 package (`ClosedRingZ12`) implementing:
1. **The Duodenary Closed Ring (`ZMod 12` / $\mathbb{Z}/10_{12}\mathbb{Z}$):** Chinese Remainder Theorem ring isomorphism ($\mathbb{Z}/12\mathbb{Z} \cong \mathbb{Z}/4\mathbb{Z} \times \mathbb{Z}/3\mathbb{Z}$), fixed-point-free antipodal involution ($J(x) = x + 6$), discrete cyclic geodesic metric axioms, 144-pair ($100_{12}$) metric partition, and unit-group automorphisms ($(\mathbb{Z}/12\mathbb{Z})^\times \cong V_4$).
2. **Common-Law Record-Integrity State Machine:** Type-level enforcement of two-gate entry rules, distinguishing *ultra vires* insertions (void *ab initio*, non-waivable, subject to expungement) from validly entered premises (unrebutted baseline subject to procedural waiver on untimely merits challenges).

### Execution Steps for Coding Agent
1. **Initialize Project (if needed):**
   ```bash
   lake new closed_ring_z12 math
   cd closed_ring_z12
   lake exe cache get
   ```
2. **Write Source Files:** Place `ClosedRingZ12.lean` (Section 3) and `RecordIntegrityGate.lean` (Section 4) into the library directory (`ClosedRingZ12/`), and export both in `ClosedRingZ12.lean` root.
3. **Build & Verify Zero Axioms/Sorries:**
   ```bash
   lake build
   lean --run ClosedRingZ12/Verify.lean
   ```
   Confirm that `#print axioms` reports only standard Lean constructive axioms (`propext`, `Quot.sound`, `Classical.choice` if imported by Mathlib, with zero `sorryAx` or custom axioms).

---

## 2. Uncontaminated Mathematical Invariant Law (Duodenary Notation)

* **Ring & CRT Isomorphism:** Let $R = \mathbb{Z}/10_{12}\mathbb{Z}$. Since $\gcd(4,3) = 1$ and $4 \cdot 3 = 10_{12}$:
  $$\Phi: R \xrightarrow{\sim} \mathbb{Z}/4\mathbb{Z} \times \mathbb{Z}/3\mathbb{Z}, \quad \Phi(x) = (x \bmod 4,\ x \bmod 3)$$
  $$\Phi^{-1}(a,b) = (9a + 4b) \bmod 10_{12}$$
* **Antipodal Involution:** $J(x) = (x + 6) \bmod 10_{12}$, satisfying $J^2 = \mathrm{id}_R$, $J(x) \neq x$, and partitioning $R$ into $6$ disjoint antipodal pairs.
* **Discrete Geodesic Metric & Partition:** $d(x,y) = \min((x-y) \bmod 10_{12},\ (y-x) \bmod 10_{12}) \in \{0,1,2,3,4,5,6\}$.
  * $N_0 = 10_{12}$, $N_1 = N_2 = N_3 = N_4 = N_5 = 20_{12}$, $N_6 = 10_{12}$.
  * $\sum_{d=0}^{6} N_d = |R \times R| = 100_{12}$ ($144_{10}$).
* **Unit-Group Automorphisms (Klein Four-Group $V_4$):** $(\mathbb{Z}/10_{12}\mathbb{Z})^\times = \{1, 5, 7, \varepsilon\}$, where $u^2 \equiv 1 \pmod{10_{12}}$ for every unit $u$, preserving both ring operations and geodesic distances ($d(u x, u y) = d(x, y)$).

---

## 3. Lean 4 Module 1: `ClosedRingZ12.lean`

```lean
import Mathlib.Data.ZMod.Basic
import Mathlib.Data.Finset.Card
import Mathlib.Algebra.Ring.Prod

namespace ClosedRingZ12

abbrev R := ZMod 12

-- ============================================================================
-- 1. Chinese Remainder Isomorphism (Bijection & Ring Homomorphism)
-- ============================================================================

def phi (x : R) : ZMod 4 × ZMod 3 :=
  (x.cast, x.cast)

def phiInv (p : ZMod 4 × ZMod 3) : R :=
  9 * p.1.cast + 4 * p.2.cast

theorem phi_left_inv (x : R) : phiInv (phi x) = x := by
  decide

theorem phi_right_inv (p : ZMod 4 × ZMod 3) : phi (phiInv p) = p := by
  decide

theorem phi_add (x y : R) : phi (x + y) = phi x + phi y := by
  decide

theorem phi_mul (x y : R) : phi (x * y) = phi x * phi y := by
  decide

theorem phi_one : phi 1 = 1 := by
  decide

def ringEquivCRT : R ≃+* ZMod 4 × ZMod 3 where
  toFun := phi
  invFun := phiInv
  left_inv := phi_left_inv
  right_inv := phi_right_inv
  map_mul' := phi_mul
  map_add' := phi_add

-- ============================================================================
-- 2. Fixed-Point-Free Antipodal Involution
-- ============================================================================

def J (x : R) : R := x + 6

theorem J_involution (x : R) : J (J x) = x := by
  decide

theorem J_no_fixed_points (x : R) : J x ≠ x := by
  decide

-- ============================================================================
-- 3. Discrete Geodesic Metric & 144-Pair (100₁₂) Partition
-- ============================================================================

def dist (x y : R) : ℕ :=
  min (x - y).val (y - x).val

theorem dist_eq_zero_iff (x y : R) : dist x y = 0 ↔ x = y := by
  decide

theorem dist_symm (x y : R) : dist x y = dist y x := by
  decide

theorem dist_triangle (x y z : R) : dist x z ≤ dist x y + dist y z := by
  decide

theorem dist_J_isometry (x y : R) : dist (J x) (J y) = dist x y := by
  decide

def N (d : ℕ) : ℕ :=
  ((Finset.univ : Finset (R × R)).filter (fun p => dist p.1 p.2 = d)).card

theorem N_values :
    N 0 = 12 ∧ N 1 = 24 ∧ N 2 = 24 ∧ N 3 = 24 ∧
    N 4 = 24 ∧ N 5 = 24 ∧ N 6 = 12 := by
  decide

theorem metric_partition_sum :
    (Finset.range 7).sum N = 144 := by
  decide

-- ============================================================================
-- 4. Unit-Group Automorphisms (Klein Four-Group V₄ Symmetry)
-- ============================================================================

def isUnitZ12 (u : R) : Bool :=
  u = 1 || u = 5 || u = 7 || u = 11

theorem unit_self_inverse (u : R) (hu : isUnitZ12 u = true) : u * u = 1 := by
  revert u hu
  decide

theorem unit_preserves_dist (u x y : R) (hu : isUnitZ12 u = true) :
    dist (u * x) (u * y) = dist x y := by
  revert u x y hu
  decide

theorem unit_commutes_with_J (u x : R) (hu : isUnitZ12 u = true) :
    u * J x = J (u * x) := by
  revert u x hu
  decide

-- ============================================================================
-- 5. Master Invariant Theorem
-- ============================================================================

theorem closed_ring_invariant :
    (∀ x : R, phiInv (phi x) = x) ∧
    (∀ p : ZMod 4 × ZMod 3, phi (phiInv p) = p) ∧
    (∀ x : R, J (J x) = x) ∧
    (∀ x y : R, dist x y = 0 ↔ x = y) ∧
    (∀ x y : R, dist x y = dist y x) ∧
    (∀ x y z : R, dist x z ≤ dist x y + dist y z) ∧
    ((Finset.range 7).sum N = 144) :=
  ⟨phi_left_inv, phi_right_inv, J_involution,
   dist_eq_zero_iff, dist_symm, dist_triangle, metric_partition_sum⟩

end ClosedRingZ12
```

---

## 4. Lean 4 Module 2: `RecordIntegrityGate.lean`

Encodes the common-law anti-contamination and procedural posture rules as an inductive state machine so invalid transitions (such as applying procedural waiver to an *ultra vires* insertion, or claiming collateral estoppel without a merits adjudication) cannot be constructed.

```lean
namespace RecordIntegrityGate

/-- Classification of an entry attempt at the boundary gate. -/
inductive EntryAuthority where
  | authorized   -- Within jurisdiction and predicate rules
  | ultraVires   -- Smuggled claim, unauthorized rule, or ipse dixit conclusion
  deriving DecidableEq, Repr

/-- Procedural posture of a record entry. -/
inductive EntryStatus where
  | voidAbInitio          -- Ultra vires insertion; legal nullity
  | enteredUnrebutted     -- Validly entered; no merits objection raised at gate
  | meritsWaived          -- Untimely merits challenge barred by procedural waiver
  | adjudicatedOnMerits   -- Actually litigated and decided on the merits
  | expunged              -- Stricken from the record to cure contamination
  deriving DecidableEq, Repr

structure LedgerEntry (α : Type) where
  payload   : α
  authority : EntryAuthority
  status    : EntryStatus
  deriving DecidableEq, Repr

/-- Gate 1: Initial admission into the ledger. -/
def admit {α : Type} (payload : α) (auth : EntryAuthority) : LedgerEntry α :=
  match auth with
  | .authorized => { payload := payload, authority := .authorized, status := .enteredUnrebutted }
  | .ultraVires => { payload := payload, authority := .ultraVires, status := .voidAbInitio }

/-- Motion to Strike Ab Initio: Available for any ultra vires insertion regardless of time. -/
def strikeAbInitio {α : Type} (e : LedgerEntry α) (h : e.authority = .ultraVires) : LedgerEntry α :=
  { e with status := .expunged }

/-- Procedural Waiver: Attaches ONLY to authorized, unrebutted entries. -/
def applyProceduralWaiver {α : Type} (e : LedgerEntry α)
    (hAuth : e.authority = .authorized)
    (hStat : e.status = .enteredUnrebutted) : LedgerEntry α :=
  { e with status := .meritsWaived }

/-- Collateral Estoppel Gate: Requires actual adjudication on the merits. -/
def isEstopped {α : Type} (e : LedgerEntry α) : Prop :=
  e.authority = .authorized ∧ e.status = .adjudicatedOnMerits

-- ============================================================================
-- Invariant Theorems of Common-Law Record Integrity
-- ============================================================================

/-- Theorem 1: An ultra vires insertion is void ab initio upon entry. -/
theorem ultra_vires_is_void {α : Type} (x : α) :
    (admit x .ultraVires).status = .voidAbInitio := rfl

/-- Theorem 2: An ultra vires insertion can NEVER satisfy collateral estoppel. -/
theorem ultra_vires_never_estopped {α : Type} (e : LedgerEntry α)
    (h : e.authority = .ultraVires) : ¬ isEstopped e := by
  intro ⟨hAuth, _⟩
  rw [h] at hAuth
  contradiction

/-- Theorem 3: An unrebutted entry (without merits hearing) is NOT estopped,
    though it may be protected by procedural waiver. -/
theorem unrebutted_not_estopped {α : Type} (x : α) :
    ¬ isEstopped (admit x .authorized) := by
  intro ⟨_, hStat⟩
  simp [admit] at hStat

/-- Theorem 4: Striking an ultra vires entry yields an expunged record. -/
theorem strike_cures_contamination {α : Type} (x : α) :
    let e := admit x .ultraVires
    (strikeAbInitio e rfl).status = .expunged := rfl

end RecordIntegrityGate
```

---

## 5. Lean 4 Verification Runner: `Verify.lean`

```lean
import ClosedRingZ12
import RecordIntegrityGate

#print axioms ClosedRingZ12.closed_ring_invariant
#print axioms ClosedRingZ12.unit_preserves_dist
#print axioms RecordIntegrityGate.ultra_vires_never_estopped
#print axioms RecordIntegrityGate.unrebutted_not_estopped

#eval IO.println "ALL DUODENARY RING & RECORD-INTEGRITY INVARIANTS VERIFIED."
```

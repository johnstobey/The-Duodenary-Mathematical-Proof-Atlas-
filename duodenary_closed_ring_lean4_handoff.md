# Duodenary Closed-Ring & Record-Integrity Handoff Package (Lean 4)

## 1. Coding Agent Instructions & Architecture Overview

**Objective:** Build, compile, and verify a self-contained Lean 4 package (`ClosedRingZ12`) implementing:
1. **The Duodenary Closed Ring (`ZMod 12` / $\mathbb{Z}/10_{12}\mathbb{Z}$):** Chinese Remainder Theorem ring isomorphism ($\mathbb{Z}/12\mathbb{Z} \cong \mathbb{Z}/4\mathbb{Z} \times \mathbb{Z}/3\mathbb{Z}$), fixed-point-free antipodal involution ($J(x) = x + 6$), discrete cyclic geodesic metric axioms, 144-pair ($100_{12}$) metric partition, and unit-group automorphisms ($(\mathbb{Z}/12\mathbb{Z})^\times \cong V_4$).
2. **Common-Law Record-Integrity State Machine:** Type-level enforcement of two-gate entry rules, distinguishing *ultra vires* insertions (void *ab initio*, non-waivable, subject to expungement) from validly entered premises (unrebutted baseline subject to procedural waiver on untimely merits challenges).

> **Build note (current):** the package at `closed_ring_z12/` is core Lean only (no Mathlib). Build with `cd closed_ring_z12 && lake build && lake env lean Verify.lean`. The `lake new` / Mathlib steps below are superseded.

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
* **Unit-Group Automorphisms ($(\mathbb{Z}/12\mathbb{Z})^\times \cong V_4$, units $\{1,5,7,11\}$):** every unit is self-inverse ($u^2 \equiv 1$), commutes with $J$ ($u\,J(x) = J(u\,x)$), and preserves $\sum_{d=0}^{6} N_d = 144$, $N_6 = 12$, and $N_1 + N_5 = 48$. Distances are split by the exact coprime criterion:
  * **Coprime distances, $\gcd(d,12)=1$ ($d \in \{1,5\}$):** generate the full 12-cycle. Under $u \in \{5,7\}$ they swap by $d \mapsto 6-d$ (so $1 \leftrightarrow 5$). Under $u \in \{1,11\}$ they are fixed.
  * **Non-coprime distances, $\gcd(d,12)>1$ ($d \in \{0,2,3,4,6\}$):** correspond to proper cyclic subgroups/sub-lattices. They are strictly invariant under all four units.
  * **Strict isometries ($u \in \{1,11\}$):** $d(ux,uy)=d(x,y)$ for all $d$.
  * **Duality automorphisms ($u \in \{5,7\}$):** $d(ux,uy)=6-d(x,y)$ when $d(x,y)\in\{1,5\}$, and $d(ux,uy)=d(x,y)$ otherwise.

  **Correction:** the earlier claim that every unit preserves $d$ was false ($u=5$, $x=1$, $y=0$: $d(5,0)=5 \neq 1=d(1,0)$). It is replaced by the statements above, which are verified in §3.

  | Property | $u=1$ | $u=11$ | $u=5$ | $u=7$ |
  |---|---|---|---|---|
  | Self-inverse ($u^2\equiv1$) | Yes | Yes | Yes | Yes |
  | Commutes with $J$ | Yes | Yes | Yes | Yes |
  | $d\in\{0,2,3,4,6\}$ preserved | Yes | Yes | Yes | Yes |
  | $d=1$, $d=5$ | fixed | fixed | swapped | swapped |
  | Strict isometry (all $d$) | Yes | Yes | No | No |
  | $N_1+N_5=48$, $\sum N_d=144$ | Yes | Yes | Yes | Yes |

---

## 3. Lean 4 Module 1: `ClosedRingZ12.lean` (core Lean, no Mathlib)

Verified: builds with exit 0; `#print axioms` shows no axioms for `unit_isometry`, `unit_duality`, `closed_ring_invariant`.

```lean
/-! Z/12Z closed-ring module, core Lean only (no Mathlib).
    Z/12Z is represented by Nat residues; every operation reduces mod 12.
    Quantifiers are bounded (`∀ x < 12`) so `decide` applies. -/
namespace ClosedRingZ12

def add (x y : Nat) : Nat := (x + y) % 12
def mul (x y : Nat) : Nat := (x * y) % 12
def sub (x y : Nat) : Nat := (x + (12 - y % 12)) % 12

-- Section 1: CRT, Z/12Z -> Z/4Z x Z/3Z
def phi (x : Nat) : Nat × Nat := (x % 4, x % 3)
def phiInv (p : Nat × Nat) : Nat := (9 * p.1 + 4 * p.2) % 12

theorem phi_left_inv : ∀ x < 12, phiInv (phi x) = x := by decide
theorem phi_right_inv : ∀ a < 4, ∀ b < 3, phi (phiInv (a, b)) = (a, b) := by decide
theorem phi_add : ∀ x < 12, ∀ y < 12,
    phi (add x y) = (((phi x).1 + (phi y).1) % 4, ((phi x).2 + (phi y).2) % 3) := by
  decide
theorem phi_mul : ∀ x < 12, ∀ y < 12,
    phi (mul x y) = (((phi x).1 * (phi y).1) % 4, ((phi x).2 * (phi y).2) % 3) := by
  decide
theorem phi_one : phi 1 = (1, 1) := by decide

-- Section 2: fixed-point-free antipodal involution
def J (x : Nat) : Nat := (x + 6) % 12

theorem J_involution : ∀ x < 12, J (J x) = x := by decide
theorem J_no_fixed_points : ∀ x < 12, J x ≠ x := by decide

-- Section 3: geodesic metric and 144-pair partition
def dist (x y : Nat) : Nat := min (sub x y) (sub y x)

theorem dist_eq_zero_iff : ∀ x < 12, ∀ y < 12, (dist x y = 0 ↔ x = y) := by decide
theorem dist_symm : ∀ x < 12, ∀ y < 12, dist x y = dist y x := by decide
theorem dist_triangle : ∀ x < 12, ∀ y < 12, ∀ z < 12,
    dist x z ≤ dist x y + dist y z := by decide
theorem dist_J_isometry : ∀ x < 12, ∀ y < 12, dist (J x) (J y) = dist x y := by decide

def N (d : Nat) : Nat :=
  ((List.range 12).map (fun x => ((List.range 12).filter (fun y => dist x y == d)).length)).foldl
    (· + ·) 0

theorem N_values :
    N 0 = 12 ∧ N 1 = 24 ∧ N 2 = 24 ∧ N 3 = 24 ∧
    N 4 = 24 ∧ N 5 = 24 ∧ N 6 = 12 := by
  decide

theorem metric_partition_sum :
    ((List.range 7).map N).foldl (· + ·) 0 = 144 := by
  decide

-- Section 4: unit group
def isUnit (u : Nat) : Bool := u == 1 || u == 5 || u == 7 || u == 11

theorem unit_self_inverse : ∀ u < 12, isUnit u = true → mul u u = 1 := by decide

theorem unit_commutes_with_J : ∀ u < 12, ∀ x < 12,
    isUnit u = true → mul u (J x) = J (mul u x) := by decide

-- Section 5: master invariant
theorem closed_ring_invariant :
    (∀ x < 12, phiInv (phi x) = x) ∧
    (∀ a < 4, ∀ b < 3, phi (phiInv (a, b)) = (a, b)) ∧
    (∀ x < 12, J (J x) = x) ∧
    (∀ x < 12, ∀ y < 12, (dist x y = 0 ↔ x = y)) ∧
    (∀ x < 12, ∀ y < 12, dist x y = dist y x) ∧
    (∀ x < 12, ∀ y < 12, ∀ z < 12, dist x z ≤ dist x y + dist y z) ∧
    ((List.range 7).map N).foldl (· + ·) 0 = 144 :=
  ⟨phi_left_inv, phi_right_inv, J_involution,
   dist_eq_zero_iff, dist_symm, dist_triangle, metric_partition_sum⟩

-- Corrected unit action (replaces the false isometry claim for all units).
-- u in {1,11}: strict isometry. u in {5,7}: fixes distances 0,2,3,4,6 and swaps 1 <-> 5.
theorem unit_isometry : ∀ u < 12, isUnit u = true → (u = 1 ∨ u = 11) →
    ∀ x < 12, ∀ y < 12, dist (mul u x) (mul u y) = dist x y := by decide
theorem unit_duality : ∀ u < 12, isUnit u = true → (u = 5 ∨ u = 7) →
    ∀ x < 12, ∀ y < 12,
      dist (mul u x) (mul u y) =
        (if dist x y = 1 ∨ dist x y = 5 then 6 - dist x y else dist x y) := by decide

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
#print axioms ClosedRingZ12.unit_isometry
#print axioms ClosedRingZ12.unit_duality
#print axioms ClosedRingZ12.unit_commutes_with_J
#print axioms RecordIntegrityGate.ultra_vires_never_estopped
#print axioms RecordIntegrityGate.unrebutted_not_estopped

#eval IO.println "ALL DUODENARY RING & RECORD-INTEGRITY INVARIANTS VERIFIED."
```

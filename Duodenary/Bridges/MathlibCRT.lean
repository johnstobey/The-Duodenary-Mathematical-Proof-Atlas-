import Mathlib.Data.ZMod.Basic

/-!
# Canonical Mathlib CRT bridge — CP-00

`ZMod.chineseRemainder` is the canonical Mathlib ring equivalence
`ZMod (m * n) ≃+* ZMod m × ZMod n`. For `m = 4`, `n = 3` it gives the
Chinese-remainder isomorphism `ZMod 12 ≃+* ZMod 4 × ZMod 3`.

This module bridges that canonical equivalence to the repository's existing
core-only bounded-Nat implementation `closed_ring_z12/ClosedRingZ12.lean`
(`phi x = (x % 4, x % 3)`, `phiInv (u, v) = (9u + 4v) % 12`). The core file is
standalone and outside this library's module graph, so the bridge is stated as
residue agreement: the theorems below prove the canonical equivalence computes
the same forward map and the same `9u + 4v` reconstruction on `.val` residues.
Nothing here replaces or silently conflates the core-only `CRTIso`; the two
descriptions are proved to agree.
-/

namespace Duodenary.Bridges

/-- Canonical Mathlib ring equivalence `ZMod 12 ≃+* ZMod 4 × ZMod 3`.
`ZMod (4 * 3)` is definitionally `ZMod 12`, so the Mathlib declaration applies
directly at this type. -/
def crtEquiv : ZMod 12 ≃+* ZMod 4 × ZMod 3 :=
  ZMod.chineseRemainder (by decide : Nat.Coprime 4 3)

/-- CRT reconstruction candidate `9u + 4v (mod 12)` in `ZMod 12`, matching the
core-only `phiInv`. -/
def crtReconstruct (u : ZMod 4) (v : ZMod 3) : ZMod 12 :=
  ((9 * u.val + 4 * v.val) % 12 : ℕ)

theorem crtReconstruct_val (u : ZMod 4) (v : ZMod 3) :
    (crtReconstruct u v).val = (9 * u.val + 4 * v.val) % 12 := by
  unfold crtReconstruct
  exact ZMod.val_natCast_of_lt (Nat.mod_lt _ (by decide))

/-- Bridge, forward direction: the canonical map's first coordinate is `k mod 4`,
agreeing with core-only `phi`. -/
theorem crt_fst_val : ∀ k : ZMod 12, (crtEquiv k).1.val = k.val % 4 := by decide

/-- Bridge, forward direction: the canonical map's second coordinate is `k mod 3`,
agreeing with core-only `phi`. -/
theorem crt_snd_val : ∀ k : ZMod 12, (crtEquiv k).2.val = k.val % 3 := by decide

/-- The candidate `9u + 4v (mod 12)` has the CRT image `(u, v)`. -/
theorem crtEquiv_reconstruct (u : ZMod 4) (v : ZMod 3) :
    crtEquiv (crtReconstruct u v) = (u, v) := by
  apply Prod.ext
  · apply (ZMod.val_injective 4)
    rw [crt_fst_val, crtReconstruct_val]
    have e4 : (9 * u.val + 4 * v.val) % 4 = u.val := by
      have hu : u.val < 4 := ZMod.val_lt u
      omega
    rw [Nat.mod_mod_of_dvd _ (show 4 ∣ 12 from by decide), e4]
  · apply (ZMod.val_injective 3)
    rw [crt_snd_val, crtReconstruct_val]
    have e3 : (9 * u.val + 4 * v.val) % 3 = v.val := by
      have hv : v.val < 3 := ZMod.val_lt v
      omega
    rw [Nat.mod_mod_of_dvd _ (show 3 ∣ 12 from by decide), e3]

/-- Forward inverse: reconstruction after decomposition returns `k`. -/
theorem crt_left_inv : ∀ k : ZMod 12, crtEquiv.symm (crtEquiv k) = k :=
  crtEquiv.left_inv

/-- Reverse inverse: decomposition after reconstruction returns `(u, v)`. -/
theorem crt_right_inv : ∀ p : ZMod 4 × ZMod 3, crtEquiv (crtEquiv.symm p) = p :=
  crtEquiv.right_inv

/-- Preserved addition (componentwise on the product). -/
theorem crt_map_add : ∀ x y : ZMod 12, crtEquiv (x + y) = crtEquiv x + crtEquiv y :=
  map_add crtEquiv

/-- Preserved multiplication (componentwise on the product). -/
theorem crt_map_mul : ∀ x y : ZMod 12, crtEquiv (x * y) = crtEquiv x * crtEquiv y :=
  map_mul crtEquiv

/-- Preserved multiplicative identity. -/
theorem crt_map_one : crtEquiv 1 = (1, 1) := map_one crtEquiv

/-- Bridge, reverse direction: the canonical inverse reconstructs `k` as
`9u + 4v mod 12`, agreeing with core-only `phiInv`. The candidate's image under
`crtEquiv` is `(u, v)` (`crtEquiv_reconstruct`), so by injectivity it equals the
canonical inverse. -/
theorem crt_symm_val : ∀ u : ZMod 4, ∀ v : ZMod 3,
    (crtEquiv.symm (u, v)).val = (9 * u.val + 4 * v.val) % 12 := by
  intro u v
  have hsymm : crtEquiv.symm (u, v) = crtReconstruct u v := by
    apply crtEquiv.injective
    rw [RingEquiv.apply_symm_apply, crtEquiv_reconstruct]
  rw [hsymm, crtReconstruct_val]

/-- Antipode compatibility `J(k) = k + 6`: the involution acts on CRT
coordinates as `+6` in each factor (`+2` mod 4, `0` mod 3). -/
theorem crt_J : ∀ k : ZMod 12,
    crtEquiv (k + 6) = ((crtEquiv k).1 + 6, (crtEquiv k).2 + 6) := by decide

/-- `J` is an involution: applying `k ↦ k + 6` twice returns `k`. -/
theorem crt_J_involution : ∀ k : ZMod 12, k + 6 + 6 = k := by decide

/-- Full successor orbit: every `k : ZMod 12` is a bounded iterate of the
successor `+1` applied to `0`, and the orbit has the full length twelve. -/
theorem successor_orbit : ∀ k : ZMod 12, ∃ n : Fin 12, k = (n.val : ZMod 12) :=
  fun k => ⟨⟨k.val, k.isLt⟩, (ZMod.natCast_zmod_val k).symm⟩

/-- Versioned CRT test vectors for downstream consumers:
`k ↦ (k mod 4, k mod 3)` for `k = 0 … 11`. -/
def testVectors : List (Nat × (Nat × Nat)) :=
  (List.range 12).map fun k => (k, (k % 4, k % 3))

theorem testVectors_length : testVectors.length = 12 := rfl

/-- The canonical equivalence reproduces every entry of `testVectors`. -/
theorem testVectors_agree : ∀ k : ZMod 12,
    (k.val, ((crtEquiv k).1.val, (crtEquiv k).2.val)) ∈ testVectors := by decide

/-- CP-00 certificate: every acceptance lemma in one bundle. -/
theorem crt_certificate :
    (∀ k : ZMod 12, crtEquiv.symm (crtEquiv k) = k) ∧
    (∀ p : ZMod 4 × ZMod 3, crtEquiv (crtEquiv.symm p) = p) ∧
    (∀ x y : ZMod 12, crtEquiv (x + y) = crtEquiv x + crtEquiv y) ∧
    (∀ x y : ZMod 12, crtEquiv (x * y) = crtEquiv x * crtEquiv y) ∧
    crtEquiv 1 = (1, 1) ∧
    (∀ u : ZMod 4, ∀ v : ZMod 3,
      (crtEquiv.symm (u, v)).val = (9 * u.val + 4 * v.val) % 12) ∧
    (∀ k : ZMod 12,
      crtEquiv (k + 6) = ((crtEquiv k).1 + 6, (crtEquiv k).2 + 6)) ∧
    (∀ k : ZMod 12, ∃ n : Fin 12, k = (n.val : ZMod 12)) :=
  ⟨crt_left_inv, crt_right_inv, crt_map_add, crt_map_mul, crt_map_one,
   crt_symm_val, crt_J, successor_orbit⟩

end Duodenary.Bridges

#print axioms Duodenary.Bridges.crt_certificate

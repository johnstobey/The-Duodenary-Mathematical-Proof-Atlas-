# CP-01 interface contract — canonical Z/12 ring, generators, and the 144-pair space

Version: `cp01-interface-v1` · Date: 2026-11-24 · Status: kernel-verified
Kernel surface: `closed_ring_z12_mathlib/PairSpace144.lean` (Lean 4.14.0,
mathlib `4bbdccd`), axioms ⊆ `{propext, Classical.choice, Quot.sound}`.

This contract fixes the serialized schema and operator semantics that
downstream consumers (Recursiverse-Suite, Machine, Alien-math-decoded-2,
Ravenproofs decoder) may rely on. It describes **structure**, not semantic
interpretation.

## 1. Carrier and CRT coordinates

- Carrier: `ZMod 12` (Mathlib canonical ring). Core carrier `C12 = Fin 12`
  is bridged by `Duodenary.C12Mathlib.c12EquivZMod`.
- CRT equivalence: `crt12 : ZMod 12 ≃+* ZMod 4 × ZMod 3`
  (`ZMod.chineseRemainder`, coprime `4·3=12`). Forward coordinate of `k`:
  `(k mod 4, k mod 3)`; inverse reconstruction `k = 9u + 4v (mod 12)`.
- Antipode: `J(k) = k + 6` (six pairs `{k, k+6}`).

## 2. Generators (independent translations)

| Operator | Definition | CRT action | Certified facts |
|---|---|---|---|
| `t9` | `k ↦ k + 9` | `(u,v) ↦ (u+1, v)` — u-coordinate only | `t9_coords` |
| `t4` | `k ↦ k + 4` | `(u,v) ↦ (u, v+1)` — v-coordinate only | `t4_coords` |
| `sigma` | `k ↦ k + 1` | successor, order 12 | `sigma_iterate_full` |

- `t9 ∘ t4 = sigma` (`t9_t4_eq_sigma`); translations commute
  (`t9_t4_commute`).
- `J(k) = k + 6 = t9^[2] k` (`antipode_eq_t9_iterate`).
- T₄-orbits: four fibers of size 3, `{k, k+4, k+8}`, indexed by `u`.
  T₉-orbits: three fibers of size 4, `{k, k+9, k+6, k+3}`, indexed by `v`.
- **Incidence (CRT cell property)**: every T₄-orbit × T₉-orbit pair
  intersects in exactly one element (`orbit_unique_intersection`,
  `crt_cell_unique`). This is `crt12` bijectivity restated — the 4×3 grid
  is the complete incidence structure.

## 3. The 144 ordered pairs

- Type: `ZMod 12 × ZMod 12` — ordered pairs of residues. **144 pairs, not
  144 states**: `pair_product_not_zmod144` proves no ring equivalence to
  `ZMod 144` exists (units: `|(Z12×Z12)ˣ| = 16` vs `|(Z144)ˣ| = φ(144) = 48`).
- Serialization: `encode144 (a,b) = 12·a + b ∈ Fin 144` (row-major);
  `decode144 n = (n/12, n%12)`. Bijection `pairEquiv`.
- Cardinality: `pair_card` — exactly 144.
- Core agreement: `encode144_agrees_core` — canonical encoding composed
  with `toZMod` equals `Duodenary.encode144` on `C12 × C12`.

## 4. Machine-readable vectors

`closed_ring_z12_mathlib/test_vectors/`:

- `crt12_vectors_v1.csv` — 12-row CRT correspondence (existing).
- `generators_v1.csv` — per-residue `t9/t4/sigma` images + CRT coords +
  orbit ids.
- `pair144_vectors_v1.csv` — full 144-row serialization table.

## 5. Cross-repo compatibility

| System | Surface | Relation |
|---|---|---|
| Ravenproofs `Tobey.CRT`/`Generators` | `canonicalCRT`, `kappa`/`kappaInv`, `T9`/`T4`/`sigma`, orbit partition + unique-intersection theorems | Identical definitions and theorem shapes; Atlas versions are the canonical-tower statements (`crt12`-based coordinate proofs rather than `native_decide`) |
| Recursiverse kernel (`CANONICAL_KERNEL_THEOREMS.lean`) | `P12 := ZMod 12`, `R k = k+1`, `A k = k+6`, `crtPair`, K08 order witness | Same carrier and successor/antipode; Atlas adds generator orbit structure + pair-space serialization |

See `geometry/CP02_CROSS_REPO_MAPPING.md` for the GeometryIR lane, which is
orthogonal to this ring interface.

## 6. Non-claims

- The 144 pairs carry no asserted semantics (linguistic, astrological,
  geometric) — per `CRT_RING_CONTRACT.md`, algebraic structure only.
- `ZMod 144` cyclic structure is explicitly **not** claimed for the pair
  space (see §3).

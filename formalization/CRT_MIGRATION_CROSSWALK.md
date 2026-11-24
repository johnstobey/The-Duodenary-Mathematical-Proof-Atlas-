# CRT migration crosswalk — CP-00

Bridge between the core-only bounded-Nat implementation
`closed_ring_z12/ClosedRingZ12.lean` (`CRTIso`) and the canonical Mathlib
equivalence `ZMod.chineseRemainder` in `Duodenary/Bridges/MathlibCRT.lean`.

Status vocabulary per `contracts/2026-11-13/EVIDENCE_AND_ACCEPTANCE.md`:
EXECUTED = kernel-checked in the pinned Lean/Mathlib toolchain this build.

## Correspondence

| Core-only (bounded Nat, no Mathlib) | Canonical (Mathlib `ZMod`) | Lean name | Status |
|---|---|---|---|
| `phi x = (x % 4, x % 3)` | `(crtEquiv k).1/.2` with `.val = k.val % 4 / % 3` | `Duodenary.Bridges.crt_fst_val`, `crt_snd_val` | EXECUTED |
| `phiInv (a,b) = (9a + 4b) % 12` | `crtEquiv.symm (u,v)` with `.val = (9u.val + 4v.val) % 12` | `Duodenary.Bridges.crtReconstruct`, `crt_symm_val` | EXECUTED |
| `add`, `mul`, `sub` mod 12 | `ZMod 12` ring ops | `crt_map_add`, `crt_map_mul`, `crt_map_one` | EXECUTED |
| `CRTInv.left_inv`, `right_inv` (bounded `∀ x < 12`) | `RingEquiv` left/right inverse | `crt_left_inv`, `crt_right_inv` | EXECUTED |
| `J x = (x + 6) % 12` | `k ↦ k + 6` in `ZMod 12`; acts as `+6` on each CRT factor | `crt_J`, `crt_J_involution` | EXECUTED |
| successor orbit over `List.range 12` | `∀ k : ZMod 12, ∃ n : Fin 12, k = n.val` | `successor_orbit` | EXECUTED |
| `N d` distance histogram, `metric_partition_sum = 144` | not yet lifted — Nat-bounded `decide` only | — | UNRESOLVED (out of CP-00 scope) |
| `isUnit`, `unit_self_inverse`, `unit_duality` | `ZMod 12` units group — not yet bridged | — | UNRESOLVED (out of CP-00 scope) |
| `closed_ring_invariant` conjunction | `crt_certificate` conjunction | `crt_certificate` | EXECUTED |

## CRT test vectors (versioned, `Duodenary.Bridges.testVectors`)

`k ↦ (k mod 4, k mod 3)`, k = 0…11:

| k | u = k mod 4 | v = k mod 3 | 9u+4v mod 12 |
|---|---|---|---|
| 0 | 0 | 0 | 0 |
| 1 | 1 | 1 | 13 mod 12 = 1 |
| 2 | 2 | 2 | 26 mod 12 = 2 |
| 3 | 3 | 0 | 27 mod 12 = 3 |
| 4 | 0 | 1 | 4 mod 12 = 4 |
| 5 | 1 | 2 | 17 mod 12 = 5 |
| 6 | 2 | 0 | 18 mod 12 = 6 |
| 7 | 3 | 1 | 31 mod 12 = 7 |
| 8 | 0 | 2 | 8 mod 12 = 8 |
| 9 | 1 | 0 | 9 mod 12 = 9 |
| 10 | 2 | 1 | 22 mod 12 = 10 |
| 11 | 3 | 2 | 35 mod 12 = 11 |

Every row closes: `k = (9u + 4v) mod 12` (`crt_symm_val`, EXECUTED).

## Boundary notes

- `ZMod 12` is `Fin 12`; `.val` is the canonical representative. Core-only
  theorems are bounded Nat propositions (`∀ x < 12`); canonical theorems are
  over `ZMod n`. Agreement is proved on `.val` residues, not by rewriting one
  system into the other.
- `crtEquiv`'s forward map is `castHom` into `ZMod 4 × ZMod 3`
  (`(k mod 4, k mod 3)`); its inverse is `Nat.chineseRemainder` applied to
  `.val`s. `crtReconstruct` is the explicit `9u + 4v` candidate; equality with
  the canonical inverse is proved via injectivity (`crtEquiv_reconstruct`),
  not assumed.
- `#print axioms Duodenary.Bridges.crt_certificate` reports
  `[propext, Classical.choice, Quot.sound]` — no `sorryAx`.

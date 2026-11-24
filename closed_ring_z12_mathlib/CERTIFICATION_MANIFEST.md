# Certification manifest — CP-00/01/02 (DCC-01 Article X)

Canonical structure: `ZMod 12 ≃+* ZMod 4 × ZMod 3` (Mathlib CRT, pinned
`4bbdccd9c5f862bf90ff12f0a9e2c8be032b9a84`, Lean `v4.14.0`).

This manifest classifies every public declaration in the certification
surface as **inherited** (Mathlib theorem applied, no new proof content),
**derived** (proved here from inherited results + finite computation), or
**constructed** (new object: definition/instance/equivalence).

## CP-00 — `CRTMathlib.lean` (Mathlib CRT instantiation)

| Declaration | Class | Basis |
|---|---|---|
| `crt12` | constructed | `ZMod.chineseRemainder` (inherited) applied at `m=4, n=3` |
| `crt12_apply_lt`, `crt12_eq_phi` | derived | `decide` over `k < 12` |
| `inv_formula_mod4/3` | derived | `omega` |
| `crt12_symm_apply_lt` | derived | injectivity + forward computation |
| `crt12_symm_eq_casterm`, `crt12_symm_val_eq_phiInv`, `crt12_symm_phi_roundtrip` | derived | composition of above + core `phi_right_inv` |
| `bridge_add`, `bridge_mul`, `bridge_one`, `bridge_one_eq_phi_one`, `bridge_J` | derived | `decide` over bounded residues |

## CP-01 — `C12ZModBridge.lean` (`C12 ≃+* ZMod 12`)

| Declaration | Class | Basis |
|---|---|---|
| `c12EquivZMod` | constructed | `decide`-proved bijection `Fin 12 ≃ ZMod 12` |
| `c12CommRing` | constructed | `CommRing` instance transported across defeq `ZMod 12 = Fin 12 = C12` |
| `c12ToZModRingHom` | constructed | hom fields `decide`-checked |
| `c12RingEquivZMod` | constructed | `RingEquiv.ofBijective` |
| `c12CrtEquiv` | constructed | `RingEquiv.trans` with `crt12` |
| `c12CrtEquiv_apply`, `crt_eq_zmod_crt`, `crt_eq_c12CrtEquiv`, `uncrt_zmod`, `opposite_transport`, `unitSlope_isUnit` | derived | `decide`/`rfl` transport lemmas |

## CP-02 — `ZMod12Transport.lean` (transport interface)

| Declaration | Class | Basis |
|---|---|---|
| `natCast_mod12` | inherited | `ZMod.natCast_mod` |
| `natResidue_add/mul/sub/J/zero/one` | derived | `natCast_mod12` + `Nat.cast_*` simp lemmas |
| `natResidue_isUnit`, `natResidue_dist` | derived | `decide` over `u, x, y < 12` |
| `zmod12_units_card` | **inherited** | `ZMod.card_units_eq_totient` + `Nat.totient 12 = 4` |
| `c12_units_card` | inherited, transported | same, through defeq carrier |
| `zmod12_unit_iff_coprime` | inherited characterization | `decide` (matches `ZMod.unitsEquivCoprime`) |
| `crtFactorModel` | inherited | `RingEquiv.symm` of `crt12` |

## Workload accounting (Article X: inheritance vs construction)

- Ring axioms for `ZMod 12`, `ZMod 4`, `ZMod 3`, products, and units:
  **zero** — inherited from Mathlib (not reproved anywhere in this repo).
- CRT decomposition: **one** application of `ZMod.chineseRemainder`.
- `C12` ring structure: **zero** operation redefinitions — the instance is
  the `ZMod 12` instance transported across a definitional equality.
- New proof obligations actually discharged: ~30 bounded `decide`/`omega`
  elements plus 3 `RingEquiv` assemblies. Everything else is citation.

## Axiom surface

All gates report axioms ⊆ `{propext, Classical.choice, Quot.sound}`;
zero `sorryAx` across `VerifyAxioms.lean` (14), `VerifyC12.lean` (13),
`VerifyTransport.lean` (13), enforced in CI by `.github/workflows/verify.yml`.

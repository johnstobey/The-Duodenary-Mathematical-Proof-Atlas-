# closed_ring_z12_mathlib — CP-00 Mathlib CRT Bridge

Canonical Mathlib `RingEquiv` for the Duodenary closed ring, bridging the
core-only implementation in `../closed_ring_z12/ClosedRingZ12.lean`.
This package **bridges, does not replace or modify**, the core module.

Resolves [issue #5](https://github.com/johnstobey/The-Duodenary-Mathematical-Proof-Atlas-/issues/5) (CP-00, P0).

## Toolchain pins

| Component | Pin |
|---|---|
| Lean | `leanprover/lean4:v4.14.0` (same as core package) |
| Mathlib | `4bbdccd9c5f862bf90ff12f0a9e2c8be032b9a84` (same as root repo `lake-manifest.json`) |
| API verified at pinned rev | `ZMod.chineseRemainder {m n : ℕ} (h : m.Coprime n) : ZMod (m * n) ≃+* ZMod m × ZMod n` (`Mathlib/Data/ZMod/Basic.lean`) |

## Canonical object

```lean
open ClosedRingZ12.MathlibCRT
def crt12 : ZMod 12 ≃+* ZMod 4 × ZMod 3 := ZMod.chineseRemainder (m := 4) (n := 3) (by decide)
```

## Public interface (downstream consumers)

| Declaration | Statement (shape) |
|---|---|
| `crt12` | `ZMod 12 ≃+* ZMod 4 × ZMod 3` |
| `crt12_apply_lt` | `k < 12 → crt12 ↑k = (↑(k % 4), ↑(k % 3))` (agrees with core `phi`) |
| `crt12_eq_phi` | same, stated against core `phi` directly |
| `inv_formula_mod4/3` | `(9u+4v) % 12 % 4 = u`, `(9u+4v) % 12 % 3 = v` for `u < 4, v < 3` |
| `crt12_symm_apply_lt` | `crt12.symm (↑u, ↑v) = ↑((9*u + 4*v) % 12)` for `u < 4, v < 3` |
| `crt12_symm_eq_casterm` | `crt12.symm (↑(k%4), ↑(k%3)) = ↑k` for `k < 12` |
| `crt12_symm_val_eq_phiInv` | `.val`-level agreement with core `phiInv` |
| `crt12_symm_phi_roundtrip` | `phi (crt12.symm (↑u, ↑v)).val = (u, v)` |
| `bridge_add` / `bridge_mul` | core `add`/`mul` compatible with `crt12` on all residues |
| `bridge_one`, `bridge_one_eq_phi_one` | `crt12 1 = (1, 1)` (core `phi_one` shape) |
| `bridge_J` | `J(k) = (k+6) mod 12` transports to `(a, b) ↦ (a + 2, b)` |

## Migration crosswalk (core → Mathlib)

| Core (`ClosedRingZ12.lean`) | Mathlib bridge | Relation |
|---|---|---|
| `phi : Nat → Nat × Nat` | `crt12` (forward coercion) | `crt12_apply_lt`, `crt12_eq_phi` |
| `phiInv (a,b) = (9a+4b) % 12` | `crt12.symm` | `crt12_symm_apply_lt`, `crt12_symm_val_eq_phiInv` |
| `CRTIso` / `crtIso` (bundled bounded propositions) | `RingEquiv` (unbundled, typeclass ring laws) | **non-conflation**: `crtIso` remains untouched; bridge lemmas relate the two, no replacement |
| `add`, `mul`, `1` on Nat residues | ring ops on `ZMod 12`, `ZMod 4 × ZMod 3` | `bridge_add`, `bridge_mul`, `bridge_one` |
| `J x = (x+6) % 12` | `(a, b) ↦ (a + 2, b)` on `ZMod 4 × ZMod 3` (6 ≡ 2 mod 4, 6 ≡ 0 mod 3) | `bridge_J` |

## Proof method note

`crt12`'s forward map is kernel-computable, so forward theorems are `decide`-proved
over the bounded domain (the core module's method). `crt12.symm` is **not**
kernel-computable (reduction gets stuck inside `ZMod.chineseRemainder`'s inverse),
so the inverse theorems use a uniqueness argument: the `(9u+4v)` formula value is
shown to be *the* preimage of `(u, v)` under the decided forward map, and
injectivity of the equivalence identifies it with `crt12.symm`.

## CP-01: `C12` ↔ `ZMod 12` bridge (`C12ZModBridge.lean`)

The Duodenary core carrier `C12 := Fin 12` (`Duodenary/Core/Cyclic.lean`,
mathlib-free, underlying all 108 core theorems) is now connected to the
canonical Mathlib CRT by a path dependency on `duodenary_proof_atlas` (`..`).

| Declaration | Statement (shape) |
|---|---|
| `c12EquivZMod` | `C12 ≃ ZMod 12` (computable carrier equivalence, `decide`-proved) |
| `c12CommRing` | `CommRing C12` — instance transported from `CommRing (ZMod 12)` across `ZMod 12 = Fin 12 = C12`; no new operations |
| `c12ToZModRingHom` | `C12 →+* ZMod 12` (`decide`-checked add/mul/zero/one) |
| `c12RingEquivZMod` | `C12 ≃+* ZMod 12` (noncomputable; `RingEquiv.ofBijective`) |
| `c12CrtEquiv` | `C12 ≃+* ZMod 4 × ZMod 3` — composed with `crt12` |
| `c12CrtEquiv_apply` | pointwise `c12CrtEquiv x = crt12 (toZMod x)` (`rfl`) — the computable form for `decide` |
| `crt_eq_zmod_crt` / `crt_eq_c12CrtEquiv` | core `Duodenary.crt` agrees with the canonical CRT image |
| `uncrt_zmod` | core `uncrt` is the `ZMod`-level inverse: `(u mod 4, v mod 3) ↦ (9u+4v) mod 12` |
| `opposite_transport` | antipode `x + 6` transports to `(a, b) ↦ (a + 2, b)` (same law as `bridge_J`) |
| `unitSlope_isUnit` | the four affine slopes `{1,5,7,11}` are `IsUnit` in `ZMod 12` |

Axiom gate: `lake env lean VerifyC12.lean` — 13 `#print axioms` reports,
zero `sorryAx`; computable declarations depend only on
`[propext, Quot.sound]`, bundled equivalences on Mathlib-standard
`[propext, Classical.choice, Quot.sound]`. Nine compile-time test-vector
rows included.

## Versioned test vectors

`test_vectors/crt12_vectors_v1.csv` — 12 rows:
`k, phi_fst_mod4, phi_snd_mod3, phiInv_9u_4v_mod12, J_k_plus6_mod12`.
Self-checked: `phiInv ∘ phi = id`, `phi ∘ phiInv = id`, `J ∘ J = id`.
Compile-time counterparts: the 24 `example` rows in `VerifyAxioms.lean`
plus the 9 rows in `VerifyC12.lean`.

## Build and verification receipts (2026-11-23)

```
$ cd closed_ring_z12_mathlib && lake build
✔ [999/1000] Built CRTMathlib
Build completed successfully.
BUILD_EXIT=0

$ lake env lean VerifyAxioms.lean   # 14 axiom reports, 0 errors
VERIFY_EXIT=0
GATE PASS: no sorryAx
```

Axiom discipline: every public declaration depends only on
`[propext, Classical.choice, Quot.sound]` (Mathlib-standard); `inv_formula_mod4/3`
depend only on `[propext, Quot.sound]`. Zero `sorryAx`. Core bundle
`crtIso`/`crtIso`-family theorems remain axiom-clean in the unmodified core package.

## Reproduce

```bash
cd closed_ring_z12_mathlib
lake update          # fetch Mathlib at pinned rev + path deps
lake exe cache get   # fetch precompiled Mathlib oleans
lake build
lake env lean VerifyAxioms.lean   # CP-00 gate: 14 axiom reports
lake env lean VerifyC12.lean      # CP-01 gate: 13 axiom reports + 9 vectors
```

Note (macOS): `lake exe cache get` builds the `cache` helper locally; on
hosts whose system linker emits `__DATA_CONST` without `SG_READ_ONLY`
(observed with Apple clang 21 CLT on macOS 14), the helper fails under `dyld`
before downloading anything. Workaround — run the same entrypoint through
`lean --run`'s linker path, which produces a working binary:

```bash
printf 'import Cache.Main\n#eval main ["get"]\n' > /tmp/runcache.lean
lake env lean /tmp/runcache.lean   # downloads + unpacks the oleans
```

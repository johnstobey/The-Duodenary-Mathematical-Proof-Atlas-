# The invariant: geometric identity through representation and execution

**Across the supported representations, the same structured object retains its identity: its defining relationships and permitted operations remain consistent through translation and execution.**

This is the organizing purpose connecting the geometry, operation languages,
codecs, runtime checks and admission controls. The public mathematical work
supplies explicit proved instances; the following runnable example makes the
correspondence visible without changing any of the 157 canonical definitions.

## What "same" means here

An object is a station x in Z/12Z, with its declared rotation/opposition/reflective
operations. Its representations are the integer 0..11, its zodiac glyph, and
an exact rational angle x/12 turns (30*x degrees). For a lattice cell the object
is the ordered pair (domain,modality); its encoding is 12*domain+modality.
The glyph order and orientation are fixed explicitly. Angles are compared modulo
one turn, never by approximate floating-point equality. The 144-address pair
encoding is not an assertion that its operations form the cyclic ring Z/144Z.

For a representation h, source operation f and declared target operation g:

    h(f(x)) = g(h(x))
    decode(h(x)) = x

These state operational correspondence and exact recovery. They do not assert
that every allowed operation preserves every metric: a distance-preserving map
and a general affine permutation have different obligations. Here state identity
means exact recovery of the specified state and agreement of the specified operations.
The worked subset preserves cyclic relationships under the relevant translations,
opposition and reflection. Arbitrary claims about text meanings are not inferred.

## Inspect a full example

Input: `☉♓ □ ☉♊` — start 11, advance three steps (90 degrees), finish 2.

| Stage | Exact representation |
|---|---|
| Canonical declaration | ALG-001: twelve positions, 30 degrees per step |
| Mathematical state | 11 in Z/12Z |
| Input glyph | Pisces: ♓ |
| Input angle | 11/12 turn = 330 degrees |
| Executed operation | (11+3) mod 12 = 2 |
| Output glyph | Gemini: ♊ |
| Output angle | (11/12+3/12) mod 1 = 1/6 turn = 60 degrees |
| Recovered state | decode(♊) = 2 |
| Broken counterpart | `☉♓ □ ☉♋` is rejected: it names state 3, not 2 |

The shift is applied both in the finite engine and independently through the
glyph successor operation. All 84 expected aspect cases are compared with the
pre-existing, hash-frozen fixture. Reversibility and operator preservation are
separate checks. A deliberately permuted labeling x↦5x paired with unchanged
one-step target rotation is bijective but fails correspondence; the verifier
prints concrete counterexamples. A matching label count cannot pass that check.

## One command, complete finite tables

```sh
python3 03_ENGINE/invariant.py
```

Exit 0 means all enumerated checks ran without a mismatch; otherwise exit 1.
The JSON output contains all 12 representation rows, all 48 generator rows,
all 84 angular executions, all 144 address rows, the worked example, and six
rejected controls. This is a reproducible finite check, not a new Lean theorem
or an independent hidden-target evaluation. Existing Lean proofs remain linked below.

## Declaration → execution → evidence

| Binding | Source | Executable | Evidence |
|---|---|---|---|
| Angular geometry | Locked ALG-001 | finite engine and typed Fulgurite subset | 84 fixture cases and glyph/angle commuting checks |
| Opposite station | Locked ALG-013 | A(x)=x+6 mod12 | 12 station checks and 144 lattice checks |
| Rotation/reflection | Explicit finite-engine T/I/rho definitions | Source and target operators evaluated separately | Full 48-row generator table |
| Cartesian address | Defined pair (d,m) | address/inverse_address | All 144 round trips and coordinate-operation checks |
| Admission witnesses | Typed adapter + frozen source/fixture hashes | invariant.admit | Genuine positive programs and six rejecting controls |

Machine-readable bindings: [INVARIANT_BINDINGS.json](INVARIANT_BINDINGS.json).
Computed receipts: [verification/invariant-legibility/](verification/invariant-legibility/).
Interactive view: [02_ATLAS/index.html#invariant](02_ATLAS/index.html#invariant).

## BB: expose the structural witnesses

This new admission bridge computes syntax, source-lock, directed-operation,
exact-angle, glyph-correspondence and recovery witnesses. Bad endpoints,
keyword padding and label-only submissions are rejected. They are not assigned
passing marks for language describing geometric quality.

H/RR/GG/AA are the owner's structurally governed components. This increment
exposes concrete checks that an admission implementation can consume; it neither
rescales the permanent register nor invents historical component equations.
It does not claim that every existing BB call site already consumes this bridge.
See the machine binding's bb_admission section for that exact boundary.

## Existing formal evidence and repository roles

- [Independent structural ledger](https://github.com/johnstobey/Alien-math-decoded-2/blob/main/verification/STRUCTURAL_LEDGER.md): CRT, symmetries, affine permutations and recovery.
- [Station codec](https://github.com/johnstobey/Alien-math-decoded-2/blob/main/verification/STATION_CODEC.md): full permutation meanings, translation and decoding.
- [Canonical envelope](https://github.com/johnstobey/Alien-math-decoded-2/blob/main/verification/CANONICAL_ENVELOPE.md): state representation and naturality.
- Atlas: theorem/evidence inventory plus this inspectable worked implementation.
- Machine: source-bearing declarations and language/runtime compilation.
- z12z-Memory-Module: ring runtime, storage and provenance mechanisms.
- Recursiverse-Suite: state and geometry integration.
- Omni-Lattice-Suite: declared integration location; its present minimal README is not execution evidence.

The formal results and the new finite checks establish specified instances of
the same organizing principle. Their explicit bindings make the invariant inspectable,
reproducible and open to counterexample, rather than resting on a verbal assurance.

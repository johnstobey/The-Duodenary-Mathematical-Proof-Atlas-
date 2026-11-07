# Invariant relational geometry

**The primary object is one relational whole. Its differentiation articulates positions whose identities consist entirely in their places within the complete arrangement.**

The twelve-position organization is articulated as

\[
W \cong \mathbb Z/12\mathbb Z
\cong \mathbb Z/4\mathbb Z\times\mathbb Z/3\mathbb Z.
\]

These coordinates name internal relationships. They do not give positions an
identity independent of the whole. A reference and orientation belong to a
particular articulation, not to a privileged constituent from which the whole
is assembled.

## Constitutive differentiation

Four classes of three positions intersect three classes of four positions.
Every crossing contains exactly one position, and every position belongs to
exactly one crossing. This is differentiation within a complete field.

In a frame, x has determinations (x mod 4, x mod 3). Their unique conjunction is
x = 9a + 4b mod 12. Neither determination identifies a position by itself.
The cycle includes its relational organization; a bare count of four times
three does not specify its orientation or opposition.

## Internal relations

| Relation | Within the whole | Coordinate articulation |
|---|---|---|
| Succession S | Directed adjacency in one complete circuit | x ↦ x+1; (a,b) ↦ (a+1,b+1) |
| Opposition A | Complementary half-circuit pairing | A=S⁶; x ↦ x+6; (a,b) ↦ (a+2,b) |
| Reversal R_c | Exchange of orientation within the same arrangement | x ↦ c−x; R_c S R_c=S⁻¹ |
| Return | Closure of the complete differentiation | S¹²=id; no shorter positive return |

Opposition is fixed-point-free and involutive: every position belongs to a
pair, neither pole standing alone. Reversal is involutive and retains opposition:
R_c²=id and R_c A=A R_c. The reference-centered reversal articulates the two
determinations as (−a,−b).

Powers describe incidence around a complete circuit. They are not elapsed time,
commands to execute, or a causal sequence producing the whole.

## Co-present manifestations

A manifestation articulates the whole through the relationships intrinsic to
its medium. There is no privileged first medium and no architectural requirement
that one manifestation be produced from another.

| Manifestation | Articulation of belonging |
|---|---|
| Spatial | Interlacing, incidence, directed adjacency, antipodal pairing and closure |
| Type-theoretic | Position types, constitutive differentiation, symmetry identities and coherence |
| Dialogical | Mutually defining positions, opposed movements, reversal and return within one composition |
| Schema | Explicit declaration of the whole, its differentiations and its simultaneous relations |
| Module | A component's relational place, complementary roles and participation in the complete arrangement |

The formal manifestation does not constitute a tribunal outside the geometry.
The schema is not a sequence of workflow states. A module's architectural role
is not exhausted by a procedural account of what its implementation does.
A dialogue's structural articulation is not a count of twelve section labels.

**The invariant is the integrity of the complete organization through its distinct articulations.**
Each manifestation retains the constitutive crossing, circuit, opposition,
reversal and return. Their unity is structural, not a linear chain of causes
or a succession of code-level translations.

## Repository articulation

- [Whole](Duodenary/Relational/Whole.lean): an abstract inhabited cyclic whole,
  frames at every position, and unique fourfold–three-mode conjunctions.
- [Relations](Duodenary/Relational/Relations.lean): succession, opposition,
  reversal, closure and absence of premature return.
- [Manifestations](Duodenary/Relational/Manifestations.lean): spatial,
  type-theoretic and dialogical articulations of one relational signature.
- [Structural schema](schemas/relational/whole.schema.json): the declarative
  organization and co-present manifestation family.
- [Structural instance](schemas/relational/whole.json): the organization stated
  without a workflow, execution status or causal hierarchy.
- [Component relationships](docs/relational/COMPONENT_RELATIONS.md): how the
  repository's parts articulate the same whole.
- [File organization](STRUCTURE.md): locations and structural roles.

Earlier operational witnesses remain preserved under
[historical documentation](docs/relational/history/README.md). They are particular
engineering artifacts, not the primary definition of this architecture.

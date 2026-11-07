# Structural closure and admission relations

The primary constitutive crossing governs every admitted manifestation. The
following conditions are simultaneous obligations, not a causal production
sequence between media.

| Condition | Required relationship |
|---|---|
| Closed whole | Exactly the fourfold–three-mode crossing, with all twelve cells in their declared places |
| Register unity | Obsidian and Fulgurite identify the same crossing in every state |
| Declared relations | Succession, opposition, reversal with a bounded axis, or full return |
| Adjacency | Each neighboring state agrees with the relation joining it to the next |
| Complete expression | The state family has exactly one more member than its relation family |
| Compositional closure | Every finite expression retains grid distance and unique constitutive coverage |

## Formal closure

Closure.lean states the permutation identity R S R = S⁻¹ explicitly. Opposition
conjugates succession to itself. GridIntegrity includes preservation of cyclic
distance and unique exhaustive coverage of the 4×3 crossing; mere agreement of
cardinalities does not establish it. Algebraic proofs establish reversal and
opposition integrity. Composition closure follows by induction for arbitrary
finite expressions; no bounded profile substitutes for that theorem.

## Formal admission

Admission.lean proves pathGate=true if and only if ConstitutivePath. It also
proves that an admitted path's endpoint equals the full composite relation,
that every relation expression retains grid integrity, and that synchronization
holds through every composite. Empty state families, mismatched lengths and
broken adjacency are excluded. A single state with no relation is the identity
expression, not a claim of independent transfer or research completion.

## Inspect the structural manifestation

Build the native articulation:

    lake build relationalGate

Submit the provided manifestation:

    python3 scripts/structural_gate.py schemas/relational/synchronized-example.json

Inspect the canonical matrix or a station row:

    .lake/build/bin/relationalGate --matrix
    .lake/build/bin/relationalGate --row 11

The supported public admission entry is structural_gate.py: its strict textual
JSON boundary precedes the semantic Lean JSON gate. Native --check consumes a
JSON syntax tree; duplicate textual keys must be rejected by the public boundary.
Native --batch reports each case's admission separately; its exit 0 means the
batch was processed, not that every case was admitted. No command defines the
architecture's ontology. These are inspectable manifestations of its relations.

Evidence is preserved under verification/relational-synchronization/.

# Obsidian and Fulgurite: one constitutive crossing

The two registers are co-present articulations of W. Obsidian names the unique
fourfold–three-mode conjunction. Fulgurite names its station within the cycle.
Neither register has architectural priority.

| Articulation | Carrier |
|---|---|
| Obsidian | Fin 4 × Fin 3 |
| Fulgurite | Z/12Z |
| Canonical JSON state | [station, fourfold, mode] with mutually consistent determinations |
| Whole matrix | Four rows and three columns, with each cell at its unique crossing |

The equivalence is explicit: (a,b) corresponds to 9a+4b mod12; station x
corresponds to (x mod4,x mod3). Both round trips are identities. The Lean
register equivalence is an equivalence of typed structural states; it does not
identify proof terms with JSON bytes or declare arbitrary prose to be isomorphic.

## Internal synchronization

Synchronized(o,f) means o.crossing = crt(f.station). This holds exactly when
the register equivalence identifies o with f. Their actions are coherent for
each declared relation and for every finite compositional expression. A path's
order expresses adjacency; it does not confer causal priority on a manifestation.

## Structured JSON matrix

For example, station 11 is [11,3,2]. Its crossing is row 3, column 2, using
zero-based coordinates. The complete matrix is:

    [[[0,0,0], [4,0,1], [8,0,2]],
     [[9,1,0], [1,1,1], [5,1,2]],
     [[6,2,0], [10,2,1], [2,2,2]],
     [[3,3,0], [7,3,1], [11,3,2]]]

Each cell contains both register determinations; replacing a cell independently
violates its place in the whole. A theorem states that any typed matrix with
this constitutive property is the same matrix, cell by cell.

## Exact JSON scope

Registers.lean proves the actual Lean JSON row round trip for each station,
then constructs equivalences Fulgurite ≃ JsonState and Obsidian ≃ JsonState.
JsonState is exactly the canonical admissible semantic JSON image. The proof
uses the actual decoder and serializer. Whitespace, object-key order and proof
terms are not additional structural states. These equivalences lift cellwise to full 4×3 indexed matrices, with two inverse
identities proved by function extensionality. The constitutive matrix condition
then restricts the cells to their declared crossing. The whole matrix is a JSON array;
its presentation order names the crossing and is not a temporal sequence.

The executable JSON boundary rejects duplicate object keys, non-finite numbers,
extra fields and noncanonical state declarations. There is no accepting fallback
when the Lean gate is unavailable. The complete 157-definition register and all
existing Dewey strings remain unchanged: these are typed adapters for the
structural subset, not replacements for the original declarations or languages.

Lean: Duodenary/Relational/Registers.lean and Admission.lean.
Schema: schemas/relational/register-manifestation.schema.json.
Example: schemas/relational/synchronized-example.json.

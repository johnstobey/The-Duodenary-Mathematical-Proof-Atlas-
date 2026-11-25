# Architecture tiers — computation, proof, consumption

Version: `arch-tiers-v1` · Date: 2026-11-25 · Status: owner decision recorded

Authority: owner directive, 2026-11-25 — the canonical computation tier remains
canonical; the Atlas proof tier sits above it; the CP series is algebra-first
by intention, not drift.

## 1. The three tiers

| Tier | Owner | Contents | Status |
|---|---|---|---|
| Computation | External canonical pipeline (private; not redistributed here) | Corpus-to-structure extraction; emits `z12x/1` GeometryIR documents and derived tabular artifacts | Canonical — single source |
| Proof | This repository | Kernel-verified Z/12 ring structure: `closed_ring_z12_mathlib/*`, `Duodenary/Bridges/*`; serialized schema `cp01-interface-v1` | Canonical proof surface |
| Consumption | Sibling repositories | Verified adapters pinned to schema + shared fixtures: Recursiverse-Suite (Python), Machine and z12z-Memory-Module (Rust), Ravenproofs (specification), Alien-* (certified consumers) | Adapters, not sources |

## 2. What this repository does not do

- Does not re-implement the computation tier. Atlas consumes its *outputs* —
  `z12x/1` documents and `geometry/cp04_e2e_fixture.json` — as pinned artifacts.
- Does not assign semantic roles (cipher structure, geometric mappings,
  narrative interpretation) to coordinates. Algebra-first scope is deliberate:
  the CP series certifies ring structure, operators, and interfaces — not the
  semantics the computation tier derives.
- Does not treat finite-cardinality agreement as isomorphism (AGENTS.md).

## 3. Interface surfaces

- `cp01-interface-v1` — pair-space serialized schema
  (`formalization/CP01_INTERFACE_CONTRACT.md`, kernel surface
  `closed_ring_z12_mathlib/PairSpace144.lean`).
- `CP04-E2E/1` — three-implementation agreement fixture
  (`geometry/cp04_e2e_fixture.json`), consumed by Machine and
  z12z-Memory-Module test suites.
- `z12x/1` — upstream document schema, reached through the Recursiverse
  `artifacts/geometry_ir/` reader.

## 4. Rules for new work

1. New theorems cite kernel declarations; new consumers pin schema versions.
2. No consumer re-proves Atlas theorems — cite declaration names instead.
3. No Atlas module re-derives computation-tier semantics.
4. Independent reimplementation is permitted only as verification evidence
   (the shared-fixture pattern), never as a second canonical source.

## 5. Decision record

- 2026-11-25: owner confirmed the computation tier remains canonical and the
  proof tier sits above it; algebra-first scope for the CP series is
  intentional. Semantic-integration questions are deferred to a future owner
  decision rather than silently absorbed into CP items.

# CRITICAL PATH — Mathlib Ring Closure → Geometry → Engineering

Date: 2026-11-22
Authority: task sequencing index, not a mathematical proof or experimental certification.
Canonical queue: [GitHub Issues](https://github.com/johnstobey/The-Duodenary-Mathematical-Proof-Atlas-/issues). Claimable issues are unassigned until an agent or collaborator claims and is accepted by the owner.

## Dependency DAG

```text
P0 CP-00 #5 Mathlib CRT ring equivalence
   ↓
P1 CP-01 #6 canonical 4×3 / 12 / J / 144-coordinate schema
   ├─────────────────────────────→ P2 CP-04 #9 downstream adapters
   │
   └──→ P2 CP-03 #8 hue/geometry layered interface
            ↑
P1 CP-02 #7 original-art graph extraction, invariant tests ──→ P3 CP-05 #10 physical and computational simulations

P1 CP-06 #11 cross-repo queue / evidence synchronization runs immediately in parallel
```

Critical dependency chain: #5 → #6 → #8 (with #7) → #10.
Parallel value delivery: #7 source extraction and #11 coordination begin now; #9 nonvisual consumers begin after #6. CP-05 is not a prerequisite for certified mathematical software.

## P0 — Mathlib CRT: exact acceptance

Use a pinned Lean 4 + Mathlib environment and the actual type/API exposed by the pin. Expected target:
`ZMod.chineseRemainder (by decide : Nat.Coprime 4 3) : ZMod 12 ≃+* ZMod 4 × ZMod 3`.
Check the exact declaration in the pinned Mathlib version rather than assuming the signature. Preserve existing core-only bounded Nat `closed_ring_z12/ClosedRingZ12.lean` and its `CRTIso`, but publish an explicit bridge to canonical Mathlib `RingEquiv`. Cover forward/reverse maps, preserved operations, reconstructed `9u+4v`, `J(k)=k+6`, full successor orbit length twelve, and `#print axioms` plus CI receipts. Pass only upon independent replay, not merely existence of a source file.

## Structural interpretation of submitted colored circle

Geometric state `k ∈ ZMod 12`, at angle `theta=30°k`. Antipode `J(k)=k+6`. Outer labels show `(k,(k+6) mod 12)`. This **is not** the CRT coordinate pair, which is `(k mod 4, k mod 3)`. There are 144 ordered state pairs `(k,l)`, 6 unordered antipodal pairs `{k,k+6}`, and 12 positions. Hue is another coordinate only if defined independently; 12×12=144 is available for a separately discretized 12-hue state, whereas `h=k` has only 12 allowable pairs. The graphic is not, by itself, evidence of physical device operation.

## Reuse map

- [Proof Atlas](https://github.com/johnstobey/The-Duodenary-Mathematical-Proof-Atlas-): authoritative Lean interface, `closed_ring_z12`, established `roadmap/queue/tasks.json`, verified-build artifacts.
- [Ravenproofs](https://github.com/johnstobey/Ravenproofs): `projects/tobey-relational-decoder/03_specifications/CRT_RING_CONTRACT.md`; existing claim workflow `coordination/README.md`, contracts and agent ownership. Image tasks RVC-EXEC-20261113-002 and RVC-IMG-20261115-011 already exist. Avoid duplicate agent ownership. Do not describe the Ravenproofs workflow as managing Atlas issues.
- [Recursiverse-Suite](https://github.com/johnstobey/Recursiverse-Suite): existing JS/native canonical kernel, geometry and governance tests; consumer adapter.
- [Machine](https://github.com/johnstobey/Machine): Lean formalization, sentence decoding, and formal-verify CI; consumer adapter.
- [Alien-math-decoded-2](https://github.com/johnstobey/Alien-math-decoded-2): IndependentDuodenary Lean packages and CI; consumer/counterexample tests.
- [Alien-Math-Duodenary-Closure](https://github.com/johnstobey/Alien-Math-Duodenary-Closure): Z144 and closure bridge; consumer.
- [z12z-Memory-Module](https://github.com/johnstobey/z12z-Memory-Module): Rust ledger and memory; serialized state consumer.
- [tobey-resolution](https://github.com/johnstobey/tobey-resolution): existing `geometric/blueprint_deliverables` with QuTiP, Meep, two Lean files and manifest. A topological-transport theorem relies on an explicit physical axiom; separate this from derived mathematics and test numerically.
- [lattice-images-](https://github.com/johnstobey/lattice-images-): original image source inventory and geometry-extraction feed.
- [oversight](https://github.com/johnstobey/oversight): provenance / independent review; not the math kernel source.
- [Omni-Lattice-Suite](https://github.com/johnstobey/Omni-Lattice-Suite) and [Machine-Artifacts-](https://github.com/johnstobey/Machine-Artifacts-): minimal current trees; integrate only after interfaces are stable to avoid creating duplicate source-of-truth projects.

## Blueprint provenance and engineering differentiation

The uploaded DeepSeek *Geometric Blueprint System* transcript develops a text-only v2.0 proposed cryogenic topological metamaterial specification, plus Python QuTiP / Meep scripts, Lean models, runbook, FMEA and JSON config. Its final handoff explicitly says there was no local compilation, numeric solving, or fabrication/experimental validation. Treat as proposed candidate designs with testable predictions. The ring proofs cannot establish quantum topology, hardware performance, energy gain, or engineering feasibility. Record which assumptions are explicit axioms. Use baselines and a reproducible numerical simulation suite before fabrication proposals.

## Task and evidence ledger protocol

Use existing GitHub **Issues** as the primary operational queue rather than introducing a second task database. Allowed task progression: OPEN (unassigned) → CLAIMED (accepted owner) → IN PROGRESS → VERIFY (independent receipt attached) → ACCEPTED (owner closes issue). Reopen on regression. Each issue must link its blocking issue(s), output path, input versions/hashes, implementation SHA, CI run, reviewer and acceptance decision. Existing Atlas `roadmap/queue/tasks.json` remains a research-scoring queue and `roadmap/graph/dependencies.json` remains the prior graph; neither is silently overwritten. Existing Ravenproofs `coordination/claims.json` is a separate contract ownership registry and should only be extended via its documented workflow.

### Issues ready for pickup

- [#5 CP-00 CRT Mathlib closure](https://github.com/johnstobey/The-Duodenary-Mathematical-Proof-Atlas-/issues/5) — P0, no dependency.
- [#7 CP-02 image extraction](https://github.com/johnstobey/The-Duodenary-Mathematical-Proof-Atlas-/issues/7) — P1, independent preparatory work.
- [#11 CP-06 ledger integration](https://github.com/johnstobey/The-Duodenary-Mathematical-Proof-Atlas-/issues/11) — P1, independent operational work.
- [#6 CP-01 canonical interface](https://github.com/johnstobey/The-Duodenary-Mathematical-Proof-Atlas-/issues/6) — blocked by #5.
- [#8 CP-03 color layer](https://github.com/johnstobey/The-Duodenary-Mathematical-Proof-Atlas-/issues/8) — blocked for acceptance by #6 and #7.
- [#9 CP-04 consumers](https://github.com/johnstobey/The-Duodenary-Mathematical-Proof-Atlas-/issues/9) — blocked by #6.
- [#10 CP-05 engineering simulations](https://github.com/johnstobey/The-Duodenary-Mathematical-Proof-Atlas-/issues/10) — blocked by #7, and #8 where color is used as a modeled input.

The working repository is not directly modified by this planning index. Actual code changes require separate, verified PRs.

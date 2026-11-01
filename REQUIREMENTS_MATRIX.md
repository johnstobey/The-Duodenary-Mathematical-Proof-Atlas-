# 182-slot coverage matrix

The handoff provides grouped ID ranges, not 182 original atomic statements. registry/requirements.json expands numbering with explicit null original wording. These slots are traceability records, not invented completed requirements.

**Grounding audit 2026-11-01 (UTM-ALIGN-5R-01):** every evidence file below was verified to
exist and its content measured. "Partial; exact individual wording unavailable" remains the
honest status of the *original wording* — that gap is real and is not papered over. What the
audit adds is verified, machine-checkable evidence status per row. The mathematical core
(row 11–30) is additionally machine-verified: `lake build` completed with 0 errors
(UTM-ALIGN-5R-01 Chunk 2, LEAN_BUILD_VERIFICATION.md) and its operators carry executed
cross-repo preservation witnesses (CHUNK4_OPERATOR_RECONCILIATION/, 19/19 accepted;
R3 extension 8/8 accepted).

| IDs | Area | Evidence | Grounding (audited) | Status |
|---|---|---|---|---|
| 1–10 | recognition | [research/history/RECOGNITION.md](research/history/RECOGNITION.md) | EXISTS, 1 section | Partial; exact individual wording unavailable |
| 11–30 | mathematical core | [Duodenary/Core/Cyclic.lean](Duodenary/Core/Cyclic.lean) | EXISTS, 47 defs+theorems, **lake build 0 errors, 19+8 cross-repo witnesses** | Partial wording; **content machine-verified** |
| 31–41 | original research migration | [verification/source-audits/MIGRATION.md](verification/source-audits/MIGRATION.md) | EXISTS, 1 section | Partial; exact individual wording unavailable |
| 42–60 | Clearing and Alignment | [research/clearing/BLOCKED.json](research/clearing/BLOCKED.json) | EXISTS, dict 12 entries | Partial; exact individual wording unavailable |
| 61–73 | external catalogue | [sources/metadata/OPENAI_PIN.json](sources/metadata/OPENAI_PIN.json) | EXISTS, dict 14 entries | Partial; exact individual wording unavailable |
| 74–88 | frontier registry | [registry/problems/frontier.json](registry/problems/frontier.json) | EXISTS, list 42 entries | Partial; exact individual wording unavailable |
| 89–97 | institutional rules | [research/institutions/CLAY.md](research/institutions/CLAY.md) | EXISTS, 1 section | Partial; exact individual wording unavailable |
| 98–112 | Geometric Imperative | [research/geometric-imperative/SYNTHESIS.md](research/geometric-imperative/SYNTHESIS.md) | EXISTS, 1 section | Partial; exact individual wording unavailable |
| 113–130 | artifact dossiers | [registry/artifacts/index.json](registry/artifacts/index.json) | EXISTS, list 11 entries | Partial; exact individual wording unavailable |
| 131–158 | governance and roadmap | [roadmap/ROADMAP.md](roadmap/ROADMAP.md) | EXISTS, 1 section | Partial; exact individual wording unavailable |
| 159–166 | pyramid | [artifacts/ontological/pyramid/DOSSIER.md](artifacts/ontological/pyramid/DOSSIER.md) | EXISTS, 17 sections | Partial; exact individual wording unavailable |
| 167–174 | Aztec control | [artifacts/ontological/aztec-calendar/DOSSIER.md](artifacts/ontological/aztec-calendar/DOSSIER.md) | EXISTS, 17 sections | Partial; exact individual wording unavailable |
| 175–182 | disclosure continuity | [verification/source-audits/MIGRATION.md](verification/source-audits/MIGRATION.md) | EXISTS, 1 section | Partial; exact individual wording unavailable |

## Audit summary

- **12/12 unique evidence files exist** on disk with non-trivial content (was previously
  unverified: the matrix asserted pointers without existence evidence).
- **0 files fabricated, 0 wording invented.** The unavailable-wording gap is preserved
  exactly as stated in the original handoff.
- **Row 11–30 (mathematical core) is now the strongest row**: content compiles (0 errors),
  theorem registry matches (104 == 104, Gate 0), and every core operator family
  (antipode, rotation, inversion, CRT, distance, affine, group closure) carries an
  executed cross-repository preservation witness with full-vector domains.
- Remaining honest limitation: rows outside the mathematical core point at narrative
  evidence files whose *individual original statements* cannot be recovered from the
  handoff; traceability is at row (area) level, not per-slot wording.

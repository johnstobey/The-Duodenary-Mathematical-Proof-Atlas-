# Shared harmonic execution verification baseline

This self-contained fixture recomputes the root `verification_ledger.json` from the preserved legacy harmonic formulas and antipodally closed subsets of Z/12Z. It contains no source documents, private archives, credentials, or runtime caches.

Run from the repository root:

```
python3 -m pytest tests/harmonic_execution_baseline/ --tb=short
```

A standard-library alternative is:

```
python3 tests/harmonic_execution_baseline/test_verification_ledger.py
```

The ledger records six fixed points, 23 canonical cycles, 72 scalar outputs, 144 scalar states, 64 closed masks and 4,096 ordered mask pairs. Tests derive those counts rather than accepting a printed success label. They also check exact fixed points, scalar parity, pair-vector distinctness, cycle-entry/repetition bounds and closure of every mask intersection.

Scope: this is the same shared legacy-model baseline across repositories. It does not claim that unrelated repository implementations share those dynamics, establish course provenance, prove empirical Alignment efficacy, or replace the repository's own build and test requirements.

Recorded originating research checkpoint: `2b15b48889feeff3834b34427c7d88dff1152c59` (local harmonic execution research). The fixture is independently executable without that repository.

# ATLAS-WORKBENCH-01

Run `python3 03_ENGINE/serve_atlas.py` and open
http://localhost:8765/02_ATLAS/index.html . The server binds loopback only.
The workbench is self-contained and needs no Internet assets or JavaScript libraries.
Opening 02_ATLAS/index.html directly works in browsers permitting file URLs;
managed browsers may require the supplied local server.

The original 157 algorithms, canonical files, 25 scene definitions, 84 finite
fixtures and 22 JPEG assets are preserved. The imported PACKAGE_SHA256_MANIFEST.json
remains the original distribution manifest, not a claim that edited implementation
files are byte-identical to the starter. A separate delivery manifest hashes this revision.

## Implemented workbench features (obligation 1)

Directed SVG angular arcs are calculated from actual finite ring transitions.
A zero-step operation has zero arc length; opposition has a 180-degree arc.
Manual T/A/I/rho controls record actual before/after states with reversible
history; a new operation after undo truncates only the abandoned future branch.
Scene state remains the supplied deterministic fixture selection; reversing scroll
replays the same fixture. Square-to-diamond presentation does not redefine ring arithmetic.

All 144 cells support click and arrow/Home/End keyboard selection, synchronized
with domain/modality selectors and aria-selected. The source record viewer preserves
all English/math/Dewey strings, adds register citations, and uses semantic buttons.
Seal captions expose available source-defined attributes without inventing missing
CMD/LOG fields. Every scene links its original definition and finite trace fixture.
Skip navigation, reduced motion, narrow layout and visible focus are supported.

## Runtime adapter (obligation 2)

See 03_ENGINE/adapters/README.md for the precisely typed Fulgurite subset,
recovered glyph source, ALG-001 binding and unsupported forms. Example:

    python3 03_ENGINE/adapters/fulgurite.py '☉♈ □ ☉♋'

This is a new adapter, not a replacement or claim of complete 31-glyph language
coverage. It independently checks the canonical SHA on every call.

## Tests and evidence (obligation 3)

    python3 04_TESTS/verify_canonical.py
    python3 04_TESTS/test_engine.py
    python3 04_TESTS/test_adapter.py
    python3 04_TESTS/test_browser.py

Browser tests require Python Playwright and Chromium at /usr/bin/chromium.
They serve the package on an ephemeral loopback port and block nonlocal requests.
Receipts preserve stdout/stderr verbatim, failures, source hashes and exit codes.
Browser checks cover all 25 scenes in both scroll directions, 84 angular traces,
144 lattice addresses, 157 displayed canonical records, operation history, source
links, all images, mobile width, reduced motion and keyboard interactions.

The executing agent reports observed results; it does not act as the independent
verifier or grant its own engineering PASS. Green execution and unchanged source
lock are submitted for integration review.

# Fulgurite finite angular adapter — ATLAS-WORKBENCH-01 / obligation 2

Run `python3 03_ENGINE/adapters/fulgurite.py '☉♈ □ ☉♋'` from the package root.
This new typed adapter binds to locked ALG-001 (12 positions, 30 degrees per step).
It does not assert that ALG-001 contained an executable Fulgurite program.
The glyph tables are recovered from the unmodified `fulgurite_lexer_reference.rs`.
Original private path: projects/dual-ring-research/codex/recovered-native/adapted/fulgurite_lexer.rs.
The supported subset restricts planets to Sun: the recovered parser assigns Sun
zero sub-degree offset, making the finite projection exact. Aspect C–I map to
0–6 steps; only their Unicode glyphs are accepted by this adapter. Nodes, house
bindings, other planets, shorthand and multi-statement programs are outside this
adapter's type and rejected. Directed right-operand consistency is an added
adapter constraint. No canonical identity, field, score or opcode is changed.
Each call verifies the canonical lock before executing and returns a typed trace.

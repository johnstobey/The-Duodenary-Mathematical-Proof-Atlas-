# Registry source audit

**Verified directly (web text):** Clay 2018 rules PDF §§3–8 and seven-problem listing; OpenAI math live README reporting 721 manuscripts, 373 families, approximately 42% top-line Lean formalizations; formal-conjectures repository README; mathlib4 repository; arXiv 2605.13171 and 2605.22763; OpenAI announcements dated 2026-09-08 and 2026-10-26.

**Snapshot conflict:** OpenAI launch 2026-10-06 and discussion cited 722 manuscripts / 372 families, while a fetched live README displays 721 / 373. No commit SHA pinned; do not present snapshot counts as immutable.

**Incomplete acquisition:** Could not clone GitHub within container because DNS/network access unavailable. Consequently the entire manuscript map, each original manuscript, Lean kernel log, history and revisions were **not** enumerated or audited.

**Primary-source limitations:** For non-Clay candidate statements this is a screening corpus. Shared links to Formal Conjectures are *project-level starting sources*, not individually verified source locators. Individual primary literature, exact original dates, formalized statement IDs, and partial-results audit remain REQUIRED. Any registry property saying `statement_needs_primary_problem_locator` is a deliberate failing audit flag.

**Verification tier rules:** (a) source-primary status evidence; (b) precise problem statement checked against original; (c) proof text acquired; (d) Lean source mapped to theorem with assumptions; (e) reproducible pinned-toolchain clean build; (f) independent mathematical audit. This run establishes (a) for selected headline claims, not (b–f) generally.

**Source URLs:**
- https://www.claymath.org/millennium-problems/
- https://www.claymath.org/wp-content/uploads/2022/03/millennium_prize_rules_0.pdf
- https://github.com/openai/math
- https://openai.com/index/sharing-ai-progress-in-mathematics/
- https://openai.com/index/navier-stokes-solution/
- https://openai.com/index/building-scientific-understanding-with-academic-communities/
- https://github.com/google-deepmind/formal-conjectures
- https://github.com/leanprover-community/mathlib4
- https://arxiv.org/abs/2605.13171
- https://arxiv.org/abs/2605.22763

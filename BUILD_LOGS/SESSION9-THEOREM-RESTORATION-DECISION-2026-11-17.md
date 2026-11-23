# SESSION 9 — Theorem Restoration Decision Record (2026-11-17)

**Verdict: STOP invoked per ABSOLUTE RULE. All four disputed theorems are FALSE as stated.
`Duodenary/Core/Rational.lean` left untouched (GREEN, 0 sorry, 47 theorem names).**

## The four statements (verbatim from 979cd79)

    @[simp] theorem Q.num_add (a b : Q) :
        (a + b).num = a.num * ↑b.den + b.num * ↑a.den := rfl
    @[simp] theorem Q.den_add (a b : Q) : (a + b).den = a.den * b.den := rfl
    @[simp] theorem Q.num_mul (a b : Q) : (a * b).num = a.num * b.num := rfl
    @[simp] theorem Q.den_mul (a b : Q) : (a * b).den = a.den * b.den := rfl

## Why they are unreachable

Both HEAD (`979cd79`) and the current working file define `Add`/`Mul` via the gcd-reducing
smart constructor `Q.mkRat`. `mkRat n d` divides both parts by `n.natAbs.gcd d`. Each claim
above asserts the raw cross-product is already reduced — false in general.

Machine-checked counterexamples (`/tmp/q_counterexample.lean`, `lake env lean`, exit 0;
kernel accepted all four `by decide` disproofs):

| Statement instance            | LHS | RHS |
|-------------------------------|-----|-----|
| `(1/2 + 1/2).num`             | 1   | 4   |
| `(1/2 + 1/2).den`             | 1   | 4   |
| `(2/3 * 3/2).num`             | 1   | 6   |
| `(2/3 * 3/2).den`             | 1   | 6   |

## Audit-premise corrections

1. HEAD file was never green. Standalone build of
   `git show 979cd79:Duodenary/Core/Rational.lean` fails with dozens of errors, including
   `type mismatch` at lines 172–175 — exactly these four `rfl` proofs (Lean: `rfl` has type
   `(a+b).num = (a+b).num`, not the claimed equation). Commit message itself: "in-progress
   ... (70/39 errors)".
2. Name count: HEAD has **48** unique theorem names, not 51. Current file: 47.
   47 + 4 − 3 (private helpers `mkRat_num_pos`, `mkRat_num_nonneg`, `mulCommAux` are
   NEW in the working file, absent at HEAD) = 48. The audit's "47+4=51" does not match git.

## Remediation options (require principal decision — statement changes are not authorized)

- (a) Accept 47-name file as correct (the "deletions" removed false claims).
- (b) Re-add TRUE normalization lemmas under NEW names, e.g. provable by
  `num_mkRat`/`den_mkRat` + gcd machinery:
      `(a + b).num = (a.num * ↑b.den + b.num * ↑a.den).tdiv ↑g`,
      `g * something`-form coprimality/fraction lemmas, where `g` is the raw gcd.
- (c) Redefine `Add`/`Mul` without reduction and keep the four statements true —
  breaks the reduced-representation design (`Q.reduced` field).

Scratch evidence files: `/tmp/rational_orig_test.lean`, `/tmp/q_counterexample.lean`.

# CP-03 (#8) — Hue coordinate layer v1

Date: 2026-11-24 · Agent: jjcav84/Devin
Checker: `scripts/check_hue_layer.py` → **14/14 PASS, exit 0**
Artifacts: `geometry/hue_layer_v1.json` (schema + results), `geometry/hue_overlay_v1.svg` (reproducible figure)

## The issue's core question, answered executably

Is hue `h` a function of position `k`, or independent?

| Case | Definition | Accessible pairs | Structure |
|---|---|---|---|
| A | `h = k` | **12** | diagonal of Z/12×Z/12 |
| B | `h = k + c`, any c∈Z/12 | **12** | coset — offset is gauge, adds zero states (12 distinct offset graphs verified disjoint) |
| C | `h` independent | **144** | full product Z/12×Z/12 |

Case C's 144 is the **product**, not Z/144: executable exponent witness — every product element has order dividing 12 (max element order = 12), while Z/144 has order-144 elements. Consistent with the certified `product_exponent`/`cyclic144_not_exponent12` in `Duodenary.Core.Cyclic`. The two 144s must not be merged without a bijection — none exists.

## Operator results (all verified)

- Position antipode `J: k→k+6` and hue antipode `h→h+6`: each gives 6 fixed-point-free pairs; combined `(k,h)→(k+6,h+6)` is a fixed-point-free involution on all 144.
- Position successor acts on `k` only — 12-cycles per hue fiber.
- Hue cyclic distance `min(d,12−d)` ∈ {0..6}, symmetric, attains all values (mirrors `cyclicDistance`).
- Grayscale projection `π(k,h)=k`: surjective, kernel = exactly the 12 hue-only states — removing hue leaves position geometry invariant by construction.
- Inversion `(k,h)→(−k,−h)` involution on the product.

## Genuinely new distinguishable information

Independent hue adds **132 states beyond the diagonal** (144−12). Whether hue *is* independent is a modeling choice — **no corpus evidence assigns hue independently**; cases A/B are the only ones supported by `h=f(k)` evidence. The schema records this explicitly rather than asserting C. **Update 2026-11-27:** an executed corpus probe (`geometry/CP03_HUE_CORPUS_PROBE.md`) found the lattice-image corpus hue-monochromatic (all dominant hues 35–72°, h≈1–2) with no sector→hue correlation (permutation p=0.069) — the caveat is now an executed negative, not just an absence of evidence.

## Reproduce

```bash
python3 scripts/check_hue_layer.py   # 14/14, exit 0; rewrites JSON + SVG
```

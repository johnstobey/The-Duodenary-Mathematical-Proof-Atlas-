# Preserved browser execution failures — obligation 3

1. Chromium local socket creation denied in sandbox. Rerun with reviewed process permission.
2. Managed Chromium blocks file URLs. Change test transport to loopback HTTP and reject nonlocal requests.
3. Browser-specific SVGPoint.toJSON absent; actual 320px overflow found. Keep assertions, access x/y directly; fix CSS wrapping/control widths.
4. Mobile layout assertions pass. Skip-link assertion tested after scene-anchor scrolling had altered browser sequential focus origin. Move identical initial-navigation assertion before scrolling.
5. All eight tests pass. No canonical files or original acceptance tests modified. All earlier stdout/stderr and pre-correction harness versions retained.

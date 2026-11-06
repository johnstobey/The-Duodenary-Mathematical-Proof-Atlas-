#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
python3 04_TESTS/verify_canonical.py
exec python3 03_ENGINE/serve_atlas.py

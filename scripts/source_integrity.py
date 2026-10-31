#!/usr/bin/env python3
"""Check released immutable baseline files against their original byte hashes."""
from pathlib import Path
import json,hashlib
ROOT=Path(__file__).resolve().parents[1]
def main():
    baseline=json.loads((ROOT/'sources/metadata/DPA_FRONTIER_01.json').read_text())
    for row in baseline['manifest']:
        p=ROOT/'sources'/row['path']
        assert p.is_file(),p
        assert p.stat().st_size==row['bytes']
        assert hashlib.sha256(p.read_bytes()).hexdigest()==row['sha256'],p
    handoff=json.loads((ROOT/'sources/metadata/HANDOFF_MANIFEST.json').read_text())
    original=next(r for r in handoff if r['path']=='CONSTITUTION.md')
    assert hashlib.sha256((ROOT/'CONSTITUTION.md').read_bytes()).hexdigest()==original['sha256']
    print('PASS: ten exact original frontier files and unchanged proposed constitution')
if __name__=='__main__':main()

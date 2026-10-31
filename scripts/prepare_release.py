#!/usr/bin/env python3
"""Refresh candidate file listing and nonrecursive content hash manifest."""
from pathlib import Path
import subprocess,hashlib
ROOT=Path(__file__).resolve().parents[1]
def main():
    names=sorted(set(n.decode() for n in subprocess.check_output(['git','ls-files','-co','--exclude-standard','-z'],cwd=ROOT).split(b'\0') if n))
    rows=[]
    for name in names:
        p=ROOT/name
        if name=='verification/CONTENT_SHA256SUMS' or not p.is_file():continue
        rows.append(hashlib.sha256(p.read_bytes()).hexdigest()+'  '+name)
    (ROOT/'verification/CONTENT_SHA256SUMS').write_text('\n'.join(rows)+'\n')
    print(f'Hashed {len(rows)} release files (manifest excludes itself)')
if __name__=='__main__':main()

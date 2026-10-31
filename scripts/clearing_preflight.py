#!/usr/bin/env python3
"""Validate original frozen inputs before a Clearing trial can be scheduled."""
from pathlib import Path
import argparse,json,hashlib,sys
def validate(manifest,base):
    assert set(manifest['conditions'])=={f'C{i}' for i in range(4)}
    assert set(manifest['perturbations'])=={f'P{i}' for i in range(1,6)}
    assert set(manifest['recovery'])=={f'R{i}' for i in range(3)}
    assert len(manifest['benchmarks'])==7
    assert manifest['planned_trials']==84
    records=list(manifest['conditions'].values())+list(manifest['perturbations'].values())+list(manifest['recovery'].values())+manifest['benchmarks']+[manifest['model'],manifest['scorer']]
    assert len({b['path'] for b in manifest['benchmarks']})==7
    for row in records:
        path=(base/row['path']).resolve()
        assert path.is_relative_to(base.resolve()),'frozen input escapes manifest directory'
        assert path.is_file(),path
        assert hashlib.sha256(path.read_bytes()).hexdigest()==row['sha256'],path
    assert manifest['source_provenance'] and manifest['trial_design']
    return {'status':'INPUT_HASHES_VERIFIED','model_executed':False,'scored_primary_trials':0,'planned_trials':84}
def main():
    p=argparse.ArgumentParser();p.add_argument('--manifest',type=Path);args=p.parse_args()
    if args.manifest is None:
        print(json.dumps({'status':'BLOCKED','reason':'Original frozen manifest, trial design and verified model are absent. No primary trial executed.','scored_primary_trials':0,'planned_trials':84}));return 2
    print(json.dumps(validate(json.loads(args.manifest.read_text()),args.manifest.parent)));return 0
if __name__=='__main__':sys.exit(main())

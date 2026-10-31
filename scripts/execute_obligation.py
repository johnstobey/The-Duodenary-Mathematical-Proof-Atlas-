#!/usr/bin/env python3
"""Execute an explicitly registered local proof target and verify its expected symbols.
This runner never executes a command extracted from a paper or model transcript.
"""
from pathlib import Path
from datetime import datetime,timezone
import argparse,subprocess,json,hashlib,sys
ROOT=Path(__file__).resolve().parents[1]
def main():
    p=argparse.ArgumentParser();p.add_argument('--task',required=True);p.add_argument('--out',type=Path,default=ROOT/'.lake/obligation-runs');args=p.parse_args()
    targets=json.loads((ROOT/'registry/execution_targets.json').read_text())
    if args.task not in targets:
        print(json.dumps({'status':'BLOCKED','task':args.task,'reason':'No reviewed executable local target; source/proof construction remains required.'}));return 2
    target=targets[args.task];out=args.out/args.task;out.mkdir(parents=True,exist_ok=True);commands=[['lake','build',target['module']],[sys.executable,'scripts/audit_lean.py','--check']];runs=[]
    for i,command in enumerate(commands):
        log=out/f'command-{i}.log';start=datetime.now(timezone.utc).isoformat()
        with log.open('w') as stream:r=subprocess.run(command,cwd=ROOT,stdout=stream,stderr=subprocess.STDOUT)
        runs.append({'command':command,'started_at':start,'returncode':r.returncode,'log':log.name,'sha256':hashlib.sha256(log.read_bytes()).hexdigest()})
        if r.returncode:break
    proofs={r['lean_name']:r for r in json.loads((ROOT/'registry/theorems/theorems.json').read_text())}
    passed=all(r['returncode']==0 for r in runs) and len(runs)==2 and all(n in proofs for n in target['expected_theorems'])
    report={'task':args.task,'status':'KERNEL_VERIFIED' if passed else 'FAILED','expected_theorems':target['expected_theorems'],'checks':runs,'statement_records':[proofs[n]['id'] for n in target['expected_theorems'] if n in proofs],'publication':'candidate until an actual successful push is recorded'}
    (out/'RUN.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({'task':args.task,'status':report['status'],'theorems':len(report['statement_records'])}));return 0 if passed else 1
if __name__=='__main__':sys.exit(main())

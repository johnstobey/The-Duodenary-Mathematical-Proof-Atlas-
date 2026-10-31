#!/usr/bin/env python3
"""Run the local acceptance commands and preserve each real exit code and log."""
from pathlib import Path
from datetime import datetime,timezone
import argparse,subprocess,hashlib,json,sys
ROOT=Path(__file__).resolve().parents[1]
def main():
    parser=argparse.ArgumentParser();parser.add_argument('--out',type=Path,default=ROOT/'.lake/reproduce');args=parser.parse_args();args.out.mkdir(parents=True,exist_ok=True)
    commands=[('lean-build',['lake','build']),('axiom-audit',[sys.executable,'scripts/audit_lean.py','--check']),('finite-controls',[sys.executable,'scripts/finite_checks.py','--check']),('evidence-tests',[sys.executable,'-m','unittest','discover','-s','tests','-v']),('schema-status',[sys.executable,'scripts/validate.py']),('roadmap',[sys.executable,'scripts/roadmap.py','--check'])]
    rows=[]
    for name,command in commands:
        start=datetime.now(timezone.utc).isoformat();log=args.out/(name+'.log')
        with log.open('w') as stream:result=subprocess.run(command,cwd=ROOT,stdout=stream,stderr=subprocess.STDOUT)
        rows.append({'name':name,'command':command,'cwd':str(ROOT),'started_at':start,'completed_at':datetime.now(timezone.utc).isoformat(),'returncode':result.returncode,'log':log.name,'log_sha256':hashlib.sha256(log.read_bytes()).hexdigest()})
        print(name,result.returncode,flush=True)
    report={'status':'PASS' if all(r['returncode']==0 for r in rows) else 'FAILED','checks':rows,'scope':'local candidate validation, not external manuscript proof review or publication'}
    (args.out/'RUN.json').write_text(json.dumps(report,indent=2)+'\n');return 0 if report['status']=='PASS' else 1
if __name__=='__main__':sys.exit(main())

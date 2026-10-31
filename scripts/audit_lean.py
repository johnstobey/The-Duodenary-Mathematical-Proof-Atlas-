#!/usr/bin/env python3
"""Elaborate every Atlas theorem; record statements, used constants and axioms."""
from pathlib import Path
from datetime import datetime,timezone
import subprocess,hashlib,re,json,sys,argparse
ROOT=Path(__file__).resolve().parents[1]
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
    parser=argparse.ArgumentParser();parser.add_argument('--check',action='store_true');args=parser.parse_args()
    declarations=[]
    for source in sorted((ROOT/'Duodenary').rglob('*.lean')):
        text=source.read_text()
        assert not re.search(r'\b(sorry|admit|native_decide|axiom)\b',text),source
        for m in re.finditer(r'^theorem\s+(\w+)(.*?)\s*:=',text,re.M|re.S):
            declarations.append((source,m[1],('theorem '+m[1]+m[2]).strip()))
    commands=['import Duodenary','import Lean.Util.FoldConsts']
    for _,name,_ in declarations:
        commands += [f'#check Duodenary.{name}',f'#print axioms Duodenary.{name}',f'run_cmd do\n  let env ← Lean.getEnv\n  let some ci := env.find? ``Duodenary.{name} | throwError "Missing theorem"\n  Lean.logInfo m!"DIRECT_DEPENDENCIES {name}: {{ci.getUsedConstantsAsSet.toList}}"']
    audit=ROOT/'.lake/AtlasAudit.lean';audit.write_text('\n'.join(commands)+'\n')
    command=['lake','env','lean',str(audit.relative_to(ROOT))]
    result=subprocess.run(command,cwd=ROOT,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    log=ROOT/('.lake/AtlasAuditRun.log' if args.check else 'verification/builds/atlas-axioms.log');log.parent.mkdir(parents=True,exist_ok=True);log.write_text(result.stdout)
    if result.returncode:print(result.stdout);return result.returncode
    matches=re.findall(r"'Duodenary\.(\w+)' (?:does not depend on any axioms|depends on axioms: \[([^\]]*)\])",result.stdout)
    assert len(matches)==len(declarations)
    axioms={n:re.findall(r'[\w.]+',ax) for n,ax in matches}
    assert set(axioms)=={n for _,n,_ in declarations}
    for name,used in axioms.items():assert set(used)<={'propext','Classical.choice','Quot.sound'},(name,used)
    if args.check:
        saved=json.loads((ROOT/'registry/theorems/theorems.json').read_text())
        assert {x['lean_name'] for x in saved}=={'Duodenary.'+name for _,name,_ in declarations}
        for item in saved:
            assert item['source_sha256']==digest(ROOT/item['source'])
            assert item['axioms']==axioms[item['lean_name'].removeprefix('Duodenary.')]
        print(f'PASS: {len(saved)} kernel checks; saved theorem records match source and axioms; tracked files unchanged')
        return 0
    compiled=datetime.now(timezone.utc).isoformat();records=[]
    for index,(source,name,statement) in enumerate(declarations,1):
        records.append({'id':f'DPA-THM-{index:03d}','lean_name':'Duodenary.'+name,'exact_statement':statement,'statement_sha256':hashlib.sha256(statement.encode()).hexdigest(),'source':str(source.relative_to(ROOT)),'source_sha256':digest(source),'dependencies':'Elaborated used-constant list in axiom_audit_log, keyed by DIRECT_DEPENDENCIES '+name,'axioms':axioms[name],'verification_status':'FORMALLY_PROVED','lean_toolchain':(ROOT/'lean-toolchain').read_text().strip(),'compiled_on':compiled,'command':command,'returncode':result.returncode,'log':str(log.relative_to(ROOT)),'log_sha256':digest(log),'axiom_audit_log':str(log.relative_to(ROOT)),'novelty_claim':False})
    (ROOT/'registry/theorems/theorems.json').write_text(json.dumps(records,indent=2)+'\n')
    print(f'PASS: {len(records)} elaborated theorems; only standard permitted axioms; exact statements and source/log hashes recorded')
    return 0
if __name__=='__main__':sys.exit(main())

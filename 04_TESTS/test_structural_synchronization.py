"""Independent finite witnesses for the typed relational gate; no self-scored semantics."""
from pathlib import Path
import copy,hashlib,json,subprocess,sys,tempfile,itertools
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'verification/relational-synchronization'
BIN=ROOT/'.lake/build/bin/relationalGate'
row=lambda x:[x,x%4,x%3]
MATRIX=[[row(next(x for x in range(12) if x%4==a and x%3==b)) for b in range(3)] for a in range(4)]
GENERATORS=[{'kind':'succession'},{'kind':'opposition'},*[{'kind':'reversal','axis':c} for c in range(12)],{'kind':'return'}]
def act(x,r):
 if r['kind']=='succession':return [1,2,3,4,5,6,7,8,9,10,11,0][x]
 if r['kind']=='opposition':return [6,7,8,9,10,11,0,1,2,3,4,5][x]
 if r['kind']=='reversal':return (r['axis']-x)%12
 if r['kind']=='return':return x
 raise ValueError('unsupported reference relation')
def manifestation(start,relations):
 states=[row(start)];x=start
 for r in relations:x=act(x,r);states.append(row(x))
 return {'version':'relational-register-v1','matrix':copy.deepcopy(MATRIX),'states':states,'relations':relations}
def fixtures():
 cases=[];expected=[];labels=[]
 for size in [0,1,2]:
  for rs in itertools.product(GENERATORS,repeat=size):
   for x in range(12):cases.append(manifestation(x,list(rs)));expected.append(True);labels.append(f'word-{size}-start-{x}')
 cases.append(manifestation(11,[GENERATORS[i%len(GENERATORS)] for i in range(257)]));expected.append(True);labels.append('257-relations')
 base=manifestation(11,[{'kind':'succession'},{'kind':'opposition'},{'kind':'reversal','axis':11},{'kind':'return'}])
 def negative(name,edit):
  x=copy.deepcopy(base);edit(x);cases.append(x);expected.append(False);labels.append(name)
 negative('unsynchronized-register',lambda x:x['states'][0].__setitem__(1,0))
 negative('consistent-row-wrong-adjacency',lambda x:x['states'].__setitem__(1,row(1)))
 negative('missing-path-state',lambda x:x['states'].pop())
 negative('extra-path-state',lambda x:x['states'].append(row(5)))
 negative('empty-state-family',lambda x:x.update(states=[]))
 negative('missing-matrix-row',lambda x:x['matrix'].pop())
 negative('duplicate-matrix-cell',lambda x:x['matrix'][0].__setitem__(1,x['matrix'][0][0]))
 negative('unsynchronized-matrix-cell',lambda x:x['matrix'][0][0].__setitem__(1,2))
 negative('unknown-relation',lambda x:x['relations'][0].update(kind='scale5'))
 negative('axis-outside-whole',lambda x:x['relations'][2].update(axis=12))
 negative('negative-station',lambda x:x['states'][0].__setitem__(0,-1))
 negative('extra-root-field',lambda x:x.update(accepted=True))
 negative('extra-relation-field',lambda x:x['relations'][0].update(axis=0))
 return cases,expected,labels
if __name__=='__main__':
 if sys.argv[1:]==['--freeze']:
  cases,expected,labels=fixtures();(OUT/'FROZEN_CASES.json').write_text(json.dumps(cases,separators=(',',':'))+'\n');(OUT/'FROZEN_EXPECTATIONS.json').write_text(json.dumps({'expected':expected,'labels':labels},separators=(',',':'))+'\n')
  files=['04_TESTS/test_structural_synchronization.py','RelationalGate.lean','Duodenary/Relational/Closure.lean','Duodenary/Relational/Registers.lean','Duodenary/Relational/Admission.lean','schemas/relational/register-manifestation.schema.json','verification/relational-synchronization/FROZEN_CASES.json','verification/relational-synchronization/FROZEN_EXPECTATIONS.json']
  (OUT/'TEST_LOCK.json').write_text(json.dumps([{'path':n,'sha256':hashlib.sha256((ROOT/n).read_bytes()).hexdigest()} for n in files],indent=2)+'\n');print('Frozen independent cases and expectations before execution.');raise SystemExit(0)
 for entry in json.loads((OUT/'TEST_LOCK.json').read_text()):assert hashlib.sha256((ROOT/entry['path']).read_bytes()).hexdigest()==entry['sha256'],entry['path']
 expected=json.loads((OUT/'FROZEN_EXPECTATIONS.json').read_text());r=subprocess.run([str(BIN),'--batch',str(OUT/'FROZEN_CASES.json')],capture_output=True,text=True)
 (OUT/'batch.stdout').write_text(r.stdout);(OUT/'batch.stderr').write_text(r.stderr);assert r.returncode==0
 actual=json.loads(r.stdout);assert len(actual)==len(expected['expected'])
 failures=[{'case':i,'label':expected['labels'][i],'expected':truth,'actual':item} for i,(truth,item) in enumerate(zip(expected['expected'],actual)) if item.get('admitted') is not truth]
 (OUT/'COUNTEREXAMPLES.json').write_text(json.dumps(failures,indent=2)+'\n');assert not failures
 codec=[]
 for x in range(12):
  result=subprocess.run([str(BIN),'--row',str(x)],capture_output=True,text=True);assert result.returncode==0 and json.loads(result.stdout)==row(x);codec.append({'station':x,'json_row':json.loads(result.stdout),'exit_code':result.returncode})
 matrix=subprocess.run([str(BIN),'--matrix'],capture_output=True,text=True);assert matrix.returncode==0 and json.loads(matrix.stdout)==MATRIX
 (OUT/'CODEC_WITNESSES.json').write_text(json.dumps(codec,indent=2)+'\n')
 boundary=[]
 with tempfile.TemporaryDirectory() as tmp:
  sample=json.loads((ROOT/'schemas/relational/synchronized-example.json').read_text());valid=json.dumps(sample);samples=[('positive',valid,0),('duplicate-key','{"version":"relational-register-v1",'+valid[1:],1),('non-finite',valid.replace('11','NaN',1),1),('boolean-coordinate',valid.replace('[11, 3, 2]','[true, 3, 2]'),1)]
  for name,text,code in samples:
   p=Path(tmp)/'candidate.json';p.write_text(text);result=subprocess.run([sys.executable,str(ROOT/'scripts/structural_gate.py'),str(p)],capture_output=True,text=True);boundary.append({'case':name,'exit_code':result.returncode,'stdout':result.stdout,'stderr':result.stderr});assert result.returncode==code,(name,result.stdout)
 (OUT/'BOUNDARY_WITNESSES.json').write_text(json.dumps(boundary,indent=2)+'\n')
 print(json.dumps({'finite_cases':len(actual),'admitted_cases':sum(expected['expected']),'rejected_cases':len(actual)-sum(expected['expected']),'codec_states':12,'constitutive_matrix_cells':12,'strict_boundary_cases':len(boundary),'counterexamples':failures},indent=2))

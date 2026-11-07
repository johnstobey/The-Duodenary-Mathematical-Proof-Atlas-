#!/usr/bin/env python3
"""Strict JSON boundary for the Lean relational gate. No alternate acceptance path."""
from pathlib import Path
import json,subprocess,sys,tempfile,hashlib
import jsonschema
ROOT=Path(__file__).resolve().parents[1]
LOCK='f4615587891cf5ca5823a8b64e18a4f268c36de280e7bfd0055b30a7a92e32bc'
def unique_object(pairs):
 out={}
 for k,v in pairs:
  if k in out:raise ValueError('duplicate object key: '+k)
  out[k]=v
 return out
def bad_number(value):raise ValueError('non-finite JSON number: '+value)
def check(path):
 raw=Path(path).read_text();value=json.loads(raw,object_pairs_hook=unique_object,parse_constant=bad_number)
 schema=json.loads((ROOT/'schemas/relational/register-manifestation.schema.json').read_text())
 jsonschema.Draft202012Validator(schema).validate(value)
 if hashlib.sha256((ROOT/'01_CANONICAL/157_ALGORITHMS_LOCKED.jsonl').read_bytes()).hexdigest()!=LOCK:raise ValueError('canonical register lock mismatch')
 binary=ROOT/'.lake/build/bin/relationalGate'
 if not binary.is_file():raise ValueError('Lean gate unavailable; build with lake build relationalGate')
 with tempfile.TemporaryDirectory() as tmp:
  file=Path(tmp)/'manifestation.json';file.write_text(json.dumps(value,allow_nan=False))
  result=subprocess.run([str(binary),'--check',str(file)],capture_output=True,text=True)
  if result.returncode:return {'admitted':False,'stage':'Lean structural conditions','details':json.loads(result.stdout)},1
  output=json.loads(result.stdout)
  if output.get('admitted') is not True:raise ValueError('Lean response lacks admission witness')
  output.update(canonical_sha256=LOCK,lean_gate_sha256=hashlib.sha256(binary.read_bytes()).hexdigest())
  return output,0
if __name__=='__main__':
 try:
  if len(sys.argv)!=2:raise ValueError('usage: python3 scripts/structural_gate.py MANIFESTATION.json')
  answer,code=check(sys.argv[1]);print(json.dumps(answer,ensure_ascii=False));raise SystemExit(code)
 except (OSError,ValueError,jsonschema.ValidationError) as error:
  print(json.dumps({'admitted':False,'stage':'strict input boundary','error':str(error)},ensure_ascii=False));raise SystemExit(1)

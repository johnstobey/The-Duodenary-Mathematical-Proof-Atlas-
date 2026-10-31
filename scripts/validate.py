#!/usr/bin/env python3
"""Validate typed evidence records and reject unsupported theorem promotion."""
from pathlib import Path
import json,re,hashlib,importlib.util
import jsonschema

ROOT=Path(__file__).resolve().parents[1]
STATUSES={'SOURCE_REPORTED','CLAIMED','SOURCE_CHECKED','COMPUTATION_TESTED','FORMALLY_PROVED','REFUTED','DISPUTED','BLOCKED','EXPERIMENT_PLANNED','EXPERIMENT_EXECUTED','RELEASED'}
TYPES={'source text','historical attribution','mathematical definition','formally proved theorem','computationally checked finite result','informal derivation','empirical observation','statistical model','ontological interpretation','research hypothesis','claimed external result','disputed result','refuted claim'}
def validate_claim(claim,schema):
    jsonschema.validate(claim,schema)
    assert claim['id'] and claim['type'] and claim['conclusion']
    assert claim['type'] in TYPES
    assert claim['verification_status'] in STATUSES
    assert claim.get('validator') and claim.get('provenance')
    if claim['verification_status']=='FORMALLY_PROVED':
        assert claim['type']=='formally proved theorem'
        assert claim.get('proof_record'), 'formal status requires proof record'
    if claim['type']=='ontological interpretation':assert claim['verification_status']!='FORMALLY_PROVED'

def main():
    count=0
    for p in ROOT.rglob('*.json'):
        if '.lake' in p.relative_to(ROOT).parts:continue
        json.loads(p.read_text());count+=1
    schema=json.loads((ROOT/'schemas/claim.schema.json').read_text())
    claims=json.loads((ROOT/'registry/claims/claims.json').read_text())
    for claim in claims:validate_claim(claim,schema)
    tasks=json.loads((ROOT/'roadmap/graph/dependencies.json').read_text())
    ts=json.loads((ROOT/'schemas/task.schema.json').read_text())
    for task in tasks['nodes']:
        if task['type']=='TASK':jsonschema.validate(task,ts)
    spec=importlib.util.spec_from_file_location('roadmap',ROOT/'scripts/roadmap.py');module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module);module.schedule(tasks)
    problems=json.loads((ROOT/'registry/problems/frontier.json').read_text())
    assert len(problems)==len({r['id'] for r in problems})==42
    assert {f'DPA-{i:03d}' for i in range(1,8)}.issubset({r['id'] for r in problems})
    requirements=json.loads((ROOT/'registry/requirements.json').read_text());assert [r['id'] for r in requirements]==list(range(1,183))
    for p in (ROOT/'Duodenary').rglob('*.lean'):
        text=re.sub(r'/\-.*?\-/|--[^\n]*','',p.read_text(),flags=re.S)
        assert not re.search(r'\b(sorry|admit|axiom|native_decide)\b',text),p
    for proof in json.loads((ROOT/'registry/theorems/theorems.json').read_text()):
        if proof['verification_status']=='FORMALLY_PROVED':
            log=ROOT/proof['log'];assert proof['returncode']==0 and log.is_file()
            assert hashlib.sha256(log.read_bytes()).hexdigest()==proof['log_sha256']
            assert proof['source_sha256']==hashlib.sha256((ROOT/proof['source']).read_bytes()).hexdigest()
            assert proof['exact_statement'] and proof['axiom_audit_log']
    print(f'PASS: {count} JSON files, {len(claims)} premise-bounded claims, 42 frontier entries, 182 coverage slots, typed DAG and proof evidence')
if __name__=='__main__':main()

#!/usr/bin/env python3
"""Independent black-box finite-domain tests, using direct Python reference arithmetic."""
import importlib.util, pathlib, json, random
ROOT=pathlib.Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('engine',ROOT/'03_ENGINE/finite_engine.py')
engine=importlib.util.module_from_spec(spec);spec.loader.exec_module(engine)
count=0
for start in range(12):
    for d in range(7):
        assert engine.apply(start,f'aspect:{d}')==(start+d)%12;count+=1
    for op,answer in [('T',(start+1)%12),('A',(start+6)%12),('I',(-start)%12),('rho',(11-start)%12)]:
        assert engine.apply(start,op)==answer;count+=1
    assert engine.apply(engine.apply(start,'I'),'I')==start
    assert engine.apply(engine.apply(start,'A'),'A')==start
    assert engine.apply(engine.apply(start,'rho'),'rho')==start;count+=3
for d in range(12):
 for m in range(12):
    assert engine.inverse_address(engine.address(d,m))=={'domain':d,'modality':m};count+=1
for bad in [-1,12,1.5,'7',None]:
 try:engine.apply(bad,'T')
 except ValueError:count+=1
 else:raise AssertionError('invalid position was accepted')
for bad in ['aspect:7','unknown','aspect:-1','aspect:abc']:
 try:engine.apply(7,bad)
 except ValueError:count+=1
 else:raise AssertionError('invalid operator was accepted')
for s in range(12):
 assert engine.trace(s,['A','A'])['finish']==s;count+=1
print(json.dumps({'status':'PASS','assertions':count,'full_finite_domain':True},indent=2))

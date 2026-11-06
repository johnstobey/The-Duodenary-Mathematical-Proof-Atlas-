"""Typed finite-ring adapter, not a replacement for canonical algorithm definitions.
Supported recovered glyph subset: Sun/sign, aspect, Sun/sign. Sun has zero
sub-sign offset in the recovered parser. All other syntax is rejected.
"""
from dataclasses import dataclass, asdict
from pathlib import Path
import hashlib,json,argparse
ROOT=Path(__file__).resolve().parents[2]
LOCK='f4615587891cf5ca5823a8b64e18a4f268c36de280e7bfd0055b30a7a92e32bc'
SIGNS='♈♉♊♋♌♍♎♏♐♑♒♓'
ASPECTS='☌⚺⚹□△⚻☍'
@dataclass(frozen=True)
class AngularTrace:
    algorithm_id:str
    before:int
    delta:int
    after:int
    angle_degrees:int
    canonical_sha256:str

def execute(program:str)->AngularTrace:
    if not isinstance(program,str):raise TypeError('program must be a glyph string')
    raw=(ROOT/'01_CANONICAL/157_ALGORITHMS_LOCKED.jsonl').read_bytes()
    if hashlib.sha256(raw).hexdigest()!=LOCK:raise ValueError('canonical lock mismatch')
    text=''.join(program.split())
    if len(text)!=5 or text[0]!='☉' or text[3]!='☉' or text[1] not in SIGNS or text[2] not in ASPECTS or text[4] not in SIGNS:
        raise ValueError('expected Sun sign aspect Sun sign; unsupported syntax rejected')
    before=SIGNS.index(text[1]);delta=ASPECTS.index(text[2]);after=SIGNS.index(text[4])
    if after!=(before+delta)%12:raise ValueError('right operand violates directed ring transition')
    return AngularTrace('ALG-001',before,delta,after,delta*30,LOCK)
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('program');a=p.parse_args();print(json.dumps(asdict(execute(a.program)),ensure_ascii=False,indent=2))

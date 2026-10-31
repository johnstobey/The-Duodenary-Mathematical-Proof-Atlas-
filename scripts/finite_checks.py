#!/usr/bin/env python3
"""Exhaustive model checks and counterexamples; never substitutes for Lean."""
from itertools import product
from fractions import Fraction
from math import gcd, lcm, atan, degrees, sqrt, pi
from pathlib import Path
import json,argparse

def run():
    counts={}
    for x in range(12):
        assert ((x+6)%12+6)%12==x
        assert (x+6)%12!=x
    counts['antipode']=12
    coords={(x%4,x%3) for x in range(12)}
    assert len(coords)==12
    for a,b in product(range(4),range(3)):
        assert ((9*a+4*b)%12%4,(9*a+4*b)%12%3)==(a,b)
    counts['crt_pairs']=12
    distance=lambda x,y:min((x-y)%12,(y-x)%12)
    assert {distance(x,y) for x,y in product(range(12),repeat=2)}==set(range(7))
    for x,y,a in product(range(12),repeat=3):
        assert distance(x,y)==distance(y,x)==distance((x+a)%12,(y+a)%12)
    counts['distance_translation_cases']=12**3
    slopes=[a for a in range(12) if gcd(a,12)==1]
    affines=list(product(slopes,range(12)))
    action=lambda f,x:(f[0]*x+f[1])%12
    compose=lambda f,g:((f[0]*g[0])%12,(f[0]*g[1]+f[1])%12)
    assert len({tuple(action(f,x) for x in range(12)) for f in affines})==48
    for f,g,x in product(affines,affines,range(12)):
        assert action(compose(f,g),x)==action(f,action(g,x))
    for f in affines:
        inverse=(f[0],(-f[0]*f[1])%12)
        assert compose(f,inverse)==compose(inverse,f)==(1,0)
    counts['affine_composition_cases']=48*48*12
    for x,y in product(range(12),repeat=2):
        n=12*x+y;assert divmod(n,12)==(x,y)
    counts['product144_encoding']=144
    # Independent falsification controls: numerical similarity is insufficient.
    assert len({(x%6,x%2) for x in range(12)})==6
    assert 260!=12 and gcd(260,12)==4
    assert (12*1)%144==12 and (12*1)%12==0
    assert (5*1)%12==5 and distance(0,1)!=distance(0,5)
    # Thus 48 affine permutations do not all preserve the seven distance labels.
    assert (13%12)==(1%12) and ((3*13+1)//2)%12 != ((3*1+1)//2)%12
    counts['negative_controls']=5
    assert lcm(260,365)==18980==52*365==73*260
    for k in range(1,101):
        assert Fraction(4,3*k)==Fraction(1,k)+Fraction(1,4*k)+Fraction(1,12*k)
    counts['unit_fraction_samples']=100
    # Exact source arithmetic, without validating astronomical or ontological claims.
    first=Fraction(240)+19+Fraction(32,60)
    second=Fraction(330)+3+Fraction(47,60)
    separation=(second-first)%360
    assert separation==Fraction(297,4) # 74.25 degrees
    assert Fraction('93.25')-separation==19
    probabilities=[Fraction('2.14e-9'),Fraction('6.94e-4'),Fraction('1.90e-6'),Fraction('6.06e-3'),Fraction('1e-4')]
    joint=1
    for value in probabilities:joint*=value
    assert joint!=Fraction('1.72e-24')
    return {'status':'PASS','case_counts':counts,'source_arithmetic':{'forward_angle_degrees':str(separation),'claimed_forward_angle_degrees':'93.25','probability_product_exact':str(joint),'probability_product_scientific':float(joint),'reported_product':'1.72e-24','probability_model_verified':False},'pyramid':{'unique_edges':8,'triangular_face_edge_incidences':12,'binary_bits_for_12_states':4,'slope_pi_approx_degrees':degrees(atan(4/pi)),'slope_phi_approx_degrees':degrees(atan(sqrt((1+sqrt(5))/2))),'44_percent_reproduced':False},'aztec':{'calendar_round_days':18980,'cultural_primary_mapping_verified':False}}

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--check',action='store_true');args=parser.parse_args()
    result=run();root=Path(__file__).resolve().parents[1]
    target=root/'verification/negative-controls/finite-results.json';target.parent.mkdir(parents=True,exist_ok=True)
    rendered=json.dumps(result,indent=2)+'\n'
    if args.check:assert target.read_text()==rendered,'Finite-check record differs from current calculation'
    else:target.write_text(rendered)
    print(json.dumps(result,indent=2))

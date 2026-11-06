#!/usr/bin/env python3
"""Deterministic Tobey ring + 144-cell finite operator engine; standard library only.
The immutable 157-entry registry is not scored or rewritten by this program.
"""
import argparse, json

def check(x):
    if type(x) is not int or not 0<=x<12:raise ValueError('ring position must be an integer in 0..11')
    return x

def apply(x,operation):
    x=check(x)
    if operation=='T':return (x+1)%12
    if operation=='I':return (-x)%12
    if operation=='A':return (x+6)%12
    if operation=='rho':return (11-x)%12
    if operation.startswith('aspect:'):
        value=operation.split(':',1)[1]
        if not value.isdigit() or not 0<=int(value)<=6:raise ValueError('aspect index must be 0..6')
        return (x+int(value))%12
    raise ValueError('unsupported operation '+operation)

def trace(start,operations):
    state=check(start);output=[]
    for idx,op in enumerate(operations):
        after=apply(state,op)
        output.append({'step':idx,'before':state,'operator':op,'after':after,'element':after%4,'modality':after%3})
        state=after
    return {'start':start,'steps':output,'finish':state}

def address(domain,modality):
    return 12*check(domain)+check(modality)

def inverse_address(index):
    if type(index) is not int or not 0<=index<144:raise ValueError('address must be integer in 0..143')
    return {'domain':index//12,'modality':index%12}

def main():
    p=argparse.ArgumentParser(); sub=p.add_subparsers(dest='action',required=True)
    t=sub.add_parser('trace');t.add_argument('--start',type=int,required=True);t.add_argument('--operations',required=True)
    c=sub.add_parser('cell');c.add_argument('--domain',type=int,required=True);c.add_argument('--modality',type=int,required=True)
    a=p.parse_args()
    result=trace(a.start,[o.strip() for o in a.operations.split(',')]) if a.action=='trace' else {'address':address(a.domain,a.modality)}
    print(json.dumps(result,ensure_ascii=False,sort_keys=True,indent=2))
if __name__=='__main__':main()

#!/usr/bin/env python3
"""Generate a deterministic queue from typed prerequisite edges and explicit scores."""
from pathlib import Path
import json, argparse

WEIGHTS={'significance':.20,'bridge':.20,'tractability':.15,'discovery':.15,'leverage':.15,'verification':.10,'publication':.05}
def schedule(graph):
    nodes={x['id']:x for x in graph['nodes']}
    assert len(nodes)==len(graph['nodes']), 'duplicate nodes'
    prerequisites={n:set() for n in nodes}
    for edge in graph['edges']:
        assert edge['from'] in nodes and edge['to'] in nodes
        if edge['type']=='REQUIRES':prerequisites[edge['from']].add(edge['to'])
    todo={n:set(p) for n,p in prerequisites.items()};order=[]
    while todo:
        ready=sorted(n for n,p in todo.items() if not p)
        if not ready:raise ValueError('REQUIRES cycle')
        for n in ready:
            order.append(n);del todo[n]
        for p in todo.values():p.difference_update(ready)
    done={'KERNEL_VERIFIED','IMPLEMENTED','SOURCE_CHECKED','RELEASED'}
    queue=[]
    for n in order:
        item=nodes[n]
        if item['type']!='TASK' or item['status'] in done:continue
        runnable=item['status']!='BLOCKED' and all(nodes[p]['status'] in done for p in prerequisites[n])
        score=round(sum(WEIGHTS[k]*item['scores'][k] for k in WEIGHTS)*20,2)
        queue.append({'id':n,'objective':item['objective'],'score':score,'runnable':runnable,'prerequisites':sorted(prerequisites[n]),'next_action':item['next_action'],'acceptance_test':item['acceptance_test'],'output_artifacts':item['output_artifacts']})
    return sorted(queue,key=lambda x:(not x['runnable'],-x['score'],x['id']))

def render(queue):
    return '# Dependency-driven work queue\n\nWeights: '+', '.join(f'{k} {v:.0%}' for k,v in WEIGHTS.items())+'. Scores are documented triage judgments, not evidence of mathematical truth.\n\n'+''.join(f"- {x['id']} ({x['score']}, {'runnable' if x['runnable'] else 'blocked/prerequisite pending'}): {x['objective']} Next: {x['next_action']} Acceptance: {x['acceptance_test']}\n" for x in queue)
if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--check',action='store_true');args=parser.parse_args()
    root=Path(__file__).resolve().parents[1];g=json.loads((root/'roadmap/graph/dependencies.json').read_text());q=schedule(g)
    outputs={'roadmap/queue/tasks.json':json.dumps(q,indent=2)+'\n','roadmap/ROADMAP.md':render(q)}
    for name,text in outputs.items():
        p=root/name
        if args.check:assert p.read_text()==text,'stale generated roadmap: '+name
        else:p.parent.mkdir(parents=True,exist_ok=True);p.write_text(text)
    print(f'Validated DAG; {len(q)} outstanding tasks; {sum(x["runnable"] for x in q)} runnable')

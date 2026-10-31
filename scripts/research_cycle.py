#!/usr/bin/env python3
"""Refresh evidence-driven tasks without claiming automatic mathematical discovery."""
from pathlib import Path
import json,hashlib,re
ROOT=Path(__file__).resolve().parents[1]
def main():
    path=ROOT/'roadmap/graph/dependencies.json';g=json.loads(path.read_text());nodes={n['id']:n for n in g['nodes']};edges=g['edges']
    proofs={p['lean_name']:p for p in json.loads((ROOT/'registry/theorems/theorems.json').read_text())}
    def node(id,kind,status,**fields):
        if id not in nodes:nodes[id]={'id':id,'type':kind,'status':status,**fields}
    def task(id,objective,next_action,acceptance,artifact,prereq,category,status='SPECIFIED',scores=None):
        node(id,'TASK',status,objective=objective,next_action=next_action,acceptance_test=acceptance,prerequisites=prereq,output_artifacts=[artifact],source_locators=[artifact],verification_logs=[],inputs=prereq,owner_agent='Atlas implementing agent',category=category,scores=scores or dict(significance=4,bridge=3,tractability=3,discovery=3,leverage=3,verification=5,publication=4),score_evidence='Source availability and explicit proof obligation; triage weights, not truth or novelty probability.',downstream_unlocks=[])
        nodes[id]['category']=category
        for dep in prereq:
            e={'from':id,'to':dep,'type':'REQUIRES'}
            if e not in edges:edges.append(e)
    if 'Duodenary.calendar_no_surjective_hom' in proofs:
        n=nodes['T-AZTEC-MAP'];n['status']='KERNEL_VERIFIED';n['verification_logs']=['verification/builds/atlas-axioms.log'];n['verified_scope']='Image size at most four and no surjection; exact divisibility follows as a separate remaining obligation.'
        task('T-AZTEC-DIVISIBILITY','Prove exact image-cardinality divisibility by four','Construct the image as a subgroup of the four-element annihilator; apply finite-group divisibility.','Kernel proof that image cardinality divides four.','Duodenary/Acausal/Calendar.lean',['CORE'],'new_structural_proposition',scores=dict(significance=3,bridge=5,tractability=5,discovery=3,leverage=4,verification=5,publication=5))
    if 'Duodenary.machine_composition_agrees' in proofs:
        task('T-MACHINE-AFFINE','Transport the archived affine implementation to the Atlas representation','Completed by explicit bijection, action and composition agreement.','Axiom-audited bridge theorems.','Duodenary/Bridges/Machine.lean',['CORE'],'implementation_reconciliation',status='KERNEL_VERIFIED')
    if json.loads((ROOT/'registry/external/openai/RECONCILIATION.json').read_text())['status']=='RESOLVED':
        nodes['T-CATALOGUE-AUDIT']['status']='IMPLEMENTED';nodes['T-CATALOGUE-AUDIT']['verification_logs']=['registry/external/openai/RECONCILIATION.json'];nodes['T-CATALOGUE-AUDIT']['completion_evidence']='721 unique primary paths; CAT(0) parser regression corrected.'
    publication=ROOT/'publications/releases/foundation-publication.json'
    if publication.exists():
        receipt=json.loads(publication.read_text())
        if receipt.get('push_returncode')==0 and receipt.get('remote_sha_verified') is True:
            nodes['T-RELEASE']['status']='RELEASED'
            nodes['T-RELEASE']['verification_logs']=['publications/releases/foundation-publication.json']
    node('SOURCE-OAI-TOOLCHAIN','SOURCE','BLOCKED',required='Lean 4.34.1 is installed; external locked dependencies and a compatible guarded Comparator environment are still required. See VERIFIER_READINESS.json.')
    papers=json.loads((ROOT/'registry/external/openai/manuscripts.json').read_text())
    for paper in papers:
        source_id='SRC-'+paper['id'];node(source_id,'SOURCE','SOURCE_CHECKED',locator=paper['source_url'],source_blob=paper['git_blob'])
        if not paper['formalization_manifest_listed']:
            task('T-FORMALIZE-'+paper['id'],'Audit/formalize '+paper['title'],'Read the pinned main theorem and proof; extract exact hypotheses and first nontrivial missing lemma.','Statement/proof-gap ledger and one actual checked lemma, or a recorded counterexample.','registry/external/openai/manuscripts.json#'+paper['id'],[source_id],'result_without_direct_manifest_link')
    configs=json.loads((ROOT/'registry/external/openai/proof_execution_configs.json').read_text())
    for c in configs:
        key=hashlib.sha256(c['declaration'].encode()).hexdigest()[:14]
        task('T-COMPARATOR-'+key,'Independently verify '+c['declaration'],'Prepare the pinned external project and execute its exact Comparator configuration; audit hypotheses/axioms.','Real comparator exit status and logs; no promotion from source presence.','registry/external/openai/proof_execution_configs.json#'+c['declaration'],['SOURCE-OAI-TOOLCHAIN'],'announced_proof_verification',status='BLOCKED')
    task('T-COLLATZ-QUOTIENT','Formalize the counterexample to a naive accelerated mod-12 quotient','Prove that 1 and 13 agree mod 12 but their accelerated odd successors do not.','Kernel proof of the stated quotient obstruction, without implying Collatz is refuted.','formalization/NEW_CONJECTURE.md',['CORE'],'new_structural_proposition')
    if 'Duodenary.accelerated_collatz_quotient_counterexample' in proofs:
        nodes['T-COLLATZ-QUOTIENT']['status']='KERNEL_VERIFIED'
        nodes['T-COLLATZ-QUOTIENT']['verification_logs']=['verification/builds/atlas-axioms.log']
    # Every checked theorem receives its own source and proof-prerequisite nodes.
    audit=(ROOT/'verification/builds/atlas-axioms.log').read_text()
    used={name:set(re.findall(r"[A-Za-z_][A-Za-z0-9_'.]*", body)) for name,body in re.findall(r'DIRECT_DEPENDENCIES ([\w.]+):\s*\[([\s\S]*?)\]',audit)}
    for name,proof in proofs.items():
        source_id='SRC-LEAN-'+hashlib.sha256(proof['source'].encode()).hexdigest()[:12]
        node(source_id,'SOURCE','SOURCE_CHECKED',path=proof['source'],sha256=proof['source_sha256'])
        node(proof['id'],'THEOREM','KERNEL_VERIFIED',lean_name=name,statement_sha256=proof['statement_sha256'],evidence=proof['log'])
        deps=[source_id]+[proofs[d]['id'] for d in used.get(name,set()) if d in proofs and d!=name]
        for dep in sorted(deps):
            edge={'from':proof['id'],'to':dep,'type':'REQUIRES'}
            if edge not in edges:edges.append(edge)
    if 'Duodenary.affine_twelve_iterates' in proofs:
        task('T-AFFINE-PERIOD-CLASSIFICATION','Classify the exact minimal orbit periods of all affine actions','Use the verified twelve-iterate bound to construct minimal-period witnesses in {1,2,3,4,6,12}.','Kernel-checked minimality, not only an upper bound.','Duodenary/Problems/QuotientObstruction.lean',['CORE'],'new_structural_proposition')
    g['nodes']=list(nodes.values());g['edges']=edges;g['update_policy']='Re-run after a theorem audit or primary source change. Verified source availability is not proof validity. Completed tasks retain evidence; blocked work does not block unrelated tasks.'
    path.write_text(json.dumps(g,indent=2)+'\n')
    print(f'Research graph: {len(nodes)} nodes, {len(edges)} typed edges; {sum(n.get("category")=="result_without_direct_manifest_link" for n in nodes.values())} unformalized-source tasks, {len(configs)} external verifier tasks')
if __name__=='__main__':main()

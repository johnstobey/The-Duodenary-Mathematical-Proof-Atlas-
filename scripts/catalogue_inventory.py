#!/usr/bin/env python3
"""Index pinned primary catalogue identifiers, revisions and proof-source availability.
Syntactic proof availability is never promoted to mathematical validity.
"""
from pathlib import Path
from datetime import datetime,timezone
import re,json,hashlib,subprocess,argparse,collections,posixpath
import yaml
ROOT=Path(__file__).resolve().parents[1]
def manuscript_links(text):
    # Parentheses inside Markdown destinations are legal (the CAT(0) regression).
    return re.findall(r'\[([^\n]+?)\]\((preprints/[^\n]+?\.pdf)\)',text)
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def build(source):
    commit=subprocess.check_output(['git','rev-parse','HEAD'],cwd=source,text=True).strip()
    contents=(source/'CONTENTS.md').read_text();manifest=yaml.safe_load((source/'lean/formalization.yaml').read_text())
    heads=list(re.finditer(r'^\*\*(\d{3})\. (.+?)\*\*',contents,re.M))
    families=[];papers=[];formal_ids={s['id'].removeprefix('../') for s in manifest['sources']}
    tree={l.split('\t',1)[1]:l.split()[2] for l in subprocess.check_output(['git','ls-tree','-r','HEAD'],cwd=source,text=True).splitlines()}
    primary_readmes=[]
    for p in sorted((source/'preprints').glob('*/README.md')):
        s=p.read_text();title=re.search(r'^# \[(.*?)\]\(([^\n]+?\.pdf)\)',s,re.M)
        primary_readmes.append({'id':str(p.parent.relative_to(source)),'readme':str(p.relative_to(source)),'readme_sha256':digest(p),'heading':title[1] if title else None,'entry_pdf':posixpath.normpath(str(p.parent.relative_to(source))+'/'+title[2]) if title else None,'withdrawn':bool(re.search(r'\*\*Withdrawn on ',s)),'version_note':s.split('## Version note',1)[1].strip() if '## Version note' in s else None,'withdrawal_note':s if re.search(r'\*\*Withdrawn on ',s) else None,'bibtex_id':(re.search(r'@misc\{([^,]+)',s)[1] if re.search(r'@misc\{([^,]+)',s) else None)})
    by_dir={x['id']:x for x in primary_readmes}
    for i,m in enumerate(heads):
        block=contents[m.start():heads[i+1].start() if i+1<len(heads) else len(contents)]
        links=manuscript_links(block)
        families.append({'id':'OAI-'+m[1],'title':m[2].rstrip('.'),'catalogue_claim':block[m.end()-m.start():].split('</td>')[0].strip(),'manuscript_paths':[p for _,p in links],'status':'SOURCE_REPORTED','commit':commit,'proof_checked_here':False})
        for title,path in links:
            directory=posixpath.dirname(path);primary=by_dir.get(directory);assert path in tree,path
            tex=list((source/directory).rglob('*.tex'));proofs=0;closed=0;conditional=[]
            for p in tex:
                s=p.read_text(errors='replace');proofs+=len(re.findall(r'\\begin\{proof\}',s));closed+=len(re.findall(r'\\end\{proof\}',s))
                if re.search(r'conditional on|assuming the|remains open|proof gap',s,re.I):conditional.append(str(p.relative_to(source)))
            withheld=primary and primary['withdrawn']
            scope='WITHDRAWN_WITH_RECORDED_GAP' if withheld else ('PROOF_SOURCE_AVAILABLE_UNAUDITED' if proofs else 'MANUSCRIPT_AVAILABLE_PROOF_NOT_PARSED')
            papers.append({'id':'OAI-P-'+hashlib.sha256(path.encode()).hexdigest()[:16],'family':'OAI-'+m[1],'title':title,'path':path,'git_blob':tree[path],'source_url':f'https://github.com/openai/math/blob/{commit}/{path}','primary_id':primary['bibtex_id'] if primary else directory,'readme_sha256':primary['readme_sha256'] if primary else None,'formalization_manifest_listed':path in formal_ids,'source_status':'SOURCE_CHECKED','proof_availability_status':scope,'tex_sources':[{'path':str(p.relative_to(source)),'sha256':digest(p)} for p in tex],'proof_environments':proofs,'closed_proof_environments':closed,'conditional_language_source_candidates':conditional,'complete_proof_independently_verified':False,'mathematical_proof_status':'NOT_INDEPENDENTLY_CHECKED','local_kernel_build':False})
    return commit,families,papers,primary_readmes,manifest

def main():
    parser=argparse.ArgumentParser();parser.add_argument('--source',type=Path,required=True);args=parser.parse_args()
    commit,families,papers,readmes,manifest=build(args.source)
    out=ROOT/'registry/external/openai';out.mkdir(parents=True,exist_ok=True)
    def put(n,d):(out/n).write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n')
    previous=json.loads((out/'manuscripts.json').read_text());old_ids={p['path']:p['id'] for p in previous}
    assert all(old_ids.get(p['path'],p['id'])==p['id'] for p in papers)
    put('families.json',families);put('manuscripts.json',papers);put('primary_readmes.json',readmes)
    configs=[]
    for result in manifest['status']['main_results']:
        p=args.source/'lean'/result['comparator_config'];data=json.loads(p.read_text()) if p.exists() else None
        configs.append({**result,'config_sha256':digest(p) if p.exists() else None,'configuration':data,'verification_status':'CONFIGURATION_ACQUIRED_NOT_EXECUTED','requires_toolchain':(args.source/'lean/lean-toolchain').read_text().strip()})
    put('proof_execution_configs.json',configs)
    missing='preprints/Sharp-integral-fillings-in-CAT(0)-spaces-September-23-2026/paper.pdf'
    put('RECONCILIATION.json',{'status':'RESOLVED','commit':commit,'families':len(families),'manuscripts':len(papers),'unique_pdf_identifiers':len({p['path'] for p in papers}),'publisher_headline':721,'previous_parser_count':720,'previously_omitted_primary_identifier':missing,'cause':'The BUILD-03 regex excluded right parentheses in Markdown destinations; CAT(0) is part of this exact primary path.','primary_blob':next(p['git_blob'] for p in papers if p['path']==missing),'primary_readmes_acquired':len(readmes),'formalization_manifest_sources':len(manifest['sources']),'formal_main_results':len(configs),'proof_status_counts':dict(collections.Counter(p['proof_availability_status'] for p in papers)),'all_proofs_complete_or_validated':False,'exact_statement_deduplication_complete':False})
    put('withdrawn_and_versions.json',{'withdrawn':[r for r in readmes if r['withdrawn']],'versioned':[r for r in readmes if r['version_note']],'historical_or_unmapped_readmes':[r['id'] for r in readmes if r['id'] not in {posixpath.dirname(p['path']) for p in papers}]})
    pin=ROOT/'sources/metadata/OPENAI_PIN.json';d=json.loads(pin.read_text());d.update(manuscript_records=len(papers),unique_manuscript_paths=len({p['path'] for p in papers}),primary_readmes_acquired=len(readmes),formal_main_results=len(configs),count_discrepancy='resolved by primary identifier containing parentheses');pin.write_text(json.dumps(d,indent=2)+'\n')
    print(json.dumps({'families':len(families),'manuscripts':len(papers),'readmes':len(readmes),'formal_configs':len(configs),'withdrawn_readmes':sum(r['withdrawn'] for r in readmes)},indent=2))
if __name__=='__main__':main()

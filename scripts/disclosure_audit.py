#!/usr/bin/env python3
"""Bounded candidate/history hygiene scan; does not grant disclosure or licensing rights."""
from pathlib import Path
import subprocess,json,re,hashlib,sys
ROOT=Path(__file__).resolve().parents[1]
PATTERNS={
    'private_key':rb'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----',
    'github_token':rb'gh[pousr]_[A-Za-z0-9]{30,}',
    'aws_access_id':rb'AKIA[0-9A-Z]{16}',
    'personal_street_address':rb'\b[0-9]{3,6} [A-Za-z]+ (?:Woods|Street|Drive|Road|Lane)\b',
}
def git(*args):return subprocess.check_output(['git',*args],cwd=ROOT)
def main():
    issues=[];checked=[]
    names=sorted(set(x.decode() for x in git('ls-files','-co','--exclude-standard','-z').split(b'\0') if x))
    for name in names:
        p=ROOT/name
        if not p.is_file():continue
        b=p.read_bytes()
        if p.suffix.lower() in {'.pdf','.docx','.zip','.bundle'}:issues.append({'path':name,'issue':'original_binary_or_archive_in_candidate'})
        for label,pattern in PATTERNS.items():
            if re.search(pattern,b):issues.append({'path':name,'issue':label})
        checked.append({'path':name,'sha256':hashlib.sha256(b).hexdigest(),'bytes':len(b)})
    blobs=[]
    for line in git('rev-list','--objects','--all').decode().splitlines():
        oid=line.split(' ',1)[0]
        if git('cat-file','-t',oid).strip()!=b'blob':continue
        b=git('cat-file','blob',oid);blobs.append(oid)
        for label,pattern in PATTERNS.items():
            if re.search(pattern,b):issues.append({'blob':oid,'issue':label})
    report={'scan_status':'PASS_PATTERN_SCAN_ONLY' if not issues else 'FAILED','candidate_files_scanned':len(checked),'reachable_history_blobs_scanned':len(blobs),'issues':issues,'limitations':['Pattern matching is not a complete secrecy or personal-data audit.','All third-party rights and selected private-derived disclosures require owner review.','No approval, visibility change, public push, tag or release is performed.'],'publication_gate':('AUTHORIZATION_RECORDED' if json.loads((ROOT/'registry/governance.json').read_text()).get('publication_approval') else 'BLOCKED_PENDING_OWNER_APPROVAL')}
    out=ROOT/'verification/disclosure-audits/SCAN.json';out.parent.mkdir(parents=True,exist_ok=True);out.write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2));return bool(issues)
if __name__=='__main__':sys.exit(main())

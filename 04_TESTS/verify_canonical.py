#!/usr/bin/env python3
"""Independent byte-level registry lock, geometry and atlas coverage verifier. No BB scoring."""
import hashlib, json, pathlib, collections, base64, re
ROOT=pathlib.Path(__file__).resolve().parents[1]
sha=lambda data:hashlib.sha256(data).hexdigest()
source=ROOT/'01_CANONICAL/157_ALGORITHMS_LOCKED.jsonl'
lock=json.loads((ROOT/'01_CANONICAL/CANONICAL_LOCK.json').read_text())
raw=source.read_bytes()
assert sha(raw)==lock['canonical_register_sha256'],'canonical file altered'
records=[json.loads(line) for line in raw.decode().splitlines() if line.strip()]
assert len(records)==157 and len({r['id'] for r in records})==157
assert dict(collections.Counter(r['register'] for r in records))==lock['namespaces']
for r in records:
    ref=lock['record_digests'][r['id']]
    assert sha(r['english_container_original'].encode())==ref['source_sha256']
    assert sha(r['mathematical_notation'].encode())==ref['mathematics_sha256']
    assert sha(r['obsidian_dewey_v11_1_D00'].encode())==ref['dewey_sha256']
    d=r['obsidian_dewey_v11_1_D00'];assert len(d)==89 and len(d.split('.'))==30 and d.startswith('Φ.CPT.D00.')
assets=list((ROOT/'02_ATLAS/assets').glob('*.jpg'))
assert len(assets)==22 and sum(p.name.startswith('plate_') for p in assets)==8 and sum(p.name.startswith('seal_') for p in assets)==14
scenes=json.loads((ROOT/'02_ATLAS/scenes.json').read_text());assert len(scenes)==25
seals=json.loads((ROOT/'01_CANONICAL/sacred_seal_index.json').read_text());assert len(seals)==14
fixtures=json.loads((ROOT/'03_ENGINE/ring_84_finite_transitions.json').read_text())
assert len(fixtures)==84 and len({(x['start'],x['delta']) for x in fixtures})==84
for x in fixtures:assert x['finish']==(x['start']+x['delta'])%12 and x['angle_degrees']==30*x['delta']
page=(ROOT/'02_ATLAS/index.html').read_text()
assert page.count('data:image/jpeg;base64,')==22
assert all(r['id'] in page for r in records)
assert all(r['obsidian_dewey_v11_1_D00'] in page for r in records)
assert 'prefers-reduced-motion' in page and 'requestAnimationFrame' in page and 'position:sticky' in page
assert 'source-anchored candidate' not in page.lower() and 'not admitted' not in page.lower()
receipt={'status':'PASS','canonical_sha256':sha(raw),'records':157,'plates':8,'seals':14,'scenes':25,'finite_cases':84,'lexical_bb_rescored':False,'source_modified':False,'test':'byte_lock_and_atlas_coverage'}
print(json.dumps(receipt,ensure_ascii=False,indent=2))

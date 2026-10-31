import importlib.util,unittest,json,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def load(name):
    s=importlib.util.spec_from_file_location(name,ROOT/'scripts'/f'{name}.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
class CatalogueAndExecution(unittest.TestCase):
    def test_real_primary_identifier_with_parentheses_is_preserved(self):
        path='preprints/Sharp-integral-fillings-in-CAT(0)-spaces-September-23-2026/paper.pdf'
        self.assertEqual(load('catalogue_inventory').manuscript_links(f'[Sharp fillings]({path})'),[('Sharp fillings',path)])
    def test_primary_catalogue_and_source_ids_are_unique(self):
        rows=json.loads((ROOT/'registry/external/openai/manuscripts.json').read_text())
        self.assertEqual(len(rows),721);self.assertEqual(len({r['path'] for r in rows}),721)
        self.assertTrue(all(r['git_blob'] and r['primary_id'] for r in rows))
    def test_missing_clearing_inputs_cannot_be_scored(self):
        r=subprocess.run([sys.executable,str(ROOT/'scripts/clearing_preflight.py')],capture_output=True,text=True)
        self.assertEqual(r.returncode,2);self.assertEqual(json.loads(r.stdout)['scored_primary_trials'],0)
    def test_foundation_theorem_ids_survive_extension(self):
        original=json.loads((ROOT/'registry/theorems/foundation_ids.json').read_text());now={r['lean_name']:r['id'] for r in json.loads((ROOT/'registry/theorems/theorems.json').read_text())}
        self.assertTrue(all(now.get(k)==v for k,v in original.items()))
if __name__=='__main__':unittest.main()

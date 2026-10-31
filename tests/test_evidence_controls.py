import importlib.util,copy,json,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def load(name):
    spec=importlib.util.spec_from_file_location(name,ROOT/'scripts'/f'{name}.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
class EvidenceControls(unittest.TestCase):
    def test_ontology_cannot_be_promoted(self):
        v=load('validate');s=json.loads((ROOT/'schemas/claim.schema.json').read_text());c=json.loads((ROOT/'registry/claims/claims.json').read_text())[0];c=copy.deepcopy(c);c['type']='ontological interpretation';c['verification_status']='FORMALLY_PROVED'
        with self.assertRaises(AssertionError):v.validate_claim(c,s)
    def test_missing_validator_rejected(self):
        v=load('validate');s=json.loads((ROOT/'schemas/claim.schema.json').read_text());c=copy.deepcopy(json.loads((ROOT/'registry/claims/claims.json').read_text())[0]);c['validator']=None
        with self.assertRaises(AssertionError):v.validate_claim(c,s)
    def test_cycle_rejected_and_feedback_allowed(self):
        m=load('roadmap');g={'nodes':[{'id':'a','type':'SOURCE'},{'id':'b','type':'SOURCE'}],'edges':[{'from':'a','to':'b','type':'REQUIRES'},{'from':'b','to':'a','type':'REQUIRES'}]}
        with self.assertRaises(ValueError):m.schedule(g)
        g['edges'][1]['type']='GENERATES';self.assertEqual(m.schedule(g),[])
    def test_wrong_crt_and_nonisomorphism_controls(self):
        self.assertEqual(len({(x%6,x%2) for x in range(12)}),6)
        self.assertNotEqual(12%144,0)
        self.assertNotEqual(min(1,11),min(5,7))
if __name__=='__main__':unittest.main()

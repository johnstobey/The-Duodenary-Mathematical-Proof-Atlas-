import unittest,importlib.util,sys,tempfile,shutil
from pathlib import Path
from fractions import Fraction
ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('invariant',ROOT/'03_ENGINE/invariant.py');m=importlib.util.module_from_spec(spec);sys.modules[spec.name]=m;spec.loader.exec_module(m)
class InvariantTests(unittest.TestCase):
 def test_full_domain_and_all_tables(self):
  r=m.verify();self.assertEqual(r['checks'],{'state_round_trips':12,'generator_commutations':48,'angular_adapter_cases':84,'lattice_round_trips_and_oppositions':144,'negative_controls_rejected':6});self.assertTrue(all(c['rejected'] for c in r['negative_controls']))
 def test_worked_wraparound_and_recovery(self):
  r=m.admit('☉♓□☉♊');self.assertEqual((r['before'],r['after'],r['angle_degrees']),(11,2,90));self.assertEqual(m.decode_angle((m.angle(11)+Fraction(3,12))%1),2)
 def test_nonstation_angle_and_bad_glyph_rejected(self):
  for x in [Fraction(1,13),Fraction(1),Fraction(-1,12),0.5]:
   with self.assertRaises(ValueError):m.decode_angle(x)
  for x in ['♈♉','harmony','',None]:
   with self.assertRaises(ValueError):m.decode(x)
 def test_structural_admission_rejects_wrong_endpoint(self):
  with self.assertRaises(ValueError):m.admit('☉♓□☉♋')
 def test_frozen_fixture_tamper_rejected(self):
  with tempfile.TemporaryDirectory() as tmp:
   root=Path(tmp)
   for name in ['INVARIANT_BINDINGS.json','01_CANONICAL/157_ALGORITHMS_LOCKED.jsonl','01_CANONICAL/CANONICAL_LOCK.json','03_ENGINE/ring_84_finite_transitions.json']:
    dst=root/name;dst.parent.mkdir(exist_ok=True,parents=True);shutil.copy2(ROOT/name,dst)
   path=root/'03_ENGINE/ring_84_finite_transitions.json';path.write_bytes(path.read_bytes()+b' ')
   old=m.ROOT;m.ROOT=root
   try:
    with self.assertRaisesRegex(ValueError,'frozen source or fixture changed'):m.verify()
   finally:m.ROOT=old
if __name__=='__main__':unittest.main(verbosity=2)

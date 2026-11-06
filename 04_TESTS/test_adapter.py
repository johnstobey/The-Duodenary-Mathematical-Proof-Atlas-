import importlib.util,sys,unittest
from pathlib import Path
spec=importlib.util.spec_from_file_location('fulgurite',Path(__file__).resolve().parents[1]/'03_ENGINE/adapters/fulgurite.py');m=importlib.util.module_from_spec(spec);sys.modules[spec.name]=m;spec.loader.exec_module(m)
class AdapterTests(unittest.TestCase):
 def test_all_finite_programs(self):
  for start in range(12):
   for delta in range(7):
    end=(start+delta)%12;t=m.execute('☉'+m.SIGNS[start]+m.ASPECTS[delta]+'☉'+m.SIGNS[end]);self.assertEqual((t.before,t.delta,t.after,t.angle_degrees),(start,delta,end,delta*30));self.assertEqual(t.algorithm_id,'ALG-001')
 def test_wrong_right_operands(self):
  for start in range(12):
   for delta in range(7):
    for end in range(12):
     if end!=(start+delta)%12:
      with self.assertRaises(ValueError):m.execute('☉'+m.SIGNS[start]+m.ASPECTS[delta]+'☉'+m.SIGNS[end])
 def test_unsupported_syntax(self):
  for text in ['', 'Sun Aries square Sun Cancer','☉♈□☉♋ trailing','☽♈□☉♋','☉♈□☉♋;☉♈','☉♈?☉♋']:
   with self.assertRaises(ValueError):m.execute(text)
 def test_invalid_type(self):
  for text in [None,{},1]:
   with self.assertRaises(TypeError):m.execute(text)
if __name__=='__main__':unittest.main(verbosity=2)

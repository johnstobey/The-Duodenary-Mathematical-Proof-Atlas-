"""Executable structural-identity witnesses; canonical definitions remain read-only."""
from pathlib import Path
from fractions import Fraction
import hashlib,json,importlib.util,sys
ROOT=Path(__file__).resolve().parents[1]
LOCK='f4615587891cf5ca5823a8b64e18a4f268c36de280e7bfd0055b30a7a92e32bc'
SIGNS='♈♉♊♋♌♍♎♏♐♑♒♓'

def load(name,path):
 spec=importlib.util.spec_from_file_location(name,path);module=importlib.util.module_from_spec(spec);sys.modules[name]=module;spec.loader.exec_module(module);return module
engine=load('invariant_finite_engine',ROOT/'03_ENGINE/finite_engine.py')
fulgurite=load('invariant_fulgurite',ROOT/'03_ENGINE/adapters/fulgurite.py')

def glyph(x):return SIGNS[engine.check(x)]
def decode(text):
 if not isinstance(text,str) or len(text)!=1 or text not in SIGNS:raise ValueError('expected exactly one station glyph')
 return ord(text)-ord('♈')
def angle(x):return Fraction(engine.check(x),12)
def decode_angle(turn):
 if not isinstance(turn,Fraction) or not 0<=turn<1 or (turn*12).denominator!=1:raise ValueError('not an exact canonical station angle')
 return int(turn*12)
def target_operation(text,operation):
 # Direct target-alphabet operations, independently evaluated from source engine.
 n=decode(text)
 if operation=='T':return SIGNS[n+1] if n<11 else SIGNS[0]
 if operation=='A':return SIGNS[n+6] if n<6 else SIGNS[n-6]
 if operation=='I':return SIGNS[0] if n==0 else SIGNS[12-n]
 if operation=='rho':return SIGNS[11-n]
 raise ValueError('unknown target operation')

def admit(program):
 """A new computed structural admission bridge, not a new BB score allocation."""
 trace=fulgurite.execute(program)
 actual_angle=angle(trace.after)
 expected_angle=(angle(trace.before)+Fraction(trace.delta,12))%1
 if actual_angle!=expected_angle:raise ValueError('angular correspondence violated')
 if glyph(trace.after)!=target_advance(glyph(trace.before),trace.delta):raise ValueError('glyph correspondence violated')
 return {'admitted':True,'canonical_id':trace.algorithm_id,'before':trace.before,'after':trace.after,'delta':trace.delta,'angle_degrees':trace.angle_degrees,'canonical_sha256':trace.canonical_sha256,'witnesses':{'strict_glyph_syntax':True,'source_lock':True,'directed_operation':True,'exact_angular_identity':True,'glyph_identity':True,'recoverable_state':decode(glyph(trace.after))==trace.after}}

def target_advance(text,delta):
 if type(delta) is not int or not 0<=delta<=6:raise ValueError('aspect index 0..6 required')
 result=text
 for _ in range(delta):result=target_operation(result,'T')
 return result

def verify():
 raw=(ROOT/'01_CANONICAL/157_ALGORITHMS_LOCKED.jsonl').read_bytes()
 if hashlib.sha256(raw).hexdigest()!=LOCK:raise ValueError('canonical lock changed')
 binding=json.loads((ROOT/'INVARIANT_BINDINGS.json').read_text())
 for item in binding['frozen_inputs']:
  if hashlib.sha256((ROOT/item['path']).read_bytes()).hexdigest()!=item['sha256']:raise ValueError('frozen source or fixture changed: '+item['path'])
 fixtures=json.loads((ROOT/'03_ENGINE/ring_84_finite_transitions.json').read_text())
 if len(fixtures)!=84 or {(x['start'],x['delta']) for x in fixtures}!={(x,d) for x in range(12) for d in range(7)}:raise ValueError('fixture coverage changed')
 states=[];generators=[];angular=[];addresses=[];rejections=[]
 for x in range(12):
  if decode(glyph(x))!=x or decode_angle(angle(x))!=x:raise ValueError('state round trip failed')
  states.append({'state':x,'glyph':glyph(x),'degrees':x*30,'turn':str(angle(x)),'recovered_state':decode(glyph(x))})
  for op in ['T','A','I','rho']:
   y=engine.apply(x,op);target=target_operation(glyph(x),op)
   if glyph(y)!=target:raise ValueError('commuting square failed')
   generators.append({'source':x,'operator':op,'source_result':y,'h_of_f':glyph(y),'g_of_h':target,'preserved':True})
 for f in fixtures:
  x,d=f['start'],f['delta'];y=engine.apply(x,'aspect:'+str(d))
  if y!=f['finish'] or d*30!=f['angle_degrees']:raise ValueError('independent fixture mismatch')
  receipt=admit('☉'+glyph(x)+fulgurite.ASPECTS[d]+'☉'+glyph(y));angular.append(receipt)
 for d in range(12):
  for m in range(12):
   index=engine.address(d,m);recovered=engine.inverse_address(index)
   if recovered!={'domain':d,'modality':m}:raise ValueError('lattice identity lost')
   # Direct address operation: change column by six with the same row.
   target=index+6 if index%12<6 else index-6
   expected=engine.address(d,engine.apply(m,'A'))
   if target!=expected:raise ValueError('lattice operation not preserved')
   addresses.append({'domain':d,'modality':m,'address':index,'recovered':recovered,'opposition_address':target})
 # Negative controls are never counted as proof of an unrelated transfer.
 controls=[('inconsistent_endpoint','☉♈□☉♌'),('label_only','square aspect'),('keyword_padding','harmony geometric identity'),('unsupported_planet','☽♈□☉♋'),('trailing_payload','☉♈□☉♋ extra')]
 for name,program in controls:
  try:admit(program)
  except (ValueError,TypeError) as error:rejections.append({'control':name,'rejected':True,'reason':str(error)})
  else:raise ValueError('negative control admitted: '+name)
 wrong=[]
 for x in range(12):
  # A bijection with the right labels still fails when paired with unchanged target operations.
  perm=lambda z:glyph((5*z)%12)
  if perm(engine.apply(x,'T'))!=target_operation(perm(x),'T'):wrong.append(x)
 if not wrong:raise ValueError('label permutation control did not expose broken operation')
 rejections.append({'control':'bijective_labels_wrong_operation','rejected':True,'counterexample_states':wrong,'example':{'x':0,'h_of_T':glyph(5),'T_of_h':glyph(1)}})
 example=admit('☉♓□☉♊')
 return {'scope':'Explicit finite station/glyph/angle/address correspondence, not hidden-target transfer or historical-language interpretation','canonical_sha256':LOCK,'states':states,'generator_table':generators,'angular_traces':angular,'lattice_table':addresses,'negative_controls':rejections,'worked_example':example,'checks':{'state_round_trips':12,'generator_commutations':48,'angular_adapter_cases':84,'lattice_round_trips_and_oppositions':144,'negative_controls_rejected':6}}

if __name__=='__main__':
 try:print(json.dumps(verify(),ensure_ascii=False,indent=2))
 except Exception as error:print(json.dumps({'error':str(error)}));raise SystemExit(1)

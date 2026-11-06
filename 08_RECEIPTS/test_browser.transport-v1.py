"""ATLAS-WORKBENCH-01 obligation 3: real offline Chromium interactions."""
from pathlib import Path
import json,unittest,math
from playwright.sync_api import sync_playwright
ROOT=Path(__file__).resolve().parents[1]
class AtlasBrowser(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  cls.p=sync_playwright().start();cls.browser=cls.p.chromium.launch(executable_path='/usr/bin/chromium',headless=True,args=['--no-sandbox']);cls.observations=[]
 @classmethod
 def tearDownClass(cls):
  cls.browser.close();cls.p.stop()
  (ROOT/'08_RECEIPTS/browser_observations.json').write_text(json.dumps(cls.observations,indent=2))
 def setUp(self):
  self.context=self.browser.new_context(viewport={'width':1280,'height':900},reduced_motion='reduce',offline=True);self.page=self.context.new_page();self.errors=[];self.page.on('pageerror',lambda e:self.errors.append(str(e)));self.page.goto((ROOT/'02_ATLAS/index.html').as_uri());self.page.wait_for_selector('#SC-24');self.page.wait_for_timeout(80)
 def tearDown(self):
  self.assertEqual(self.errors,[]);self.context.close()
 def scene(self,i):
  self.page.evaluate('(i)=>{document.documentElement.style.scrollBehavior="auto";document.getElementById("SC-"+String(i).padStart(2,"0")).scrollIntoView({block:"start",behavior:"instant"})}',i);self.page.wait_for_timeout(60)
  return self.page.locator('#storyState').inner_text(),self.page.locator('#storyRing').inner_html(),self.page.locator('#storyAngle').inner_text()
 def test_every_scene_reversible(self):
  snapshots=[self.scene(i) for i in range(25)]
  for i in reversed(range(25)):self.assertEqual(self.scene(i),snapshots[i])
  self.assertEqual(self.page.locator('#scenes .chapter-card a').count(),50)
  self.observations.append({'test':'25_scenes_forward_and_reverse','snapshots':[x[0] for x in snapshots]})
 def test_84_angular_traces(self):
  for start in range(12):
   for d in range(7):
    self.page.select_option('#start',str(start));self.page.select_option('#delta',str(d));path=self.page.locator('#ringSvg path');self.assertEqual(path.get_attribute('data-angle'),str(30*d));self.assertEqual(path.get_attribute('data-finish'),str((start+d)%12))
    coords=self.page.evaluate('({start,d})=>{const p=document.querySelector("#ringSvg path");const n=p.getTotalLength();return {length:n,end:p.getPointAtLength(n).toJSON()}}',{'start':start,'d':d})
    self.assertAlmostEqual(coords['length'],92*math.pi*d/6,delta=.3)
    if d:self.assertAlmostEqual(coords['end']['x'],170+92*math.cos(((start+d)%12)*math.pi/6-math.pi/2),delta=.1)
  self.observations.append({'test':'directed_arcs','cases':84})
 def test_144_cells_and_keyboard(self):
  for d in range(12):
   for m in range(12):
    self.page.select_option('#domain',str(d));self.page.select_option('#modality',str(m));self.assertEqual(self.page.locator('.cell[aria-selected="true"]').get_attribute('data-index'),str(12*d+m))
  self.page.locator('.cell').nth(0).click();self.page.keyboard.press('ArrowLeft');self.assertEqual(self.page.locator('.cell:focus').get_attribute('data-index'),'143');self.page.keyboard.press('Home');self.assertEqual(self.page.locator('.cell:focus').get_attribute('data-index'),'0');self.page.keyboard.press('End');self.assertEqual(self.page.locator('.cell:focus').get_attribute('data-index'),'143')
  self.observations.append({'test':'lattice_addresses','cases':144})
 def test_registry_sources_copy(self):
  records=[json.loads(line) for line in (ROOT/'01_CANONICAL/157_ALGORITHMS_LOCKED.jsonl').read_text().splitlines()]
  for r in records:
   self.page.fill('#query',r['id']);self.page.get_by_role('button',name=r['id']+' · '+r['name'],exact=True).click();self.assertEqual(self.page.locator('#oldDewey').inner_text(),r['obsidian_dewey_v11_1_D00']);self.assertEqual(self.page.locator('#originalEnglish').inner_text(),r['english_container_original']);self.assertEqual(self.page.locator('#mathCode').inner_text(),r['mathematical_notation']);self.assertTrue(self.page.locator('#prov a').get_attribute('href').endswith('157_ALGORITHMS_LOCKED.jsonl'))
  self.page.fill('#query','no-such-record');self.assertEqual(self.page.locator('#recordCount').inner_text(),'0 of 157');self.page.fill('#query','');self.assertEqual(self.page.locator('#recordList button').count(),157)
  self.page.evaluate('window.copied=null;Object.defineProperty(navigator,"clipboard",{configurable:true,value:{writeText:async value=>{window.copied=value}}})');self.page.click('#copyDewey');self.assertEqual(self.page.evaluate('window.copied'),records[-1]['obsidian_dewey_v11_1_D00'])
  self.observations.append({'test':'canonical_record_rendering','cases':157})
 def test_operators_undo_redo(self):
  for op,expected in [('T',0),('A',5),('I',1),('rho',0)]:
   self.page.select_option('#start','11');self.page.select_option('#operator',op);self.page.click('#executeOperator');self.assertEqual(self.page.input_value('#start'),str(expected));self.page.click('#undoOperator');self.assertEqual(self.page.input_value('#start'),'11');self.page.click('#redoOperator');self.assertEqual(self.page.input_value('#start'),str(expected))
  self.page.click('#undoOperator');self.page.select_option('#operator','T');self.page.click('#executeOperator');self.assertTrue(self.page.locator('#redoOperator').is_disabled())
 def test_navigation_and_assets(self):
  self.scene(0);self.page.locator('#nextScene').click();self.page.wait_for_timeout(120);self.assertIn('Scene 2:',self.page.locator('#storyState').inner_text());self.page.locator('#previousScene').click();self.page.wait_for_timeout(120);self.assertIn('Scene 1:',self.page.locator('#storyState').inner_text())
  self.assertEqual(self.page.locator('#plates img').count(),8);self.assertEqual(self.page.locator('#sealGallery img').count(),14)
  self.page.evaluate('async()=>{await Promise.all([...document.images].map(im=>{im.loading="eager";return im.decode()}))}')
  self.assertTrue(self.page.evaluate('[...document.images].every(x=>x.naturalWidth>0&&x.alt.length>0)'))
  for href in self.page.locator('a').evaluate_all('(links)=>links.map(x=>x.getAttribute("href")).filter(x=>x&&!x.startsWith("#"))'):
   self.assertTrue((ROOT/'02_ATLAS'/href).resolve().is_file(),href)
 def test_mobile_accessible_reduced_motion(self):
  self.page.set_viewport_size({'width':320,'height':740});self.scene(12)
  self.assertLessEqual(self.page.evaluate('document.documentElement.scrollWidth'),320)
  self.assertEqual(self.page.locator('#storyRing').evaluate('(x)=>getComputedStyle(x).transform'),'none')
  for i in range(25):
   box=self.page.locator('#SC-'+str(i).zfill(2)+' .chapter-card').bounding_box();self.assertGreaterEqual(box['x'],0);self.assertLessEqual(box['x']+box['width'],321)
  self.page.evaluate('window.scrollTo(0,0)');self.page.keyboard.press('Tab');self.assertEqual(self.page.locator(':focus').inner_text(),'Skip to workbench');self.page.keyboard.press('Enter');self.assertEqual(self.page.locator(':focus').get_attribute('id'),'math')
  self.page.screenshot(path=str(ROOT/'08_RECEIPTS/mobile.png'),full_page=False)
 def test_animated_scroll_reversal(self):
  self.page.emulate_media(reduced_motion='no-preference');before=self.scene(7);self.scene(18);self.assertEqual(self.scene(7),before);self.assertNotEqual(self.page.locator('#storyRing').evaluate('(x)=>getComputedStyle(x).transform'),'none');self.page.screenshot(path=str(ROOT/'08_RECEIPTS/desktop.png'))
if __name__=='__main__':unittest.main(verbosity=2)

import unittest,threading,json
from pathlib import Path
from http.server import ThreadingHTTPServer,SimpleHTTPRequestHandler
from functools import partial
from playwright.sync_api import sync_playwright
ROOT=Path(__file__).resolve().parents[1]
class InvariantBrowser(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  cls.server=ThreadingHTTPServer(('127.0.0.1',0),partial(SimpleHTTPRequestHandler,directory=str(ROOT)));threading.Thread(target=cls.server.serve_forever,daemon=True).start();cls.url='http://127.0.0.1:'+str(cls.server.server_port);cls.p=sync_playwright().start();cls.browser=cls.p.chromium.launch(executable_path='/usr/bin/chromium',headless=True,args=['--no-sandbox'])
 @classmethod
 def tearDownClass(cls):cls.browser.close();cls.p.stop();cls.server.shutdown();cls.server.server_close()
 def setUp(self):
  self.context=self.browser.new_context(viewport={'width':1280,'height':900},reduced_motion='reduce');self.context.route('**/*',lambda r:r.continue_() if r.request.url.startswith(self.url+'/') else r.abort());self.page=self.context.new_page();self.errors=[];self.page.on('pageerror',lambda e:self.errors.append(str(e)));self.page.goto(self.url+'/02_ATLAS/index.html#invariant')
 def tearDown(self):self.assertEqual(self.errors,[]);self.context.close()
 def test_all_84_mappings_and_broken_counterparts(self):
  for x in range(12):
   for d in range(7):
    self.page.select_option('#invStart',str(x));self.page.select_option('#invDelta',str(d));self.assertEqual(self.page.locator('#invResult').get_attribute('data-admitted'),'true');self.page.click('#invBreak');self.assertEqual(self.page.locator('#invResult').get_attribute('data-admitted'),'false');self.page.click('#invBuild');self.assertEqual(self.page.locator('#invResult').get_attribute('data-admitted'),'true')
 def test_visible_identity_controls_and_mobile(self):
  self.assertEqual(self.page.input_value('#invProgram'),'☉♓□☉♊');self.assertIn('Expected state: 2',self.page.locator('#invSquare').inner_text());self.page.fill('#invProgram','harmonic geometric identity');self.page.click('#invRun');self.assertEqual(self.page.locator('#invResult').get_attribute('data-admitted'),'false');self.page.click('#invBuild');self.page.set_viewport_size({'width':320,'height':740});self.assertLessEqual(self.page.evaluate('document.documentElement.scrollWidth'),320);self.page.screenshot(path=str(ROOT/'verification/invariant-legibility/explorer-mobile.png'));self.page.set_viewport_size({'width':1280,'height':900});self.page.screenshot(path=str(ROOT/'verification/invariant-legibility/explorer-desktop.png'))
if __name__=='__main__':unittest.main(verbosity=2)

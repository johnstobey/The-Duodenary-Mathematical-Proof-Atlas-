#!/usr/bin/env python3
"""Serve the offline atlas locally with no network dependencies."""
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import os

if __name__ == '__main__':
    os.chdir(Path(__file__).resolve().parents[1])
    print('Tobey / Raven canonical atlas: http://localhost:8765/02_ATLAS/index.html', flush=True)
    ThreadingHTTPServer(('127.0.0.1',8765),SimpleHTTPRequestHandler).serve_forever()

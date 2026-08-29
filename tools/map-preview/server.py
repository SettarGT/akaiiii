#!/usr/bin/env python3
"""Dizayn baxışı serveri — yalnız inkişaf üçündür (FiveM ilə əlaqəsi yoxdur).

Repo kökünü statik fayl kimi verir, amma '/' ünvanını dizayn baxışı
səhifəsinə yönləndirir. Beləliklə brauzerdə /xerite interfeysini görmək olur.
"""

import http.server
import os
import socketserver

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=ROOT, **kwargs)

    def do_GET(self):
        if self.path in ('/', ''):
            self.path = '/tools/map-preview/index.html'
        return super().do_GET()


class Server(socketserver.ThreadingTCPServer):
    allow_reuse_address = True
    daemon_threads = True


if __name__ == '__main__':
    print('Dizayn baxışı: http://0.0.0.0:8080/')
    Server(('0.0.0.0', 8080), Handler).serve_forever()

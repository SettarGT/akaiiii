#!/usr/bin/env python3
"""Lua sintaksis yoxlaması — resources/[196rp] üçün.

luaparser ilə hər .lua faylını parse edir. Xəta varsa exit code 1 qaytarır.
Qeyd: [core] resursları bilərəkdən yoxlanmır — orada luaparser-in başa düşmədiyi
Lua 5.4 atribut sintaksisi (`?`, backtick) var və onlar false positive verir.

İstifadə:  python3 tools/ci/check_syntax.py [qovluq]
"""
import os
import sys

from luaparser import ast as lua_ast

ROOT = sys.argv[1] if len(sys.argv) > 1 else 'resources/[196rp]'


def main():
    checked = 0
    errors = []

    for dirpath, _dirs, files in os.walk(ROOT):
        for name in sorted(files):
            if not name.endswith('.lua'):
                continue
            path = os.path.join(dirpath, name)
            checked += 1
            try:
                lua_ast.parse(open(path, encoding='utf-8').read())
            except Exception as exc:  # noqa: BLE001 - parser xətası
                errors.append((path, str(exc).split('\n')[0][:160]))

    for path, msg in errors:
        print('SINTAKSIS XETASI: %s\n    %s' % (path, msg))

    print('[syntax] yoxlanılan fayl: %d, xəta: %d' % (checked, len(errors)))
    return 1 if errors else 0


if __name__ == '__main__':
    sys.exit(main())

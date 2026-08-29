#!/usr/bin/env python3
"""196 RP — Lua unit test icraçısı.

`lupa` vasitəsilə real Lua mühitində (Lua 5.5) işləyir: konfiq faylları
yükLƏNİR və testlər HƏQİQİ kodu yoxlayır (kopya/stand-in deyil).

Quraşdırma:  pip3 install lupa
İstifadə:    python3 tools/tests/run_tests.py
"""
import os
import sys

try:
    import lupa
except ImportError:
    print('XƏTA: lupa quraşdırılmayıb →  pip3 install lupa')
    sys.exit(2)

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# (qrup adı, yüklənən konfiqlər, test faylları)
GROUPS = [
    ('Bakı xəritəsi',
     ['resources/[196rp]/196rp_bakumap/config.lua'],
     ['tools/tests/test_bakumap.lua']),

    ('3D obyekt qatı',
     ['resources/[196rp]/196rp_bakumap/config.lua',
      'resources/[196rp]/196rp_bakumap/objects.lua'],
     ['tools/tests/test_objects.lua']),

    ('Telefon mağazası',
     ['resources/[196rp]/196rp_phoneshop/config.lua'],
     ['tools/tests/test_phoneshop.lua']),

    ('İqtisadiyyat',
     ['resources/[196rp]/196rp_economy/config.lua'],
     ['tools/tests/test_economy.lua']),
]


def read(path):
    with open(os.path.join(ROOT, path), encoding='utf-8') as handle:
        return handle.read()


def run_group(group_name, configs, tests):
    lua = lupa.LuaRuntime(unpack_returned_tuples=True)
    lua.execute(read('tools/tests/prelude.lua'))

    for cfg in configs:
        lua.execute(read(cfg))

    for test_file in tests:
        lua.execute(read(test_file))

    table = lua.globals().TEST_RESULTS
    results = []

    for i in range(1, len(table) + 1):
        item = table[i]
        results.append({
            'group': group_name,
            'name': item['name'],
            'ok': bool(item['ok']),
            'err': None if item['ok'] else str(item['err']),
        })

    return results


def main():
    all_results = []
    skipped = []

    for group_name, configs, tests in GROUPS:
        missing = [p for p in configs + tests if not os.path.exists(os.path.join(ROOT, p))]

        if missing:
            skipped.append((group_name, missing[0]))
            continue

        try:
            all_results.extend(run_group(group_name, configs, tests))
        except Exception as exc:  # noqa: BLE001
            all_results.append({
                'group': group_name,
                'name': 'QRUP YÜKLƏNƏ BİLMƏDİ',
                'ok': False,
                'err': str(exc)[:300],
            })

    current = None
    failures = 0

    for res in all_results:
        if res['group'] != current:
            current = res['group']
            print('\n== %s ==' % current)

        mark = 'PASS' if res['ok'] else 'FAIL'
        print('  [%s] %s' % (mark, res['name']))

        if not res['ok']:
            failures += 1
            print('         %s' % (res['err'] or ''))

    for group_name, path in skipped:
        print('\n== %s == SKIPPED (%s tapılmadı)' % (group_name, path))

    total = len(all_results)
    print('\n[unit] cəmi: %d, keçdi: %d, uğursuz: %d, buraxıldı: %d'
          % (total, total - failures, failures, len(skipped)))

    return 1 if failures else 0


if __name__ == '__main__':
    sys.exit(main())

#!/usr/bin/env python3
"""Manifest və qeydiyyat yoxlaması.

- Hər resursda fxmanifest.lua olmalıdır
- fxmanifest-də göstərilən bütün fayllar (shared/client/server/ui_page/files) mövcud olmalıdır
- server.cfg-dəki ensure sətirləri real resurslara uyğun olmalıdır
- Eyni əmr iki resursda qeydiyyatdan keçməməlidir
"""
import os
import re
import sys

RES_ROOT = 'resources/[196rp]'
RES_ROOTS = ['resources/[196rp]', 'resources/[system]']
problems = []

# FiveM server artifacts ilə birlikdə gələn, repo-da saxlanmayan resurslar
CFX_BUILTIN = {
    'chat', 'spawnmanager', 'sessionmanager', 'sessionmanager-rdr3', 'mapmanager',
    'hardknight', 'monitor', 'rconlog', 'yarn', 'webpack', 'oxmysql', 'qb-core',
    'ox_lib', 'baseevents', 'basic-gamemode', 'hardcap',
}


def res_dirs():
    seen = set()
    for root in RES_ROOTS:
        if not os.path.isdir(root):
            continue
        for name in sorted(os.listdir(root)):
            path = os.path.join(root, name)
            if os.path.isdir(path) and name not in seen:
                seen.add(name)
                yield name, path


# ---------- 1. fxmanifest mövcudluğu və fayl referansları ----------
referenced_lua = []


def res_path(base, ref):
    """FiveM manifest yolu: başlanğıc '/' resurs kökünə nəzərən olur."""
    return os.path.join(base, ref.lstrip('/'))


for res, path in res_dirs():
    manifest = os.path.join(path, 'fxmanifest.lua')

    if not os.path.exists(manifest):
        problems.append('%s: fxmanifest.lua yoxdur' % res)
        continue

    text = open(manifest, encoding='utf-8').read()

    # ui_page
    m = re.search(r"ui_page\s+'([^']+)'", text)
    if m and not os.path.exists(res_path(path, m.group(1))):
        problems.append('%s: ui_page faylı yoxdur → %s' % (res, m.group(1)))

    # files { ... } bloku
    for block in re.findall(r'files\s*\{([^}]*)\}', text, re.S):
        for ref in re.findall(r"'([^']+)'", block):
            if '*' in ref:
                continue
            if not os.path.exists(res_path(path, ref)):
                problems.append('%s: files içindəki fayl yoxdur → %s' % (res, ref))

    # script faylları
    for block in re.findall(r'(?:shared_scripts|client_scripts|server_scripts)\s*\{([^}]*)\}', text, re.S):
        for ref in re.findall(r"'([^']+)'", block):
            if ref.startswith('@'):
                other = ref[1:]
                base = other.split('/')[0]
                candidates = [
                    os.path.join('resources', '[qb]', other),
                    os.path.join('resources', '[standalone]', other),
                    os.path.join('resources', '[196rp]', other),
                    os.path.join('resources', '[voice]', other),
                    os.path.join('resources', '[defaultmaps]', other),
                ]
                if not any(os.path.exists(c) for c in candidates):
                    problems.append('%s: idxal olunan fayl yoxdur → %s' % (res, ref))
            else:
                if not os.path.exists(res_path(path, ref)):
                    problems.append('%s: script faylı yoxdur → %s' % (res, ref))
                else:
                    referenced_lua.append(res_path(path, ref))

# ---------- 2. server.cfg ensure sətirləri ----------
if os.path.exists('server.cfg'):
    cfg = open('server.cfg', encoding='utf-8').read()
    ensured = set(re.findall(r'^ensure\s+([A-Za-z0-9_\-\[\]]+)', cfg, re.M))
    bracket_ensured = set(re.findall(r'^ensure\s+(\[[^\]]+\])', cfg, re.M))
    existing = set()
    for root_dir in sorted(os.listdir('resources')):
        rp = os.path.join('resources', root_dir)
        if os.path.isdir(rp):
            for name in sorted(os.listdir(rp)):
                if os.path.isdir(os.path.join(rp, name)):
                    existing.add(name)
    for br in bracket_ensured:
        for name in sorted(os.listdir(os.path.join('resources', br))):
            if os.path.isdir(os.path.join('resources', br, name)):
                ensured.add(name)

    for name in sorted(ensured):
        if name.startswith('[') or name in CFX_BUILTIN:
            continue
        if name not in existing:
            problems.append('server.cfg: ensure %s — belə resurs yoxdur' % name)

    missing = sorted(existing - ensured)
    if missing:
        problems.append('server.cfg-də ensure olunmayan resurslar: %s' % ', '.join(missing))
else:
    problems.append('server.cfg tapılmadı')

# ---------- 3. təkrarlanan əmr qeydiyyatları ----------
commands = {}

for dirpath, _dirs, files in os.walk(RES_ROOT):
    for name in files:
        if not name.endswith('.lua'):
            continue
        path = os.path.join(dirpath, name)
        for i, line in enumerate(open(path, encoding='utf-8'), 1):
            m = re.search(r"RegisterCommand\(\s*'([^']+)'", line)
            if m:
                cmd = m.group(1)
                commands.setdefault(cmd, []).append('%s:%d' % (path, i))

def context_of(where):
    # (resurs, tərəf) cütlükləri — eyni resursda client+server cütlüyü normaldır
    pairs = set()
    for w in where:
        path = w.rsplit(':', 1)[0]
        res = os.path.relpath(path, RES_ROOT).split(os.sep)[0]
        side = 'server' if '/server/' in path else 'client'
        pairs.add((res, side))
    return pairs


for cmd, where in sorted(commands.items()):
    pairs = context_of(where)
    distinct_resources = {res for res, _side in pairs}

    if len(distinct_resources) > 1:
        problems.append('əmr "%s" müxtəlif resurslarda təkrarlanır: %s'
                        % (cmd, ', '.join(sorted(distinct_resources))))
    elif len(pairs) > 1 and len({side for _res, side in pairs}) < 2:
        problems.append('əmr "%s" eyni tərəfdə təkrarlanır: %s' % (cmd, ', '.join(where)))

for p in problems:
    print('  PROBLEM: %s' % p)

print('[manifest] resurs: %d, əmr: %d, problem: %d'
      % (len(list(res_dirs())), len(commands), len(problems)))
sys.exit(1 if problems else 0)

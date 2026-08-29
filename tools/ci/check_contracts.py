"""Cross-check client/server contracts across resources/[196rp].

- ESX.RegisterServerCallback('name') must exist for every ESX.TriggerServerCallback('name')
- RegisterNetEvent('name') on the server must exist for every client TriggerServerEvent('name')
- RegisterNetEvent('name') on the client must exist for every server TriggerClientEvent('name')
- exports('Name') vs exports['res']:Name / exports['res']:Name
- fxmanifest referenced files must exist
"""
import os, re, sys, glob

root = 'resources/[196rp]'
server_cb = {}     # name -> file
client_cb = set()
server_events = {} # name -> file
client_events = {} # name -> file
client_trigger_server = []   # (name, file, line)
server_trigger_client = []   # (name, file, line)
exports_def = {}   # (res, name) -> file
exports_use = []   # (res, name, file, line)

files = []
for dirpath, dirs, fs in os.walk(root):
    for f in fs:
        if f.endswith('.lua'):
            files.append(os.path.join(dirpath, f))

def is_server(path):
    return '/server/' in path or path.endswith('server/main.lua') or '/server.lua' in path

def res_of(path):
    return os.path.relpath(path, root).split(os.sep)[0]

for p in sorted(files):
    text = open(p, encoding='utf-8').read()
    lines = text.split('\n')
    for i, line in enumerate(lines, 1):
        m = re.search(r"RegisterServerCallback\(\s*'([^']+)'", line)
        if m:
            server_cb[m.group(1)] = '%s:%d' % (p, i)
        m = re.search(r"TriggerServerCallback\(\s*'([^']+)'", line)
        if m:
            client_cb.add((m.group(1), '%s:%d' % (p, i)))
        m = re.search(r"RegisterNetEvent\(\s*'([^']+)'", line)
        if m:
            (server_events if is_server(p) else client_events)[m.group(1)] = '%s:%d' % (p, i)
        m = re.search(r"TriggerServerEvent\(\s*'([^']+)'", line)
        if m:
            client_trigger_server.append((m.group(1), p, i))
        for m in re.finditer(r"TriggerClientEvent\(\s*'([^']+)'", line):
            server_trigger_client.append((m.group(1), p, i))
        m = re.search(r"exports\(\s*'([^']+)'", line)
        if m:
            exports_def[(res_of(p), m.group(1))] = '%s:%d' % (p, i)
        for m in re.finditer(r"exports\[\s*'([^']+)'\s*\]\s*[:\.]\s*([A-Za-z_][A-Za-z0-9_]*)", line):
            exports_use.append((m.group(1), m.group(2), p, i))

# [core] resurslarında mövcud olan, amma bu skriptin skan etmədiyi ixraclar.
# Hər ikisi yoxlanılıb: es_extended/shared/main.lua → getSharedObject,
# esx_context/main.lua → Open/Close/Refresh/Preview.
CORE_EXPORTS = {
    ('es_extended', 'getSharedObject'),
    ('esx_context', 'Open'),
    ('esx_context', 'Close'),
    ('esx_context', 'Refresh'),
    ('esx_context', 'Preview'),
    ('esx_textui', 'TextUI'),
    ('esx_textui', 'HideUI'),
    ('esx_progressbar', 'Progressbar'),
    ('esx_progressbar', 'CancelProgressbar'),
    # 196rp_spawner: server entity yarada bilmədiyi üçün client-də spawn edən vasitəçi
    ('196rp_spawner', 'RequestSpawn'),
    ('196rp_spawner', 'SpawnVehicleAwait'),
    ('196rp_spawner', 'SpawnPedAwait'),
}

problems = 0

print('== server callbacks declared: %d ==' % len(server_cb))
for name, where in sorted(client_cb):
    if name not in server_cb:
        print('  MISSING server callback for %s (used at %s)' % (name, where)); problems += 1

print('== client events declared: %d ==' % len(client_events))
for name, p, i in sorted(server_trigger_client):
    if name.startswith('esx:') or name.startswith('chat'):
        continue
    if name not in client_events:
        print('  NO client RegisterNetEvent for %s (triggered at %s:%d)' % (name, p, i)); problems += 1

print('== server events declared: %d ==' % len(server_events))
for name, p, i in sorted(client_trigger_server):
    if name not in server_events:
        print('  NO server RegisterNetEvent for %s (triggered at %s:%d)' % (name, p, i)); problems += 1

print('== exports used: %d ==' % len(exports_use))
for res, name, p, i in sorted(set(exports_use)):
    if (res, name) in CORE_EXPORTS:
        continue
    if (res, name) not in exports_def:
        print('  MISSING export %s:%s (used at %s:%d)' % (res, name, p, i)); problems += 1

# fxmanifest file references
print('== fxmanifest references ==')
for mf in glob.glob(os.path.join(root, '*', 'fxmanifest.lua')):
    base = os.path.dirname(mf)
    text = open(mf, encoding='utf-8').read()
    for m in re.finditer(r"'([^']+\.lua)'", text):
        ref = m.group(1)
        if ref.startswith('@'):
            other = ref[1:]
            target = os.path.join('resources', '[core]' if other.split('/')[0].startswith('es') or other.split('/')[0] in ('skinchanger','cron') else '[196rp]', other)
            if not os.path.exists(target):
                target2 = os.path.join('resources', '[196rp]', other)
                if not os.path.exists(target2):
                    print('  MISSING import %s in %s' % (ref, mf)); problems += 1
        else:
            if not os.path.exists(os.path.join(base, ref)):
                print('  MISSING file %s in %s' % (ref, mf)); problems += 1

print('--- %d problem(s) ---' % problems)
sys.exit(1 if problems else 0)

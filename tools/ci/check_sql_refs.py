import os, re
import sys

sql = open('196rp.sql', encoding='utf-8').read()

# items defined in SQL
items = set(re.findall(r"^\('([a-z_0-9]+)',\s*'", sql, re.M))
# jobs defined in SQL
jobs = set(re.findall(r"\('([a-z_0-9]+)',\s*'[^']*',\s*'(?:civ|leo|ems|job)'", sql))
# licenses
lics = set()
for mblock in re.finditer(r"INSERT(?: IGNORE)? INTO `licenses`[^;]*;", sql):
    lics |= set(re.findall(r"\('([a-z_0-9]+)',\s*'[^']*'\)", mblock.group(0)))

root = 'resources/[196rp]'
item_refs = {}
job_refs = {}
lic_refs = {}

keys_item = ['item', 'giveItem', 'giveItem2', 'output', 'takeItem', 'moneyItem', 'fakeIdItem',
             'scrapItem', 'ringItem', 'toolItem']

for dirpath, dirs, files in os.walk(root):
    for f in files:
        if not f.endswith('.lua'):
            continue
        p = os.path.join(dirpath, f)
        text = open(p, encoding='utf-8').read()
        for i, line in enumerate(text.split('\n'), 1):
            for k in keys_item:
                for m in re.finditer(r"\b%s\s*=\s*'([a-z_0-9]+)'" % k, line):
                    item_refs.setdefault(m.group(1), []).append('%s:%d' % (p, i))
            m = re.search(r"\{ item = '([a-z_0-9]+)'", line)
            if m:
                item_refs.setdefault(m.group(1), []).append('%s:%d' % (p, i))
            m = re.search(r"illegalItems\s*=\s*\{([^}]*)\}", line)
            if m:
                for name in re.findall(r"'([a-z_0-9]+)'", m.group(1)):
                    item_refs.setdefault(name, []).append('%s:%d' % (p, i))
            for m in re.finditer(r"\bjob\s*=\s*'([a-z_0-9]+)'", line):
                job_refs.setdefault(m.group(1), []).append('%s:%d' % (p, i))
            for m2 in re.finditer(r"\btype = '([a-z_0-9]+)',\s*\n?\s*label = '[^']*(?:vəsiqə|Vəsiqə)", line):
                lic_refs.setdefault(m2.group(1), []).append('%s:%d' % (p, i))
            for m2 in re.finditer(r"requires = '([a-z_0-9]+)'", line):
                lic_refs.setdefault(m2.group(1), []).append('%s:%d' % (p, i))
            for m2 in re.finditer(r"licenseTypes\s*=\s*\{([^}]*)\}", line):
                for name in re.findall(r"'([a-z_0-9]+)'", m2.group(1)):
                    lic_refs.setdefault(name, []).append('%s:%d' % (p, i))

print('SQL defines %d items, %d jobs, %d license-ish rows' % (len(items), len(jobs), len(lics)))
print('configs reference %d distinct items, %d jobs, %d license types' % (len(item_refs), len(job_refs), len(lic_refs)))

missing = 0
for name in sorted(item_refs):
    if name not in items:
        print('  ITEM MISSING in SQL: %s  <- %s' % (name, ', '.join(item_refs[name][:3])))
        missing += 1
for name in sorted(job_refs):
    if name not in jobs:
        print('  JOB MISSING in SQL: %s  <- %s' % (name, ', '.join(job_refs[name][:3])))
        missing += 1
for name in sorted(lic_refs):
    if name not in lics:
        print('  LICENSE MISSING in SQL: %s  <- %s' % (name, ', '.join(lic_refs[name][:3])))
        missing += 1
print('--- %d missing reference(s) ---' % missing)

sys.exit(1 if missing else 0)

"""Forward-reference check restricted to chunk-level `local function` helpers.

A reference to a chunk-level local that appears before its `local function`
declaration compiles to a *global* lookup (nil at runtime), no matter when the
enclosing function is called.
"""
import os, re, sys

decl_re = re.compile(r'^local\s+function\s+([A-Za-z_][A-Za-z0-9_]*)')
also_local_re = re.compile(r'^local\s+([A-Za-z_][A-Za-z0-9_]*)\b')

def strip_noise(line):
    line = re.sub(r'--.*$', '', line)
    line = re.sub(r'"[^"]*"', '""', line)
    line = re.sub(r"'[^']*'", "''", line)
    return line

root = sys.argv[1]
total = 0
for dirpath, dirs, files in os.walk(root):
    for f in sorted(files):
        if not f.endswith('.lua'):
            continue
        p = os.path.join(dirpath, f)
        lines = open(p, encoding='utf-8').read().split('\n')
        decls = {}
        for i, line in enumerate(lines, 1):
            m = decl_re.match(line)
            if m and m.group(1) not in decls:
                decls[m.group(1)] = i
        for name, dline in decls.items():
            pat = re.compile(r'(?<![\w.:])' + re.escape(name) + r'(?![\w])')
            for i, line in enumerate(lines, 1):
                if i >= dline:
                    break
                clean = strip_noise(line)
                if pat.search(clean):
                    print('%s:%d: `%s` referenced before `local function %s` at line %d' % (p, i, name, name, dline))
                    print('      %s' % clean.strip()[:110])
                    total += 1
print('--- %d finding(s) ---' % total)
print('exit: %d' % (1 if total else 0))
sys.exit(1 if total else 0)

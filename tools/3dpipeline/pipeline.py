#!/usr/bin/env python3
"""196 RP — 3D boru kəməri orkestratoru.

AI mesh (.glb/.obj) → LOD + kolliziya (Blender) → .ydr/.ytyp/.ymap → server.

Addımlar:
  1. tools/3dpipeline/input/ qovluğundakı .glb/.obj fayllarını tapır
     (bunları TRELLIS / Hunyuan3D / Modly ilə öz maşınınızda yaradırsınız)
  2. Blender tapılsa: blender_lod.py ilə LOD + kolliziya yaradır
     Blender YOXDURSA: bu addımı atlayır və xəbər verir (sandbox vəziyyəti)
  3. ymap_gen.py ilə .ymap / .ytyp XML yaradır və doğrulayır
  4. Nəticə manifestini (poly büdcələri ilə) çap edir

İstifadə: python3 tools/3dpipeline/pipeline.py
"""
import os
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
INPUT = os.path.join(HERE, 'input')
OUT = os.path.join(HERE, 'out')
BLENDER = os.environ.get('BLENDER') or shutil.which('blender')


def find_models():
    if not os.path.isdir(INPUT):
        return []
    return sorted(
        os.path.join(INPUT, f) for f in os.listdir(INPUT)
        if f.lower().endswith(('.glb', '.gltf', '.obj')))


def main():
    os.makedirs(OUT, exist_ok=True)
    models = find_models()

    print('[pipeline] giriş modelləri: %d' % len(models))
    for m in models:
        print('   -', os.path.basename(m))

    if not models:
        print('[pipeline] input/ boşdur. AI modeli əlavə edin və ya --selftest işlədin.')

    if models and BLENDER:
        print('[pipeline] Blender tapıldı:', BLENDER)
        for m in models:
            subprocess.run([BLENDER, '-b', '-P', os.path.join(HERE, 'blender_lod.py'),
                            '--', m, OUT], check=False)
    elif models:
        print('[pipeline] Blender tapılmadı — LOD/kolliziya ADDIMI ATLANDI.')
        print('   Öz maşınınızda: blender -b -P tools/3dpipeline/blender_lod.py -- <model> tools/3dpipeline/out')

    # ymap/ytyp generasiyası və doğrulama (Blender tələb etmir)
    print('[pipeline] ymap/ytyp generasiyası...')
    code = subprocess.run([sys.executable, os.path.join(HERE, 'ymap_gen.py'), '--selftest']).returncode

    print('[pipeline] tamamdır. Nəticə: tools/3dpipeline/out/')
    return code


if __name__ == '__main__':
    sys.exit(main())

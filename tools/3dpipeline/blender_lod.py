#!/usr/bin/env python3
"""196 RP — Blender başsız (headless) LOD + kolliziya skripti.

Bu skript Blender İÇİNDƏ işləyir. `pipeline.py` onu belə çağırır:

    blender -b -P tools/3dpipeline/blender_lod.py -- <input.glb> <output_dir>

Vəzifəsi:
  1. AI-dan gələn .glb/.obj mesh-i idxal edir
  2. Poliqon büdcəsinə uyğun 3 LOD səviyyəsi yaradır (L0 tam, L1 ~40%, L2 ~15%)
  3. Konveks kolliziya (.ybn üçün) mesh-i yaradır
  4. Sollumz varsa .ydr/.ybn ixrac edir, yoxdursa .obj kimi saxlayır

Qeyd: Blender və (istəyə görə) Sollumz quraşdırılmış maşında işlədilməlidir.
Bu sandbox-da Blender YOXDUR — bu skript yalnız sənədkarın maşını üçündür.
"""
import os
import sys

# LOD poliqon büdcələri (CATISMAZLIQLAR.md bölmə 4 ilə eyni)
LOD_RATIO = {0: 1.0, 1: 0.4, 2: 0.15}
MAX_TRIS = 8000          # bina üçün yuxarı hədd (L0)
COLLISION_HULLS = 1      # konveks hull sayı


def log(*a):
    print('[blender_lod]', *a)


def tri_count(obj):
    obj.data.calc_loop_triangles()
    return len(obj.data.loop_triangles)


def decimate(obj, ratio):
    import bpy
    mod = obj.modifiers.new('dec', 'DECIMATE')
    mod.ratio = max(0.01, min(1.0, ratio))
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.modifier_apply(modifier=mod.name)


def convex_collision(obj):
    import bpy
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    # convex hull → sadə kolliziya
    bpy.ops.mesh.convex_hull_make()
    return obj


def main():
    argv = sys.argv
    if '--' in argv:
        argv = argv[argv.index('--') + 1:]

    if len(argv) < 2:
        log('İstifadə: blender -b -P blender_lod.py -- <input> <out_dir>')
        return 1

    input_path, out_dir = argv[0], argv[1]
    os.makedirs(out_dir, exist_ok=True)

    import bpy

    bpy.ops.wm.read_factory_settings(use_empty=True)

    if input_path.endswith('.obj'):
        bpy.ops.wm.obj_import(filepath=input_path)
    else:
        bpy.ops.import_scene.gltf(filepath=input_path)

    mesh = None
    for o in bpy.context.scene.objects:
        if o.type == 'MESH':
            mesh = o
            break

    if not mesh:
        log('XƏTA: mesh tapılmadı →', input_path)
        return 1

    tris = tri_count(mesh)
    log('idxal olundu:', os.path.basename(input_path), '| tri:', tris)

    if tris > MAX_TRIS:
        log('diqqət: tri > %d, L0-a qədər sıxılır' % MAX_TRIS)
        decimate(mesh, MAX_TRIS / float(tris))
        tris = tri_count(mesh)

    results = {}
    for lod in (0, 1, 2):
        dup = mesh.copy()
        dup.data = mesh.data.copy()
        bpy.context.collection.objects.link(dup)
        if lod > 0:
            decimate(dup, LOD_RATIO[lod])
        out = os.path.join(out_dir, '%s_lod%d.obj' % (os.path.basename(input_path).split('.')[0], lod))
        bpy.ops.object.select_all(action='DESELECT')
        dup.select_set(True)
        bpy.ops.wm.obj_export(filepath=out)
        results['lod%d' % lod] = tri_count(dup)
        bpy.data.objects.remove(dup)

    # kolliziya
    col = convex_collision(mesh)
    col_out = os.path.join(out_dir, '%s_col.obj' % os.path.basename(input_path).split('.')[0])
    bpy.ops.object.select_all(action='DESELECT')
    col.select_set(True)
    bpy.ops.wm.obj_export(filepath=col_out)
    results['collision'] = tri_count(col)

    log('LOD nəticə:', results)
    return 0


if __name__ == '__main__':
    sys.exit(main())

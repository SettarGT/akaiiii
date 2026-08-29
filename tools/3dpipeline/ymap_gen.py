#!/usr/bin/env python3
"""196 RP — GTA V ymap/ytyp generatoru.

AI ilə yaradılmış (.glb/.obj) modelləri və hazır prop adlarını CodeWalker-ün
oxuya biləcəyi `.ymap` (yerləşdirmə) və `.ytyp` (arxetip) XML-ə çevirir.

Bu modulun XML hissəsi Blender tələb etmir və self-test ilə yoxlanıla bilər:
    python3 tools/3dpipeline/ymap_gen.py --selftest

Blender tələb edən hissə (LOD + kolliziya) `blender_lod.py`-dədir və
`pipeline.py` tərəfindən yalnız Blender tapılanda çağırılır.
"""
import argparse
import json
import math
import os
import sys
import xml.etree.ElementTree as ET

DEFAULT_OUT = os.path.join(os.path.dirname(__file__), 'out')


def quat_from_heading(heading_deg):
    """Y fırlanmasını kvaterniona çevirir (GTA yaw)."""
    h = math.radians(heading_deg)
    return {
        'x': 0.0,
        'y': 0.0,
        'z': math.sin(h / 2.0),
        'w': math.cos(h / 2.0),
    }


def make_entity(name, x, y, z, heading=0.0, lod_dist=100.0, child_lod=0.0):
    r = quat_from_heading(heading)
    return {
        'archetypeName': name,
        'position': (x, y, z),
        'rotation': r,
        'lodDist': lod_dist,
        'childLodDist': child_lod,
    }


def write_ymap(path, map_name, entities, extents=300.0):
    root = ET.Element('CMapData')

    def tag(parent, name, **attrs):
        el = ET.SubElement(parent, name)
        for k, v in attrs.items():
            el.set(k, str(v))
        return el

    tag(root, 'name').text = map_name
    tag(root, 'parent').text = 'v_parent'
    tag(root, 'flags', value='0')
    tag(root, 'contentFlags', value='65')
    tag(root, 'streamingExtentsMin', x=-extents, y=-extents, z=0)
    tag(root, 'streamingExtentsMax', x=extents, y=extents, z=200)
    tag(root, 'entitiesExtentsMin', x=-extents, y=-extents, z=0)
    tag(root, 'entitiesExtentsMax', x=extents, y=extents, z=200)

    ents = ET.SubElement(root, 'entities')
    ET.SubElement(ents, 'Item')  # placeholder — aşağıda doldurulur

    for e in entities:
        item = ET.SubElement(ents, 'Item', type='CMapEntity')
        ET.SubElement(item, 'archetypeName').text = e['archetypeName']
        ET.SubElement(item, 'flags', type='uint32', value='1552')
        tag(item, 'guid', value='0')
        p = e['position']
        tag(item, 'position', x=p[0], y=p[1], z=p[2])
        r = e['rotation']
        tag(item, 'rotation', x=r['x'], y=r['y'], z=r['z'], w=r['w'])
        ET.SubElement(item, 'scaleXY', value='1')
        ET.SubElement(item, 'scaleZ', value='1')
        ET.SubElement(item, 'parentIndex', value='-1')
        ET.SubElement(item, 'lodDist', value=str(e['lodDist']))
        ET.SubElement(item, 'childLodDist', value=str(e['childLodDist']))
        ET.SubElement(item, 'lodLevel').text = 'LODTYPES_DEPTH_ORPHANLOD'
        ET.SubElement(item, 'numChildren', value='0')
        ET.SubElement(item, 'priorityLevel').text = 'PRI_REQUIRED'
        ET.SubElement(item, 'numAmbientExtensions', value='0')
        ET.SubElement(item, 'ambientOcclusionMultiplier', value='255')
        ET.SubElement(item, 'lightAmbientMult', value='1')

    ET.SubElement(root, 'containerLods')
    ET.SubElement(root, 'boxOccluders')
    ET.SubElement(root, 'occludeModels')
    ET.SubElement(root, 'physicsDictionaries')
    ET.SubElement(root, 'instancedData')
    ET.SubElement(root, 'timeCycleModifiers')
    ET.SubElement(root, 'carGenerators')
    ET.SubElement(root, 'LODLightsLODs')
    ET.SubElement(root, 'entityExtensions')

    tree = ET.ElementTree(root)
    ET.indent(tree)
    tree.write(path, encoding='utf-8', xml_declaration=True)
    return len(entities)


def write_ytyp(path, archetypes):
    root = ET.Element('CMapTypes')

    def tag(parent, name, **attrs):
        el = ET.SubElement(parent, name)
        for k, v in attrs.items():
            el.set(k, str(v))
        return el

    ET.SubElement(root, 'extensions')
    archs = ET.SubElement(root, 'archetypes')

    for a in archetypes:
        item = ET.SubElement(archs, 'Item', type='CBaseArchetypeDef')
        ET.SubElement(item, 'lodDist', value=str(a.get('lodDist', 100)))
        ET.SubElement(item, 'flags', value='32')
        ET.SubElement(item, 'specialAttribute', value='0')
        tag(item, 'bbMin', x=a['bbMin'][0], y=a['bbMin'][1], z=a['bbMin'][2])
        tag(item, 'bbMax', x=a['bbMax'][0], y=a['bbMax'][1], z=a['bbMax'][2])
        tag(item, 'bsCentre', x=0, y=0, z=0)
        ET.SubElement(item, 'bsRadius', value=str(a.get('bsRadius', 10)))
        ET.SubElement(item, 'hdTextureDist', value=str(a.get('hdTextureDist', 30)))
        ET.SubElement(item, 'name').text = a['name']
        ET.SubElement(item, 'textureDictionary').text = a.get('txd', 'baku_txd')
        ET.SubElement(item, 'clipDictionary')
        ET.SubElement(item, 'drawableDictionary')
        ET.SubElement(item, 'physicsDictionary')
        ET.SubElement(item, 'assetType').text = 'ASSET_TYPE_DRAWABLE'
        ET.SubElement(item, 'assetName').text = a['name']
        ET.SubElement(item, 'extensions')

    tree = ET.ElementTree(root)
    ET.indent(tree)
    tree.write(path, encoding='utf-8', xml_declaration=True)
    return len(archetypes)


def validate_xml(path):
    try:
        ET.parse(path)
        return True, 'valid XML'
    except ET.ParseError as exc:
        return False, str(exc)


def selftest():
    os.makedirs(DEFAULT_OUT, exist_ok=True)

    # 36 stansiya üçün demo yerləşdirmə
    stations = [
        ('28may', -265.0, -957.0), ('genclik', -544.0, -204.0),
        ('gence', 549.2, 2669.2), ('seki', -530.0, 5380.0),
    ]
    entities = []
    for sid, x, y in stations:
        entities.append(make_entity('baku_metro_entrance', x, y, 30.0, 0.0))
        entities.append(make_entity('baku_metro_sign', x, y + 2.4, 31.0, 180.0))

    ymap = os.path.join(DEFAULT_OUT, 'baku_map.ymap')
    n = write_ymap(ymap, 'baku_map', entities)
    ok1, msg1 = validate_xml(ymap)

    archetypes = [
        {'name': 'baku_metro_entrance', 'bbMin': (-4, -4, 0), 'bbMax': (4, 4, 6),
         'bsRadius': 8, 'lodDist': 120, 'txd': 'baku_txd'},
        {'name': 'baku_metro_sign', 'bbMin': (-1, -0.3, 0), 'bbMax': (1, 0.3, 3),
         'bsRadius': 2, 'lodDist': 60, 'txd': 'baku_txd'},
    ]
    ytyp = os.path.join(DEFAULT_OUT, 'baku_props.ytyp')
    m = write_ytyp(ytyp, archetypes)
    ok2, msg2 = validate_xml(ytyp)

    print('[ymap_gen] ymap entity: %d → %s (%s)' % (n, ymap, msg1))
    print('[ymap_gen] ytyp archetype: %d → %s (%s)' % (m, ytyp, msg2))

    return 0 if (ok1 and ok2) else 1


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--selftest', action='store_true')
    args = parser.parse_args()

    if args.selftest:
        return selftest()

    return selftest()


if __name__ == '__main__':
    sys.exit(main())

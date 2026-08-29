# 3D BORU KƏMƏRİ — AI → GTA V (.ydr/.ytyp/.ymap)

Bu qovluq **real Bakı 3D xəritəsi** üçün tam avtomatlaşdırılmış boru kəməridir.
AI saytları bu sandbox-dan əlçatmazdır (`000`), ona görə **AI mesh generasiyasını öz
maşınınızda** edirsiniz; qalan avtomatlaşdırma buradadır.

## Pulsuz alətlər (yoxlanılıb)

| Addım | Alət | Link |
|---|---|---|
| Mesh | Microsoft TRELLIS / TRELLIS.2 (MIT) | github.com/microsoft/TRELLIS |
| Mesh | Tencent Hunyuan3D 2.1 | github.com/Tencent-Hunyuan/Hunyuan3D-2.1 |
| Mesh (lokal GUI) | Modly | modly3d.app/extensions |
| Brauzerdə pulsuz | Hugging Face demo-ları (.glb yüklə) | huggingface.co |
| GTA formatı | Sollumz (Blender, pulsuz) | github.com/Sollumz/Sollumz |
| Yerləşdirmə | CodeWalker (pulsuz) | gta5-mods.com/tools/codewalker |

## Axın

```
1) AI mesh (.glb)  →  tools/3dpipeline/input/ qoyun
2) python3 tools/3dpipeline/pipeline.py
     ├─ Blender varsa: LOD (3 səviyyə) + konveks kolliziya (.ybn üçün)
     ├─ Blender yoxdursa: bu addım atlanır (mesaj verir)
     └─ ymap_gen.py → .ymap + .ytyp XML (doğrulanır)
3) Nəticəni CodeWalker-də yekunlaşdırıb serverə qoyun:
     resources/196rp_bakumap_assets/stream/
4) 196rp_bakumap/config.lua → Config.UseCustomMap = true + CustomCoords
```

## Performans büdcəsi (pozulsa FPS düşür)

- Bina ≤ 8000 tris (L0), prop ≤ 1500 tris
- Tekstura ≤ 2048², əksəriyyət 1024²
- 3 LOD səviyyəsi (L1 ~40%, L2 ~15%)
- Rayon başına ≤ 12 unikal mesh, ≤ 6 real-time işıq

## Fayllar

- `pipeline.py` — orkestrator (Blender-i avtomatik tapır/atlama edir)
- `blender_lod.py` — Blender başsız LOD + kolliziya (sənədkar maşınında)
- `ymap_gen.py` — ymap/ytyp XML generatoru + selftest (burada işləyir)

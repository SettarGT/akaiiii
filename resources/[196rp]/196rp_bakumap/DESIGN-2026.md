# BAKI 2026 — original xəritə dizaynı (196 RP)

Bu sənəd **tamamilə original** dizayn işidir: heç bir yerdən kopyalanmayıb,
heç bir üçüncü tərəf xəritə modundan, heç bir real brend loqosundan istifadə olunmur.

---

## 1. Nə originaldır, nə deyil — dürüst bölgü

| Hissə | Vəziyyət |
|---|---|
| Rayon planı, stansiya topoqrafiyası, zonalaşdırma (bu sənəd) | ✅ Original — bizim dizayn |
| Xəritə interfeysi (`web/index.html`, `css/style.css`, `js/app.js`) | ✅ Original — sıfırdan yazılıb, xarici kitabxana/font/şəkil yoxdur |
| Stansiya/rayon məlumatları (`config.lua`) | ✅ Original |
| 3D bina həndəsəsi | ❌ Kodla yaradıla **bilməz** — bax: bölmə 5 |

### Niyə 3D bina kodla yaradıla bilməz

FiveM serveri GTA V oyununun üstündə işləyir. Resurs (Lua/C#/JS) yalnız:
- oyunun özündə olan obyektləri yerləşdirə bilər,
- blip/marker/UI çəkə bilər,
- mövcud interyerləri (MLO) işlədə bilər.

**Yeni mesh yaratmaq üçün** ayrı boru kəməri lazımdır:

```
Blender / 3ds Max  →  CodeWalker  →  .ydr (mesh) + .ytyp (arxetip)
                                  →  .ymap (yerləşdirmə)
                                  →  .dds (tekstura)
```

Bu fayllar binary RAGE formatındadır, server qovluğuna ayrıca paket kimi qoyulur
və `server.cfg`-də `ensure` olunur. Lua bunu əvəz edə bilməz. Bu sandbox-da
Blender/CodeWalker yoxdur, ona görə həmin paket burada istehsal oluna bilməz.

> Nəticə: "fərqli, kopya olmayan 3D şəhər" üçün **modelləşdirmə paketi** sifariş
> edilməlidir. Aşağıdakı spesifikasiya həmin sənətkara verilmək üçün hazırlanıb.

---

## 2. Dizayn konsepsiyası — "Bakı 2026"

**İdea:** tarixi qat (İçərişəhər) + sovet modernizmi + şüşə-qüllə işgüzar mərkəzi
bir şəhərdə. Üç xətt bu üç qatı bir-birinə bağlayır.

**Vizual dil:** sakit, gecə-mavi fon; teal işıq vurğusu; qum rəngi detallar.
Materiallar: şüşə, açıq beton, əhəng daşı, mis.

### Dizayn tokenləri (UI-da istifadə olunur)

| Token | Dəyər | İstifadə |
|---|---|---|
| `--ink` | `#070b12` | fon |
| `--accent` | `#35e0c0` | əsas vurğu (teal) |
| `--accent2` | `#7aa2ff` | ikinci vurğu |
| `--sand` | `#e9c79a` | oyunçu markeri, detallar |
| `--text` / `--muted` | `#e8eef6` / `#8b9aab` | mətn |
| `--radius` | `18px` | kart radiusu |
| Hərəkət | `0.18–0.22s` `cubic-bezier(.2,.8,.2,1)` | panel açılışı |

Xətt rəngləri: Qırmızı `#ff6b6b`, Yaşıl `#4ade80`, Bənövşəyi `#a78bfa`.

---

## 3. Rayon planı (12 rayon)

| Rayon | Xətt | Xarakter | Zonalaşdırma |
|---|---|---|---|
| İçərişəhər | 1 | Tarixi qala, dar küçələr | Turizm, kafelər, sənətkarlıq |
| Sahil | 1 | Bulvar, dənizkənarı | İstirahət, çimərlik, restoran |
| 28 May | 1 | Əsas qovşaq, şəhər mərkəzi | Ticarət, ofis, nəqliyyat |
| Gənclik | 1 | Ticarət küçələri | Mağazalar, restoranlar |
| Nəriman Nərimanov | 1 | Yaşayış + iş | Mənzil, dövlət orqanları |
| Koroğlu | 1 | Nəqliyyat qovşağı | Sənaye, anbar, servis |
| Qara Qarayev | 1 | Şərq yaşayış massivi | Mənzil, məktəb, bazar |
| Xətai | 2 | Cənub yaşayış | Mənzil, tibb, idman |
| Ağ şəhər | 2 | Yeni işgüzar məhəllə | Ofis qüllələri, liman |
| Dərnəgül | 2 | Şimal massivi | Mənzil, qaraj, bazar |
| 20 Yanvar | 3 | Qərb qovşağı | Universitet, texnopark |
| Elmlər Akademiyası | 3 | Elm və təhsil | Kampus, kitabxana, laboratoriya |

### Xətt topoqrafiyası

- **Qırmızı xətt (1):** İçərişəhər → Sahil → 28 May → Gənclik → Nəriman Nərimanov → Koroğlu → Qara Qarayev
- **Yaşıl xətt (2):** Xətai → Ağ şəhər → Dərnəgül
- **Bənövşəyi xətt (3):** 20 Yanvar → Elmlər Akademiyası

Hər stansiya öz rayonunun mərkəzidir: `Config.DistrictRadius = 700 m` daxilindəki
bütün obyektlər (mağaza, iş yeri, qaraj, xəstəxana) həmin rayona bağlanır.

---

## 4. Performans büdcəsi (sərt tələb)

| Göstərici | Limit |
|---|---|
| Rayon başına unikal mesh | ≤ 12 |
| Bir mesh-in poliqon sayı | ≤ 8 000 tris (bina), ≤ 1 500 tris (kiçik prop) |
| Tekstura ölçüsü | 2048×2048 maksimum, əksəriyyət 1024 |
| Hər mesh üçün LOD | 3 səviyyə (L0/L1/L2), L2 ≤ 15 % poliqon |
| Eyni anda aktiv obyekt | ≤ 150 (kod səviyyəsində məhdudlaşdırılıb) |
| İşıq mənbələri (rayon) | ≤ 6 real-time, qalanları emissive tekstur |

Bunlar pozulsa FPS düşür — ona görə paket bu cədvəllə təhvil verilməlidir.

---

## 5. Modelləşdirmə paketi üçün texniki tapşırıq

Hər rayon üçün:

1. **Metro stansiyası girişi** — 1 unikal mesh: pilləkən/blok, örtük,
   işıqlı lövhə (emissive), 2 skamya, 2 dirək. ≤ 8 000 tris.
2. **Yaşayış blokları** — 3 modul variantı (5, 9, 16 mərtəbə), ümumi atlas.
3. **İşgüzar qüllə** — 1 modul, şüşə fasad (emissive + refleksiya).
4. **Küçə mebeli** — skamya, zibil qutusu, maneə, küçə işığı (bir atlas).
5. **Yer örtüyü** — asfalt, səki, daş döşəmə (tiling, 512×512).

**Fayl strukturu:**

```
196rp_bakumap_assets/
├── fxmanifest.lua          (this_is_a_map 'yes')
├── stream/
│   ├── baku_props.ytyp
│   └── baku_map.ymap
└── assets/*.dds
```

Quraşdırıldıqdan sonra `196rp_bakumap/config.lua` faylında:

```lua
Config.UseCustomMap = true
Config.CustomCoords = {
    ['iceriseher'] = vector3(REAL_X, REAL_Y, REAL_Z),
    -- ... 12 stansiya
}
```

Bundan sonra **bütün** resurslar (mağazalar, iş yerləri, qarajlar, xəritə UI)
avtomatik yeni koordinatlara keçir — heç bir faylda əl ilə düzəliş lazım deyil.

---

## 6. Hazırda işləyən qatlar

| Qat | Fayl | Vəziyyət |
|---|---|---|
| Rayon/stansiya məlumatı | `config.lua` | ✅ İşləyir |
| 3 xətt, rayon bildirişi, marker | `client/main.lua` | ✅ İşləyir |
| Server ixracları (`GetDistrict` və s.) | `server/main.lua` | ✅ İşləyir |
| **Interaktiv xəritə UI (original dizayn)** | `web/` + `client/mapui.lua` | ✅ İşləyir — `/xerite` |
| GTA V prop qatı | `objects.lua` + `client/objects.lua` | ⏸️ **Söndürülüb** (`Config.Objects.Enabled = false`) — tam original dizayn tələbinə görə |

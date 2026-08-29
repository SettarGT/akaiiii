# 196 RP — QURAŞDIRMA BƏLƏDÇİSİ

Bu fayl layihəni **necə və haradan yükləyəcəyinizi** izah edir.

Repo: **https://github.com/SettarGT/akaiiii**
Branch: **`arena/01a04e00-akaiiii`** ← bütün iş buradadır

---

## A. Layihəni İNDİ yükləmək (öz maşınınıza)

### Yol 1 — Git ilə (tövsiyə)
```bash
git clone -b arena/01a04e00-akaiiii https://github.com/SettarGT/akaiiii.git
cd akaiiii
```
Sonra yeniləmək üçün: `git pull`

### Yol 2 — ZIP (git bilmirsinizsə)
1. Brauzerdə açın: `https://github.com/SettarGT/akaiiii`
2. Branch seçicidən `arena/01a04e00-akaiiii` seçin
3. Yaşıl **Code** düyməsi → **Download ZIP**
4. ZIP-i açın

---

## B. FiveM serverinə qoşmaq

1. **FiveM server qovluğu** hazırlayın (adətən `server/`):
   ```
   server/
   ├── run.sh  (Linux) və ya FXServer.exe (Windows)
   ├── server.cfg
   └── resources/
   ```
2. Repo-dakı `resources/` qovluğunun **içindəkiləri** serverin `resources/`-a kopyalayın
   (`[core]`, `[196rp]`, `[oxmysql]`).
3. `server.cfg`-ni kopyalayın və **baza məlumatlarını** özünüzə uyğunlaşdırın:
   ```
   set mysql_connection "mysql://user:ŞİFRƏ@localhost/196rp"
   ```
4. **İkon:** `load_server_icon 'assets/196-icon.png'` sətri server kökündən
   nisbi işləyir — `assets/196-icon.png` faylını server kökündə saxlayın.
5. **Bazanı qurun:**
   ```bash
   mysql -u root -p < 196rp.sql
   ```
6. Serveri işə salın:
   ```bash
   ./run.sh   # və ya start
   ```

Əmrlər yoxlaması: oyunda `/xerite` (xəritə), `P` (telefon), `/iqtisadiyyat`.

---

## C. Gələcəkdə REAL Bakı MLO xəritəsi (inşallah 🙂)

Hazır real Bakı 3D xəritəsi **yoxdur** — bizim qat adlandırma + rayon + UI-dır.
Gələcəkdə real MLO istəsəniz:

1. **Mənbələr** (öz maşınınızda yükləyin):
   - **Cfx.re forumu** → "Map Releases" bölməsi → `Baku` / `Azerbaijan` axtarışı: `forum.cfx.re`
   - **gta5-mods.com** → Maps bölməsi
   - YouTube/Discord icmaları (FiveM map satıcıları)
   - Diqqət: fayl ölçüsü, optimallaşdırma və **lisenziya**-nı yoxlayın.

2. MLO-nu serverə qoyun (adətən `resources/[maps]/baku/`).

3. Sonra **yalnız bir faylı** dəyişin — `resources/[196rp]/196rp_bakumap/config.lua`:
   ```lua
   Config.UseCustomMap = true
   Config.CustomCoords = {
       ['iceriseher'] = vector3(REAL_X, REAL_Y, REAL_Z),
       ['28may']      = vector3(REAL_X, REAL_Y, REAL_Z),
       -- ... 12 metro + 24 region
   }
   ```
   Bütün mağazalar, iş yerləri, qarajlar və xəritə UI **avtomatik** yeni
   koordinatlara keçəcək — əl ilə heç nə dəyişməyə ehtiyac yoxdur.

4. Öz 3D obyektinizi etmək istəsəniz: `tools/3dpipeline/README.md`-ə baxın
   (AI mesh → Blender LOD → Sollumz `.ydr/.ytyp/.ymap`).

---

## D. Yoxlama (server işə düşməzdən əvvəl)

```bash
bash tools/ci/run_ci.sh     # lokal tam yoxlama (7 mərhələ, 54 unit test)
```

Suallar və düzəlişlər üçün: hansı detalı bəyənmədinizsə, deyin — birlikdə düzəldək.

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


---

## E. FXSERVER-İ YÜKLƏMƏK VƏ FAYLLARI YERLƏŞDİRMƏK

Bizim repo yalnız **resurs + konfiq + sql**-dir. FiveM-in öz işlədicisi (FXServer)
ayrıca, rəsmi mənbədən yüklənir:

- **Windows:** https://fivem.net → "Download" (server build)
- **Linux:**
  ```bash
  cd ~ && mkdir -p fxserver && cd fxserver
  curl -Lo fx.tar.xz https://runtime.fivem.net/artifacts/fivem/build_server_linux/master/latest
  tar xf fx.tar.xz
  ```

### Qovluq quruluşu (nə hara gedir)

```
fxserver/
├── run.sh / FXServer.exe          ← FXServer-dən gəlir
├── server.cfg                     ← BİZİM server.cfg
├── assets/196-icon.png            ← BİZİM ikon (server kökü)
└── resources/
    ├── [core]/…                   ← BİZİM resources/[core]
    ├── [196rp]/…                  ← BİZİM resources/[196rp]
    └── [oxmysql]/…                ← BİZİM resources/[oxmysql]
```

| Bizim fayl | Haraya |
|---|---|
| `resources/[core],[196rp],[oxmysql]` | `fxserver/resources/` altına |
| `server.cfg` | `fxserver/server.cfg` (DB şifrəsi + lisenziya) |
| `assets/196-icon.png` | `fxserver/assets/196-icon.png` |
| `196rp.sql` | bazaya idxal — qovluğa atılmır |

### Baza və açar
```bash
mysql -u root -p -e "CREATE DATABASE 196rp CHARACTER SET utf8mb4"
mysql -u root -p 196rp < 196rp.sql
```
`server.cfg`-də:
```
set mysql_connection "mysql://root:SIFRE@localhost/196rp"
set sv_licenseKey "KEYMASTER-DƏN-ACAR"   # https://keymaster.fivem.net (pulsuz)
```

### İşə sal + hamıya aç
```bash
./run.sh
```
- Port **30120** (TCP+UDP) açıq olsun (router/firewall).
- Lisenziya açarı düzgün olanda server FiveM siyahısında görünür → hamı qoşulur.
- Yoxlamaq: FiveM → `connect localhost:30120`.
- Əvvəl: `bash tools/ci/run_ci.sh`


---

## F. WINDOWS + XAMPP (sualın cavabı)

**Hə, XAMPP quraşdır** — MySQL (və phpMyAdmin) üçün ən asan yol.

1. **XAMPP** yüklə: https://www.apachefriends.org → quraşdır.
2. **XAMPP Control Panel** → yalnız **MySQL** → `Start`.
3. Brauzerdə `http://localhost/phpmyadmin` aç.
   - Sol tərəfdə **New** → adı `196rp` → **Create**.
   - `196rp` bazasını seç → **Import** → `196rp.sql` faylını seç → **Go**.
4. `server.cfg`-də baza sətrini XAMPP-ə uyğunlaşdır.
   XAMPP-də root-un **parolu boşdur**, ona görə:
   ```
   set mysql_connection_string "mysql://root@localhost/196rp?waitForConnections=true&charset=utf8mb4"
   ```
   (Əgər XAMPP-də parol qoymusunuzsa: `mysql://root:PAROL@localhost/196rp`)
5. `server.cfg`-də `sv_licenseKey` doldur (keymaster.fivem.net).
6. **Faylları yerləşdir** (şəkildəki `server/` qovluğuna):
   - `resources/` qovluğu yarat → içində `[core]`, `[196rp]`, `[oxmysql]`
   - `server.cfg` (bizimki) → `FXServer.exe` ilə eyni qovluğa
   - `assets/196-icon.png` → eyni qovluqda `assets/` içində
   - `run.bat` (bizimki) → eyni qovluğa
7. **İşə sal:** `run.bat`-a iki dəfə kliklə. Konsol açılar, resurslar yüklənər.
8. FiveM → `connect localhost:30120`.

Qeyd: `FXServer.exe` + `citizen/` + `.dll` faylları FXServer-in özündəndir — onlara toxunma.
Bizim əlavə etdiklərimiz yalnız: `resources/`, `server.cfg`, `assets/`, `run.bat`.

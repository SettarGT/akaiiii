# 196 RP — Azərbaycan Dilində Tam Rol-Pley Server Paketi

**196 RP** — tam hazır, müasir **FiveM** rol-pley serveridir. Bütün interfeys, menyular, işlər və məkanlar yalnız **Azərbaycan dilindədir**. "196" uydurma bir şəhərdir — serverin heç bir real ölkə ilə əlaqəsi yoxdur.

> Bu repozitoriyada serveri işə salmaq üçün **lazım olan hər şey var**: ESX framework, 70+ iş və 120+ məkan, tam verilənlər bazası (SQL), xüsusi giriş ekranı, geyim dəyişmə məntəqələri, polis/TİB/iş/admin sistemləri.

---

## ✨ Xüsusiyyətlər

| Bölmə | Təsvir |
|---|---|
| 🏙️ **120+ real məkan** | Bələdiyyə, məhkəmə, polis, xəstəxana, banklar, marketlər, restoranlar, kafe, çay evi, gecə klubu, idman zalı, hovuz, kazino, liman, hava limanı, avtovağzal, meşə, mədən, ferma, üzüm bağı, çimərlik, göl və s. — hamısı xəritədə işarə (blip + marker) ilə |
| 💼 **70+ iş** | Balıqçı 🎣, mədənçi ⛏️, meşəçi 🪓, fermer 🌾, üzüm yığan 🍇, zibilçi ♻️, bələdiyyə işçisi 🏛️, çörəkçi 🥖, qəssab 🥩, elektrikçi ⚡, liman işçisi ⚓, dəmirçi 🔨, bağban 🌿, taksi 🚕, avtobus 🚌, yük maşını 🚛, kuryer 📦, polis 🚓, təcili yardım 🚑 və s. |
| 📋 **İş elanları lövhəsi** | Bələdiyyə və İş Mərkəzindəki lövhədən oyunçu özü işə düzəlir (polis, TİB, taksi, mexanik + bələdiyyə işləri) |
| 🍞 **Həyat statusu + HUD** | Aclıq, susuzluq və enerji sistemi — yemək/içki əşyaları işləyir; can/zireh/pul/saat paneli (HUD) |
| 🎭 **Animasiya menyusu** | `/anim` və ya `U` düyməsi — otur, salam ver, siqaret çək, idman et və s. (30+ animasiya) |
| 📣 **Discord loqları** | Qoşulma/çıxma, admin əməlləri (`/setjob`, `/ban`...) və reportlar Discord webhook-a düşür |
| 🚪 **Ayrıca giriş (cinematic) ekranı** | İlk qoşulmada filmvari yüklənmə ekranı + "harada doğulmaq istəyirsiniz?" spawn seçimi |
| 👕 **Ayrıca paltar dəyişmə məntəqəsi** | Şəhərin müxtəlif yerlərində geyim dükanları (kişi/qadın geyimləri, aksesuarlar) |
| 🏦 **Real iqtisadiyyat** | Nağd pul + bank hesabı, bank əməliyyatları, maaş sistemi, avtomobil və ev alışı |
| ⛽ **Yanacaq sistemi** | Hər avtomobilin yanacağı var — yanacaqdoldurma məntəqəsində doldurun |
| 🚗 **Qaraj + Avtosalon** | Avtomobil al, saxla, çıxar; polis müsadirə etdiyi avtomobillər anbara gedir |
| 🏠 **Ev sistemi** | Evlər alınır və sahibinə qeyd olunur |
| 👮 **Polis sistemi** | Növbə, tapança/möhkəmə, cərimə yazma, həbsxanaya atma, avtomobil müsadirəsi |
| 🚑 **TİB (EMS) sistemi** | Növbə, ölüm/respawn, müalicə, xəstəxana avtomobili |
| 🛡️ **Admin sistemi** | `/setjob`, `/giveitem`, `/givecar`, `/ban`, `/kick`, `/tp`, `/goto` və s. |
| 💬 **RP əmrləri** | `/me`, `/do`, `/try`, `/ooc`, `/report` |

---

## 🧱 Sistem tələbləri

- **GTA V** (Steam/Rockstar) — oyunçular üçün
- **FXServer** — quraşdırma skripti ilə (aşağıda)
- **MySQL / MariaDB** — verilənlər bazası (v8+)
- **Node.js 18+** *(opsional — yalnız txAdmin idarə paneli üçün)*

---

## 🚀 Quraşdırma (addım-addım)

### 1. FXServer (server faylları) endirin

Bu repozitoriyada FiveM-in rəsmi server faylı (artifact) **skriptlə endirilir** (fayl ~250 MB-dır və GitHub-a yüklənmir):

**Linux / Ubuntu / Debian:**
```bash
bash install-fxserver.sh
```

**Windows:**
```
install-fxserver.bat  (iki dəfə klikləyin)
```

Skript ən son **tövsiyə olunan** rəsmi build-i `https://runtime.fivem.net` ünvanından endirib `server/` qovluğuna açır. Əl ilə də edə bilərsiniz: [runtime.fivem.net](https://runtime.fivem.net/) → *Linux/Windows Server* → tövsiyə olunan build-i endirib `server/` qovluğuna açın.

> 💡 **txAdmin** (veb idarə paneli) istəyirsinizsə: [github.com/tabarra/txAdmin/releases](https://github.com/tabarra/txAdmin/releases) səhifəsindən `txAdmin-linux` / `txAdmin.exe` faylını endirib bu qovluğa atın.

### 2. Verilənlər bazasını qurun

1. MySQL-də yeni verilənlər bazası yaradın (məsələn: `196rp`):
   ```sql
   CREATE DATABASE 196rp CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```
2. `196rp.sql` faylını həmin bazaya idxal edin:
   - **phpMyAdmin / Adminer:** `196rp.sql` faylını seçin → *İdxal (Import)*
   - **Terminal:**
     ```bash
     mysql -u root -p 196rp < 196rp.sql
     ```

> ⚠️ SQL faylı **hər şeyi** ehtiva edir: ESX əsas cədvəlləri, Azərbaycan dilində iş adları, 23 yeni əşya, evlər və ban cədvəlləri. Əlavə heç nə idxal etmək lazım deyil.

### 3. `server.cfg` faylını tənzimləyin

1. **FiveM lisenziya açarı:** [keymaster.fivem.net](https://keymaster.fivem.net) saytından pulsuz açar götürün və:
   ```
   set sv_licenseKey "BURAYA_LISENS_ACHARINIZI_YAZIN"
   ```
2. **MySQL bağlantısı:**
   ```
   set mysql_connection_string "mysql://root:PAROLUNUZU_YAZIN@localhost/196rp?waitForConnections=true&charset=utf8mb4"
   ```
3. İstəsəniz `sv_hostname` və `sv_maxclients` dəyərlərini dəyişin.

### 4. Discord loqları (istəyə bağlı)

Discord loqlarını aktivləşdirmək üçün `resources/[196rp]/196rp_discord/config.lua` faylını açın və 3 webhook URL-i yapışdırın:

- **server** — oyunçu qoşulma/çıxma
- **admin** — admin əməlləri (`/setjob`, `/giveitem`, `/ban` və s.)
- **report** — oyunçuların `/report` müraciətləri

Webhook yaratmaq: Discord server → Parametrlər → İnteqrasiyalar → Webhook → Yeni webhook. Boş qalsa, loqlar işləmir (server normal davam edir).

### 5. Admin olun

`196rp.sql` faylının ən sonunda şərhə salınmış sətir var:
```sql
-- UPDATE `users` SET `group` = 'admin' WHERE `identifier` = 'license:BU_BURAYA_OZ_LISENZIYANIZI_YAZIN';
```
Öz lisenziyanızı yazıb `--` hissəsini silin və sorğunu yenidən işlədin. Lisenziyanızı öyrənmək üçün serverə girib konsolda (F8) `identifier` yazın.

### 6. Serveri işə salın

**Linux:**
```bash
./server/run.sh +exec server.cfg
```

**Windows:**
```
server\FXServer.exe +exec server.cfg
```

Hamısı qaydasındadırsa, FiveM-də serveri axtarın: **"196 RP"** → daxil olun! 🎉

---

## 🎮 Oyun daxili əmrlər

| Əmr | Kim istifadə edə bilər | Nə edir |
|---|---|---|
| `/me <mətn>` | hamı | Fəaliyyəti təsvir edir (sarı rəng) |
| `/do <mətn>` | hamı | Ətraf vəziyyətini təsvir edir (bənövşəyi) |
| `/try <mətn>` | hamı | Şanslı fəaliyyət (yaşıl — uğurlu/olmadı) |
| `/ooc <mətn>` | hamı | Oyunçudan kənar söhbət (boz) |
| `/report <mətn>` | hamı | Adminə şikayət göndərir |
| `/setjob [id] [iş] [rütbə]` | admin | İş dəyişir (məs: `/setjob 2 polis 2`) |
| `/anim` və ya `U` | hamı | Animasiya menyusu (oturmaq, salam, idman və s.) |
| `/giveitem [id] [əşya] [say]` | admin | Əşya verir (məs: `/giveitem 2 kola 5`) |
| `/givecar [id] [model]` | admin | Avtomobil verir |
| `/kick [id] [səbəb]` | admin | Oyunçunu atır |
| `/ban [id] [dəq] [səbəb]` | admin | Oyunçunu ban edir |
| `/unban [license:...]` | admin | Banı götürür |
| `/announce [mətn]` | admin | Ekranda elan göstərir |
| `/tp x y z` | admin | Koordinatlara yollanır |
| `/goto [id]` | admin | Oyunçunun yanına gedir |
| `/bring [id]` | admin | Oyunçunu yanına çağırır |

---

## 📁 Qovluq strukturu

```
akaiiii/
├── server.cfg              ← əsas konfiqurasiya
├── 196rp.sql               ← tam verilənlər bazası (idxal edin!)
├── icon.png                ← server ikonu (96x96)
├── install-fxserver.sh     ← Linux üçün FXServer endirmə skripti
├── install-fxserver.bat    ← Windows üçün FXServer endirmə skripti
├── server/                 ← FXServer faylları (skript yaradır)
└── resources/
    ├── [core]/             ← ESX framework (16 əsas resurs, AZ lokalları ilə)
    ├── [oxmysql]/          ← MySQL bağlantı resursu
    └── [196rp]/            ← 18 xüsusi resurs (iş, məkan, giriş ekranı və s.)
```

### 196 RP xüsusi resursları

| Resurs | Vəzifəsi |
|---|---|
| `196rp_loading` | Filmvari yüklənmə ekranı (progress bar + ipucları) |
| `196rp_spawn` | İlk qoşulmada doğum yerini seçmə ekranı |
| `196rp_business` | 120+ məkan (blip + marker + məlumat) |
| `196rp_jobs` | 30+ iş (balıqçılıq, mədənçilik, çörəkçilik, kuryer, taksi və s.) |
| `196rp_jobcenter` | İş elanları lövhəsi (Bələdiyyə — özün işə düzəl) |
| `196rp_status` | Həyat statusu (aclıq/susuzluq/enerji) + HUD paneli |
| `196rp_animations` | `/anim` animasiya menyusu |
| `196rp_discord` | Discord webhook loqları (qoşulma, admin, report) |
| `196rp_shops` | 49 mağaza kateqoriyası (market, yemək, geyim və s.) |
| `196rp_clotheshop` | Geyim dəyişmə məntəqələri (esx_skin ilə) |
| `196rp_bank` | Bank əməliyyatları (pul qoyma/çıxarma/balans) |
| `196rp_fuel` | Yanacaq sistemi (yanacaqdoldurma məntəqələri) |
| `196rp_garage` | Qaraj sistemi (saxla/çıxar, müsadirə anbarı) |
| `196rp_vehicleshop` | Avtosalon (avtomobil alışı) |
| `196rp_housing` | Ev alış sistemi |
| `196rp_police` | Polis növbəsi, cərimə, həbs, müsadirə |
| `196rp_ems` | TİB növbəsi, müalicə, respawn |
| `196rp_rpcommands` | `/me /do /try /ooc /report` |
| `196rp_admin` | Admin əmrləri + ban sistemi |

---

## 🛠️ Problem həlli

**"Couldn't find the game executable" / server açılmır**
`server/` qovluğunda `FXServer` (Linux) və ya `FXServer.exe` (Windows) faylının olub-olmadığını yoxlayın. Yoxdursa: `bash install-fxserver.sh` və ya `install-fxserver.bat` işlədin.

**"Access denied for user"**
`server.cfg`-də MySQL parolunuzu düzgün yazdığınıza əmin olun və `196rp.sql`-i idxal etdiyinizi yoxlayın.

**"Invalid license key"**
`sv_licenseKey` dəyərini keymaster.fivem.net-dən aldığınız açarla əvəz edin.

**Dil ingilis görünür**
`server.cfg`-də `setr esx:locale "az"` sətrinin olduğunu yoxlayın (olmalıdır — silməyin).

---

## 📜 Lisenziya / Qeyd

- Bu paket açıq mənbəli [ESX Framework (esx-legacy)](https://github.com/esx-framework/esx_legacy) və [oxmysql](https://github.com/overextended/oxmysql) üzərində qurulub.
- FiveM server faylları (artifact) **CitizenFX-in rəsmi** paylama qaydalarına əsasən bu repozitoriyaya daxil edilmir — `install-fxserver.sh/.bat` skriptləri ilə rəsmi mənbədən endirilir.
- "196" tamamilə **uydurma şəhərdir**; bu layihənin heç bir real ölkə, şəhər və ya təşkilatla əlaqəsi yoxdur.

**Xoş oyunlar!** 🎮

# 🎮 Azerbaijan Role Play (196 RP)

**Azerbaijan Role Play** — QBCore(ω) əsaslı, tam Azərbaycan dilində, whitelist-li FiveM RP serveri.

| | |
|---|---|
| Framework | [QBCore](https://github.com/qbcore-fivem/qb-core) (qbcore-fivem, aktiv) |
| Dil / UIC | Azərbaycan (`setr qb_locale "az"`) |
| Giriş | Whitelist (Discord + in-game müraciət) |
| Paylaşım | Public GitHub (GPL-3.0 mənbələr) |

---

## 📦 Nə daxildir

### QBCore əsas resursları (58)
`resources/[qb]/` — qb-core, qb-multicharacter, qb-inventory, qb-clothing, qb-garages,
qb-vehicleshop, qb-vehiclesales, qb-fuel, qb-spawn, qb-vehiclekeys, qb-banking,
qb-radialmenu, qb-smallresources, qb-weathersync, qb-policejob, qb-ambulancejob,
qb-taxijob, qb-busjob, qb-truckerjob, qb-garbagejob, qb-recyclejob, qb-hotdogjob,
qb-newsjob, qb-cityhall, qb-vineyard, qb-diving, qb-weed, qb-drugs, qb-crafting,
qb-crypto, qb-pawnshop, qb-management, qb-mechanicjob, qb-towjob, qb-scrapyard,
qb-storerobbery, qb-bankrobbery, qb-houserobbery, qb-jewelery, qb-prison,
qb-doorlock, qb-lapraces, qb-streetraces, qb-minigames, qb-target, qb-menu,
qb-input, qb-hud, qb-scoreboard, qb-phone, qb-shops, qb-truckrobbery,
qb-houses, qb-apartments, qb-interior, qb-loading, qb-adminmenu, qb-weapons.

### Köməkçi resurslar
- `resources/[standalone]/` — oxmysql, menuv, PolyZone, progressbar,
  connectqueue, bob74_ipl, safecracker, screencapture, interact-sound
- `resources/[voice]/` — pma-voice, qb-radio
- `resources/[defaultmaps]/` — hospital_map, dealer_map, prison_main/canteen/meeting

### 196 RP xüsusi resursları (`resources/[196rp]/`)
| Resurs | Vəzifə |
|---|---|
| `196rp_whitelist` | DB əsaslı whitelist: `/muraciet`, Discord webhook, `/wluygula /wlqebul /wlred /wlrem /wlkesifle` |
| `196rp_rpcommands` | `/me`, `/do`, `/ame`, `/try`, `/ooc`, `/report`, `/pm` — Azərbaycanca |
| `196rp_jobs` | İş Mərkəzi — 10 mülki işə düzəlmə |
| `196rp_animations` | `U` düyməsi / `/anim` — animasiya menyusu |
| `196rp_tuning` | Tuninq emalatxanası (mühərrik, əyləc, turbo, ksenon, rəng) |
| `196rp_mdt` | Polis MDT — axtarış, cərimə, nəqliyyat, qeydlər (NUI) |
| `196rp_hospital` | Xəstəxana — 2x qayıdış, müalicə, EMS duty (0 NPC) |
| `196rp_dealer` | Avtosalon — premium NUI ilə avtomobil alışı |
| `196rp_atm` | ATM — NUI maliyyə paneli (nağd ↔ bank) |
| `196rp_ems` | Advanced EMS — 6 zona zədə, rentgen NUI, xərək, cərrahiyyə minigame |
| `196rp_prison` | Həbsxana işləri — mətbəx/təmizlik/idman → vaxt azalması |
| `196rp_fire` | Yanğınsöndürmə — stansiya kiosku, /yangin, /sondur, təsadüfi yanğınlar |
| `196rp_radar` | Polis radarı + plate scanner (/radar, /plate) |
| `196rp_dispatch` | Dispatch — /911 zəng, /dispatch paneli |
| `196rp_social` | Twatter + 196-Gram — /twatter, /gram, /social |
| `196rp_pets` | Heyvanlar — mağaza, /heyvan, qulluq |
| `196rp_winter` | Qış mövsümü — /qis, qış təkərləri, buz |

---

## 🚀 Quraşdırma (qısa)

1. **Artifact:** FXServer-i [Windows](https://runtime.fivem.net/) / [Linux](https://runtime.fivem.net/)
   yükləyin və `server/` qovluğuna açın.
2. **Fayllar:** Bu reponun bütün fayllarını server qovluğuna kopyalayın
   (`server.cfg`, `resources/`, `196rp.sql`, `icon.png`). **Vacib:** reponun
   `resources/` qovluğu AVTOMATİK olaraq sistem resurslarını da ehtiva edir
   (`[system]` — mapmanager, chat, spawnmanager, sessionmanager,
   basic-gamemode, hardcap, baseevents). Ona görə artefaktın köhnə `resources/`
   qovluğu əgər varsa onu silmək **olmaz** — köhnə sistem resurslarını saxlayıb
   yalnız repodakı faylları onun üzərinə **birləşdirin (merge)**. Əgər host-da
   sistem resursları artıq mövcuddursa və təkrarçılıq xətası çıxarsa,
   `resources/[system]/` qovluğunu sadəcə silin.
3. **Verilənlər bazası:** MySQL-də `196rp` adlı boş bazanı yaradın və
   `196rp.sql` faylını idxal edin.
4. **server.cfg:** `sv_licenseKey` və `mysql_connection_string` dəyərlərini doldurun.
5. **Admin:** Öz `license:` (və ya `steam:`) identifikatorunuzu server.cfg sonundakı
   `add_principal` sətrində `group.admin`-a əlavə edin.
6. **Discord:** `resources/[196rp]/196rp_whitelist/config.lua` → `Config.Webhook`
   və `Config.DiscordInvite` dəyərlərini doldurun.
7. İşə salın: `run.bat` (Windows) və ya `./server/run.sh +exec server.cfg` (Linux).

> `setr qb_locale "az"` server.cfg-də artıq var — bütün UI Azərbaycandır.

## 🏛️ Bələdiyyə və Faktura (v1.1)

- **/pasport** — FİN (11 rəqəm) + qan qrupu ilə NUI şəxsiyyət kartı
- Bələdiyyə (City Hall): pasport ₣500, sürücülük lisenziyası ₣1500 (nəzəri 10 sual + praktik 3 nöqtə), silah lisenziyası ₣5000
- **/faktura <id> <məbləğ> <səbəb>** — NUI faktura (qəbul/imtina, bank/nağd ödəniş, Discord webhook)

## 🚔 PD / MDT / Xəstəxana / Bank (v1.1)

- **F6** və ya `/mdt` — Polis MDT (oyunçu axtarışı, cərimə yazma, nəqliyyat/plitə, qeydlər)
- **`/faktura <id> <məbləğ> <səbəb>`** — NUI faktura (qəbul/imtina, bank/nağd, webhook)
- Xəstəxana qəbulu `[E]`: sığorta ₣2 500 (30 gün müalicə pulsuz), müalicə ₣800, AED canlandırma ₣2 000 (EMS növbətçidə olmayanda)
- **`/temir`** — mexanik işində maşını təmir et (zədəyə görə qiymət)
- **`/geyim`** — qarderob (geyim hissələrini fərdi çıxar/dəyiş)
- **196 Bank ATM-ləri** `[E]` — çıxarış/yatırma/köçürmə (₣250 000 limit)
- **196 Avtosalon** — premium NUI salon, sınaq sürüşü, bank/nağd alış

## 🎰 Kazino / 🏪 Biznes / 🏁 Yarış Liqası (v1.2)

- **196 Kazino** `[E]` — Rulet (rəng/cüt-tək/nömrə x35), Zar (x2), Slot (🍒x5 … 7️⃣x100) — server RNG, ₣100–100 000 mərc
- **Bizneslər** `[E]` — mağaza ₣25k / restoran ₣50k / avtoservis ₣75k / klub ₣100k — boss menyu (kassa yatır/çıxar, işçi əlavə et/sil)
- **Yarış Liqası** — 3 trek (Şəhər ₣500 / Vinewood ₣750 / Magistral ₣1000), nəzarət nöqtələri, `/liqa` lider cədvəli, mövsüm xalları (10-8-6…)
- **Evlər** — qb-houses: satış, açar paylaşımı, **3D mebel qoyma** (bütün mebel adları Azərbaycan dilində)

## ⚖️ Məhkəmə / ₿ Kripto / 🐕 K9 / 🛸 Dron / 🛡 VIP (v1.3)

- **196 Məhkəmə** `[E]` — öz qeydiyyatını gör; hakim: `/qerar <id> <cərimə> <həbs dəq> <səbəb>` (qb-prison həbs edir), `/qerar2 <id>` işə baxır; hüquqşünas: `/vekil <id>`
- **196 Kripto Bazarı** `[E]` — 196COIN canlı qiymət (60 saniyədə yenilənir), SVG qrafik, al/sat (1% komissiya), balans paneli
- **Vergi paneli** — `/vergi` (admin: `/vergi <faiz>` 0-50%), avtosalon/kazino/faktura vergiləri avtomatik, vergi statistikası
- **K9** — `/k9` (polis iti çağır), `/k9axtar` (15m radius silah/qaçaqmal iyləmə, 90s soyutma) — narkotik YOX
- **Dron** — `/dron` (60s batareya, klaviatura ilə idarə, kamera), `/dronendir`
- **Streamer rejim** — `/streamer` (RP mesajlarında adı "Gizli Şəxs" edir)
- **VIP** — `/vip` status, `/vipplate <plaka>` (3-8 simvol), admin: `/viptver <id> <gün>`, `/viptelə <id>` — pay-to-win YOX (kosmetika + növbə prioriti + plitə)

## 💻 Kiber / 🔧 Söküm / 🧠 Stress / 🖥️ Hibrid (v1.3+)

- **Kiber cinayət** (narkotik ƏVƏZİ) — `/hack`: yaddaş minigame (5 simvol) + server şansı, ₣8k-30k, kit ilə +25% (DarkWeb `[E]`: ₣5000), polis xəbərdarlığı
- **Söküm sexi** `[E]` — yaxın maşını sök (45s, polis xəbərdarlığı), metal hissə → qara bazarda ₣120/əd; öz maşını sökülmür, 10 dəq soyutma
- **Stress** — `/stress` (0-100), `/nəfəs` (4s → -20), yüksək stressdə ekran effekti
- **Növbət paneli** — `[E]` PD/Xəstəxana/İş Mərkəzi və ya `/nobvet`: kim işləyir (PD/EMS/mexanik/yedək/hakim/reporter)

## 📖 Əmrlər

- **Oyunçu əmrləri:** `/me /do /try /ooc /report /muraciet /is /anim /rentqaytar /vehicleui` (və ya F5), `/givekeys <id>`
- **Admin əmrləri:** `ADMIN_KOMANDALARI.txt` (repo kökündə) — tam siyahı az dilində

## 🆘 Tez-tez xətalar (troubleshooting)

| Ekranda görünən | Səbəb | Həll |
|---|---|---|
| `Could not find dependency oxmysql for resource qb-core` | oxmysql resursu paketdə deyil və ya köhnə mənbə kodu ilə əvəz olunub | Repodan yeni `resources/` götürün — `resources/[standalone]/oxmysql` rəsmi v2.14.1 release-dir |
| `Couldn't find resource mapmanager / chat / spawnmanager ...` | Artefaktın sistem resursları silinib | Yeni `resources/` paketində `[system]` qovluğu var — onu saxlayın |
| `SCRIPT ERROR: ... No such export GetCoreObject in resource qb-core` | qb-core oxmysql olmadığı üçün başlamayıb | Yuxarıdakı iki sətri həll edin — bu xəta öz-özünə yox olur |
| `SCRIPT ERROR: locales/az.lua ... near 'delete'` | Köhnə tərcümə faylındakı sintaksis xətası | Repodan yenilənmiş `qb-policejob/locales/az.lua` götürün |
| `Failed to get processes' tree usage data ... wmic` | Windows 11-də `wmic` köhnəlib | **Zərərsizdir** — diqqət etməyin |

---

## 🛠 Əsas əmrlər

### Oyunçu
| Əmr | İzah |
|---|---|
| `/me <mətn>` | Personaj hərəkəti (3D mətn, yaxınlıqdakılar görür) |
| `/do <mətn>` | Mühit təsviri (3D mətn) |
| `/ame <mətn>` | Anlaşılmayan/pərakəndə hərəkət |
| `/try <mətn>` | Şans testi (50/50, ✔/✘) |
| `/ooc <mətn>` | OOC çat |
| `/report <mətn>` | Adminlərə report (webhook + çat) |
| `/pm <id> <mətn>` | Şəxsi mesaj |
| `/muraciet` | Whitelist müraciəti |
| `/is` / İş Mərkəzi `[E]` | Mülki işə düzəl (balıqçılıq, mədən, meşə, inşaat, mexanik, avtosalon, ...) |
| `/anim` | Animasiya menyusu |
| `/temir` | Mexanik — yaxın avtomobili təmir et |
| `/avtomobil` `/sat` | Avtosalon — satış maşını çağır / alıcıya sat |
| `/rentgen` `/sarqi` `/gips` `/cerrahiye` `/dirilt` `/xertek` | EMS — rentgen, sarğı, gips, cərrahiyyə, diriltmə, xərək |
| `/radar` `/plate` | Polis — radar aç/bagla, plate skan |
| `/yangin` `/sondur` | Yanğın zəngi / söndürmə |
| `/sat` (həbsxanada yox) | Həbsxana işləri: [E] ilə mətbəx/təmizlik/idman |

### Admin
`/wluygula`, `/wlqebul <id>`, `/wlred <id> <səbəb>`, `/wlrem <id>`, `/wlkesifle` —
whitelist idarəetməsi. QBCore standart əmrləri (`/tp`, `/givemoney`, `/setjob`, `/setgang`,
`/car`, `/dv`, `/openserver`, `/closeserver`, ...) az.lua ilə tam Azərbaycandır.

---

## 🔧 İnkişaf / CI

```bash
bash tools/ci/run_ci.sh
```

Yoxlayır: Lua sintaksis, server-native, forward-ref, client/server kontraktları,
SQL referansları, manifestlər, NUI JavaScript, Lua unit testləri.

---

## 📜 Lisenziyalar

Bu paket açıq mənbəli resurslardan ibarətdir:
[QBCore (GPL-3.0)](https://github.com/qbcore-fivem/qb-core),
[ox_lib/oxmysql (LGPL-3.0)](https://github.com/overextended/oxmysql),
[MenuV (GPL-3.0)](https://github.com/ThymonA/menuv),
[pma-voice (MIT)](https://github.com/AvarianKnight/pma-voice) və s.
Hər resursun öz LICENSE faylı saxlanılır.

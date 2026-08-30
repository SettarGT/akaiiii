# 📋 "196 RP" — 60 SUALLIQ EKSİK DETALLAR ANKETİ

> **Kimə:** Qardaşm (server sahibi) · **Kimdən:** Developer (Arena agenti)
>
> TT-nin 1–34-cü hissələrində çox şey yazılıb, amma **konkret rəqəmlər, yerlər və "hansı əvvəl"** qərarı yoxdur.
> Bu anket onları bağlayır. Hər sualda **`D` = mənim tövsiyəm (default)**.
>
> **Cavab formatı:**
> ```
> 1: D
> 2: 64 slot, EU host
> 12: 12 deyil, 6 saat
> ```
> Sadəcə nömrə + cavab yaz; qalan "D" qəbul olunur. Cavabları verdikdə onları TT-yə əlavə edib quraşdırmaya başlayıram.

---

## ✅ TƏSDİQLƏNMİŞ QƏRARLAR (30.08.2026) — HAMISI "D"

| # | Sual | Qərar |
|---|---|---|
| 1 | Framework | **QBCore** qalır |
| 39 | Envanter | **qb-inventory** + müasir dizayn (geyim tab ilə) |
| 5 | Valyuta | **"196 Fanteyn"** (₣ — HUD/bank/cüzdan hamısında) |
| 3 | Slot sayı | **30** (az pop başlanğıc; sonra 64/128) |
| 44 | Telefon | **lb-phone** — ⚠️ AŞKARLAMA: lb-phone **pulsuz deyil** (lbscripts.com premium, ~$15+) və **ox_inventory tələb edir**. Sən qb-inventory seçdiyin üçün: **v1 = qb-phone + premium (dark-glass) yenidən dizayn**; lb-phone lisenziyası alınarsa 1 günə inteqrasiya edirəm. |
| 6/19/28.. | V1 əhatəsi | **Core + İşlər + Dövlət Xidmətləri** (PD/EMS/Bələdiyyə/MDT/faktura) — qalanı v1.1–v2 |
| 2–66 | Qalan bütün suallar | **HAMISI D** (mənim tövsiyələrim) |

> server.cfg artıq: 30 slot, OneSync Infinity, "196 RP | Azərbaycandilli Semi-RP | 0-NPC | Hibrid Sistemlər".

## ✅ V1-də TƏHVİL EDİLƏN (bu gün tamamlandı)

1. **196rp_onboarding** — aeroport spawn + kinematik kamera (göydən eniş), qızılı "196 RP — Yeni Era" giriş ekranı, 5 interaktiv tooltip ([N]/[F7], [I]/[TAB], [M], [G]/[L]/[B], Bələdiyyə), Bələdiyyəyə GPS ulduzu, **Rentcar kiosk** (ilk 30 dəq pulsuz, sonra ₣250/saat, /rentqaytar).
2. **196rp_vehicleui** — F5 Radial (glassmorphism): mühərrik, kilid, qapılar, sərnişin, baqaj, kapot, pəncərə, farlar, əlavə işıqlar.
3. **Valyuta "196 Fanteyn"** — ₣ simvolu qb-banking + az locale-lar, start pulu ₣5 000.
4. **Kəmər avtomatik** — maşına minəndə avtomatik taxılır (B ilə dəyişdirilir), yüksək sürətdə qəzada ejection qalır.
5. **ADMIN_KOMANDALARI.txt** — tam az dilli admin/əməl bələdçisi (repo kökündə).
6. SQL: `196_tutorial` + `196_rentals` cədvəlləri (196rp.sql + resurs daxilində).
7. CI ✅ (manifest, kontrakt, native, SQL, NUI, Lua).

## ✅ V1.4 TƏHVİL EDİLDİ (bu gün)
- `196rp_metro` — 6 stansiya, bilet ₣100, NUI gediş animasiyası, teleport (anti-abuse).
- `196rp_aviation` — hangar, 3 təyyarə icarəsi (lisenziya tələbi), `/planqaytar`.
- `196rp_media` — boombox/TV, GTA radio stansiyaları.
- `196rp_logs` — Discord webhooks (#conn #money #kills #admin #veh #anticheat) + yüngül anticheat (teleport/sürət → 3 flag → kick).
- `196rp_restock` — 4 kiosk (24/7 ×2, LTD ×2), ₣500 + 5 dəq CD, qb-shops useStock ilə.
- `196rp_jobs` təkmilləşdirmə — 12 iş, balıqçılıq/mədən/meşə/inşaat zonaları + satış məntəqələri, mexanik `/temir`, avtosalon `/avtomobil`+`/sat` (player_vehicles qeydiyyatı).
- qb: `pilot` işi, 24/7 + LTD mağazalarına `useStock`.

## ✅ V1.5 TƏHVİL EDİLDİ (bu gün)
- `196rp_ems` — 6 zona zədə, rentgen NUI, sarğı/gips, cərrahiyyə minigame, xərək daşıma, şərti diriltmə.
- `196rp_prison` — mətbəx/təmizlik/idman işləri → həbs vaxtı azalması (-30/-35 san, CD 90 san).
- `196rp_fire` — yanğınsöndürmə: stansiya kiosku, /yangin 911 zəngi, blip, /sondur (+₣120), təsadüfi avtomobil yanğınları, yanğın maşını.
- `196rp_radar` — polis radarı (NUI, sürət həddi xəbərdarlığı) + /plate skan (DB sahib axtarışı).

## ✅ V1.6 TƏHVİL EDİLDİ (bu gün)
- `196rp_dispatch` — `/911` zəngi, `/dispatch` paneli (qəbul/bitdi), xidmət işçilərinə blip + bildiriş.
- `196rp_social` — Twatter + 196-Gram: `/twatter`, `/gram`, `/social` feed paneli (bəyənmə ilə).
- Kazino: **Blackjack (21)** əlavə edildi (server-side kart, hit/stand, 21=2.5x).
- `196rp_pets` — heyvan mağazası, `/heyvan`, `/heyvanqaytar`, `/heyvanbesle` (stress -10), `/heyvanad`.
- `196rp_winter` — `/qis` admin, qar havası, qış təkəri (`/qisteker` mexanik, buzda 70 km/s həddi).
- **Narkotik TƏMİZLƏNMƏSİ** — bütün weed/meth/cocaine/psychotropic item-ları items.lua-dan və qb-shops `weedshop`-dan çıxarıldı; `qb-drugs` + `qb-weed` resursları server.cfg-də `stop` edildi.
- **0 NPC** — qb-shops bütün 39 mağazada satıcı ped-ləri söndürüldü (tam self-service zona).
- Streamer rejimi `/pm`-də də adı gizlədir.

## ✅ V1.11 TƏHVİL EDİLDİ (bu gün)
- `196rp_expiry` — **əşya istifadə müddəti**: yemək/içki 48 saat, dərman 7 gün; qb-inventory `ItemAdded` hook-u ilə yeni əşyalara avtomatik vaxt yazılır, bitənlər silinir + bildiriş (TT-40/41).
- **Baqaj**: bütün avtomobillərdə 15 slot (TT-42), əlcək 5, ev anbarı 50.
- **Qaraj limiti**: hər oyunçu qarajda maksimum 15 maşın saxlaya bilər (TT-42).
- **Gəlir vergisi**: iş satışlarından 5% (TT-14) — `196rp_jobs` Config.IncomeTax.
- **Benzin**: ₣1.75/litr (TT-17).

## ⏳ NÖVBƏTİ MƏRHƏLƏLƏR (v1 davamı)

- **v1.1:** Bələdiyyə paketi (pasport/FİN 11 rəqəm/qan qrupu + sürücülük imtahanı 10 sual), xüsusi MDT + dispatch, faktura NUI, ATM dizaynı, iş geyimləri (uniforma), cərimə bildiriş pəncərəsi.
- **v1.2:** Advanced EMS (6 zona zədə, xərək, rentgen), shell ev + 3D mebel (Gizmo), kiber cinayət + chop-shop, kripto/196-Coin, kazino çipləri, stress sistemi.
- **v1.3:** Player-owned bizneslər (boss menu), hibrid stok/restock, rəqabətli yarışlar (ELO), qar mövsümü + qış təkərləri.
- **v2:** Court/judicial (hakim paneli), metro/qatarlar, aviasiya, yaxtalar, boombox 3D musiqi, TVs YouTube/Twitch, seçkilər, evlilik/miras (CK), anbarlar + Storage Wars, donat/VIP sistemi.

---

## A) BAZA VƏ TEXNOLOGİYA (1–9)

**1.** Framework: **QBCore** (hazırda tam qurulub, işləyir) / QBX / ESX?
- D: QBCore qalır (36+ resurs artıq az-dillə hazırdır, dəyişmək = hər şeyi yenidən yığmaq)

**2.** Xəritə: standart **Los Santos** / xüsusi (Bakı/başqa)?
- D: Standart GTA xəritəsi (custom map çox böyük işdir, ayrıca layihə)

**3.** Server növü və gücü: hazırkı host **Windows**-dır — neçə **RAM/CPU vCPU**? Slot sayı: **64** (hazırkı) yoxsa **128** (TT-də yazılıb)?
- D: 64 slot start; 128-ə OneSync Infinity ilə yalnız RAM ≥16GB olsa keçirik

**4.** NPC=0 təsdiqi: **piyadalar 0** və **trafik 0** — hər ikisi tam söndürülsün?
- D: Hər ikisi 0 (TT "Sıfır NPC" qaydası)

**5.** Valyuta adı: **₼ (manat)** / **196$** / **196₼**?
- D: **"196 ₼"** (həm HUD, həm bank, həm cüzdan UI-da bu simvol)

**6.** Server adı (listinqdə görünən): "196 RP | Azərbaycandilli Semi-RP | 0-NPC | Hibrid Sistemlər" — təsdiq? Yoxsa qısa variant?
- D: TT-dəki uzun ad + `sv_projectName "196 RP"`

**7.** Dil: yalnız **az** / az + rusca / az + ingiliscə?
- D: Yalnız az (UI, menyu, bildirişlər); `/` çat az — ingilis/rus əlavə ayrıca sorğu olmadan əlavə edilmir

**8.** Oyun quruluşu (build): hazırkı `sv_enforceGameBuild 3095` — təsdiq?
- D: 3095

**9.** Host bölgəsi (datacenter) haradadır — **Bakı/Avropa/Türkiyə**? Gecikmə (ping) vacibdir.
- D: Avropa (Frankfurt/Amsterdam) — Bakı oyunçusu üçün 45–70ms optimal

---

## B) İQTİSADİYYAT (10–18)

**10.** Yeni oyunçuya **başlanğıc pul**: 0 / 2 500 / 5 000 / 10 000 ₼?
- D: **5 000 ₼** (nağd) + 1 telefon (qb-phone start item)

**11.** İlk 1 saatlıq qazanc hədəfi (sadə işlərlə): 500 / 800 / 1200 ₼?
- D: **~800–1 000 ₼/saat** (mədən/odun/zibil kimi)

**12.** Ən ucuz maşın (Panto ≈ 4 000 ₼) neçə saat təmiz işdən sonra alınmalı?
- D: **4–5 saat** (yəni 1 həftə sonu intensiv və ya 2 gün normal oyun)

**13.** Cərimə cədvəli (sürət həddi, qırmızı işıq, parklanma, aqressiv sürmə): mən standart cədvəl yazım — təsdiq?
- D: Bəli, mən yazıram (sürət 30/60/120+ mərhələli, qırmızı işıq 1 000 ₼, parklanma 250 ₼, aqressiv 750 ₼, təhlükəli 1 500 ₼)

**14.** Vergilər (TT-də dinamik var — ilkin dəyərlər):
- Satış %: **5%** (market/mağazalar) — D
- Gəlir %: **5%** (maaşdan kəsmə) — D
- Avtomobil vergisi: **250 ₼/həftə** — D
- Ev vergisi: **500 ₼/həftə** — D

**15.** Xəstəxana qiymətləri: yüngül müalicə / ağır müalicə / canlandırma (revive)?
- D: 500 ₼ / 1 500 ₼ / 3 000 ₼ (həkim olmayanda avtomatik check-in 1 500 ₼)

**16.** Lisenziya rüsumları: sürücülük / silah / mətbuat / vəkillik?
- D: 1 500 ₼ / 5 000 ₼ / 2 000 ₼ / 10 000 ₼

**17.** Benzin qiyməti (litr): 1,50 / 1,75 / 2,00 / 2,50 ₼?
- D: **1,75 ₼** (sahibkarlıqda sahib tənzimləyir)

**18.** Hibrid qiymət çarpanları (TT-də 1.5x–3x yazılıb — konkretləşdir):
- Market terminal (satıcı yoxdursa): **+30%** → D
- Mexanik self-repair: **2.5x** → D
- Silah lisenziyasız terminal: **3x** → D
- Tow/cərimə meydançası terminal: **2x** → D
- EMS avtomatik: **2x** → D

---

## C) MÜLKİ İŞLƏR VƏ START (19–27)

**19.** İşlərin **v1 prioriteti** (hansı əvvəl, hansı sonra?) — mənim təklifim:
- **V1:** mədənçilik, odunçuluq, balıqçılıq, inşaat, zibilçilik, taksi, logistika/trucker, avtobus, tow, hotdog, üzümçülük, reporter
- **V1.2:** mədən→emal→konteyner ixracat zənciri tam, şərab istehsalı
- **Təsdiq?** D: Bəli

**20.** Mədənçilik: yerlər **Chumash daş karxanası** (default) + yeni 2 nöqtə? Alət itemi (**Pikak**/pickaxe) tələb olunsun?
- D: Default karxana + 2 nöqtə; pikak item məcburi, çəkisi 2kg

**21.** Odunçuluq: meşə sahələri (Paleto / Chiliad ətəyi), **balta** itemi, ağac→taxta→satış zənciri?
- D: Bəli — balta itemi, 3 meşə nöqtəsi, satış nöqtəsi konteyner (NPC görünmür)

**22.** Balıqçılıq: **qayıq** tələb olunsun? Hansı növlər (sazan, qılınc balığı, köpəkbalığı?) və satış yeri (balıq bazarı / restoranlara)?
- D: Qayıq + 3 növ qarmaq mini-game; satış limandakı konteynerə; restoran tədarükü v1.2

**23.** İnşaat (yeni): neçə **tikinti sahəsi** (3?) və zəncir **beton/lövhə/dəmir → pul**, yoxsa sadə danışıq?
- D: 3 sahə (Legion, Paleto, Sandy), material zənciri: təchizat nöqtəsindən yüklə, sahəyə daşı, montaj minigame, sonra ödəniş

**24.** Üzümçülük: mövcud **qb-vineyard** qalır, yoxsa tam **üzüm→şərab→butulka** zənciri (fermentasiya vaxtı, keyfiyyət ulduzları)?
- D: Tam zəncir (şərab butulkası satış + lüks restoranlara v1.2)

**25.** Zibilçilik: qb-garbagejob + **təkrar emal zavodu** (plastik/şüşə/alüminium çıxışı)?
- D: Bəli, zavod Cove-wood kənarında, emal 30 dəq → xammal itemlərə çevrilir

**26.** Logistika: trucker **liman marşrutları** (terminal → anbar), trayler növləri (qida tez xarab, materiallar, yanacaq)?
- D: Bəli — 3 yük növü, hər növün öz qiyməti/riski

**27.** **Rent-A-Car** (airport start, sənin əlavən): qiymət 150 / 250 / 400 ₼/saat? Maşınlar: Blista, Panto, Prairie, Kanjo? Sığorta (qəza halında) haqqı?
- D: **250 ₼/saat**, 4 model, gecə saatı 00:00–06:00 endirim 50%; zəmanət 1 000 ₼ (qaytaranda geri)

---

## D) DÖVLƏT XİDMƏTLƏRİ VƏ GİRİŞ (28–38)

**28.** **Start nöqtəsi** (sənin əlavən): LSIA aeroport terminalı — çıxışda gömrük/pasport masası (NUI), sonra rentcar. Təsdiq?
- D: Bəli — spawn aeroport, "Gömrük" zolağında ilk dəfə pasport (FİN + qan qrupu) verilir

**29.** **Bələdiyyə** (sənin əlavən): bina **City Hall** (mövcud qb-cityhall) kifayət, yoxsa xüsusi MLO? İçində: pasport, sürücülük lisenziyası (nəzəri **azərbaycanca 10 sual** + praktik marşrut), silah lisenziyası, vəkillik — hamısı?
- D: City Hall, hamısı orada; nəzəri test 10 sual/60% keçid, praktik marşrut 3 nəzarət nöqtəsi

**30.** **Pasport UI**: FİN **11 rəqəm** avtomatik, qan qrupu təsadüfi, NUI kart (şəkil + imza) — kart item kimi /mənim sənədlərim üçün görünsün?
- D: Bəli

**31.** **Polis Departamenti** (sənin əlavən): bina **Mission Row** (default) + "196 PD" lövhələri/loqolar; yoxsa tam xüsusi MLO?
- D: V1 Mission Row + generik "196 PD" lövhələri; xüsusi MLO v2 (material ayrıca)

**32.** **MDT** (sənin əlavən): mövcud qb-policejob MDT (axtarış/cərimə/həbs/veh) kifayətdir, yoxsa xüsusi MDT (warrant, VIN tarixçəsi, bodycam, dispatch xəritəsi)?
- D: V1 qb-policejob MDT + az UI; v1.5 dispatch/radar/plate scanner əlavəsi

**33.** **Faktura sistemi** (sənin əlavən): qb-banking invoice kifayət, yoxsa xüsusi NUI faktura (**şirkət adı, item/qeyd, PDF ekran**)?
- D: Xüsusi faktura — /faktura <id> <məbləğ> <səbəb>, webhook + bank köçürməsi

**34.** **Xəstəxana** (sənin əlavən): Pillbox + qb-ambulancejob — ancaq TT-dəki **advanced EMS** (6 zona zədə, xərək, skaner, rentgen, gips, cərrahiyyə minigame) v1 yoxsa v1.2?
- D: V1: əsas qb-ambulancejob + auto-check-in kiosk | V1.2: advanced EMS (xərək, 6 zona)

**35.** Həbsxana: Bolingbroke + **məhkum işləri** (mətbəx/təmizlik/idman → vaxt azalma) v1; **prison break** v1.5. Təsdiq?
- D: Bəli

**36.** Yanğınsöndürmə: mövcud resurslar azdır — **qb-firejob** (və ya custom) v1.1? Dinamik yanğınlar v2?
- D: V1.1 qb-firejob, v2 dinamik alov + meşə yanğını

**37.** **Avtosalon** (sənin əlavən): **PDM** (mövcud qb-vehicleshop) + maşın yanında katalog stendi (NPC yox) — təsdiq? Player-owned dealership v1.3?
- D: Bəli — kiosk tipli kataloq (Ebas → menyu), NPC yox

**38.** **Mexanik** (sənin əlavən): Benny's qaraj + **təmir lifti** (player), duty yoxdursa **self-repair stansiyası 2.5x**, ehtiyat hissələri itemlər (şam, yağ, təkər) — təsdiq?
- D: Bəli (qb-mechanicjob əsasında genişlət)

---

## E) ENVANTER VƏ UI (39–43)

**39.** Envanter nüvəsi: **qb-inventory** (hazır, az UI, drag-drop) — dəyişmə (ox_inventory/qs) yoxsa qalıb **yenidən dizayn**?
- D: **qb-inventory qalır** + müasir dizayn (tünd şüşə) + geyim hissələri (üst/alt/ayaqqabı/aksesuar) ayrıca tab

**40.** Envanter xüsusiyyətləri: slot/çəki limitsi, jugs, **ƏSAS** olaraq hansılar v1:
- Əşya atma/atma stansiyası: D bəli
- Baqaj/əlcək/trunk: D bəli
- Geyim tab (paltarların hissə-hissə çıxarılması): D bəli
- Silah holster (kürəkdə/beldə qoşma): D bəli
- İstifadə müddəti (yeməklər 48s): D bəli

**41.** Əşya korlanması: yalnız yemək/içki, yoxsa hər şey?
- D: Yalnız yemək/içki (48 saat), dərman 7 gün

**42.** Stash/trunk limitləri (default): ev 50 slot, maşın baqajı 15, əlcək 5, qaraj 15?
- D: Bəli

**43.** **Sürücülük/silah lisenziya" itemləri**: ID kart + sürücülük + silah lisenziyası item kimi görünsün (yoxlamada /license göstər).
- D: Bəli

---

## F) TELEFON VƏ SOSİAL (44–47)

**44.** Telefon nüvəsi: **qb-phone** (hazır) — UI yenidən (müasir) yoxsa **lb-phone** (daha premium, amma ox_lib/ox_target əlavəsi)?
- D: V1 qb-phone + yenidən dizayn | lb-phone ayrıca qərar (45-ci sual vacibdir)

**45.** Telefon nömrəsi: format **196-XXX** (196-001...) — təsdiq? Sim-kart hava limanı kioskundan alınır (TT 71).
- D: Bəli

**46.** Sosial tətbiqlər: **Twatter** (default) + **196-Gram** (şəkil yükləmə, bəyənmə/şərh) v1.2 — təsdiq? Foto → Discord webhook (v2)?
- D: Bəli

**47.** **DarkWeb/Kripto** tətbiqi (anonim elanlar, kripto 196-Coin): v1.2, yoxsa v2?
- D: V1.2 (kripto əsas, DarkWeb chat v2)

---

## G) EV VƏ BİZNES (48–52)

**48.** Ev sistemi: qb-apartments (start mənzil) + qb-houses (alış) — təsdiq? **Shell sistem** (boş interyer + mebel mağazası) v1.2?
- D: V1 hazır interyerlər | V1.2 boş shell + mebel (3D gizmo ilə yerləşdirmə)

**49.** Açar paylaşımı: ev açarını dosta vermək (/home key) v1 — təsdiq? İcarə (rent) sistemi v1.2?
- D: Bəli

**50.** **Player-owned bizneslər**: sayı 5 (1 kafe, 1 restoran, 1 gecə klubu, 1 mexanik qarajı, 1 avtosalon)? Boss menu (işçi qəbul, maaş, bank) — v1.3. Təsdiq?
- D: Bəli

**51.** Biznes restock/logistika zənciri (terminal stok bitəndə sifariş → kuryer): v2? Təsdiq?
- D: V2

**52.** Anbarlar (self-storage + blind auction "Storage Wars"): v2?
- D: V2

---

## H) DÜNYA, ƏYLƏNCƏ VƏ MÜHİT (53–58)

**53.** Emotes: mövcud 196rp_animations genişləndirmək (50+) yoxsa **dpemotes** (150+)? 
- D: **dpemotes** (prop dəstəyi ilə) + xüsusi 196 animlər

**54.** Yarışlar: qb-lapraces (artıq var) + lider lövhəsi (lap times) — v1.2? Gizli yarış liqaları (ELO) v2?
- D: V1.2 lapraces | v2 ELO

**55.** Kazino: **real çiplər**, blackjack/rulet/slot (fişlər banka birbaşa), at yarışları — v1.5? Limitlər (günlük max itki)?
- D: V1.5, günlük max itki 25 000 ₼ (anti-broke)

**56.** Musiqi: **boombox** (3D, YouTube link) + maşın radioları + **TV-lərdə YouTube/Twitch** — v1.4 (xsound təməli)?
- D: Bəli

**57.** Hava/iqlim: qb-weathersync (artıq var) — **qar mövsümü** (qış təkərləri, buz sürüşməsi) v1.4? Yağışda handling azalması v1.1?
- D: Yağış efekti v1.1 | qış v1.4

**58.** **Stress sistemi** (TT 13, 61): v1.1 (stress bar + siqaret/qəhvə azaltma + titrəmə effekti)? Təsdiq?
- D: Bəli

---

## I) TƏHLÜKƏSİZLİK, LOG VƏ MONETİZASİYA (59–63)

**59.** Anti-cheat: hazır server-side yoxlama (whitelist gate, oxmysql) + txAdmin — **əlavə AC** (pulsuz/ödenişli) lazımdırmı?
- D: V1 daxili (bütün pul/əşya eventləri server-side təsdiq), v1.5 free AC (qb-anticheat/volt?)

**60.** **Discord log kanalları** (webhook): #join #money #items #kills #admin #reports #wl — hamısı ayrıca? Təsdiq?
- D: Bəli, hamısı

**61.** **VIP/Donat**: kanal **Tebex** / oyun içi kod / Discord? 3 paket (10/25/50 ₼) — xüsusiyyətlər: queue priority (txAdmin), 196-VIP nömrə nişanı, xüsusi telefon nömrəsi, VIP badge. **P2W yox** — təsdiq?
- D: Tebex + in-game redeem, 3 paket (10/25/50 ₼), yalnız kosmetik

**62.** Backup: MySQL avtomatik **6 saatdan bir** (cron) + həftəlik sql faylı Git-ə? Təsdiq?
- D: Bəli

**63.** Admin heyət: başlanğıcda neçə admin mövcuddur (sən daxil 2–3?) — `qbcore.god/adam` rolları yetərli?
- D: 2 god (sən + 1), admin/mod sonra

---

## J) MƏZMUN — CLEAN RP SİYASƏTİ (64–66)

**64.** **Narkotik tam ləğv**: mövcud **qb-drugs, qb-weed** resurslarını **sil** + qb-core items listəsindən bütün narkotik itemləri (weed/meth/coke/oxy/xtc...) **çıxar** — təsdiq? (TT 21-ci hissəyə uyğundur)
- D: Bəli — tam sil, qalıq item yox

**65.** İlk qeyri-qanuni əvəzedici: **kiber cinayət** (hacking data drives) yoxsa **chop-shop** (ehtiyat hissələri) — hansı əvvəl?
- D: Hər ikisi v1.2 (chop-shop daha sürətli hazırlanır, kiber v1.3)

**66.** Ghost guns (lisenziyasız silah emalatxanası — seriya nömrəsiz): v2?
- D: V2

---

## ⚡ YEKUN: 6 KRİTİK QƏRAR — ✅ CAVABLANDI

1. **Framework:** ✅ QBCore qalır
2. **Envanter:** ✅ qb-inventory + müasir dizayn
3. **Valyuta:** ✅ **196 Fanteyn**
4. **Slot sayı:** ✅ **30** (sonra 64/128-a artırıla bilər)
5. **Telefon:** ✅ **lb-phone** (ox_lib əlavəsi tələb edir — növbəti addımda qurulacaq)
6. **İlk buraxılış (v1):** ✅ Core + İşlər + Dövlət Xidmətləri (mərhələli)

> ⏳ **Gözləyən suallar:** 2, 4, 7–18, 20–38, 40–43, 45–66 — chat-da `N: cavab` formatında yaz, ya da hamısı üçün sadəcə `hamısı D` demə kifayətdir (mənim tövsiyələrimlə davam edirəm).

---

*Cavabları verdikdən sonra TT-yə "Hissə 35 — Təsdiqlənmiş Qərarlar" kimi əlavə edəcəyəm və cari QBCore bazası üzərində bu siyahıya uyğun yığıma başlayacağam.*

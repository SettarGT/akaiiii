# ÜMUMİ ÇATIŞMAZLIQLAR — 196 RP (2026-08-29, YENİLƏNİB)

> **2026-08-29 status:** bu sənəddəki bir çox maddə ARTIQ tamamlanıb.
> Aşağıdakı cədvəl son vəziyyəti göstərir.

## Bu sessiyada TAMAMLANANLAR
| # | Maddə | Vəziyyət |
|---|---|---|
| 3 | Avtomatik test + CI | ✅ `tools/ci/` + `.github/workflows/ci.yml` (7 mərhələ) |
| 4 | İqtisadiyyat balansı | ✅ `196rp_economy` (dinamik qiymət, vergi, sink, dupe) + 20 unit test |
| 5 | Backup skripti | ✅ `tools/backup.sh` + `tools/restore.sh` (rotasiya + cron) |
| 6 | Telefon real UI | ✅ premium NUI (zəng/SMS/kontakt/bank) |
| 9 | Loading screen | ⏳ hələ yox |
| — | Server ikonu | ✅ `assets/196-icon.png` + `load_server_icon` |
| — | 3D boru kəməri | ✅ `tools/3dpipeline/` (ymap/ytyp generatoru + Blender LOD skripti) |

---
 — 196 RP (2026-08-29 vəziyyəti)

Bu sənəd layihənin **dürüst** vəziyyətini göstərir: nə hazırdır, nə çatışmır,
nəyi mən (kodla) edə bilərəm, nə üçün xarici asset lazımdır.

Hazırda: **41 xüsusi resurs**, 144 item, 32 job, 36 şəhər/rayon, 1595 sətir SQL.

---

## 1. Kritik — canlı serverə çıxmazdan əvvəl mütləq

| # | Çatışmazlıq | Kim edə bilər |
|---|---|---|
| 1 | **Heç bir şey canlı FiveM serverində test olunmayıb.** Bütün yoxlamalar statikdir (sintaksis, kontrakt, SQL). İlk işə salmada mütləq xətalar çıxacaq. | Server sahibi — birlikdə düzəldərik |
| 2 | **Real Bakı 3D xəritəsi yoxdur** — yalnız adlandırma/rayon/UI qatı var | 3D sənətkar (bax: bölmə 4) |
| 3 | Avtomatik test yoxdur (unit/integration) | ✅ Mən |
| 4 | İqtisadiyyat balansı yoxlanılmayıb — qiymətlər təxminidir (iş maaşı vs. ev kirayəsi vs. maşın) | ✅ Mən (balans cədvəli + düzəliş) |
| 5 | Backup/miqrasiya skripti yoxdur (`196rp.sql` yalnız ilkin qurulumdur) | ✅ Mən |

---

## 2. Funksional çatışmazlıqlar (kodla həll oluna bilər)

| # | Nə çatışmır | Qeyd |
|---|---|---|
| 6 | **Telefon real UI deyil** — `196rp_phone` menyularla işləyir, `web/` qovluğu yoxdur. Zəng/SMS/kamera/bank interfeysi yoxdur | ✅ NUI ilə sıfırdan yaza bilərəm (xəritə UI kimi) |
| 7 | Crafting/sintez sistemi yoxdur (yalnız qanunsuz emal var) | ✅ |
| 8 | Dispetcher sistemi yoxdur — taksi/EMS/polis çağırışı xəritəyə düşmür | ✅ |
| 9 | Loading screen yoxdur | ✅ |
| 10 | Yeni oyunçu üçün dərslik (onboarding) yoxdur | ✅ |
| 11 | Player report/ticket sistemi yoxdur (ban var, müraciət yox) | ✅ |
| 12 | Mövsümi hadisələr/tədbirlər yoxdur | ✅ |
| 13 | Ev interyerləri hazır GTA interyeridir, öz mebel sistemimiz var amma MLO yoxdur | ⚠️ asset |
| 14 | Maşın tuning vizualı yoxdur (yalnız rəng/plaka) | ⚠️ qismən kod |
| 15 | Səs/animasiya paketləri (radio, musiqi) yoxdur | ⚠️ asset |

---

## 3. İnfrastruktur / keyfiyyət

| # | Çatışmazlıq |
|---|---|
| 16 | Anti-cheat yoxdur — server-side validasiya var, amma sürət/teleport/injection yoxlaması yoxdur |
| 17 | CI yoxdur (hər push-da sintaksis + kontrakt yoxlaması avtomatik işlənmir) |
| 18 | Performans ölçmə yoxdur (resmon bazası, FPS hədəfləri ölçülməyib) |
| 19 | Admin veb paneli yoxdur (`196rp_admin` yalnız oyundandır) |
| 20 | Discord inteqrasiyası yalnız webhook-dur (bot, rol sinxronizasiyası, whitelist yoxdur) |
| 21 | Log sistemi sadədir (`print`) — strukturlu log/fayl yazımı yoxdur |
| 22 | Tərcümə yalnız Azərbaycan dilindədir |

---

## 4. Xarici asset tələb edən hissələr (kodla olmaz)

Bunlar üçün **modelləşdirmə paketi** lazımdır. Pulsuz boru kəməri:

```
1) AI mesh      →  Microsoft TRELLIS / TRELLIS.2  (MIT, açıq mənbə)
                   github.com/microsoft/TRELLIS
                →  Tencent Hunyuan3D 2.1  (açıq çəki, kommersiya icazəli)
                   github.com/Tencent-Hunyuan/Hunyuan3D-2.1
                →  Modly (lokal, pulsuz, open-source GUI)
                   modly3d.app/extensions
                →  Brauzerdə pulsuz: Hugging Face TRELLIS / Hunyuan3D demo-ları

2) GTA formatı  →  Sollumz (Blender plugin, pulsuz + open-source)
                   github.com/Sollumz/Sollumz
                   .ydr / .ytyp / .ymap / .ybn ixrac edir
                   (son versiya binary ixracı da dəstəkləyir; YMAP üçün
                    hələ CodeWalker XML lazımdır)

3) Tekstura     →  CC0 mənbələr (Poly Haven, ambientCG) + Blender
4) Yerləşdirmə  →  CodeWalker (pulsuz) → .ymap
5) Server       →  resources/196rp_bakumap_assets/ + ensure
```

Bu paket hazır olanda `196rp_bakumap/config.lua` faylında yalnız
`Config.UseCustomMap = true` + `Config.CustomCoords` doldurulur — bütün
resurslar avtomatik keçir.

**Məhdudiyyət:** AI mesh generatorları bina ölçüsündə təmiz topoqrafiya vermir;
adətən nəticə Blender-də retopologiya + LOD tələb edir. Bu əl işidir.

---

## 5. Növbəti addımlar (mənim edə biləcəyim, prioritet sırası ilə)

1. **Telefon NUI interfeysi** — zəng, SMS, kontakt, banka baxış, yol xəritəsi
2. **Dispetcher sistemi** — polis/EMS/taksi çağırışlarının xəritədə görünməsi
3. **İqtisadi balans cədvəli** — bütün qiymətlərin bir faylda auditi
4. **Avtomatik test + CI** — sintaksis/kontrakt/SQL yoxlamalarını GitHub Actions-a bağlamaq
5. **Backup skripti** — gündəlik mysqldump + bərpa əmri
6. **Loading screen + onboarding**
7. **Strukturlu log** — fayla yazılan JSON log + admin paneli üçün oxuma

---

## 6. Hazır olan (xatırlatma)

İş, məşğulluq, biznes, mağazalar, telefon mağazası (20 model), nəqliyyat (avtobus,
taksi, icarə, servis), dövlət qüvvələri (polis, TİB, yanğın, EMS, bələdiyyə),
qanunsuz fəaliyyət, ev sistemi, lisenziyalar, sosial sistem (evlilik, dostluq),
həyat tərzi (aclıq, stress, xəstəlik), kazino, sürət kameraları, Bakı xəritəsi
qatı (36 şəhər/rayon, 12 metro stansiyası, 3 xətt) + original interaktiv xəritə UI.

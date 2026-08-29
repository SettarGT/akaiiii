# 🇦🇿 Azerbaijan Role Play — Tam Quraşdırma Bələdçisi

Bu bələdçi QBCore əsaslı **Azerbaijan Role Play (196 RP)** serverinin sıfırdan quraşdırılmasını izah edir.

## 1. Tələblər

| Komponent | Tövsiyə |
|---|---|
| OS | Windows Server / Ubuntu 22.04+ |
| CPU | 4+ nüvə |
| RAM | 16 GB (32–64 oyunçu üçün) |
| DB | MySQL 8+ / MariaDB 10.6+ |
| FiveM | Son FXServer artifact (Windows / Linux) |
| Key | [keymaster.fivem.net](https://keymaster.fivem.net) — `sv_licenseKey` |

## 2. Server qovluğunun hazırlanması

```bash
mkdir -p /path/to/server
cd /path/to/server
# Repo fayllarını bura kopyalayın:
#   server.cfg, run.bat, icon.png, 196rp.sql, resources/, tools/, ...
```

Linux-da artifact quraşdırmaq üçün (isteğe bağlı):

```bash
bash install-fxserver.sh
```

## 3. Verilənlər bazası

```bash
mysql -u root -p -e "CREATE DATABASE 196rp CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -p 196rp < 196rp.sql
```

`196rp.sql` bütün QBCore cədvəllərini (players, inventory, jobs, vehicles, bans, ...)
və 196 RP cədvəllərini (`196_whitelist`) yaradır.

## 4. server.cfg tənzimləməsi

Açın və dəyişin:

```lua
sv_licenseKey "SIZIN_FX_LICENSE_KEY"
set mysql_connection_string "mysql://root:PAROL@127.0.0.1/196rp?charset=utf8mb4"
```

Əlavə olaraq istəsəniz:

```lua
setr UseTarget "true"          -- qb-target interaksiyaları (varsayılan: true)
setr qb_locale "az"            -- AZ dil (artıq qoyulub)
```

## 5. İlk adminin əlavə edilməsi

Konsolda `add_principal identifier.license:AAAA... group.admin` yazın və ya server.cfg sonuna:

```lua
# add_principal license:SIzinLicenseHashi group.admin
```

Adminlər whitelist-dən avtomatik keçir (`qbcore.god/admin/mod` ACE icazələri).

## 6. Discord Webhook

`resources/[196rp]/196rp_whitelist/config.lua`:

```lua
Config.Webhook = "https://discord.com/api/webhooks/..."
Config.DiscordInvite = "discord.gg/196rp"
Config.WhitelistEnabled = true
Config.OpenRegistration = false
```

Administratorlar wl əmrləri ilə müraciətləri qəbul edir.

## 7. İşə salma

**Windows:** `run.bat` (FXServer.exe ilə eyni qovluqda)

**Linux:**

```bash
./server/run.sh +exec server.cfg
```

## 8. CI yoxlaması

```bash
bash tools/ci/run_ci.sh
```

Hər şey keçməlidir; xəta halında `tools/ci/` çıxışını oxuyun.

## 9. Tez-tez verilən suallar

**Portal açılmır?**
`sv_licenseKey` və `mysql_connection_string` düzgündürsə, `console` loguna baxın.
Kayıp resurs = `ensure` sətri unudulub.

**Oyunçu "whitelist tələb olunur" görür?**
`196_whitelist` cədvəli idxal edilibmi? Admin `wlqebul <id>` etməlidir.

**Dil ingiliscə görünür?**
`setr qb_locale "az"` server.cfg-də olmalıdır və resursların `locales/az.lua`
fiksləri yerində olmalıdır.

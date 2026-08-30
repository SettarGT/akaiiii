@echo off
rem ═══ 196 RP | MySQL avtomatik backup (Windows · Task Scheduler) ═══
rem Task Scheduler nümunəsi: hər 6 saat - bu faylı işlədin
set DB_USER=root
set DB_PASS=senin_pasvordin
set DB_NAME=azrp
set OUT_DIR=C:\196RP\backups

if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"
set STAMP=%date:~-4%%date:~3,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set STAMP=%STAMP: =0%

mysqldump -u %DB_USER% -p%DB_PASS% %DB_NAME% --routines --events --single-transaction > "%OUT_DIR%\azrp_%STAMP%.sql" 2>nul
echo [196RP] backup ok: %OUT_DIR%\azrp_%STAMP%.sql

@echo off
chcp 65001 >nul
REM ============================================================
REM  196 RP - FXServer quraşdırma skripti (Windows)
REM  Bu skript rəsmi FiveM server fayllarini (artifact) endirir
REM  ve 'server' qovluguna acir.
REM
REM  Istifade:  install-fxserver.bat
REM  Not: Windows 10/11 ucun tar (libarchive) daxilidir.
REM ============================================================
setlocal
cd /d "%~dp0"

echo [196 RP] En son tovsiye olunan build tapilir...
set "REC="
for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "(Invoke-RestMethod 'https://changelogs-live.fivem.net/api/changelog/versions/windows/server').recommended" 2^>nul`) do set "REC=%%i"
if "%REC%"=="" set "REC=35245-6efb47dff473c0e2a12fb50b08d74c0eb24a50d5"
echo [196 RP] Build: %REC%

if not exist server mkdir server
if not exist server\cache mkdir server\cache

echo [196 RP] Endirilir (fayl ~250 MB, bir nece deqiqe ceke biler)...
powershell -NoProfile -Command "Invoke-WebRequest -Uri ('https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/%REC%/fx.tar.xz') -OutFile 'server\cache\fx.tar.xz'"

echo [196 RP] Acilir (server qovluguna)...
tar -xJf server\cache\fx.tar.xz -C server
rmdir /s /q server\cache

echo.
echo =============================================
echo  ✓ FXServer hazirdir!
echo =============================================
echo  Isle salmaq ucun:
echo    cd %CD%
echo    server\FXServer.exe +exec server.cfg
echo.
echo  Diqqet: server.cfg faylinda oz FiveM lisenziya
echo  acarinizi (keymaster.fivem.net) ve MySQL
echo  parolunuzu yazmagi unutmayin!
pause

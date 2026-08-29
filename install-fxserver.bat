@echo off
setlocal EnableExtensions
cd /d "%~dp0"

REM ============================================================
REM  196 RP - FXServer qurasdirma skripti (Windows)
REM
REM  Bu skript resmi FiveM server fayllarini (artifact) endirir
REM  ve 'server' qovluguna acir.
REM
REM  Istifade:   install-fxserver.bat            (en son build)
REM              install-fxserver.bat 35245      (xususi build)
REM
REM  Telebler: Windows 10/11 + internet. tar.exe
REM  (Windows 10/11 daxili) ve ya 7-Zip lazimdir.
REM ============================================================

title 196 RP - FXServer Qurasdirici

echo.
echo  ==================================================
echo     196 RP - FXServer Qurasdirici (Windows)
echo  ==================================================
echo.

REM ---------- 1. Qovluq hazirligi ----------
if not exist "server" mkdir server
if not exist "server\cache" mkdir server\cache

REM ---------- 2. Build nomresi ----------
set "REC=%~1"
if not "%REC%"=="" goto :have_rec

echo  [1/4] En son tovsiye olunan build tapilir...
for /f "delims=" %%i in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; $j=Invoke-RestMethod -UseBasicParsing 'https://changelogs-live.fivem.net/api/changelog/versions/windows/server'; $j.recommended" 2^>nul') do set "REC=%%i"
if not "%REC%"=="" (
    echo  [1/4] Build tapildi: %REC%
    goto :have_rec
)
set "REC=35245-6efb47dff473c0e2a12fb50b08d74c0eb24a50d5"
echo  [1/4] API alinamadi, sabit build istifade edilir: %REC%

:have_rec

REM ---------- 3. Endirme ----------
echo  [2/4] Endirilir: fx.tar.xz  (fayl ~250 MB, bir nece deqiqe ceke biler)...
set "DOWNLOAD_URL=https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/%REC%/fx.tar.xz"
echo        %DOWNLOAD_URL%

set "DL_OK=0"
where curl.exe >nul 2>&1
if %errorlevel%==0 (
    echo  [i] curl.exe istifade edilir...
    curl.exe -L -f -sS --retry 3 --connect-timeout 20 -o "server\cache\fx.tar.xz" "%DOWNLOAD_URL%"
    if exist "server\cache\fx.tar.xz" set "DL_OK=1"
)

if not "%DL_OK%"=="1" (
    echo  [i] curl.exe alinmadi / xeta. PowerShell ile yeniden cagirilir (TLS 1.2)...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -UseBasicParsing -Uri '%DOWNLOAD_URL%' -OutFile 'server\cache\fx.tar.xz'"
    if exist "server\cache\fx.tar.xz" set "DL_OK=1"
)

if not "%DL_OK%"=="1" goto :err_download

REM ---------- 4. Acma ----------
echo  [3/4] Fayl acilir (server qovluguna)...
set "EXTRACT_OK=0"

REM 4a. tar.exe (Windows 10/11 daxili)
where tar >nul 2>&1
if %errorlevel%==0 (
    tar -xJf "server\cache\fx.tar.xz" -C server
    if exist "server\FXServer.exe" set "EXTRACT_OK=1"
)

REM 4b. 7-Zip (tar yoxdursa)
if not "%EXTRACT_OK%"=="1" (
    set "SEVENZIP="
    if exist "%ProgramFiles%\7-Zip\7z.exe" set "SEVENZIP=%ProgramFiles%\7-Zip\7z.exe"
    if not defined SEVENZIP if exist "%ProgramFiles(x86)%\7-Zip\7z.exe" set "SEVENZIP=%ProgramFiles(x86)%\7-Zip\7z.exe"
    if not defined SEVENZIP where 7z >nul 2>&1 && set "SEVENZIP=7z"
    if defined SEVENZIP (
        echo  [i] 7-Zip istifade edilir...
        "%SEVENZIP%" x -y -o"server\cache" "server\cache\fx.tar.xz" >nul
        if exist "server\cache\fx.tar" (
            "%SEVENZIP%" x -y -o"server" "server\cache\fx.tar" >nul
        )
        if exist "server\FXServer.exe" set "EXTRACT_OK=1"
    )
)

if not "%EXTRACT_OK%"=="1" goto :err_extract

REM ---------- 5. Temizlik ve bitis ----------
rmdir /s /q "server\cache" >nul 2>&1
echo  [4/4] Hazir!
echo.
echo  ==================================================
echo   ✓ FXServer ugurla qurasdirildi!
echo  ==================================================
echo.
echo   Isle salmaq ucun:
echo      cd /d "%CD%"
echo      server\FXServer.exe +exec server.cfg
echo.
echo   Diqqet: server.cfg faylinda oz FiveM lisenziya acarini
echo   (keymaster.fivem.net) ve MySQL parolunu yazmagi unutma!
echo.
pause
exit /b 0

:err_download
echo.
echo  ==================================================
echo   [X] XETA: Fayl endirile bilmedi!
echo  ==================================================
echo.
echo   Mumkun sebebler:
echo    - Internet baglantisini yoxla
echo    - Antivirus / Firewall yuklemeni engelliyir
echo    - Build nomresi sehvdir
echo.
echo   El ile endirmek ucun brauzerde bu linki ac:
echo   %DOWNLOAD_URL%
echo.
echo   Endirilen fx.tar.xz faylini 'server\cache' qovluguna qoyub
echo   skripti yeniden calisdir.
pause
exit /b 1

:err_extract
echo.
echo  ==================================================
echo   [X] XETA: Fayl acila bilmedi!
echo  ==================================================
echo.
echo   Windows 10/11-de tar.exe daxilidir. Tapilmadisa:
echo   1) 7-Zip qurasdir:  https://www.7-zip.org/
echo   2) 'server\cache\fx.tar.xz' faylini tap
echo   3) Sag klik - 7-Zip - Extract here (once .tar,
echo      sonra qovlugun icindeki .tar fayli)
echo.
echo   NOT: Qovluq strukturu bele olmalidir:
echo      server\FXServer.exe
pause
exit /b 1

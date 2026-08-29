#!/usr/bin/env bash
# ============================================================
#  196 RP — FXServer quraşdırma skripti (Linux / Ubuntu/Debian)
#  Bu skript rəsmi FiveM server fayllarını (artifact) endirir
#  və 'server/' qovluğuna açır.
#
#  İstifadə:  bash install-fxserver.sh
# ============================================================
set -e
cd "$(dirname "$0")"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

# --- Əvvəlki yükləməni təmizlə ---
rm -rf server/cache

echo -e "${YELLOW}[196 RP]${NC} Ən son tövsiyə olunan FXServer build-i tapılır..."
API_URL="https://changelogs-live.fivem.net/api/changelog/versions/linux/server"

if command -v curl >/dev/null 2>&1; then
    API_JSON="$(curl -fsSL "$API_URL" 2>/dev/null || true)"
    REC="$(echo "$API_JSON" | grep -oP '"recommended":\s*"\K[^"]+' || true)"
elif command -v wget >/dev/null 2>&1; then
    API_JSON="$(wget -qO- "$API_URL" 2>/dev/null || true)"
    REC="$(echo "$API_JSON" | grep -oP '"recommended":\s*"\K[^"]+' || true)"
fi

# API tapılmadıqda — məlum yaxşı build (əllə yenilənə bilər)
if [ -z "${REC:-}" ]; then
    REC="35245-6efb47dff473c0e2a12fb50b08d74c0eb24a50d5"
    echo -e "${YELLOW}[196 RP]${NC} API əldə olunmadı, sabit build istifadə edilir: ${REC}"
else
    echo -e "${GREEN}[196 RP]${NC} Build tapıldı: ${REC}"
fi

URL="https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/${REC}/fx.tar.xz"

mkdir -p server/cache
echo -e "${YELLOW}[196 RP]${NC} Endirilir: ${URL}"
echo -e "${YELLOW}[196 RP]${NC} (Bu bir neçə dəqiqə çəkə bilər — fayl ~250 MB-dır)"

if command -v curl >/dev/null 2>&1; then
    curl -fSL --progress-bar -o server/cache/fx.tar.xz "$URL"
else
    wget -q --show-progress -O server/cache/fx.tar.xz "$URL"
fi

echo -e "${YELLOW}[196 RP]${NC} Açılır (server/ qovluğuna)..."
tar -xJf server/cache/fx.tar.xz -C server
chmod +x server/run.sh server/FXServer 2>/dev/null || true
rm -rf server/cache

echo ""
echo -e "${GREEN}=============================================${NC}"
echo -e "${GREEN} ✓ FXServer hazırdır!${NC}"
echo -e "${GREEN}=============================================${NC}"
echo -e " İşə salmaq üçün:"
echo -e "   cd $(pwd)"
echo -e "   ./server/run.sh +exec server.cfg"
echo ""
echo -e " Diqqət: server.cfg faylında öz FiveM lisenziya açarınızı"
echo -e " (keymaster.fivem.net) və MySQL parolunuzu yazmağı unutmayın!"

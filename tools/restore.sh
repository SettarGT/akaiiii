#!/usr/bin/env bash
# 196 RP — arxivdən bərpa
# İstifadə: bash tools/restore.sh backups/db-196rp-20260829-040000.sql.gz
set -euo pipefail

FILE="${1:-}"
DB_NAME="${DB_NAME:-196rp}"
DB_USER="${DB_USER:-root}"
DB_PASS="${DB_PASS:-}"
DB_HOST="${DB_HOST:-localhost}"

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  echo "İstifadə: bash tools/restore.sh <arxiv faylı>"
  echo "Mövcud arxivlər:"
  ls -1t backups/db-*.sql.gz 2>/dev/null | head -10 || echo "  (yoxdur)"
  exit 1
fi

PASS_ARG=()
[ -n "$DB_PASS" ] && PASS_ARG=("-p$DB_PASS")

echo "Diqqət: '$DB_NAME' bazası silinib yenidən qurulacaq."
read -r -p "Davam etmək üçün 'BELI' yazın: " CONFIRM
[ "$CONFIRM" = "BELI" ] || { echo "Ləğv edildi."; exit 1; }

mysql -h "$DB_HOST" -u "$DB_USER" "${PASS_ARG[@]}" -e "DROP DATABASE IF EXISTS \`$DB_NAME\`; CREATE DATABASE \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
gunzip -c "$FILE" | mysql -h "$DB_HOST" -u "$DB_USER" "${PASS_ARG[@]}" "$DB_NAME"
echo "Bərpa tamamlandı: $FILE → $DB_NAME"

#!/usr/bin/env bash
# ═══ 196 RP | MySQL avtomatik backup (6 saatdan bir cron üçün) ═══
# Cron nümunəsi:  0 */6 * * *  /home/196rp/scripts/mysql-backup.sh
set -e
DB_USER="${DB_USER:-root}"
DB_PASS="${DB_PASS:-}"
DB_NAME="${DB_NAME:-azrp}"
OUT_DIR="${OUT_DIR:-/home/196rp/backups}"
KEEP="${KEEP:-14}"

mkdir -p "$OUT_DIR"
STAMP=$(date +%Y-%m-%d_%H-%M)
PASS_ARG=""
[ -n "$DB_PASS" ] && PASS_ARG="-p$DB_PASS"

mysqldump -u "$DB_USER" $PASS_ARG "$DB_NAME" --routines --events --single-transaction > "$OUT_DIR/azrp_$STAMP.sql" 2>/dev/null
gzip -f "$OUT_DIR/azrp_$STAMP.sql"

# yalnız son KEEP fayl saxlanılır
ls -t "$OUT_DIR"/azrp_*.sql.gz 2>/dev/null | tail -n +$((KEEP+1)) | xargs -r rm -f
echo "[196RP] backup ok: $OUT_DIR/azrp_$STAMP.sql.gz"

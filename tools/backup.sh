#!/usr/bin/env bash
# 196 RP — avtomatik arxiv (backup)
# Bazanı (mysqldump) və stream/ qovluqlarını arxivləyir, köhnələri silir.
#
# İstifadə:      bash tools/backup.sh
# Avtomatik:     crontab -e  →  0 4,16 * * *  cd /path/to/server && bash tools/backup.sh
set -uo pipefail

# ---------- tənzimləmə ----------
DB_NAME="${DB_NAME:-196rp}"
DB_USER="${DB_USER:-root}"
DB_PASS="${DB_PASS:-}"
DB_HOST="${DB_HOST:-localhost}"
BACKUP_DIR="${BACKUP_DIR:-backups}"
KEEP_DAYS="${KEEP_DAYS:-14}"          # neçə gün saxlanılır
KEEP_COUNT="${KEEP_COUNT:-20}"        # ən çox neçə arxiv
STAMP="$(date +%Y%m%d-%H%M%S)"
LOG_DIR="$BACKUP_DIR/logs"

mkdir -p "$BACKUP_DIR" "$LOG_DIR"
LOG="$LOG_DIR/backup-$STAMP.log"

log() { echo "[$(date '+%F %T')] $*" | tee -a "$LOG"; }

log "=== 196 RP backup başladı ==="

# ---------- 1. baza ----------
MYSQLDUMP="$(command -v mysqldump || true)"
if [ -z "$MYSQLDUMP" ]; then
  # bəzi quraşdırmalarda PATH-də olmur
  for c in /usr/bin/mysqldump /usr/local/bin/mysqldump /usr/local/mysql/bin/mysqldump; do
    [ -x "$c" ] && MYSQLDUMP="$c" && break
  done
fi

if [ -n "$MYSQLDUMP" ]; then
  PASS_ARG=()
  [ -n "$DB_PASS" ] && PASS_ARG=("-p$DB_PASS")
  SQL_FILE="$BACKUP_DIR/db-$DB_NAME-$STAMP.sql.gz"

  if "$MYSQLDUMP" -h "$DB_HOST" -u "$DB_USER" "${PASS_ARG[@]}" \
       --single-transaction --quick --routines --triggers --events \
       --default-character-set=utf8mb4 "$DB_NAME" 2>>"$LOG" | gzip -9 > "$SQL_FILE"; then
    SIZE="$(du -h "$SQL_FILE" | cut -f1)"
    log "BAZA OK: $SQL_FILE ($SIZE)"
  else
    log "BAZA XƏTA: mysqldump uğursuz oldu (bax: $LOG)"
    rm -f "$SQL_FILE"
  fi
else
  log "XƏBƏRDARLIQ: mysqldump tapılmadı — baza arxivlənmədi"
fi

# ---------- 2. stream/ və config faylları ----------
STREAM_DIRS="$(find resources -type d -name stream 2>/dev/null)"
if [ -n "$STREAM_DIRS" ]; then
  TAR_FILE="$BACKUP_DIR/stream-$STAMP.tar.gz"
  # shellcheck disable=SC2086
  if tar -czf "$TAR_FILE" $STREAM_DIRS 2>>"$LOG"; then
    log "STREAM OK: $TAR_FILE ($(du -h "$TAR_FILE" | cut -f1))"
  else
    log "STREAM XƏTA"
  fi
else
  log "STREAM: heç bir stream/ qovluğu tapılmadı (hələ 3D asset yoxdur)"
fi

# ---------- 3. server.cfg ----------
if [ -f server.cfg ]; then
  cp server.cfg "$BACKUP_DIR/server-$STAMP.cfg"
  log "CONFIG OK: server-$STAMP.cfg"
fi

# ---------- 4. köhnə arxivlərin təmizlənməsi ----------
find "$BACKUP_DIR" -maxdepth 1 -type f -mtime "+$KEEP_DAYS" -delete 2>/dev/null
ls -1t "$BACKUP_DIR"/db-*.sql.gz 2>/dev/null | tail -n +"$((KEEP_COUNT + 1))" | xargs -r rm -f
ls -1t "$BACKUP_DIR"/stream-*.tar.gz 2>/dev/null | tail -n +"$((KEEP_COUNT + 1))" | xargs -r rm -f
ls -1t "$LOG_DIR"/backup-*.log 2>/dev/null | tail -n +31 | xargs -r rm -f

log "=== tamamlandı. Saxlanılan arxiv sayı: $(ls -1 "$BACKUP_DIR" | grep -cE '\.(gz|cfg)$') ==="

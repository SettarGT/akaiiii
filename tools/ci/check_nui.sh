#!/usr/bin/env bash
# Bütün NUI JavaScript fayllarının sintaksisini node ilə yoxlayır
set -uo pipefail
FAIL=0
COUNT=0
while IFS= read -r f; do
  COUNT=$((COUNT+1))
  if ! node --check "$f" 2>&1; then
    echo "  JS XƏTASI: $f"
    FAIL=1
  fi
done < <(find resources -path '*/web/js/*.js' -o -path '*/html/js/*.js' | sort)
echo "[nui] yoxlanılan JS fayl: $COUNT, xəta: $FAIL"
exit $FAIL

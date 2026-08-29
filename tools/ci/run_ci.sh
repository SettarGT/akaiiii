#!/usr/bin/env bash
# 196 RP — tam CI yoxlaması. Lokal və GitHub Actions-da eyni skript işləyir.
set -uo pipefail
cd "$(dirname "$0")/../.."

FAIL=0
run() {
  local name="$1"; shift
  echo ""
  echo "── $name"
  if "$@"; then
    echo "   OK"
  else
    echo "   UĞURSUZ"
    FAIL=1
  fi
}

run "Lua sintaksisi"        python3 tools/ci/check_syntax.py
run "Forward-reference"     python3 tools/ci/check_forward_refs.py "resources/[196rp]"
run "Client/Server kontrakt" python3 tools/ci/check_contracts.py
run "SQL referansları"      python3 tools/ci/check_sql_refs.py
run "Manifestlər"           python3 tools/ci/check_manifests.py
run "NUI JavaScript"        bash tools/ci/check_nui.sh
run "Lua unit testləri"     python3 tools/tests/run_tests.py

echo ""
if [ "$FAIL" -eq 0 ]; then
  echo "✅ BÜTÜN YOXLAMALAR KEÇDİ"
else
  echo "❌ YOXLAMALAR UĞURSUZ OLDU"
fi
exit $FAIL

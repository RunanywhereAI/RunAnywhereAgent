#!/usr/bin/env bash
set -euo pipefail

# ── RunanywhereAI — Key Management ───────────────────────────────────
# Keep this file PRIVATE. Do NOT commit the .env file.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/.env" ] && source "$SCRIPT_DIR/.env"

PROXY_URL="${PROXY_URL:-http://54.226.134.16}"
MASTER_KEY="${LITELLM_MASTER_KEY:-}"

[ -z "$MASTER_KEY" ] && { echo "Set LITELLM_MASTER_KEY in admin/.env"; exit 1; }

case "${1:-help}" in
  create)
    USER="${2:?Usage: $0 create <user> [budget]}"
    BUDGET="${3:-50}"
    RESP=$(curl -s -X POST "$PROXY_URL/key/generate" \
      -H "Authorization: Bearer $MASTER_KEY" \
      -H "Content-Type: application/json" \
      -d "{\"user_id\":\"$USER\",\"max_budget\":$BUDGET,\"budget_duration\":\"monthly\"}")
    KEY=$(echo "$RESP" | python3 -c "import sys,json; print(json.load(sys.stdin).get('key','ERROR'))" 2>/dev/null)
    echo ""
    echo "  User:   $USER"
    echo "  Key:    $KEY"
    echo "  Budget: \$$BUDGET/month"
    echo ""
    echo "  Send them this:"
    echo "    curl -fsSL https://raw.githubusercontent.com/OWNER/agent/main/install.sh | bash -s -- $KEY"
    echo ""
    ;;
  list)
    curl -s "$PROXY_URL/key/list" -H "Authorization: Bearer $MASTER_KEY" | python3 -c "
import sys,json
data = json.load(sys.stdin)
keys = data if isinstance(data, list) else data.get('keys', [])
if not keys: print('  No keys.')
else:
  print(f'  {\"User\":<20} {\"Key\":<30} {\"Spend\":<10}')
  print(f'  {\"─\"*20} {\"─\"*30} {\"─\"*10}')
  for k in keys:
    print(f'  {k.get(\"user_id\",\"?\")[:20]:<20} {k.get(\"token\",k.get(\"key\",\"?\"))[:30]:<30} \${k.get(\"spend\",0):.2f}')
" 2>/dev/null
    ;;
  revoke)
    KEY="${2:?Usage: $0 revoke <key>}"
    curl -s -X POST "$PROXY_URL/key/delete" \
      -H "Authorization: Bearer $MASTER_KEY" \
      -H "Content-Type: application/json" \
      -d "{\"keys\":[\"$KEY\"]}"
    echo " Revoked."
    ;;
  *)
    echo "Usage: $0 {create <user> [budget] | list | revoke <key>}"
    ;;
esac

#!/usr/bin/env bash
set -euo pipefail

CONTAINER="${1:-test-nginx}"
WEBHOOK="${DISCORD_WEBHOOK:-}"
PATTERN="${2:-error|fail|panic|oom|timeout|stuck|no peers}"

if [[ -z "$WEBHOOK" ]]; then
  echo "DISCORD_WEBHOOK が未設定です。"
  exit 1
fi

# 直近200行からパターン検出
HIT="$(docker logs "$CONTAINER" --since 65s 2>&1 | grep -E -i "$PATTERN" | tail -n 5 || true)"

if [[ -n "$HIT" ]]; then
  # 文字列整形（改行を \n に）
  SAFE="$(printf "%s" "$HIT" | sed ':a;N;$!ba;s/\n/\\n/g')"
  PAYLOAD="$(printf "%s" "🚨 Log alert in '${CONTAINER}':\n${HIT}" | jq -Rs '{content: .}')"
  curl -sS -H "Content-Type: application/json" -d "$PAYLOAD" "$WEBHOOK" >/dev/null
fi


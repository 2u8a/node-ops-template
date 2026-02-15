#!/usr/bin/env bash
set -euo pipefail

WEBHOOK="${DISCORD_WEBHOOK:-}"
THRESHOLD_MB="${1:-500}"  # 空きメモリ+キャッシュが500MB未満で通知

if [[ -z "$WEBHOOK" ]]; then
  echo "DISCORD_WEBHOOK が未設定です。"
  exit 1
fi

# availableメモリ（MB）
AVAIL="$(free -m | awk '/Mem:/ {print $7}')"

if (( AVAIL <= THRESHOLD_MB )); then
  MSG="⚠️ Low memory: available ${AVAIL}MB (<=${THRESHOLD_MB}MB). free -h: $(free -h | tr '\n' ' ')"
  curl -H "Content-Type: application/json" -d "{\"content\":\"$MSG\"}" "$WEBHOOK" >/dev/null
fi

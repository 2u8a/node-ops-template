#!/usr/bin/env bash
set -euo pipefail

WEBHOOK="${DISCORD_WEBHOOK:-}"
THRESHOLD="${1:-80}"   # %（80%超えたら通知）

if [[ -z "$WEBHOOK" ]]; then
  echo "DISCORD_WEBHOOK が未設定です。"
  exit 1
fi

# ルート(/)の使用率を取得
USEP="$(df -P / | awk 'NR==2{gsub("%","",$5); print $5}')"

if (( USEP >= THRESHOLD )); then
  MSG="⚠️ Disk usage is ${USEP}% (>=${THRESHOLD}%). df -h: $(df -h / | tail -n 1)"
  curl -H "Content-Type: application/json" -d "{\"content\":\"$MSG\"}" "$WEBHOOK" >/dev/null
fi

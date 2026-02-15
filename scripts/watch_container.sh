#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${1:-test-nginx}"
WEBHOOK="${DISCORD_WEBHOOK:-}"

if [[ -z "$WEBHOOK" ]]; then
  echo "DISCORD_WEBHOOK が未設定です。"
  exit 1
fi

# コンテナが存在するか
if ! docker inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
  curl -H "Content-Type: application/json" \
    -d "{\"content\":\"⚠️ 監視対象コンテナ '${CONTAINER_NAME}' が見つからない\"}" \
    "$WEBHOOK" >/dev/null
  exit 0
fi

# running 判定
RUNNING="$(docker inspect -f '{{.State.Running}}' "$CONTAINER_NAME")"

if [[ "$RUNNING" != "true" ]]; then
  STATUS="$(docker inspect -f '{{.State.Status}} (exit={{.State.ExitCode}}) finished={{.State.FinishedAt}}' "$CONTAINER_NAME" 2>/dev/null || true)"
  curl -H "Content-Type: application/json" \
    -d "{\"content\":\"🚨 '${CONTAINER_NAME}' が停止/異常: ${STATUS}\"}" \
    "$WEBHOOK" >/dev/null

docker start "$CONTAINER_NAME" >/dev/null 2>&1 || true
curl -H "Content-Type: application/json" \
  -d "{\"content\":\"🛠 '${CONTAINER_NAME}' 自動再起動中...\"}" \
  "$WEBHOOK" >/dev/null

fi

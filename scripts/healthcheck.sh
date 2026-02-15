#!/usr/bin/env bash
set -euo pipefail

# このファイルの場所（scripts/）を基準にする
SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPTS_DIR/.." && pwd)"

# .env 読み込み（systemdのEnvironmentFileでも入るが、手動実行でも動くように）
if [[ -f "$ROOT_DIR/.env" ]]; then
  # shellcheck disable=SC1090
  source "$ROOT_DIR/.env"
fi

# 必須チェック
: "${DISCORD_WEBHOOK:?DISCORD_WEBHOOK is required (set in .env)}"
: "${CONTAINER_NAME:?CONTAINER_NAME is required (set in .env)}"

DISK_THRESHOLD="${DISK_THRESHOLD:-80}"
MEM_THRESHOLD_MB="${MEM_THRESHOLD_MB:-500}"
LOG_PATTERN="${LOG_PATTERN:-panic|oom|fatal|segfault|timeout|stuck|no peers}"
RPC_PORT="${RPC_PORT:-8888}"

# 1) コンテナ死活
"$SCRIPTS_DIR/watch_container.sh" "$CONTAINER_NAME"

# 2) ディスク
"$SCRIPTS_DIR/watch_disk.sh" "$DISK_THRESHOLD"

# 3) メモリ
"$SCRIPTS_DIR/watch_mem.sh" "$MEM_THRESHOLD_MB"

# 4) ログ
"$SCRIPTS_DIR/watch_logs.sh" "$CONTAINER_NAME" "$LOG_PATTERN"

# 5) 同期（check_sync.sh が引数対応してる前提。未対応なら次で直す）
"$SCRIPTS_DIR/check_sync.sh" "$CONTAINER_NAME" "$RPC_PORT"

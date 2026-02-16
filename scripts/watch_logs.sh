#!/usr/bin/env bash
set -euo pipefail

CONTAINER="${1:-$CONTAINER_NAME}"
PATTERN="${2:-$LOG_PATTERN}"
WEBHOOK="${DISCORD_WEBHOOK:-}"

STATE_FILE="/tmp/node_ops_${CONTAINER}_last_log"

HIT="$(docker logs "$CONTAINER" --tail 200 2>&1 | grep -E -i "$PATTERN" | tail -n 5 || true)"

if [[ -z "$HIT" ]]; then
  echo "" > "$STATE_FILE"
  exit 0
fi

LAST="$(cat "$STATE_FILE" 2>/dev/null || true)"

if [[ "$HIT" == "$LAST" ]]; then
  exit 0
fi

echo "$HIT" > "$STATE_FILE"

PAYLOAD="$(printf "🚨 Log alert in %s:\n%s" "$CONTAINER" "$HIT" | jq -Rs '{content: .}')"
curl -sS -H "Content-Type: application/json" -d "$PAYLOAD" "$WEBHOOK" >/dev/null

#!/bin/bash

CONTAINER="test-nginx"   # ← 実際のコンテナ名
WEBHOOK="${DISCORD_WEBHOOK}"
PORT=8888

get_height() {
  docker exec "$CONTAINER" curl -s http://localhost:$PORT/status \
    | jq '.result.last_added_block_info.height'
}

H1=$(get_height)
sleep 30
H2=$(get_height)

if [ "$H1" == "$H2" ]; then
  PAYLOAD=$(printf "🚨 Sync stopped! Height: %s" "$H1" | jq -Rs '{content: .}')
  curl -s -H "Content-Type: application/json" -d "$PAYLOAD" "$WEBHOOK"

  docker restart "$CONTAINER"
fi

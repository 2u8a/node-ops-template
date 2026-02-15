#!/usr/bin/env bash
set -euo pipefail

echo "[1/4] Packages (curl/jq)..."
sudo apt-get update -y
sudo apt-get install -y curl jq

echo "[2/4] Make scripts executable..."
chmod +x /home/user/node-ops-template/scripts/*.sh

echo "[3/4] Install systemd units..."
sudo cp /home/user/node-ops-template/systemd/node-health.service /etc/systemd/system/node-health.service
sudo cp /home/user/node-ops-template/systemd/node-health.timer /etc/systemd/system/node-health.timer

echo "[4/4] Enable timer..."
sudo systemctl daemon-reload
sudo systemctl enable --now node-health.timer

echo "✅ Done."
echo "Check: systemctl list-timers | grep node-health"
echo "Logs : sudo journalctl -u node-health.service -n 80 --no-pager"

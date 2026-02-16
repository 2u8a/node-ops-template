cat > README.md << 'EOF'
# Node Ops Template v1

Dockerコンテナで動作するノードの監視テンプレート。

## 🎯 目的

- ノードが「死んでいる」だけでなく
- 「動いているが壊れている（同期停止など）」状態も検知
- Discordへ通知
- systemd timerで自動実行

---

## 🧩 構成

systemd timer  
↓  
healthcheck.sh  
↓  
各監視スクリプト

scripts/
├── healthcheck.sh # 統合監視
├── watch_container.sh # コンテナ死活監視
├── watch_disk.sh # ディスク使用率監視
├── watch_mem.sh # メモリ監視
├── watch_logs.sh # ログパターン検知
├── check_sync.sh # RPC同期停止検知


---

## 🔔 Discord通知

Webhook URL を `.env` に設定。

bash
DISCORD_WEBHOOK="https://discord.com/api/webhooks/..."
⚙️ セットアップ
cp .env.example .env
nano .env
bash install.sh
確認：

systemctl list-timers | grep node-health
ログ：

sudo journalctl -u node-health.service -n 80 --no-pager
🖥 想定VPSスペック
Ubuntu 22.04 / 24.04 LTS

2–4 vCPU

4–8GB RAM

80GB+ SSD

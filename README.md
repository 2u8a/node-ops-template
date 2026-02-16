## Features
- Docker container health monitoring
- Disk usage alert
- Memory pressure alert
- Log pattern detection
- Sync stop detection (RPC)
- systemd timer automation
- Discord webhook notification

## Architecture
- systemd timer → healthcheck.sh
- healthcheck.sh → individual monitors
- jq-safe Discord payload
- idempotent + fail-fast design

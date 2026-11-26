#!/bin/bash
set -euo pipefail
umask 077
cd /app

mkdir -p /root/jet
# StartOS owns the optional Telegram setting. Pass it as data, without logging it.
token=
if [[ -f /root/start9/config.yaml ]]; then
    token=$(yq e '.token' /root/start9/config.yaml)
fi
JET_STARTOS_TOKEN="$token" node /usr/local/lib/jet-config.js
# Create the target before SQLite opens its symlink so journals use the data volume too.
touch /root/jet/jet.db

# Rebalance PIDs expire with the container. Clear them before Jet can inspect them.
node <<'JS'
const { DatabaseSync } = require('node:sqlite');
const db = new DatabaseSync('/root/jet/jet.db');
try {
    // Jet creates the table itself on the first run.
    if (db.prepare("SELECT 1 FROM sqlite_schema WHERE type = 'table' AND name = 'active_rebalance'").get()) {
        db.exec('DELETE FROM active_rebalance');
    }
} finally {
    db.close();
}
JS

jet start daddy
exec sleep infinity

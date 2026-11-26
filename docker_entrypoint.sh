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

jet start daddy
exec sleep infinity

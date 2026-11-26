# Welcome to Lightning Jet!

### This is a tool for working with the balance of your satoshis on LND 

**Lightning Jet is command-line only service; an SSH Key is required to use this service.**

**IMPORTANT** 
When this service is started it will automatically start rebalancing attempts. *Rebalancing may spend your satoshis!* 
Jet 1.7.0 limits automated rebalances to 100,000 sats in fees over a rolling 24 hours by default, including on existing configurations. Fees already paid on manual rebalances count toward the cap. To change the limit, set `rebalancer.maxDailyFee` in Jet's configuration. A value of `0` disables the cap.
See the [upstream configuration reference](https://github.com/drneski/lightning-jet/blob/v1.7.0-node22/README.md#config-file) for details.

## Upgrading from 1.6.0.3

The old package keeps Jet's files inside its container. **Run this on your StartOS 0.3.x server over SSH while 1.6.0.3 is still running, before stopping the service in StartOS or installing the update.** Stopping the Jet processes inside the container leaves it available for the copy. Allow free space for a second copy of the database.

```sh
sudo podman exec -i -w /app lightning-jet.embassy sh -eu <<'CARRY_OVER'
umask 077
test ! -e /root/jet || { echo 'Saved Jet data already exists. Inspect /root/jet before continuing.'; exit 1; }
jet stop all
stage=$(mktemp -d /root/.jet-import.XXXXXX)
cp api/config.json "$stage/config.json"
node -e 'JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"))' "$stage/config.json"
if [ -f db/jet.db ]; then
    node - "$stage/jet.db" <<'SQLITE'
const sqlite = require('sqlite3');
const db = new sqlite.Database('/app/db/jet.db', sqlite.OPEN_READONLY);
db.configure('busyTimeout', 30000);
db.run('VACUUM INTO ?', [process.argv[2]], err => {
  if (err) throw err;
  db.close();
  const saved = new sqlite.Database(process.argv[2], sqlite.OPEN_READONLY);
  saved.all('PRAGMA integrity_check', (err, rows) => {
    if (err) throw err;
    if (rows.length !== 1 || rows[0].integrity_check !== 'ok') throw Error('Database integrity check failed');
    saved.close();
  });
});
SQLITE
fi
mv -T "$stage" /root/jet
echo 'Jet state saved to the StartOS data volume.'
CARRY_OVER
```

Proceed with the update only after the success message. The SQLite snapshot includes committed changes in the write-ahead log. If Jet has never created a database, the command carries over the configuration alone. If you postpone the update and restart Jet on 1.6.0.3, take a fresh snapshot of any later changes.

Start the updated package and check your settings and rebalance history. From this version onward, edit `/root/jet/config.json` inside the container. The package stores it and `/root/jet/jet.db` on the StartOS main data volume, which survives container replacement and is included in package backups. The Telegram token configured in the StartOS UI takes precedence over a token in Jet's file.

On each service start, the package clears active rebalance registrations because their process IDs belong to the previous run. Completed rebalances and their fees remain in the rolling daily fee calculation.

## Setup
Please note: the default SSH user is "start9", so you will need to add `sudo` to the beginning of each command below.
> 1. SSH into this Embassy (add a new SSH Key if needed)
>
> 2. Run the following command to enter the `lightning-jet.embassy` container:
>
>    `sudo podman exec -it lightning-jet.embassy /bin/bash`

**You should now be able to run Lightning Jet commands.**

## Logs
Please note: the default SSH user is "start9", so you will need to add `sudo` to the beginning of each command below.

To access logs on Lightning Jet, you can run any of the following commands:
> 1. `sudo podman exec lightning-jet.embassy cat /tmp/rebalancer.log`
> 1. `sudo podman exec lightning-jet.embassy cat /tmp/htlc-logger.log`
> 1. `sudo podman exec lightning-jet.embassy cat /tmp/launcher.log`
> 1. `sudo podman exec lightning-jet.embassy cat /tmp/telegram.log`

## Telegram Bot

Lightning Jet telegram bot (Jet bot) will notify you about important events such as changes in fees for your remote peers.

To create Jet bot: initiate a conversation with BotFather on your Telegram app. Then, select the bot's name (e.g., JET bot) and bot's username (e.g., JET_bot).

Copy the telegram token from the Telegram app chat with BotFather (right under 'Use this token to access the HTTP API:'). Paste this token in the `Telegram API Token` field in your config window.

Start your Lightning Jet service, then open a chat with the bot you just created in your Telegram app and type /start. This will kick off the communication between the Telegram bot with Jet. You only need to do this step once.
## Run the command `jet help` for more information.

# Welcome to Lightning Jet!

### This is a tool for working with the balance of your satoshis on LND 

**Lightning Jet is command-line only service; an SSH Key is required to use this service.**

**IMPORTANT** 
When this service is started it will automatically start rebalancing attempts. *Rebalancing may spend your satoshis!* 
Jet 1.7.0 limits automated rebalances to 100,000 sats in fees over a rolling 24 hours by default, including on existing configurations. Fees already paid on manual rebalances count toward the cap. To change the limit, set `rebalancer.maxDailyFee` in Jet's configuration. A value of `0` disables the cap.
See the [upstream configuration reference](https://github.com/drneski/lightning-jet/blob/v1.7.0-node22/README.md#config-file) for details.

## Upgrading from 1.6.0.3

Jet 1.7.0 can use the existing configuration and database without conversion. The 1.6.0.3 StartOS wrapper stores Jet's `/app/api/config.json` and `/app/db/jet.db` outside the persistent `/root` volume. If you need custom Jet settings or rebalance history, save a consistent copy of those files before upgrading. The StartOS package backup covers the mounted data volume.

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

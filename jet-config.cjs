const fs = require('node:fs');

const target = '/root/jet/config.json';
const existing = fs.existsSync(target);
const config = JSON.parse(fs.readFileSync(existing ? target : '/app/api/config.default.json', 'utf8'));
if (!config || typeof config !== 'object' || Array.isArray(config)) {
  throw new Error('Expected a JSON object in the Jet configuration');
}
if (!existing) {
  config.macaroonPath = '/mnt/lnd/admin.macaroon';
  config.tlsCertPath = '/mnt/lnd/tls.cert';
  config.serverAddress = 'lnd.embassy:10009';
  config.rebalancer.minCapacity = 50000;
}

const token = process.env.JET_STARTOS_TOKEN;
const hasToken = token && token !== 'null';
const managed = '/root/jet/.startos-managed-telegram';
const clearing = !hasToken && fs.existsSync(managed);
if (!existing || (hasToken && token !== config.telegramToken) || clearing) {
  if (hasToken) config.telegramToken = token;
  if (clearing) delete config.telegramToken;
  fs.writeFileSync(target + '.tmp', JSON.stringify(config, null, 2) + '\n', { mode: 0o600 });
  fs.renameSync(target + '.tmp', target);
}
if (hasToken) fs.closeSync(fs.openSync(managed, 'a', 0o600));
if (clearing) fs.unlinkSync(managed);

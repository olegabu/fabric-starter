

const path = require('path');
const CONFIG_DEFAULT = path.join(__dirname, '../artifacts/network-config.json');

var config = process.env.CONFIG_FILE || CONFIG_DEFAULT;

module.exports = config;
/*

 */
const path = require('path');

var log4js = require('log4js');
var logger = log4js.getLogger('fabric-client');
logger.setLevel('DEBUG');

const CONFIG_DEFAULT = '../../artifacts/network-config.json';
// const CRYPTO_CONFIG_DIR_DEFAULT = '../../artifacts/crypto-config';

////
var config = process.env.CONFIG_FILE || CONFIG_DEFAULT;
if(!path.isAbsolute(config)){
  config = path.join(__dirname, config);
}
logger.info('Use network config file: %s', config);

// TODO: use basepath for 'crypto-config' folder in network-config.json
// var cryptoConfigDir = process.env.CRYPTO_CONFIG_DIR || CRYPTO_CONFIG_DIR_DEFAULT;
// if(!path.isAbsolute(cryptoConfigDir)){
//   cryptoConfigDir = path.join(__dirname, cryptoConfigDir);
// }
// logger.info('Use cryptoConfigDir: %s', cryptoConfigDir);





///////
var hfc = require('fabric-client');
hfc.setLogger(logger);
hfc.addConfigFile(config);

// you can always get config:
// var ORGS = hfc.getConfigSetting('network-config');

module.exports = hfc;
/*

 */
"use strict";
const RELPATH = '/../'; // relative path to server root. Change it during file movement
const path  = require('path');
const fs    = require('fs');

var log4js = require('log4js');
var logger = log4js.getLogger('fabric-client');
logger.setLevel('DEBUG');

// const CONFIG_DIR_DEFAULT = '/etc/hyperledger/artifacts';
const CONFIG_DIR_DEFAULT = '../artifacts/';
const CONFIG_FILE_DEFAULT = 'network-config.json';

////
// TODO: temporaly disable CONFIG_FILE to make migration simplier
var configFile = /*process.env.CONFIG_FILE || */ CONFIG_FILE_DEFAULT;
var configDir = process.env.CONFIG_DIR || CONFIG_DIR_DEFAULT;
if(!path.isAbsolute(configDir)){
  configDir = path.join(__dirname, RELPATH, configDir);
}
var config = path.join(configDir, configFile);


logger.info('Use network config file: %s', config);
fs.accessSync(config, fs.constants.R_OK);

///////
var hfc = require('fabric-client');
hfc.setLogger(logger);
hfc.addConfigFile(config);
hfc.setConfigSetting('config-dir', configDir);


// you can always get config:
// var ORGS = hfc.getConfigSetting('network-config');
// var CONFIG_DIR = hfc.getConfigSetting('config-dir');

module.exports = hfc;
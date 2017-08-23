/*

 */
"use strict";
const RELPATH = '/../'; // relative path to server root. Change it during file movement
const path  = require('path');
const fs    = require('fs');

var log4js = require('log4js');

var logger = log4js.getLogger('fabric-client');
logger.setLevel('INFO');

// const CONFIG_FILE_DEFAULT = '/etc/hyperledger/artifacts/network-config.json';
const CONFIG_FILE_DEFAULT = '../artifacts/network-config.json';

////
var configFile = process.env.CONFIG_FILE || CONFIG_FILE_DEFAULT;
if(!path.isAbsolute(configFile)){
  configFile = path.join(__dirname, RELPATH, configFile);
}
var configDir = path.dirname(configFile);

logger.info('Use network config file: %s', configFile);

// fs.accessSync(configFile, fs.constants.R_OK);
var config = JSON.parse(fs.readFileSync(configFile).toString());


///////
var hfc = require('fabric-client');
hfc.setLogger(logger);
hfc.addConfigFile(configFile);  // this config needed for lib-fabric
hfc.setConfigSetting('config', config);  // this config needed for client
hfc.setConfigSetting('config-dir',  configDir);
hfc.setConfigSetting('config-file', configFile);



// you can always get config:
// var ORGS = hfc.getConfigSetting('network-config');
// var CONFIG_DIR = hfc.getConfigSetting('config-dir');

module.exports = hfc;
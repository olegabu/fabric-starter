/**
 * Copyright 2017 IBM All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an 'AS IS' BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
'use strict';
var log4js = require('log4js');
var logger = log4js.getLogger('Helper');
logger.setLevel('DEBUG');

var path = require('path');
var util = require('util');
var fs = require('fs-extra');
var User = require('fabric-client/lib/User.js');
var Peer = require('fabric-client/lib/Peer.js');
var EventHub = require('fabric-client/lib/EventHub.js');
var CopService = require('fabric-ca-client');
var config = require('../config.json');

var hfc = require('./hfc');
var ORGS = hfc.getConfigSetting('network-config');
var CONFIG_DIR = hfc.getConfigSetting('config-dir');

var clients = {};
var channels = {};
var caClients = {};

//


/**
 * set up the client objects for each org
 * @param {string} username
 * @param {string} orgID
 * @returns {Client}
 */
function setupOrgClient(username, orgID){
  if(!ORGS[orgID]){
    throw new Error('No such organisation: '+orgID);
  }

  let client = new hfc(); // jshint ignore: line
  let cryptoSuite = hfc.newCryptoSuite();
  cryptoSuite.setCryptoKeyStore(hfc.newCryptoKeyStore({path: getKeyStoreForOrg(username, orgID)}));
  client.setCryptoSuite(cryptoSuite);

  let caUrl = ORGS[orgID].ca;
  caClients[orgID] = new CopService(caUrl, null /*default TLS opts*/, '' /* default CA */, cryptoSuite);

  return client;
}

/**
 * @param {string} channelID
 * @param {string} username
 * @param {string} orgID
 * @returns {Channel}
 */
function setupChannel(channelID, username, orgID){
  let client = getClientForOrg(username, orgID);
  if(!client._channels[channelID]) {
    let channel = client.newChannel(channelID);
    channel.addOrderer(newOrderer(client));

    setupPeers(channel, orgID, client);
    client._channels[channelID] = channel;
  }
  return client._channels[channelID];
}


function setupPeers(channel, orgID, client) {
  if(!ORGS[orgID]){
    throw new Error('No such organisation: '+orgID);
  }

	for (let peerID in ORGS[orgID]) {
    if(!ORGS[orgID].hasOwnProperty(peerID)){ continue; }

		if (peerID.indexOf('peer') === 0) { // starts with 'peer'

			let data = fs.readFileSync(path.join(CONFIG_DIR, ORGS[orgID][peerID]['tls_cacerts']));
			let peer = client.newPeer( ORGS[orgID][peerID].requests,
				{
					pem: Buffer.from(data).toString(),
					'ssl-target-name-override': ORGS[orgID][peerID]['server-hostname']
				}
			);

			channel.addPeer(peer);
		}
	}
}

function newOrderer(client) {
	var caRootsPath = ORGS['orderer'].tls_cacerts;
	let data = fs.readFileSync(path.join(CONFIG_DIR, caRootsPath));
	let caroots = Buffer.from(data).toString();
	return client.newOrderer(ORGS.orderer.url, {
		'pem': caroots,
		'ssl-target-name-override': ORGS.orderer['server-hostname']
	});
}

function readAllFiles(dir) {
	var files = fs.readdirSync(dir);
	var certs = [];
	files.forEach((file_name) => {
		let file_path = path.join(dir,file_name);
		let data = fs.readFileSync(file_path);
		certs.push(data);
	});
	return certs;
}


/**
 * @param {string} username
 * @param {string} orgID
 * @returns {string}
 */
function getKeyStoreForOrg(username, orgID) {
	return path.join(config.keyValueStore , username + '_' + orgID);
}


/**
 * @param {Array<url>} urls
 * @returns {Array}
 */
function newPeers(urls) {
  let targets = [];
  for (let index in urls) {
    if(!urls.hasOwnProperty(index)){ continue; }
    let peerUrl = urls[index];

    try {
      let peer = newPeer(peerUrl);
      targets.push(peer);
    }catch(e) {
      logger.error(e);
    }
  }
  return targets;
}

function newEventHubs(urls, username, org) {
  let targets = [];
  for (let index in urls) {
    if(!urls.hasOwnProperty(index)){ continue; }
    let peerUrl = urls[index];

    try {
      let eh = newEventHub(peerUrl, username, org);
      targets.push(eh);
    }catch(e) {
      logger.error(e);
    }
  }
  return targets;
}


/**
 * @param {url} peerUrl
 * @param {string} [orgID]
 * @returns {object}
 * @private
 */
function _getPeerInfoByUrl(peerUrl, orgID){
  for (let key in ORGS) {
    if (!ORGS.hasOwnProperty(key)) {
      continue;
    }
    if (orgID && key !== orgID) {
      continue;
    }
    // TODO: bookmark issue #9
    if (key === 'orderer') {
      continue;
    }

    let org = ORGS[key];
    for (let prop in org) {
      if (!org.hasOwnProperty(prop)) {
        continue;
      }
      if (prop.indexOf('peer') === 0) {
        if (org[prop]['requests'].indexOf(peerUrl) >= 0) {
          // found a peer matching the subject url
          return org[prop];
        }
      }
    }
  }
  return null;
}

/**
 * @param {url} peerUrl
 * @return {Peer}
 */
function newPeer(peerUrl) {

  var peerInfo = _getPeerInfoByUrl(peerUrl);
  if(!peerInfo) {
    throw new Error('Failed to find a peer matching the url: ' + peerUrl);
  }

  let tls_data = fs.readFileSync(path.join(CONFIG_DIR, peerInfo['tls_cacerts']));
  let peer = new Peer('grpcs://' + peerUrl, {
    pem: Buffer.from(tls_data).toString(),
    'ssl-target-name-override': peerInfo['server-hostname']
  });
  return peer;


}


/**
 * @param {url} peerUrl
 * @param {string} username
 * @param {string} orgID
 * @return {EventHub}
 */
function newEventHub(peerUrl, username, orgID) {

  var client = getClientForOrg(username, orgID);

  var peerInfo = _getPeerInfoByUrl(peerUrl, orgID);
  if(!peerInfo) {
    throw new Error('Failed to find a peer matching the url: ' + peerUrl);
  }
  let data = fs.readFileSync(path.join(CONFIG_DIR, peerInfo['tls_cacerts']));

  let eventHub = new EventHub(client);
  eventHub.setPeerAddr(peerInfo['events'], {
    pem: Buffer.from(data).toString(),
    'ssl-target-name-override': peerInfo['server-hostname']
  });
  return eventHub;
}



//-------------------------------------//
// APIs
//-------------------------------------//
function getChannelForOrg(channelID, username, orgID) {

  if(!channelID){
    throw new Error('channelID is not set');
  }
  if(!username){
    throw new Error('username is not set');
  }
  if(!orgID){
    throw new Error('orgID is not set');
  }

  let compositeKey = channelID+'/'+orgID+'/'+username;
  if(typeof channels[compositeKey] === "undefined"){
    channels[compositeKey] = setupChannel(channelID, username, orgID);
  }
  return channels[compositeKey];
}


function getClientForOrg(username, orgID) {
  // helps to migrate
	if(!orgID){
		throw new Error('pass username to getClientForOrg');
	}
	//
  let compositeKey = orgID + '/' + username;
  if(typeof clients[compositeKey] === "undefined"){
    clients[compositeKey] = setupOrgClient(username, orgID);
  }
  return clients[compositeKey];
}



var getMspID = function(org) {
	logger.debug('Msp ID : ' + ORGS[org].mspid);
	return ORGS[org].mspid;
};

function getAdmin(){
  var users = config.users;
  var username = users[0].username;
  var password = users[0].secret;
  return {username:username, password:password};
}

/**
 * @param {string} orgID
 * @returns {Promise.<User>}
 */
var getAdminUser = function loginAdmin(orgID) {
	var adminUser = getAdmin();
  var username = adminUser.username;
  var password = adminUser.password;
	var client = getClientForOrg(username, orgID);

	return hfc.newDefaultKeyValueStore({
		path: getKeyStoreForOrg(username, orgID)
	}).then((store) => {
		client.setStateStore(store);
		// clearing the user context before switching
		client._userContext = null;
		return client.getUserContext(username, true).then((user) => {
			if (user && user.isEnrolled()) {
				logger.info('Successfully loaded admin "%s" from persistence', username);
				return user;
			} else {
        logger.info('No admin "%s" in persistence', username);

				let caClient = caClients[orgID];
				// need to enroll it with CA server
				return caClient.enroll({
            enrollmentID: username,
            enrollmentSecret: password
          }).then((enrollment) => {
            logger.info('Successfully enrolled admin user "%s"',  username);

            //
            let member = new User(username);
            member.setCryptoSuite(client.getCryptoSuite());
            return member.setEnrollment(enrollment.key, enrollment.certificate, getMspID(orgID)).then(()=>member);
          }).then((user) => {
            return client.setUserContext(user);
          }).catch((err) => {
            logger.error('Failed to enroll and persist admin user "%s". Error: ', username, err.stack ? err.stack : err);
            throw err;
          });
			}
		});
	});
};

// TODO when we are not throwing the errors, we technically make all invocations as admin user
/**
 * @param {string} username
 * @param {string} orgID
 * @returns {Promise.<User>}
 */
var getRegisteredUsers = function login(username, orgID) {

	var client = getClientForOrg(username, orgID);
	return hfc.newDefaultKeyValueStore({
		path: getKeyStoreForOrg(username, orgID)
	}).then((store) => {
		client.setStateStore(store);
		// clearing the user context before switching
		client._userContext = null;

		return client.getUserContext(username, true)
      .then((user) => {
        if (user && user.isEnrolled()) {
          logger.info('Successfully loaded member "%s" from persistence', username);
          return user;
        } else {
          logger.info('No member "%s" in persistence', username);

          let caClient = caClients[orgID];
          var enrollmentSecret = null;
          return getAdminUser(orgID)
            .then(function(adminUserObj) {
              return caClient.register({
                enrollmentID: username,
                affiliation: orgID + '.department1'
              }, adminUserObj);
            }).then((secret) => {
              enrollmentSecret = secret;
              logger.debug('Successfully registered member "%s":',  username, enrollmentSecret);
              return caClient.enroll({
                enrollmentID: username,
                enrollmentSecret: secret
              });
            }, (err) => {
              logger.error('Fail to register member "%s"',  username, err);
              throw err;
            }).then((message) => {
              if (message && typeof message === 'string' && message.includes('Error:')) {
                logger.error('Fail to enroll member "%s"',  username, message);
                throw new Error(message);
              }
              logger.info('Successfully enrolled member "%s"',  username);

              //
              let member = new User(username);
              member._enrollmentSecret = enrollmentSecret;
              return member.setEnrollment(message.key, message.certificate, getMspID(orgID)).then(()=>member);
            })
            .then((user) => {
              return client.setUserContext(user);
            })
            .catch((err) => {
              logger.error('Failed to enroll and persist member user "%s". Error: ', username, err.stack ? err.stack : err);
              throw err;
            });
        }
    });
	})
  .catch(function(err) {
    logger.error(util.format('Failed to get registered user: %s, error: %s', username, err.stack ? err.stack : err));
    throw err;
  });
};

// TODO: refactor it
var getOrgAdmin = function(orgID) {

  var adminUser = getAdmin();
  var username = adminUser.username;
  var ks = getKeyStoreForOrg(username, orgID);

  // admin certificates
	var admin = ORGS[orgID].admin;
	var keyPath = path.join(CONFIG_DIR, admin.key);
	// TODO: explicitly set key name
	var keyPEM = Buffer.from(readAllFiles(keyPath)[0]).toString();
	var certPath = path.join(CONFIG_DIR, admin.cert);
  // TODO: explicitly set certificate name
	var certPEM = readAllFiles(certPath)[0].toString();

	var client = getClientForOrg(username, orgID);
	var cryptoSuite = hfc.newCryptoSuite();
	if (orgID) {
		cryptoSuite.setCryptoKeyStore(hfc.newCryptoKeyStore({path: ks}));
		client.setCryptoSuite(cryptoSuite);
	}

	return hfc.newDefaultKeyValueStore({path: ks})
		.then((store) => {
			client.setStateStore(store);

			return client.createUser({
				username: 'peer'+orgID+'Admin',
				mspid: getMspID(orgID),
				cryptoContent: {
					privateKeyPEM: keyPEM,
					signedCertPEM: certPEM
				}
			});
		});
};

var setupChaincodeDeploy = function() {
	process.env.GOPATH = path.join(CONFIG_DIR, config.GOPATH);
};

var getLogger = function(moduleName) {
	var logger = log4js.getLogger(moduleName);
	logger.setLevel('DEBUG');
	return logger;
};

var getPeerAddressByName = function(org, peer) {
	// console.log(ORGS);
	// console.log(org, peer);
	var address = ORGS[org][peer].requests;
	return address.split('grpcs://')[1];
};

exports.getChannelForOrg = getChannelForOrg;
exports.getClientForOrg  = getClientForOrg;
exports.getLogger = getLogger;
exports.setupChaincodeDeploy = setupChaincodeDeploy;
exports.getMspID = getMspID;
exports.ORGS = ORGS;
exports.CONFIG_DIR = CONFIG_DIR;
exports.newPeers = newPeers;
exports.newEventHubs = newEventHubs;
exports.newPeer = newPeer;
exports.newEventHub = newEventHub;
exports.getPeerAddressByName = getPeerAddressByName;
exports.getRegisteredUsers = getRegisteredUsers;
exports.getOrgAdmin = getOrgAdmin;

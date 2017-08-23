/**
 * Copyright 2017 IBM All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
"use strict";
var helper = require('./helper.js');
var logger = helper.getLogger('Query');


/**
 * @param {string} peer - orgPeerID (for example; 'org1/peer1')
 * @param {string} channelID
 * @param {string} chaincodeName
 * @param {string[]} args
 * @param {string} fcn
 * @param {string} username
 * @param {string} org
 * @returns {Promise}
 */
var queryChaincode = function(peer, channelID, chaincodeName, args, fcn, username, org) {

  /**
   * @type {Peer}
   */
	var target  = getPeer(peer, org);

  return helper.getChannelForOrg(channelID, username, org)
    .then(channel=>{
      var client = channel.getClient();

			var tx_id = client.newTransactionID();
			// send query
			var request = {
				targets: [target],
				chaincodeId: chaincodeName,
				txId: tx_id,
				fcn: fcn,
				args: args,
				transientMap: /** @type {map} */ {}
				// @property {map} transientMap - Optional. <string, byte[]> map that can be used by the chaincode but not
				// *			                      saved in the ledger, such as cryptographic information for encryption
			};
			return channel.queryByChaincode(request);
		}, (err) => {
			logger.info('Failed to get submitter \''+username+'\'');
			throw err;
		}).then((response_payloads) => {
			// here we got result from all peers if request.targets not set
			// TODO: what we should do with the rest of payloads? compare it?
			var result = response_payloads[0];
			if(result instanceof Error){
				throw result;
			}
			// result is Buffer
			result = result.toString('utf8');

			// try to parse it as json
			try{
				result = JSON.parse(result);
			}catch(e){
				logger.debug("Not a json response. It's ok, not has to be json");
			}
			return {result: result};
		}, (err) => {
			logger.error('Failed to send query due to error: ' + err.stack ? err.stack : err);
			throw err;
		}).catch((err) => {
			logger.error('Failed to end to end test with error:' + err.stack ? err.stack : err);
			throw err;
		});
};


/**
 *
 */
var getBlockByNumber = function(peer, channelID, blockNumber, username, org) {
	var target = getPeer(peer, org);

  return helper.getChannelForOrg(channelID, username, org)
		.then(channel => {
			return channel.queryBlock(parseInt(blockNumber), target);
		}, (err) => {
			logger.info('Failed to get submitter "' + username + '"');
			throw new Error('Failed to get submitter "' + username + '". Error: ' + err.stack ? err.stack : err);
		}).then((response_payloads) => {
			if (response_payloads) {
				//logger.debug(response_payloads);
				logger.debug(response_payloads);
				return response_payloads; //response_payloads.data.data[0].buffer;
			} else {
				logger.error('response_payloads is null');
				// TODO: throw an error?
				return null;
			}
		}, (err) => {
			logger.error('Failed to send query due to error: ' + err.stack ? err.stack : err);
			throw new Error('Failed to send query due to error: ' + err.stack ? err.stack : err);
		}).catch((err) => {
			logger.error('Failed to query with error:' + err.stack ? err.stack : err);
			throw new Error('Failed to query with error:' + err.stack ? err.stack : err);
		});
};


/**
 *
 */
var getTransactionByID = function(peer, channelID, trxnID, username, org) {
	var target = getPeer(peer, org);

  return helper.getChannelForOrg(channelID, username, org)
    .then(channel => {
			return channel.queryTransaction(trxnID, target);
		}, (err) => {
			logger.info('Failed to get submitter "' + username + '"');
			throw new Error('Failed to get submitter "' + username + '". Error: ' + err.stack ? err.stack : err);
		}).then((response_payloads) => {
			if (response_payloads) {
				// logger.debug(response_payloads);
				return response_payloads;
			} else {
				logger.error('response_payloads is null');
				// TODO: throw an error?
				return null;
			}
		}, (err) => {
			logger.error('Failed to send query due to error: ' + err.stack ? err.stack : err);
			throw new Error('Failed to send query due to error: ' + err.stack ? err.stack : err);
		}).catch((err) => {
			logger.error('Failed to query with error:' + err.stack ? err.stack : err);
			throw new Error('Failed to query with error:' + err.stack ? err.stack : err);
		});
};


/**
 *
 */
var getBlockByHash = function(peer, channelID, hash, username, org) {
	var target = getPeer(peer, org);

	return helper.getChannelForOrg(channelID, username, org)
		.then(channel => {
			return channel.queryBlockByHash(Buffer.from(hash, 'base64'), target);
		}, (err) => {
			logger.info('Failed to get submitter "' + username + '"');
			throw new Error('Failed to get submitter "' + username + '". Error: ' + err.stack ? err.stack : err);
		}).then((response_payloads) => {
			if (response_payloads) {
				logger.debug(response_payloads);
				return response_payloads;
			} else {
				logger.error('response_payloads is null');
				// TODO: throw an error?
				return null;
			}
		}, (err) => {
			logger.error('Failed to send query due to error: ' + err.stack ? err.stack : err);
			throw new Error('Failed to send query due to error: ' + err.stack ? err.stack : err);
		}).catch((err) => {
			logger.error('Failed to query with error:' + err.stack ? err.stack : err);
			throw new Error('Failed to query with error:' + err.stack ? err.stack : err);
		});
};


/**
 * @param {string} peer
 * @param {string} channelID
 * @param {string} username
 * @param {string} org
 */
var getChannelInfo = function(peer, channelID, username, org) {
  var target  = getPeer(peer, org);

  return helper.getChannelForOrg(channelID, username, org)
    .then(channel => {
			return channel.queryInfo(target);
		}, (err) => {
			logger.info('Failed to get submitter "' + username + '"');
			return 'Failed to get submitter "' + username + '". Error: ' + err.stack ? err.stack : err;
		}).then((blockchainInfo) => {
			if (blockchainInfo) {
				// FIXME: Save this for testing 'getBlockByHash'  ?
				// logger.debug('===========================================');
				// logger.debug(blockchainInfo);
				// logger.debug('===========================================');
				//logger.debug(blockchainInfo);

				var currentBlockHash  = blockchainInfo.currentBlockHash.toBase64();
				var previousBlockHash = blockchainInfo.previousBlockHash.toBase64();

				return {currentBlockHash:currentBlockHash, previousBlockHash:previousBlockHash};
			} else {
				logger.error('response_payloads is null');
				return 'response_payloads is null';
			}
		}, (err) => {
			logger.error('Failed to send query due to error: ' + err.stack ? err.stack : err);
			throw new Error('Failed to send query due to error: ' + err.stack ? err.stack : err);
		}).catch((err) => {
			logger.error('Failed to query with error:' + err.stack ? err.stack : err);
			throw new Error('Failed to query with error:' + err.stack ? err.stack : err);
		});
};


/**
 *
 */
//getInstalledChaincodes
// should be called as admin
var getInstalledChaincodes = function(peer, channelID, type, username, org) {
	var target = getPeer(peer, org);

	var p;
  if (type === 'installed') {
    p = helper.getClientForOrg(username, org)
			.then(client=>client.queryInstalledChaincodes(target));
  } else {
    p = helper.getChannelForOrg(channelID, username, org)
      .then(channel=>channel.queryInstantiatedChaincodes(target));
  }


	return p.then((response) => {
		if (response) {
			if (type === 'installed') {
				logger.debug('<<< Installed Chaincodes >>>');
			} else {
				logger.debug('<<< Instantiated Chaincodes >>>');
			}

			for (let i = 0; i < response.chaincodes.length; i++) {
        logger.debug('name: %s, version: %s, path: %s',
          response.chaincodes[i].name,
          response.chaincodes[i].version,
          response.chaincodes[i].path
        );
			}

			// logger.debug(response);
			return response;
		} else {
			logger.error('response is null');
		  throw new Error('Empty response: queryInstalledChaincodes/queryInstantiatedChaincodes');
		}
	}, (err) => {
		logger.error('Failed to send query due to error: ' + err.stack ? err.stack : err);
		throw err;
	}).catch((err) => {
		logger.error('Failed to query with error:' + err.stack ? err.stack : err);
		throw err;
	});
};


/**
 *
 */
var getChannels = function(peer, username, org) {
	var target = getPeer(peer, org);

	return helper.getClientForOrg(username, org)
		.then(client => {
			//channel.setPrimaryPeer(targets[0]);
			return client.queryChannels(target);
		}, (err) => {
			logger.info('Failed to get submitter "' + username + '"');
			return 'Failed to get submitter "' + username + '". Error: ' + err.stack ? err.stack : err;
		}).then((response) => {
			if (response) {
				logger.debug('<<< channels >>>');
				var channelNames = [];
				for (let i = 0; i < response.channels.length; i++) {
					channelNames.push(response.channels[i].channel_id);
				}
				logger.debug(JSON.stringify(channelNames));
				var channels = response.channels.map(function(channel){
					return {
						channel_id : channel.channel_id, // deprecated
						name : channel.channel_id
					};
				});
				return {channels:channels};
			} else {
				logger.error('response_payloads is null');
				return 'response_payloads is null';
			}
		}, (err) => {
			logger.error('Failed to send query due to error: ' + err.stack ? err.stack : err);
			throw new Error('Failed to send query due to error: ' + err.stack ? err.stack : err);
		}).catch((err) => {
			logger.error('Failed to query with error:' + err.stack ? err.stack : err);
			throw new Error('Failed to query with error:' + err.stack ? err.stack : err);
		});
};


/**
 * @param {string} peerID
 * @param {string} orgID
 * @returns {EventHub|Peer}
 */
function getPeer(peerID, orgID) {
	var target = null;
	if (typeof orgID !== 'undefined') {
		let targets = helper.newPeers([helper.getPeerAddressByName(orgID, peerID)]);
		if (targets && targets.length > 0) {
			target = targets[0];
    }
	}
	return target;
}


exports.queryChaincode = queryChaincode;
exports.getBlockByNumber = getBlockByNumber;
exports.getTransactionByID = getTransactionByID;
exports.getBlockByHash = getBlockByHash;
exports.getChannelInfo = getChannelInfo;
exports.getInstalledChaincodes = getInstalledChaincodes;
exports.getChannels = getChannels;

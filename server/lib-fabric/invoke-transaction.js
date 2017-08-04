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
'use strict';
var path = require('path');
var util = require('util');
var tools = require('../lib/tools.js');

var helper = require('./helper.js');
var logger = helper.getLogger('invoke-chaincode');

var hfc = require('./hfc');
var peerListener = require('./peer-listener');



// Invoke transaction on chaincode on target peers
var invokeChaincode = function(peersUrls, channelName, chaincodeName, fcn, args, username, org) {
	logger.debug(util.format('\n============ invoke transaction on organization %s ============\n', org));
	var client = helper.getClientForOrg(org);
	var channel = helper.getChannelForOrg(org);
	var targets = helper.newPeers(peersUrls);
	var tx_id = null;

	return helper.getRegisteredUsers(username, org).then((/*user*/) => {
		tx_id = client.newTransactionID();
		logger.debug(util.format('Sending transaction "%j"', tools.replaceBuffer(tx_id) ));
		// send proposal to endorser
		var request = {
			targets: targets,
			chaincodeId: chaincodeName,
			fcn: fcn,
			args: args,
			chainId: channelName,
			txId: tx_id
		};
		return channel.sendTransactionProposal(request);
	})

  .then((results) => {
		var proposalResponses = results[0] || [];
		var proposal = results[1];
		var lastError = null;
		for (var i=0, n=proposalResponses.length; i<n; i++){
			var response = proposalResponses[i] || {};
			var prResponseStatus = response.response ? response.response.status : -1;
			if (prResponseStatus === 200) {
				logger.info('transaction proposal was good');
			} else {
				logger.error('transaction proposal was bad', response);
        lastError = response.message || 'transaction proposal was bad';
			}
		}
		if (lastError) {
      throw new Error(lastError||'Failed to send Proposal or receive valid response. Response null or status is not 200. exiting...');
    }

    logger.debug(util.format(
      'Successfully sent Proposal and received ProposalResponse: Status - %s, message - "%s", metadata - "%s", endorsement signature: %s',
      proposalResponses[0].response.status,
      proposalResponses[0].response.message,
      proposalResponses[0].response.payload,
      proposalResponses[0].endorsement.signature.toString('base64')
    ));

    var request = {
      proposalResponses: proposalResponses,
      proposal: proposal
    };


    // set the transaction listener and set a timeout of 30sec
    // if the transaction did not get committed within the timeout period,
    // fail the test
    var transactionID = tx_id.getTransactionID();

    // var eventPromises = [];
    //
    // var eventhubs = helper.newEventHubs('localhost:7051', org);
    // for (let key in eventhubs) {
    //   let eh = eventhubs[key];
    //   eh.connect();

      let txPromise = new Promise((resolve, reject) => { // jshint ignore:line
        let handle = setTimeout(() => {
          // eh.disconnect();
          reject();
        }, 30000);


        peerListener.registerTxEvent(transactionID, (tx, code) => {
        // eh.registerTxEvent(transactionID, (tx, code) => {
          clearTimeout(handle);
          peerListener.unregisterTxEvent(transactionID);
          // eh.unregisterTxEvent(transactionID);
          // eh.disconnect();

          if (code !== 'VALID') {
            logger.error('The balance transfer transaction was invalid, code = ' + code);
            reject();
          } else {
            logger.info('The balance transfer transaction has been committed on peer '/* + eh._ep._endpoint.addr */ );
            resolve();
          }
        });
      });
    //   eventPromises.push(txPromise);
    // }

    var sendPromise = channel.sendTransaction(request);
    return Promise.all([sendPromise, txPromise]).then((results) => {
    // return Promise.all([sendPromise].concat(eventPromises)).then((results) => {
      logger.debug(' event promise all complete and testing complete');
      return results[0]; // the first returned value is from the 'sendPromise' which is from the 'sendTransaction()' call
    });

	})

  .then((response) => {
		if (response.status === 'SUCCESS') {
			logger.info('Successfully sent transaction to the orderer.');
			return tx_id.getTransactionID();
		} else {
			logger.error('Failed to order the transaction. Error code: ' + response.status);
			throw new Error('Failed to order the transaction. Error code: ' + response.status);
		}
	});
};

exports.invokeChaincode = invokeChaincode;

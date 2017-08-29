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
var fs = require('fs');
var util = require('util');
var config = require('../config.json');
var helper = require('./helper.js');
var logger = helper.getLogger('instantiate-chaincode');
var hfc = require('./hfc');
var ORGS = hfc.getConfigSetting('network-config');
var CONFIG_DIR = hfc.getConfigSetting('config-dir');
var tx_id = null;
var eh = null;


// must be called with admin credentials
var instantiateChaincode = function(channelID, chaincodeName, chaincodeVersion, functionName, args, username, org) {
	logger.debug('\n============ Instantiate chaincode on organization ' + org + ' ============\n');

  var channel;
  var client;
  return helper.getChannelForOrg(channelID, username, org)
    .then(_channel=>{
        channel = _channel;
        client = channel.getClient();

        // read the config block from the orderer for the channel
        // and initialize the verify MSPs based on the participating
        // organizations
        return channel.initialize();
    }, (err) => {
        logger.error('Failed to enroll user \'' + username + '\'. ' + err);
        throw new Error('Failed to enroll user \'' + username + '\'. ' + err);
    }).then((/*success*/) => {
        tx_id = client.newTransactionID();
        // send proposal to endorser
        var request = {
            chaincodeId: chaincodeName,
            chaincodeVersion: chaincodeVersion,
            fcn: functionName,
            args: args,
            txId: tx_id
        };
        return channel.sendInstantiateProposal(request);
    }, (err) => {
        logger.error('Failed to initialize the channel', err);
        err = err || new Error('Failed to initialize the channel');
        throw err;
    }).then((results) => {
        var proposalResponses = results[0];
        var proposal = results[1];
        var all_good = true;
        for (var i in proposalResponses) { // jshint ignore:line
            let one_good = false;
            if (proposalResponses && proposalResponses[0].response &&
                proposalResponses[0].response.status === 200) {
                one_good = true;
                logger.info('instantiate proposal was good');
            } else {
                logger.error('instantiate proposal was bad');
            }
            all_good = all_good & one_good; // jshint ignore: line
        }
        if (all_good) {
            logger.info(util.format(
                'Successfully sent Proposal and received ProposalResponse: Status - %s, message - "%s", metadata - "%s", endorsement signature: %s',
                proposalResponses[0].response.status,
                proposalResponses[0].response.message,
                proposalResponses[0].response.payload, // TODO: this made some trash in console
                proposalResponses[0].endorsement.signature // TODO: .. as well as this
            ));
            var request = {
                proposalResponses: proposalResponses,
                proposal: proposal
            };
            // set the transaction listener and set a timeout of 30sec
            // if the transaction did not get committed within the timeout period,
            // fail the test
            var deployId = tx_id.getTransactionID();

            eh = client.newEventHub();
            let data = fs.readFileSync(path.join(CONFIG_DIR, ORGS[org]['peer1']['tls_cacerts']));
            eh.setPeerAddr(ORGS[org]['peer1']['events'], {
                pem: Buffer.from(data).toString(),
                'ssl-target-name-override': ORGS[org]['peer1']['server-hostname']
            });
            eh.connect();

            let txPromise = new Promise((resolve, reject) => {
                let handle = setTimeout(() => {
                    eh.disconnect();
                    reject();
                }, parseInt(config.eventWaitTime));

                eh.registerTxEvent(deployId, (tx, code) => {
                    logger.info('The chaincode instantiate transaction has been committed on peer ' + eh._ep._endpoint.addr);
                    clearTimeout(handle);
                    eh.unregisterTxEvent(deployId);
                    eh.disconnect();

                    if (code !== 'VALID') {
                        logger.error('The chaincode instantiate transaction was invalid, code = ' + code);
                        reject();
                    } else {
                        logger.info('The chaincode instantiate transaction was valid.');
                        resolve();
                    }
                });
            });

            var sendPromise = channel.sendTransaction(request);
            return Promise.all([sendPromise].concat([txPromise])).then((results) => {
                logger.debug('Event promise all complete and testing complete');
                return results[0]; // the first returned value is from the 'sendPromise' which is from the 'sendTransaction()' call
            }).catch((err) => {
                logger.error(util.format('Failed to send instantiate transaction and get notifications within the timeout period. %s', err));
                return 'Failed to send instantiate transaction and get notifications within the timeout period.';
            });
        } else {
            logger.error('Failed to send instantiate Proposal or receive valid response. Response null or status is not 200. exiting...');
            return 'Failed to send instantiate Proposal or receive valid response. Response null or status is not 200. exiting...';
        }
    }, (err) => {
        logger.error('Failed to send instantiate proposal due to error: ' + err.stack ? err.stack : err);
        throw new Error('Failed to send instantiate proposal due to error: ' + err.stack ? err.stack : err);
    }).then((response) => {
        if (response.status === 'SUCCESS') {
            logger.info('Successfully sent transaction to the orderer.');
            return 'Chaincode Instantiateion is SUCCESS';
        } else {
            logger.error('Failed to order the transaction. Error code: ' + response.status);
            throw new Error('Failed to order the transaction. Error code: ' + response.status);
        }
    }, (err) => {
        logger.error('Failed to send instantiate due to error: ' + err.stack ? err.stack : err);
        throw new Error('Failed to send instantiate due to error: ' + err.stack ? err.stack : err);
    });
};
exports.instantiateChaincode = instantiateChaincode;

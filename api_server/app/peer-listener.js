'use strict';
var path = require('path');
var util = require('util');
var helper = require('./helper.js');
var logger = helper.getLogger('peer-listener');

var hfc = require('fabric-client');
hfc.addConfigFile(path.join(__dirname, '../network-config.json'));


/**
 * @type {Array{EventHub}>
 */
var eventhubs = null;

/**
 * listen peer for new blocks
 * channelName?
 */
function listenPeers(peersUrls, username, org, onBlockFn){

  return helper.getRegisteredUsers(username, org).then((user) => {
    logger.debug(util.format('\n(((((((((((( listen for transactions on organization %s )))))))))))\n', org));

    // set the transaction listener
    eventhubs = helper.newEventHubs(peersUrls, org);
    for (let key in eventhubs) {
      let eh = eventhubs[key];
      eh.connect();

      eh._myListenerId = eh.registerBlockEvent(function(block){
        logger.debug(util.format('(((((((((((( Got block event )))))))))))'));
        logger.debug('Got block event', block);
        onBlockFn && onBlockFn(block);
      }, function(e){
        // onError
        logger.warn('Got block eror', e);
      });
    }
  });
}

/**
 *
 */
function disconnect(){
    for (let key in eventhubs) {
      let eh = eventhubs[key];
      eh.unregisterBlockEvent(eh._myListenerId);
      eh.disconnect();
    }
}

module.exports = {
  listenPeers : listenPeers,
  disconnect : disconnect
};

'use strict';
var util = require('util');
var helper = require('./helper.js');
var logger = helper.getLogger('peer-listener');



/**
 * @type {Array<EventHub>}
 */
var eventhubs = null;

/**
 * listen peer for new blocks
 * channelName?
 */
function listenPeers(peersUrls, username, org, onBlockFn){
  // return;

  return helper.getRegisteredUsers(username, org).then((/*user*/) => {
    logger.debug(util.format('\n(((((((((((( listen for transactions on organization %s )))))))))))\n', org));

    // set the transaction listener
    eventhubs = helper.newEventHubs(peersUrls, org);
    for (let i=0, n=eventhubs.length; i<n; i++) {
      let eh = eventhubs[i];
      eh.connect();

      eh._myListenerId = eh.registerBlockEvent(_onBlock, _onBlockError);
    }


    function _onBlock(block){
      logger.debug(util.format('(((((((((((( Got block event )))))))))))'));
      logger.debug('Got block event', block);
      if(onBlockFn) {
        onBlockFn(block);
      }
    }

    function _onBlockError(e){
      // onError
      // logger.warn('Got block error', e);
      throw e;
    }
  });
}

/**
 *
 */
function disconnect(){
    for (let i=0, n=eventhubs.length; i<n; i++) {
      let eh = eventhubs[i];
      eh.unregisterBlockEvent(eh._myListenerId);
      eh.disconnect();
    }
}

module.exports = {
  listenPeers : listenPeers,
  disconnect : disconnect
};

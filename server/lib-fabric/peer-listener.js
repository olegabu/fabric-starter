'use strict';
var util = require('util');
var EventEmitter = require('events');
var helper = require('./helper.js');
var logger = helper.getLogger('peer-listener');


///////////////////////////////////////////////
/**
 * @type {EventEmitter}
 */
const blockEvents = new EventEmitter();
/**
 * @type {Array<EventHub>}
 */
var eventhubs = null;

/**
 * @type {Array<string>} array of peer url
 */
var peers = [];

/**
 * @type {string} organisation ID (json key for organisation in  network-config)
 */
var orgID = null;


/**
 * @type {Promise}
 */
var initPromise = null;

/**
 * This flag indicates that at leas one success connection with fabric1.0 was made.
 * Application tries to reconnect in this case. Otherwise it terminates, and that is an indicator of bad configuration.
 * @type {boolean}
 */
var wasConnectedAtStartup = false;

/**
 * @param {Array<string>} peersUrls
 * @param {string} username - admin username (or ID from network-config?)
 * @param {string} org organisation ID
 * @returns {Promise.<TResult>}
 */
function init(peersUrls, username, org){
  peers = peersUrls;
  orgID = org;

  initPromise = helper.getRegisteredUsers(username, org).then((user) => {
    // TODO: print organisation role from certificate?
    logger.debug(util.format('Authorized as %s@%s\n', user._name, org));
    return user;
  });
  return initPromise;
}
/**
 * listen peer for new blocks
 * channelName?
 */
function listen(){
  return initPromise.then(function () {

    // set the transaction listener
    eventhubs = helper.newEventHubs(peers, orgID);
    for (let i=0, n=eventhubs.length; i<n; i++) {
      let eh = eventhubs[i];
      eh._ep._request_timeout = 5000; // TODO: temp solution
      eh._myListenerId = eh.registerBlockEvent(_onBlock, _onBlockError);
    }
    _connect();

    //
    function _connect(){
      logger.info(util.format('connecting to %s', orgID));

      for (let i=0, n=eventhubs.length; i<n; i++) {
        let eh = eventhubs[i];
        eh.connect();
        eh._connectTimer = setInterval(_checkConnection.bind(eh), 1000); // TODO: socket connection check interval
        eh._connectTimer.unref();
      }
    }

    //
    function _checkConnection(){
      let eh = this; // jshint ignore:line
      if(eh._connected){
        clearInterval(eh._connectTimer);
        eh._connectTimer = null;
        logger.debug(util.format('\n(((((((((((( listen for transactions on organization %s: %s )))))))))))\n', orgID, eh._ep._url));
        // logger.debug(util.format('Connected to ', eh._ep._url));
        wasConnectedAtStartup = true;
      }
    }

    //
    function _onBlock(block){
      logger.debug(util.format('(((((((((((( Got block event )))))))))))'));
      logger.debug('Got block event', block.header.data_hash);

      blockEvents.emit('block_success', block);
    }

    //
    function _onBlockError(e){
      // onError
      logger.warn('Got block error', e);
      blockEvents.emit('block_error', e);

      // for (let i=0, n=eventhubs.length; i<n; i++) {
      //   let eh = eventhubs[i];
      //   eh.disconnect();
      // }

      // TODO: 'e.message' is a hotfix
      if(!wasConnectedAtStartup || e.message === 'Unable to connect to the peer event hub') {
        throw e;
      } else {
        // TODO: doesn't work propertly?
        // setTimeout( _connect, 5000); // TODO: socket reconnect interval
      }
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
      eh._myListenerId = null;
      eh.disconnect();
    }
}


// the same api as EventHub.js has

/**
 * Register a listener to receive all block events <b>from all the channels</b> that
 * the target peer is part of. The listener's "onEvent" callback gets called
 * on the arrival of every block. If the target peer is expected to participate
 * in more than one channel, then care must be taken in the listener's implementation
 * to differentiate blocks from different channels.
 *
 * @param {function} onEvent - Callback function that takes a single parameter
 *                             of a {@link Block} object
 * @param {function} onError - Optional callback function to be notified when this event hub
 *                             is shutdown. The shutdown may be caused by a network error or by
 *                             a call to the "disconnect()" method or a connection error.
 * @returns {int} This is the block registration number that must be
 *                sed to unregister (see unregisterBlockEvent)
 */
function registerBlockEvent(onEvent, onError) {
  onEvent && blockEvents.on('block_success', onEvent);
  onError && blockEvents.on('block_error', onError);
}

/**
 * Register a callback function to receive a notification when the transaction
 * by the given id has been committed into a block
 *
 * @param {string} txid - Transaction id string
 * @param {function} onEvent - Callback function that takes a parameter of type
 *                             {@link Transaction}, and a string parameter which
 *                             indicates if the transaction is valid (code = 'VALID'),
 *                             or not (code string indicating the reason for invalid transaction)
 * @param {function} onError - Optional callback function to be notified when this event hub
 *                             is shutdown. The shutdown may be caused by a network error or by
 *                             a call to the "disconnect()" method or a connection error.
 */
function registerTxEvent(txid, onEvent, onError) {
  eventhubs[0] && eventhubs[0].registerTxEvent(txid, onEvent, onError);
  // onEvent && blockEvents.on('tx_success_'+txid, onEvent);
  // onError && blockEvents.on('tx_error_'+txid, onError);
}

function unregisterTxEvent(txid){
  eventhubs[0] && eventhubs[0].unregisterTxEvent(txid);
  // blockEvents.removeAllListeners('tx_success_'+txid);
  // blockEvents.removeAllListeners('tx_error_'+txid);
}

// registerChaincodeEvent(ccid, eventname, onEvent, onError) {

module.exports = {
  init            : init,
  listen          : listen,
  disconnect      : disconnect,

  registerBlockEvent  : registerBlockEvent,
  registerTxEvent     : registerTxEvent,
  unregisterTxEvent   : unregisterTxEvent,
};

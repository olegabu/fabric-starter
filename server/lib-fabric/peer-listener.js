'use strict';
var util = require('util');
var EventEmitter = require('events');
var helper = require('./helper.js');
var logger = helper.getLogger('peer-listener');

EventEmitter.prototype.off = EventEmitter.prototype.removeListener;
///////////////////////////////////////////////
/**
 * @type {EventEmitter}
 */
const blockEvents = new EventEmitter();

/**
 * List of peers, available for listening events.
 * Event listener can change listening peers based on some criteria
 * @type {Array<string>} array of peer url
 */
var peers = [];

/**
 * current peer index
 * @type {number}
 */
var index = 0;

/**
 * Current event hub
 * @type {EventHub}
 */
var eventhub = null;


/**
 * @type {string}
 */
var _username = null;
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
var _wasConnectedAtStartup = false;

/**
 * @param {Array<string>} peersUrls
 * @param {string} username - admin username (or ID from network-config?)
 * @param {string} org organisation ID
 * @returns {Promise.<TResult>}
 */
function init(peersUrls, username, org){
  peers = peersUrls;
  _username = username;
  orgID = org;

  initPromise = helper.getClientUser(username, org)
    .then((user) => {
      // TODO: print organisation role from certificate?
      logger.debug(util.format('Authorized as %s@%s\n', user._name, orgID));
      return user;
    });
  // TODO: add promise catcher
  return initPromise;
}

/**
 * @return {string} peer url
 */
function rotatePeers(){
  index++;
  if(index >= peers.length){
    index = 0;
  }
  return peers[index];
}

/**
 * listen peer for new blocks
 * channelName?
 */
function listen(){
  return initPromise.then(function () {

    _connect();

    //
    function _connect(){
      var peer = rotatePeers();
      logger.info('connecting to %s', peer);

      // set the transaction listener
      return helper.newEventHub(peer, _username, orgID)
        .then(function(_eventhub){
          eventhub = _eventhub;
          eventhub._ep._request_timeout = 5000; // TODO: temp solution, move timeout to config
          eventhub._myListenerId = eventhub.registerBlockEvent(_onBlock, _onBlockError);

          eventhub.connect();
          eventhub._connectTimer = setInterval(_checkConnection.bind(eventhub), 1000); // TODO: socket connection check interval
          eventhub._connectTimer.unref();
          blockEvents.emit('connecting');
          // return eventhub;
        });
    }

    //
    function _checkConnection(){
      var eh = this; //jshint ignore:line
      if(eh._connected){
        clearInterval(eh._connectTimer);
        eh._connectTimer = null;

        logger.debug('connected');
        blockEvents.emit('connected');
        logger.debug(util.format('\n(((((((((((( listen for blocks in organization %s: %s )))))))))))\n', orgID, eh._ep._url));
        _wasConnectedAtStartup = true;
      }
    }

    //
    function _onBlock(block){
      logger.debug(util.format('(((((((((((( Got block event )))))))))))'));
      logger.debug('Got block event', block.header.data_hash);

      blockEvents.emit('block_success', block);
    }

    // onError
    function _onBlockError(e){
      logger.error(util.format('(((((((((((( Got block error )))))))))))'));
      logger.error(e);
      blockEvents.emit('block_error', e);

      if(!eventhub._connected){
        logger.debug('disconnected');
        blockEvents.emit('disconnected');
      }

      if(!eventhub._connected && !_wasConnectedAtStartup){
        throw e;
      }

      logger.trace('Set reconnection timer');
      setTimeout( _connect, 5000); // TODO: socket reconnect interval
    }

  });
}

/**
 *
 */
function disconnect(){
    eventhub.unregisterBlockEvent(eventhub._myListenerId);
    delete eventhub._myListenerId;
    eventhub.disconnect();
}


function isConnected(){
  return eventhub && eventhub._connected;
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
 * @param onEvent
 * @param onError
 */
function unregisterBlockEvent(onEvent, onError) {
  onEvent && blockEvents.removeListener('block_success', onEvent);
  onError && blockEvents.removeListener('block_error', onError);
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
  eventhub && eventhub.registerTxEvent(txid, onEvent, onError);
  // onEvent && blockEvents.on('tx_success_'+txid, onEvent);
  // onError && blockEvents.on('tx_error_'+txid, onError);
}

function unregisterTxEvent(txid){
  eventhub && eventhub.unregisterTxEvent(txid);
  // blockEvents.removeAllListeners('tx_success_'+txid);
  // blockEvents.removeAllListeners('tx_error_'+txid);
}

// registerChaincodeEvent(ccid, eventname, onEvent, onError) {

module.exports = {
  init            : init,
  listen          : listen,
  disconnect      : disconnect,

  eventHub        : blockEvents,
  isConnected     : isConnected,

  registerBlockEvent   : registerBlockEvent,
  unregisterBlockEvent : unregisterBlockEvent,
  registerTxEvent      : registerTxEvent,
  unregisterTxEvent    : unregisterTxEvent,
};

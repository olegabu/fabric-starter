
// const util = require('util');
const SocketClient  = require('socket.io-client');
const log4js  = require('log4js');
const logger  = log4js.getLogger('FabricSocketClient');


module.exports = FabricSocketClient;

/**
 * @param {string} endpoint - url of fabric rest api
 * @constructor
 */
function FabricSocketClient(endpoint){
  var self = this;

  /**
   * @type {string}
   * @private
   */
  this._ep = endpoint;

  /**
   * @type {boolean}
   * @private
   */
  this._wasConnected = false;

  /**
   * @type {Socket}
   * @private
   */
  this._socket = new SocketClient(this._ep);

  this._socket.on('connect', function () {
    logger.trace('connect');
    self._wasConnected = true;
  });
  // https://socket.io/docs/client-api/#event-connect_error.

  this._socket.on('disconnect',   function(reason){         logger.trace('disconnect'); });
  this._socket.on('reconnecting', function(attemptNumber){  logger.trace('reconnecting'); });
  this._socket.on('reconnect_error', function(error){       logger.trace('reconnect_error'); });
  this._socket.on('connect_timeout', function(){            logger.trace('connect_timeout'); });

  this._socket.on('connect_error', function (error) {
    logger.trace('connect_error', error);
    if (!self._wasConnected) {
      // this is a first run. exit the app, so we can see clear that configuration is wrong
      logger.error('Couldn\'t connect to ' + self._ep);
      self._socket.close();
      self._socket = null;
    }
  });

  this._socket.on('chainblock', function (block) {
    logger.trace('chainblock', block.header.number);
  });

  return this._socket;
}

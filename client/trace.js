/**
 * Simple client to listen to blocks and print out their contents.
 */

const FabricSocketClient = require('./lib/FabricSocketClient');
const log4js  = require('log4js');
log4js.configure( require('./config.json').log4js );
const logger  = log4js.getLogger('trace');

logger.info('start');

// get parameters
const API = process.env.API || 'http://localhost:4000';
if(!API){
  throw new Error("fabric-rest endpoint is not set. Please use environment variable API to set it.");
}

const socket = new FabricSocketClient(API);

socket.on('chainblock', function (block) {
  logger.trace('block', block);

  /*const extension = block.data.data[0].payload.data.actions[0].payload.action.proposal_response_payload.extension;

  logger.trace('response', extension.response);*/

});

socket.on('connect', function () {
  logger.trace('connect');
});
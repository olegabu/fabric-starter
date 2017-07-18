/**
 * Created by maksim on 7/17/17.
 */
/* jshint -W030 */
"use strict";
var SocketServer = require('socket.io');

var log4js = require('log4js');
var logger = log4js.getLogger('Socket');



module.exports.bindSocket = createSocket;


/**
 * @param {Server} httpServer - the server to bind to.
 * @param {object} [opts] socket.io parameters
 */
function createSocket(httpServer, opts){
  opts = opts || {};

  var io = new SocketServer(httpServer, opts);

  io.on('connection', function(socket){
    // console.log(socket);
    // console.log('a new user connected');
    logger.debug('a new user connected:', socket.id);
    // io.emit('chat_message_response',"1 New user Connected to chat");


    // DEBUG
    socket.emit('chainblock', getResponseExample() );

    socket.emit('hello', 'Hi user!');
    socket.on('hello',  function(payload) {
      logger.info('client hello:', payload);
    });

    socket.on('disconnect', function(/*socket*/){
      logger.debug('user disconnected:', socket.id);
      // io.emit('chat_message_response',"1 user disconnected.");
    });

  });

  return io;
}



function getResponseExample(){
  return {
    "Event": "block",
    "register": null,
    "block": {
      "version": 0,
      "timestamp": null,
      "transactions": [
        {
          "type": "MY_CHAINCODE_TEST",
          "chaincodeID": {},
          "payload": {},
          "metadata": {},
          "txid": "tst-test-transaction-id",
          "_txid_original": "d6b67c6f-5b77-43aa-8aef-9a528c874016",
          "timestamp": {
            "seconds": "1472243595",
            "nanos": 878832249
          },
          "confidentialityLevel": "PUBLIC",
          "confidentialityProtocolVersion": "",
          "nonce": {},
          "toValidators": {},
          "cert": {},
          "signature": {}
        }
      ],
      "stateHash": {},
      "previousBlockHash": {},
      "consensusMetadata": {},
      "nonHashData": {
        "localLedgerCommitTimestamp": {
          "seconds": "1472243627",
          "nanos": 376272706
        },
        "chaincodeEvents": [
          {
            "chaincodeID": "",
            "txID": "",
            "eventName": "",
            "payload": {}
          }
        ]
      }
    },
    "chaincodeEvent": null,
    "rejection": null,
    "unregister": null
  };
}

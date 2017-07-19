/**
 * Created by maksim on 7/18/17.
 */
"use strict";
var log4js = require('log4js');
var logger = log4js.getLogger('Socket');
var peerListener = require('../app/peer-listener.js');
var networkConfig = require('../network-config.json')['network-config'];


var config = require('../config.json');
const ORG = process.env.ORG || config.org;
const USERNAME = config.user.username;

module.exports = {
  init: init
};

/**
 * @param {SocketIO} io
 * @param {object} options
 */
function init(io, options){

  // var ORG = options.org;
  var PEERS = Object.keys(networkConfig[ORG])
               .filter(k=>k.startsWith('peer'));
  var peersAddress = PEERS.map(p=>getHost(networkConfig[ORG][p].requests));

  // log connections
  io.on('connection', function(socket){
    logger.debug('a new user connected:', socket.id);
    socket.on('disconnect', function(/*socket*/){
      logger.debug('user disconnected:', socket.id);
    });
  });

  // emit block appearance
  peerListener.listenPeers(peersAddress, USERNAME, ORG, function(block){
    // emit globally
    io.emit('chainblock', block);
  });


  // setInterval(function(){
  //   socket.emit('ping', Date.now() );
  // }, 5000);
}

/**
 *
 */
function getHost(address){
  //                             1111       222222
  var m = (address||"").match(/^(\w+:)?\/\/([^\/]+)/) || [];
  return m[2];
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

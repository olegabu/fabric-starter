/**
 * Created by maksim on 7/18/17.
 */
"use strict";
var log4js = require('log4js');
var logger = log4js.getLogger('Socket');
var peerListener = require('./app/peer-listener.js');
var networkConfig = require('./network-config.json')['network-config'];

// config
var config = require('./config.json');
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
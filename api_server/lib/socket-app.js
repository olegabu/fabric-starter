/**
 * Created by maksim on 7/18/17.
 */
"use strict";

module.exports = {
  init: init
};

/**
 * @param {SocketIO} socket
 */
function init(socket){

  setInterval(function(){

    socket.emit('ping', Date.now() );

  }, 5000);


}
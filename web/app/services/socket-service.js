/**
 * @class SocketService
 * @classdesc
 * @require socket.io
 * @ngInject
 */
function SocketService(env, $rootScope) {

  // jshint shadow: true
  var SocketService = this;

  var socket;

  /**
   *
   */
  SocketService.connect = function(){
    if(socket){
      return socket;
    }
    // var socket = io('ws://localhost');
    socket = io(env.api);

    socket.emit('hello', 'Hi from client');
    socket.on('hello', function(payload){
      console.log('server hello:', payload);
    });

    return socket;
  };


  /**
   *
   */
  SocketService.getSocket = function(){
    return socket;
  }



}

angular.module('nsd.service.socket', ['nsd.config.env'])
  .service('SocketService', SocketService)
  .run(function(SocketService){
    SocketService.connect();
  });
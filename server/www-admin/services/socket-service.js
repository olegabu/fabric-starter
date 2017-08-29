/**
 * @class SocketService
 * @classdesc
 * @require socket.io
 * @ngInject
 */
function SocketService(env, $rootScope, $log) {
  // jshint shadow: true
  var SocketService = this;

  var STATE_CONNECTING   = 'connecting';
  var STATE_CONNECTED    = 'connected';
  var STATE_DISCONNECTED = 'disconnected';
  var STATE_ERROR = 'error';

  var socket;
  SocketService.state = STATE_DISCONNECTED;
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
      $log.debug('server hello:', payload);
    });

    socket.on('connect',      function(){              SocketService.state = STATE_CONNECTED;   $rootScope.$apply(); });
    socket.on('disconnect',   function(reason){        SocketService.state = STATE_DISCONNECTED;$rootScope.$apply(); });
    socket.on('reconnecting', function(attemptNumber){ SocketService.state = STATE_CONNECTING;  $rootScope.$apply(); });
    socket.on('reconnect_error', function(error){      SocketService.state = STATE_ERROR;       $rootScope.$apply(); });

    socket.on('status', function(status){
      $log.debug('server status:', status);
      SocketService.state = status;
      $rootScope.$apply();
    });

    // socket.on('ping', function(){
    //   console.log('socket: ping');
    // });
    // socket.on('pong', function(latency){
    //   console.log('socket: pong', latency);
    // });

    return socket;
  };


  /**
   *
   */
  SocketService.getSocket = function(){
    return socket;
  };


  /**
   *
   */
  SocketService.getState = function(){
    return SocketService.state;
  };



}

angular.module('nsd.service.socket', ['nsd.config.env'])
  .service('SocketService', SocketService)
  .run(function(SocketService){
    SocketService.connect();
  });
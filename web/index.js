var express = require('express');
var MyEndpoint = require('./lib/MyEndpoint.js');

var port = process.env.GULP_PORT || process.env.PORT || 8080;


var app = require('express')();
var server = require('http').Server(app);
// var io = require('socket.io')(server);

MyEndpoint.trackBlockChanges(server);

server.listen(port, function () {
  console.log('Server started on port %s', port);
});


// listen protobuf socket

app.use( express.static('app', { index: 'index.html'}) );
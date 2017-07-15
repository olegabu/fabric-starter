var express = require('express');
var expressEnv = require('./lib/express-env-middleware');
// var MyEndpoint = require('./lib/MyEndpoint.js');

var port = process.env.PORT || 8080;

var clientEnv = {
  api: process.env.LEDGER_API || '//localhost:4000'
}


var app = require('express')();

console.log('Config will be exposed to client as env.js: ', clientEnv);
app.get('/env.js', expressEnv(clientEnv));
var server = require('http').Server(app);
// var io = require('socket.io')(server);

// MyEndpoint.trackBlockChanges(server);

server.listen(port, function () {
  console.log('Server started on port %s', port);
});


// listen protobuf socket

app.use( express.static('app', { index: 'index.html'}) );
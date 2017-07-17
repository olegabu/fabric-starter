
var http = require('http');
var express = require('express');
var expressEnv = require('./lib/express-env-middleware');
// var MyEndpoint = require('./lib/MyEndpoint.js');

var port = process.env.PORT || 8080;

var clientEnv = {
  api: process.env.FABRIC_API || '//localhost:4000'
}


///////////////////////// app here ///////////////////////////
var app = express();

console.log('The following config will be exposed to client as env.js: ', clientEnv);
app.get('/env.js', expressEnv(clientEnv));
app.use( express.static('app', { index: 'index.html'}) );
// var io = require('socket.io')(server);

// MyEndpoint.trackBlockChanges(server);


///////////////////////// app here ///////////////////////////
var server = http.Server(app);
server.listen(port, function () {
  console.log('Server started on port %s', port);
});

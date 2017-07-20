
var http = require('http');

var port = process.env.PORT || 8080;
var clientEnv = {
  api: process.env.FABRIC_API || '//localhost:4000'
}

var app = require('./express-app.js')(clientEnv);

///////////////////////// app here ///////////////////////////
var server = http.Server(app);
server.listen(port, function () {
  console.log('Server started on port %s', port);
});

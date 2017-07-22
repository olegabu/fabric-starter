

var express = require('express');
var expressEnv = require('./lib/express-env-middleware');


module.exports = function(clientEnv){
  clientEnv = clientEnv || {};

  var app = express();

  console.log('The following config will be exposed to client as env.js: ', clientEnv);
  app.get('/env.js', expressEnv(clientEnv));
  app.use( express.static(__dirname+'/www', { index: 'index.html'}) );

  return app;
};


var express = require('express');
var expressEnv = require('../lib/express-env-middleware');
var expressPromise = require('../lib/express-promise');


module.exports = function(rootFolder, clientEnv){
  clientEnv = clientEnv || {};

  var app = express();
  app.use(expressPromise());

  // console.log('The following config will be exposed to client as env.js: ', clientEnv);
  app.get('/env.js', expressEnv(clientEnv));
  app.use( express.static(__dirname+'/../' + rootFolder, { index: 'index.html'}) );

  // at last - send 404
  app.use(function(req, res, next) { // jshint ignore:line
    res.status(404).end('Not Found');
  });

  return app;
};


var express = require('express');
var expressEnv = require('../lib/express-env-middleware');
var expressPromise = require('../lib/express-promise');


module.exports = function(rootFolder, clientEnv){
  clientEnv = clientEnv || {};

  var app = express();
  app.use(expressPromise());

  console.log('The following config will be exposed to client as env.js: ', clientEnv);
  app.get('/env.js', expressEnv(clientEnv));
  app.use( express.static(__dirname+'/../' + rootFolder, { index: 'index.html'}) );

  // at last - report any error =)
  app.use(function(err, req, res, next) { // jshint ignore:line
    res.error(err);
  });

  return app;
};
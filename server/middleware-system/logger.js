

var log4js  = require('log4js');
var logger  = log4js.getLogger('API');

module.exports = function(){
  return function(req, res, next) {
    // logger.debug('[%s] %s  %s', new Date().toISOString(), req.method.toUpperCase(), req.url);
    logger.debug('%s  %s', req.method.toUpperCase(), req.url);
    next();
  };
}
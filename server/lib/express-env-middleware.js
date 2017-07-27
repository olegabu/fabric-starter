
var js_template_pre = '(function (window) {  window.__env = ';
var js_template_post = '; }(this));';

/**
 * @param {object} envConfig
 */
function envConfigMiddleware(envConfig){
  envConfig = envConfig || {};
  var js_code = js_template_pre + JSON.stringify(envConfig) + js_template_post;

  return function(req, res, next){
    res.set({'Content-Type':'text/javascript'}).send(js_code);
  };
}


module.exports = envConfigMiddleware;
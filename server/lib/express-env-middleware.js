
var js_template_pre = '(function (window) {  window.$VAR = ';
var js_template_post = '; }(this));';

/**
 * @param {object} envConfig
 */
function envConfigMiddleware(varName, envConfig){
  // first argument can be omitted
  if(typeof envConfig === "undefined"){
    envConfig = varName;
    varName = '__env';
  }
  var env_code = JSON.stringify(envConfig || {});
  var variable = /*req.query.var ||*/ varName;
  var js_code = js_template_pre.replace('$VAR', variable) + env_code + js_template_post;

  return function(req, res, next){
    res.set({'Content-Type':'text/javascript'}).send(js_code);
  };
}


module.exports = envConfigMiddleware;
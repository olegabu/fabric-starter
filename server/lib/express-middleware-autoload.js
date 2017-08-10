

const RELPATH = '/../'; // relative path to server root. Change it during file movement

const path  = require('path');
const fs    = require('fs');

const log4js  = require('log4js');
const logger  = log4js.getLogger('middleware');

const CONFIG_DEFAULT = 'middleware/middleware.json';

/**
 * @param {express.app} app
 * @param {string} [configFile]
 */
function loadMiddlewares(app, configFile){
  configFile = configFile || CONFIG_DEFAULT;

  // make path absolute
  if(!path.isAbsolute(configFile)){
    configFile = path.join(__dirname, RELPATH, configFile);
  }

  try{
    fs.accessSync(configFile, fs.constants.R_OK);
  }catch(e){
    // it's absolutely ok
    logger.trace('Skip missing file %s:', configFile);
    return;
  }

  var config = JSON.parse(fs.readFileSync(configFile).toString());
  var middlewareArr = config.middleware || [];

  for(let i=0, n=middlewareArr.length; i<=n-1; i++){
    var moduleInfo = middlewareArr[i];

    var name  = moduleInfo.name;
    var mount = moduleInfo.mount;
    var file  = moduleInfo.file;
    // var args  = moduleInfo.args || [];

    // make path relative to config file
    if(!path.isAbsolute(file)){
      file = path.join( path.dirname(configFile), file);
    }

    // if(!path.isAbsolute(file)){
    //   file = path.join(__dirname, file);
    // }

    // MOUNT
    logger.debug('mounting:', name||file, name ? '\t=> '+file : '' );

    let expressModule = require(file);
    let expressMiddleware = expressModule.call(expressModule, require);
    if(typeof expressMiddleware == "function"){
      app.use(expressMiddleware);
    }else{
      logger.debug('not a function:', name||file, name ? '\t=> '+file : '' );
    }
  }

}


module.exports = loadMiddlewares;
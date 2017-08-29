/**
 * Created by maksim on 7/13/17.
 */
'use strict';
const RELPATH = '/../'; // relative path to server root. Change it during file movement
var util = require('util');
var path = require('path');

var log4js = require('log4js');
var logger = log4js.getLogger('WebApp');

var express         = require('express');
// var session      = require('express-session');
// var cookieParser = require('cookie-parser');
var bodyParser      = require('body-parser');
var expressJWT      = require('express-jwt');
var cors            = require('cors');
var bearerToken     = require('express-bearer-token');
var expressPromise  = require('../lib/express-promise');
var expressEnv      = require('../lib/express-env-middleware');

var jwt   = require('jsonwebtoken');
var tools = require('../lib/tools');
var hfc   = require('../lib-fabric/hfc');
var networkConfig = hfc.getConfigSetting('network-config');

var helper        = require('../lib-fabric/helper.js');
var createChannel = require('../lib-fabric/create-channel.js');
var joinChannel   = require('../lib-fabric/join-channel.js');
var install       = require('../lib-fabric/install-chaincode.js');
var instantiate   = require('../lib-fabric/instantiate-chaincode.js');
var invoke        = require('../lib-fabric/invoke-transaction.js');
var query         = require('../lib-fabric/query.js');

var config = require('../config.json');
var packageInfo = require('../package.json');

const ORG = process.env.ORG || null;
const USERNAME = config.user.username;
const LEDGER_CONFIG_DIR  = '../artifacts/channel/';
const GENESIS_BLOCK_FILE = 'genesis.block';

logger.info('**************    API SERVER %s  ******************', packageInfo.version);
logger.info('Admin     : ' + USERNAME);
logger.info('Org name  : ' + ORG);

if(!ORG){
    throw new Error('ORG must be set in environment');
}


var app = express(); // root app
app.use(expressPromise());
var adminPartyApp = express();
adminPartyApp.use(expressPromise());


module.exports = function(){ return app; };

///////////////////////////////////////////////////////////////////////////////
//////////////////////////////// SET CONFIGURATIONS ///////////////////////////
///////////////////////////////////////////////////////////////////////////////

//support parsing of application/json type post data
app.use(bodyParser.json());
//support parsing of application/x-www-form-urlencoded post data
app.use(bodyParser.urlencoded({ extended: false }));
// custom middleware: use res.promise() to send promise response
app.use(expressPromise());

// relax cors
function corsCb(req, cb){
  cb(null, {origin: req.headers.origin, credentials:true});
}
app.options('*', cors(corsCb));
app.use(cors(corsCb));

// enable admin party before authorization, but after cors
if(config.admin_party) {
    logger.info('**************    ADMIN PARTY ENABLED     ******************');
    app.use(adminPartyApp);
}


// set secret variable
app.set('secret', config.jwt_secret);

var pathExcluded = ['/config', '/config.js', '/socket.io', '/genesis'];
app.use(expressJWT({
    secret: config.jwt_secret
}).unless({
    path: pathExcluded
}));

// extract token
// https://www.npmjs.com/package/express-bearer-token
app.use(bearerToken());

// replace Buffer with Buffer value recursively in the response object
app.use(function(req,res,next){
    // replace res.send()
    var originalSend = res.send;

    res.send = function(data){
        if(!res._binary) {
          data = tools.replaceBuffer(data);
          data = tools.replaceLong(data);
        }
        return originalSend.call(res, data);
    };

    next();
});

// verify token
app.use(function(req, res, next) {
    if ( pathExcluded.indexOf(req.originalUrl) >= 0) {
        return next();
    }

    var token = req.token;
    jwt.verify(token, app.get('secret'), function(err, decoded) {
        if (err) {
            res.error('Failed to authenticate token. Make sure to include the ' +
                'token returned from /users call in the authorization header ' +
                ' as a Bearer token');
            return;
        } else {
            // add the decoded user name and org name to the request object
            // for the downstream code to use
            req.username = decoded.username;
            req.orgname = decoded.orgName;
            logger.debug(util.format('Decoded from JWT token: username - %s, orgname - %s', decoded.username, decoded.orgName));
            return next();
        }
    });
});



///////////////////////////////////////////////////////////////////////////////
///////////////////////// REST ENDPOINTS START HERE ///////////////////////////
///////////////////////////////////////////////////////////////////////////////

// (admin party) Register and enroll user
adminPartyApp.post('/users', function(req, res) {
    logger.info('**************** ENROLL USER ****************');
    var username = req.body.username;

    logger.debug('End point : /users');
    logger.debug('User name : ' + username);

    if (!username) {
        res.error(getErrorMessage('\'username\''));
        return;
    }
    var token = jwt.sign({
        exp: Math.floor(Date.now() / 1000) + parseInt(config.jwt_expiretime),
        username: username,
        orgName: ORG
    }, app.get('secret'));

    res.promise(
        helper.getClientUser(username, ORG)
          .then((user) => {
            return {
              success: true,
              secret: user._enrollmentSecret,
              message: username + ' enrolled Successfully',
            };
          })
          .then(function(response) {
            if (response && typeof response !== 'string') {
                response.token = token;
                return response;
            } else {
                return Promise.reject(response);
            }
          })
    );
});


// (admin party) Create Channel
adminPartyApp.post('/channels', function(req, res) {
    logger.info('<<<<<<<<<<<<<<<<< C R E A T E  C H A N N E L >>>>>>>>>>>>>>>>>');
    logger.debug('End point : /channels');
    var chaincodeName     = req.body.channelName;
    var channelConfigPath = req.body.channelConfigPath;

    logger.debug('Channel ID : ' + chaincodeName);
    logger.debug('channelConfigPath : ' + channelConfigPath);

    if (!chaincodeName) {
        res.error(getErrorMessage('\'channelName\''));
        return;
    }
    if (!channelConfigPath) {
        res.error(getErrorMessage('\'channelConfigPath\''));
        return;
    }

    res.promise(
        createChannel.createChannel(chaincodeName, channelConfigPath, USERNAME, ORG)
    );
});


// (admin party) Join Channel
adminPartyApp.post('/channels/:channelName/peers', function(req, res) {
    logger.info('<<<<<<<<<<<<<<<<< J O I N  C H A N N E L >>>>>>>>>>>>>>>>>');
    var chaincodeName = req.params.channelName;
    var peersId = req.body.peers || [];
    var peers   = peersId.map(getPeerHostByCompositeID);
    logger.debug('channelName : ' + chaincodeName);
    logger.debug('peers : ' + peers);

    if (!chaincodeName) {
        res.error(getErrorMessage('\'channelName\''));
        return;
    }
    if (!peers || peers.length === 0) {
        res.error(getErrorMessage('\'peers\''));
        return;
    }

    res.promise(
        joinChannel.joinChannel(peers, chaincodeName, USERNAME, ORG)
    );
});


// (admin party) Install chaincode on target peers
adminPartyApp.post('/chaincodes', function(req, res) {
    logger.debug('==================== INSTALL CHAINCODE ==================');

    var chaincodeName = req.body.chaincodeName;
    var chaincodePath = req.body.chaincodePath;
    var chaincodeVersion = req.body.chaincodeVersion;
    var peersId = req.body.peers || [];
    var peers   = peersId.map(getPeerHostByCompositeID);

    logger.debug('peers : ' + peers); // target peers list
    logger.debug('chaincodeName : ' + chaincodeName);
    logger.debug('chaincodePath  : ' + chaincodePath);
    logger.debug('chaincodeVersion  : ' + chaincodeVersion);
    if (!peers || peers.length === 0) {
        res.error(getErrorMessage('\'peers\''));
        return;
    }
    if (!chaincodeName) {
        res.error(getErrorMessage('\'chaincodeName\''));
        return;
    }
    if (!chaincodePath) {
        res.error(getErrorMessage('\'chaincodePath\''));
        return;
    }
    if (!chaincodeVersion) {
        res.error(getErrorMessage('\'chaincodeVersion\''));
        return;
    }

    res.promise(
      install.installChaincode(peers, chaincodeName, chaincodePath, chaincodeVersion, USERNAME, ORG)
    );
});


// (admin party) Instantiate chaincode on target peers
adminPartyApp.post('/channels/:channelName/chaincodes', function(req, res) {
    logger.debug('==================== INSTANTIATE CHAINCODE ==================');
    var chaincodeName    = req.body.chaincodeName;
    var chaincodeVersion = req.body.chaincodeVersion;
    var functionName = req.body.functionName;
    var channelName  = req.params.channelName;
    var args = req.body.args;

    logger.debug('channelName  : ' + channelName);
    logger.debug('chaincodeName : ' + chaincodeName);
    logger.debug('chaincodeVersion  : ' + chaincodeVersion);
    logger.debug('functionName  : ' + functionName);
    logger.debug('args  : ' + args);

    if (!chaincodeName) {
        res.error(getErrorMessage('\'chaincodeName\''));
        return;
    }
    if (!chaincodeVersion) {
        res.error(getErrorMessage('\'chaincodeVersion\''));
        return;
    }
    if (!functionName) {
        res.error(getErrorMessage('\'functionName\''));
        return;
    }
    if (!args) {
        res.error(getErrorMessage('\'args\''));
        return;
    }


    res.promise(
      instantiate.instantiateChaincode(channelName, chaincodeName, chaincodeVersion, functionName, args, USERNAME, ORG)
    );
});


///////////////////////// REGULAR REST ENDPOINTS START HERE ///////////////////////////

// get public config
var clientConfig = hfc.getConfigSetting('config');
clientConfig.org = ORG;

app.get('/config.js', expressEnv('__config', clientConfig));
app.get('/config', function(req, res) {
    res.setHeader('X-Api-Version', packageInfo.version);
    res.send(clientConfig);
});


//Query hyperledger genesis block
app.get('/genesis', function(req, res) {
  logger.debug('================ GET GENESIS BLOCK ======================');

  res._binary = true; // prevents base64 buffer encoding
  res.promise(
    tools.readFilePromise(path.join(__dirname, RELPATH, LEDGER_CONFIG_DIR, GENESIS_BLOCK_FILE))
  );
});


// Query to fetch channels
app.get('/channels', function(req, res) {
  logger.debug('================ GET CHANNELS ======================');
  logger.debug('peer: ' + req.query.peer);
  var peer = req.query.peer;

  if (!peer) {
    res.error(getErrorMessage("'peer'"));
    return;
  }

  res.promise(
    query.getChannels(peer, req.username, ORG)
  );
});


//Query for Channel Information
app.get('/channels/:channelName', function(req, res) {
  logger.debug('================ GET CHANNEL INFORMATION ======================');
  logger.debug('channelName : ' + req.params.channelName);
  let channelName = req.params.channelName;
  let peer = req.query.peer;

  if (!peer) {
    res.error(getErrorMessage("'peer'"));
    return;
  }

  res.promise(
    query.getChannelInfo(peer, channelName, req.username, ORG)
  );
});


//Query channel binary configuration
app.get('/channels/:channelName/config', function(req, res) {
  logger.debug('================ GET CHANNEL BINARY CONFIG ======================');
  logger.debug('channelName : ' + req.params.channelName);

  // let channelName = req.params.channelName;
  var channelFile = req.params.channelName + '.tx';

  res._binary = true; // prevents base64 buffer encoding
  res.promise(
    tools.readFilePromise(path.join(__dirname, RELPATH, LEDGER_CONFIG_DIR, channelFile))
  );
});



// Invoke transaction on chaincode on target peers
app.post('/channels/:channelName/chaincodes/:chaincodeName', function(req, res) {
    logger.debug('==================== INVOKE ON CHAINCODE ==================');
    var chaincodeName = req.params.chaincodeName;
    var channelName   = req.params.channelName;
    var peersId       = req.body.peers || [];
    var peers = peersId.map(getPeerHostByCompositeID);

    var fcn = req.body.fcn;
    var args = req.body.args;
    logger.debug('channelName  : ' + channelName);
    logger.debug('chaincodeName : ' + chaincodeName);
    logger.debug('peersId  : ', JSON.stringify(peersId) );
    logger.debug('peers  : ', JSON.stringify(peers) );
    logger.debug('fcn  : ' + fcn);
    logger.debug('args  : ' + args);
    if (!peers || peers.length === 0) {
      res.json(getErrorMessage('\'peers\''));
      return;
    }
    if (!chaincodeName) {
      res.error(getErrorMessage('\'chaincodeName\''));
      return;
    }
    if (!fcn) {
        res.error(getErrorMessage('\'fcn\''));
        return;
    }
    if (!args) {
        res.error(getErrorMessage('\'args\''));
        return;
    }

    res.promise(
      invoke.invokeChaincode(peers, channelName, chaincodeName, fcn, args, req.username, ORG)
        .then(function(transactionId){
          return {transaction:transactionId};
        })
    );
});


// Query on chaincode on target peers
app.get('/channels/:channelName/chaincodes/:chaincodeName', function(req, res) {
    logger.debug('==================== QUERY BY CHAINCODE ==================');
    var channelName   = req.params.channelName;
    var chaincodeName = req.params.chaincodeName;
    let args = req.query.args;
    let fcn  = req.query.fcn;
    let peerId = req.query.peer;
    var peerInfo = getPeerInfoByCompositeID(peerId);

    logger.debug('channelName : ' + channelName);
    logger.debug('chaincodeName : ' + chaincodeName);
    logger.debug('peerId : ', peerId);
    logger.debug('fcn  : ' + fcn);
    logger.debug('args : ' + args);

    if (!chaincodeName) {
        res.error(getErrorMessage('\'chaincodeName\''));
        return;
    }
    if (!fcn) {
        res.error(getErrorMessage('\'fcn\''));
        return;
    }
    if (!args) {
      res.error(getErrorMessage('\'args\''));
      return;
    }
    if (!peerInfo) {
      res.error(getErrorMessage('\'peerInfo\''));
      return;
    }
    if (peerInfo.org !== ORG) {
      res.error("Cannot query foreign peers");
      return;
    }
    args = args.replace(/'/g, '"');
    args = JSON.parse(args);
    logger.debug(args);


    res.promise(
      query.queryChaincode(peerInfo.peer, channelName, chaincodeName, args, fcn, req.username, ORG)
    );
});


//  Query Get Block by BlockNumber
app.get('/channels/:channelName/blocks/:blockId', function(req, res) {
    logger.debug('==================== GET BLOCK BY NUMBER ==================');
    let channelName = req.params.channelName;
    let blockId     = req.params.blockId;
    let peer        = req.query.peer;

    logger.debug('channelName : ' + channelName);
    logger.debug('BlockID : ' + blockId);
    logger.debug('Peer : ' + peer);

    if (!peer) {
      res.error(getErrorMessage("'peer'"));
      return;
    }
    if (!blockId) {
        res.error(getErrorMessage('\'blockId\''));
        return;
    }

    res.promise(
      query.getBlockByNumber(peer, channelName, blockId, req.username, ORG)
    );
});

// Query Get Block by Hash
app.get('/channels/:channelName/blocks', function(req, res) {
  logger.debug('================ GET BLOCK BY HASH ======================');
  logger.debug('channelName : ' + req.params.channelName);
  let channelName = req.params.channelName;
  let hash = req.query.hash;
  let peer = req.query.peer;

  if (!peer) {
    res.error(getErrorMessage("'peer'"));
    return;
  }
  if (!hash) {
    res.error(getErrorMessage('\'hash\''));
    return;
  }

  res.promise(
    query.getBlockByHash(peer, channelName, hash, req.username, ORG)
  );
});


// Query Get Transaction by Transaction ID
app.get('/channels/:channelName/transactions/:trxnId', function(req, res) {
    logger.debug('================ GET TRANSACTION BY TRANSACTION_ID ======================');
    logger.debug('channelName : ' + req.params.channelName);
    let channelName = req.params.channelName;
    let trxnId = req.params.trxnId;
    let peer = req.query.peer;

    if (!peer) {
      res.error(getErrorMessage("'peer'"));
      return;
    }
    if (!trxnId) {
        res.error(getErrorMessage('\'trxnId\''));
        return;
    }

    res.promise(
      query.getTransactionByID(peer, channelName, trxnId, req.username, ORG)
    );
});


// Query to fetch all Installed/instantiated chaincodes
app.get('/chaincodes', function(req, res) {
    let peer        = req.query.peer;
    let installType = req.query.type || 'installed';
    let channelName = req.query.channel;
    //TODO: add Constnats
    if (installType === 'installed') {
        logger.debug('================ GET INSTALLED CHAINCODES ======================');
    } else {
        logger.debug('================ GET INSTANTIATED CHAINCODES ======================');
        if(!channelName){
          res.error(getErrorMessage('\'channel\''));
          return;
        }
    }
    if (!peer) {
      res.error(getErrorMessage("'peer'"));
      return;
    }


    res.promise(
      query.getInstalledChaincodes(peer, channelName, installType, USERNAME, ORG)
    );
});



// at last - report any error =)
app.use(function(err, req, res, next) { // jshint ignore:line
    res.error(err);
});


function getErrorMessage(field) {
  return field + ' field is missing or Invalid in the request';
}


/**
 * Get peer host:port by composite id.
 * Composite ID is a combination of orgID and peerID, split by '/'. For example: 'org1/peer2'
 * @param {string} orgPeerID
 * @returns {string}
 */
function getPeerHostByCompositeID(orgPeerID){
  var parts = orgPeerID.split('/');
  var peer = networkConfig[parts[0]][parts[1]] || {};
  return tools.getHost(peer.requests);
}
/**
 * Get peer host:port by composite id.
 * Composite ID is a combination of orgID and peerID, split by '/'. For example: 'org1/peer2'
 * @param {string} orgPeerID
 * @returns {{peer:string, org:string}}
 */
function getPeerInfoByCompositeID(orgPeerID){
  var parts = orgPeerID.split('/');
  return parts ? {peer: parts[1], org: parts[0]} : null;
}
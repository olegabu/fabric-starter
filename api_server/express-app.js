/**
 * Created by maksim on 7/13/17.
 */
'use strict';
var util = require('util');

var log4js = require('log4js');
var logger = log4js.getLogger('WebApp');

var express = require('express');
// var session = require('express-session');
// var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var expressJWT = require('express-jwt');
var jwt = require('jsonwebtoken');
var cors = require('cors');
var bearerToken = require('express-bearer-token');
var expressPromise = require('./lib/express-promise');
var app = express();

var tools = require('./lib/tools');

// network-config.json has special format, so we can't change it now
var networkConfig = require('./network-config.json')['network-config'];
var helper = require('./app/helper.js');
var createChannel = require('./app/create-channel.js');
var joinChannel = require('./app/join-channel.js');
var install = require('./app/install-chaincode.js');
var instantiate = require('./app/instantiate-chaincode.js');
var invoke = require('./app/invoke-transaction.js');
var query = require('./app/query.js');

//
var config = require('./config.json');

const ORG = process.env.ORG || config.org;
const USERNAME = config.user.username;

logger.info('**************    API SERVER     ******************');
logger.info('Admin     : ' + USERNAME);
logger.info('Org name  : ' + ORG);


module.exports = app;

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



// enable admin party before authorization
var adminPartyApp = express();
if(config.admin_party) {
    logger.info('**************    ADMIN PARTY ENABLED     ******************');
    app.use(adminPartyApp);
}


// set secret variable
app.set('secret', config.jwt_secret);

var pathExcluded = ['/config'];
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
        data = tools.replaceBuffer(data);
        data = tools.replaceLong(data);
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
        helper.getRegisteredUsers(username, ORG, true).then(function(response) {
            if (response && typeof response !== 'string') {
                response.token = token;
                return response;
            } else {
                res.error(response);
            }
        })
    );
});


// (admin party) Create Channel
adminPartyApp.post('/channels', function(req, res) {
    logger.info('<<<<<<<<<<<<<<<<< C R E A T E  C H A N N E L >>>>>>>>>>>>>>>>>');
    logger.debug('End point : /channels');
    var channelName = req.body.channelName;
    var channelConfigPath = req.body.channelConfigPath;

    logger.debug('Channel name : ' + channelName);
    logger.debug('channelConfigPath : ' + channelConfigPath);

    if (!channelName) {
        res.error(getErrorMessage('\'channelName\''));
        return;
    }
    if (!channelConfigPath) {
        res.error(getErrorMessage('\'channelConfigPath\''));
        return;
    }

    res.promise(
        createChannel.createChannel(channelName, channelConfigPath, USERNAME, ORG)
            .then(function(message) {
                return message;
            })
    );
});


// (admin party) Join Channel
adminPartyApp.post('/channels/:channelName/peers', function(req, res) {
    logger.info('<<<<<<<<<<<<<<<<< J O I N  C H A N N E L >>>>>>>>>>>>>>>>>');
    var channelName = req.params.channelName;
    var peers = req.body.peers;
    logger.debug('channelName : ' + channelName);
    logger.debug('peers : ' + peers);


    if (!channelName) {
        res.error(getErrorMessage('\'channelName\''));
        return;
    }
    if (!peers || peers.length === 0) {
        res.error(getErrorMessage('\'peers\''));
        return;
    }

    res.promise(
        joinChannel.joinChannel(channelName, peers, USERNAME, ORG)
            .then(function(message) {
                return message;
            })
    );
});


// (admin party) Install chaincode on target peers
adminPartyApp.post('/chaincodes', function(req, res) {
    logger.debug('==================== INSTALL CHAINCODE ==================');

    var peers = req.body.peers;
    var chaincodeName = req.body.chaincodeName;
    var chaincodePath = req.body.chaincodePath;
    var chaincodeVersion = req.body.chaincodeVersion;

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

    install.installChaincode(peers, chaincodeName, chaincodePath, chaincodeVersion, USERNAME, ORG)
        .then(function(message) {
            res.send(message);
        });
});


// (admin party) Instantiate chaincode on target peers
adminPartyApp.post('/channels/:channelName/chaincodes', function(req, res) {
    logger.debug('==================== INSTANTIATE CHAINCODE ==================');
    var chaincodeName = req.body.chaincodeName;
    var chaincodeVersion = req.body.chaincodeVersion;
    var channelName = req.params.channelName;
    var functionName = req.body.functionName;
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
    if (!channelName) {
        res.error(getErrorMessage('\'channelName\''));
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

    instantiate.instantiateChaincode(channelName, chaincodeName, chaincodeVersion, functionName, args, USERNAME, ORG)
        .then(function(message) {
            res.send(message);
        });
});


///////////////////////// REGULAR REST ENDPOINTS START HERE ///////////////////////////

// get public config
app.get('/config', function(req, res) {
    res.send({
        org: ORG,
        network: networkConfig
    });
});



// Invoke transaction on chaincode on target peers
app.post('/channels/:channelName/chaincodes/:chaincodeName', function(req, res) {
    logger.debug('==================== INVOKE ON CHAINCODE ==================');
    var chaincodeName = req.params.chaincodeName;
    var channelName = req.params.channelName;
    var peersId = req.body.peers || [];
    var peers = peersId.map(peerId=>{
      var parts = peerId.split('/');
      return networkConfig[parts[0]][parts[1]];
    }).map(peer=>getHost(peer.requests));

    var fcn = req.body.fcn;
    var args = req.body.args;
    logger.debug('channelName  : ' + channelName);
    logger.debug('chaincodeName : ' + chaincodeName);
    logger.debug('peersId  : ', peersId);
    logger.debug('peers  : ', peers);
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
    if (!channelName) {
        res.error(getErrorMessage('\'channelName\''));
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
    var channelName = req.params.channelName;
    var chaincodeName = req.params.chaincodeName;
    let args = req.query.args;
    let fcn = req.query.fcn;
    let peer = req.query.peer;

    logger.debug('channelName : ' + channelName);
    logger.debug('chaincodeName : ' + chaincodeName);
    logger.debug('fcn : ' + fcn);
    logger.debug('args : ' + args);

    if (!chaincodeName) {
        res.error(getErrorMessage('\'chaincodeName\''));
        return;
    }
    if (!channelName) {
        res.error(getErrorMessage('\'channelName\''));
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
    args = args.replace(/'/g, '"');
    args = JSON.parse(args);
    logger.debug(args);

    query.queryChaincode(peer, channelName, chaincodeName, args, fcn, req.username, req.orgname)
        .then(function(message) {
            res.send(message);
        });
});


//  Query Get Block by BlockNumber
app.get('/channels/:channelName/blocks/:blockId', function(req, res) {
    logger.debug('==================== GET BLOCK BY NUMBER ==================');
    let blockId = req.params.blockId;
    let peer = req.query.peer;
    logger.debug('channelName : ' + req.params.channelName);
    logger.debug('BlockID : ' + blockId);
    logger.debug('Peer : ' + peer);
    if (!blockId) {
        res.error(getErrorMessage('\'blockId\''));
        return;
    }

    query.getBlockByNumber(peer, blockId, req.username, req.orgname)
        .then(function(message) {
            res.send(message);
        });
});

// Query Get Block by Hash
app.get('/channels/:channelName/blocks', function(req, res) {
  logger.debug('================ GET BLOCK BY HASH ======================');
  logger.debug('channelName : ' + req.params.channelName);
  let hash = req.query.hash;
  let peer = req.query.peer;
  if (!hash) {
    res.error(getErrorMessage('\'hash\''));
    return;
  }

  query.getBlockByHash(peer, hash, req.username, req.orgname).then(
    function(message) {
      res.send(message);
    });
});


// Query Get Transaction by Transaction ID
app.get('/channels/:channelName/transactions/:trxnId', function(req, res) {
    logger.debug(
        '================ GET TRANSACTION BY TRANSACTION_ID ======================'
    );
    logger.debug('channelName : ' + req.params.channelName);
    let trxnId = req.params.trxnId;
    let peer = req.query.peer;
    if (!trxnId) {
        res.error(getErrorMessage('\'trxnId\''));
        return;
    }

    query.getTransactionByID(peer, trxnId, req.username, req.orgname)
        .then(function(message) {
            res.send(message);
        });
});




//Query for Channel Information
app.get('/channels/:channelName', function(req, res) {
    logger.debug(
        '================ GET CHANNEL INFORMATION ======================');
    logger.debug('channelName : ' + req.params.channelName);
    let peer = req.query.peer;

    query.getChainInfo(peer, req.username, req.orgname).then(
        function(message) {
            res.send(message);
        });
});


// Query to fetch all Installed/instantiated chaincodes
app.get('/chaincodes', function(req, res) {
    var peer = req.query.peer;
    var installType = req.query.type || 'installed';
    //TODO: add Constnats
    if (installType === 'installed') {
        logger.debug(
            '================ GET INSTALLED CHAINCODES ======================');
    } else {
        logger.debug(
            '================ GET INSTANTIATED CHAINCODES ======================');
    }

    query.getInstalledChaincodes(peer, installType, req.username, req.orgname||req.query.orgname)
        .then(function(message) {
            res.send(message);
        });
});


// Query to fetch channels
app.get('/channels', function(req, res) {
    logger.debug('================ GET CHANNELS ======================');
    logger.debug('peer: ' + req.query.peer);
    var peer = req.query.peer;
    if (!peer) {
        res.error(getErrorMessage('\'peer\''));
        return;
    }

    query.getChannels(peer, req.username, req.orgname)
        .then(function(
            message) {
            res.send(message);
        });
});



// at last - report any error =)
app.use(function(err, req, res, next) { // jshint ignore:line
    res.error(err);
});


function getErrorMessage(field) {
  return field + ' field is missing or Invalid in the request';
}


function getHost(address){
  //                             1111       222222
  var m = (address||"").match(/^(\w+:)?\/\/([^\/]+)/) || [];
  return m[2];
}
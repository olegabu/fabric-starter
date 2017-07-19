/**
 * Copyright 2017 IBM All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an 'AS IS' BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
'use strict';
var http = require('http');
var log4js = require('log4js');
var logger = log4js.getLogger('Http');
var SocketServer = require('socket.io');
var socketApp = require('./socket-app');
var app = require('./express-app');

// config
var config = require('./config.json');
const ORG = process.env.ORG || config.org;
const USERNAME = config.user.username;
// var host = process.env.HOST || config.host;
const port = process.env.PORT || config.port;

var socketOptions = { origins: '*:*'};




//////////////////////////////// INIT SERVER /////////////////////////////////
var server = http.createServer(app);

var io = new SocketServer(server, socketOptions);
socketApp.init(io, {org:ORG});

server.listen(port, function() {
	logger.info('****************** SERVER STARTED ************************');
	logger.info('**************  http://' + server.address().address + ':' + server.address().port +	'  ******************');
});
server.timeout = 240000;


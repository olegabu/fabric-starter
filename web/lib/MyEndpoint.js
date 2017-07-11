
var grpc = require('grpc');

// grpc.load(__dirname + '../proto/fabric.proto');
// grpc.load(__dirname + '../proto/chaincodeevent.proto');
// grpc.load(__dirname + '../proto/chaincode.proto');
var protos = grpc.load(__dirname + '/../protobuf/events.proto').protos;

var Events    = protos.Events;
var Interest  = protos.Interest;
var Register  = protos.Register;
var Event     = protos.Event;
var EventType = protos.EventType;


/**
 *
 */
function MyEndpoint(endpoint/*, credentials */){
  console.log('MyEndpoint', endpoint);

  var self = this;

  var _ep = endpoint;
  var _credentials = grpc.credentials.createInsecure();

  self.createChatStream = createChatStream;

  self.getEndpoint = function(){ return _ep; };

  /**
   *
   */
  function createChatStream(){
    var interest = new Interest().setEventType(EventType.BLOCK);
    var register = new Register();
    register.events.push(interest);

    var event = new Event();
    event.setRegister(register);
    event.Event = undefined;

    //
    // var eventsService = new Events("54.198.39.96:7053", grpc.credentials.createInsecure());
    var eventsService = new Events(_ep, _credentials);

    var stream = eventsService.chat();
    // console.log('eventsService: ', /*stream,*/ stream.constructor.name);

    stream.on('data', message=>{
      if(message.block){
        console.log('block:', message.block.stateHash.toString('base64')/*.substr(16)+'...'*/ );
      } else if(message.Event){
        console.log('event:', message.Event);
      } else {
        console.log('data:', message);
      }
    });
    // stream.on('error', err=>{
    //   console.log('error:', err);
    //   throw err;
    // });
    stream.on('end', message=>{
      console.log('protobuf: stream end:', message);
    });
    stream.on('error', message=>{
      console.log('protobuf: stream error:', message);
    });

    stream.write(event);

    return stream;
  }


}//



var myEndpoint = null;
var stream = null;
var _timer = null;

/**
 *
 */
function _createChannelToBlockchain(endpoint, _io){
  var that = this;
  if(myEndpoint && myEndpoint.getEndpoint() === endpoint) {
    return myEndpoint;
  }

  if(stream){
    stream.end();
    stream = null;
    clearTimeout(_timer);
  }

  // create grpc endpoint
  myEndpoint = new MyEndpoint(endpoint);

  stream = myEndpoint.createChatStream();
  stream.on('data', message=>{
    console.log('data:', message);
    if(message.block){
      _io.emit('chainblock', message);
    }
  });
  stream.on('error', err=>{
    console.log('error:', err);
    // stream.close();
    myEndpoint = null;
    _timer = setTimeout( _createChannelToBlockchain.bind(that, endpoint, _io), 1000);
  });

}



/**
 *
 */
function createSocket(app){
  if(!app){
    app = require('http').Server();
  }

  var io = require('socket.io')(app);

  io.on('connection', function(socket){
    //console.log(socket);
    console.log('[io] a new user connected');
    // io.emit('chat_message_response',"1 New user Conencted to chat");


    // DEBUG
    socket.emit('chainblock', getResponseExample() );

    socket.emit('hello', 'Hi user!');
    socket.on('hello',  function(payload) {
      console.log('[io] client hello:', payload);
    });

    socket.on('endpoint',  function(endpoint) {
      console.log('[io] client endpoint:', endpoint);

      _createChannelToBlockchain(endpoint, io);
    });

    socket.on('disconnect', function(socket){
      console.log('[io] user disconnected');
      // io.emit('chat_message_response',"1 user disconnected.");
    });

  });

  return app;
}


/**
 *
 */
function _trackBlockChanges(endpoint, io){
  var that = this;

  // create grpc endpoint
  var myEndpoint = new MyEndpoint(endpoint);

  var stream = myEndpoint.createChatStream();
  stream.on('data', message=>{
    console.log('data:', message);
    if(message.block){
      io.emit('chainblock', message);
    }
  });
  stream.on('error', err=>{
    console.log('error:', err);

    setTimeout( _trackBlockChanges.bind(that, endpoint, io), 1000);
  });

}





////////////////////////////////////////////

module.exports = {
  trackBlockChanges : function(app){
    return createSocket(app);
    // _trackBlockChanges('localhost:7053', io);
    // _trackBlockChanges(endpoint, io);
  }
};



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function getResponseExample(){
  return {
    "Event": "block",
    "register": null,
    "block": {
      "version": 0,
      "timestamp": null,
      "transactions": [
        {
          "type": "MY_CHAINCODE_TEST",
          "chaincodeID": {},
          "payload": {},
          "metadata": {},
          "txid": "tst-test-transaction-id",
          "_txid_original": "d6b67c6f-5b77-43aa-8aef-9a528c874016",
          "timestamp": {
            "seconds": "1472243595",
            "nanos": 878832249
          },
          "confidentialityLevel": "PUBLIC",
          "confidentialityProtocolVersion": "",
          "nonce": {},
          "toValidators": {},
          "cert": {},
          "signature": {}
        }
      ],
      "stateHash": {},
      "previousBlockHash": {},
      "consensusMetadata": {},
      "nonHashData": {
        "localLedgerCommitTimestamp": {
          "seconds": "1472243627",
          "nanos": 376272706
        },
        "chaincodeEvents": [
          {
            "chaincodeID": "",
            "txID": "",
            "eventName": "",
            "payload": {}
          }
        ]
      }
    },
    "chaincodeEvent": null,
    "rejection": null,
    "unregister": null
  }
}

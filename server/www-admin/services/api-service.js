/**
 * @class ApiService
 * @classdesc
 * @ngInject
 */
function ApiService($log, $http, env) {

  // jshint shadow: true
  var ApiService = this;
  var cfg = env;

  /**
   *
   */
  ApiService.getConfig = function(){
      return $http.get(cfg.api+'/config')
          .then(function(response){ return response.data; });
  };









  /**
   * User module
   */
  ApiService.user = {};
  /**
   * @typedef {string} jwtString
   * @description jwt string
   * @more https://jwt.io/
   */

  /**
   * @typedef {object} TokenInfo
   * @property {boolean} success  :true,
   * @property {string}  secret   :"WmWRCeBcRflQ",
   * @property {string}  message  :"test1 enrolled Successfully",
   * @property {jwtString} token  :"--jwt token data--"

   * property {string}    token.exp
   * property {string}    token.username
   * property {string}    token.orgName
   * property {string}    token.iat
   */

  /**
   * @param {string} username
   * @param {string} orgName
   * @return {Promise<TokenInfo>}
   * @more curl -X POST http://localhost:4000/users -H "content-type: application/x-www-form-urlencoded" -d 'username=Jim&orgName=org1'
   */
  ApiService.user.signUp = function(username, orgName) {
    // $log.debug('ApiService.signUp', username, orgName);
    var payload = {
      username:username,
      orgName:orgName
    };
    return $http.post(cfg.api+'/users', payload)
      .then(function(response){ return response.data; });
  };









  /**
   * Channel module
   */
  ApiService.channels = {};
  /**
   * Queries the names of all the channels that a peer has joined.
   */
  ApiService.channels.list = function(){
    return $http.get(cfg.api+'/channels', {params:{peer:'peer1'}})
      .then(function(response){ return response.data.channels; });
  };

  /**
   * Queries the names of all the channels that a peer has joined.
   * @param {string} channelName
   * @return {Promise<{currentBlockHash:string, previousBlockHash:string}>}
   */
  ApiService.channels.get = function(channelName){
    return $http.get(cfg.api+'/channels/'+channelName, {params:{peer:'peer1'}})
      .then(function(response){ return response.data.currentBlockHash; });
  };

  /**
   * Queries the names of all the channels that a peer has joined.
   * @param {string} channelName
   * @param {string} blockHash - base64 block hash
   * @return {Promise<{currentBlockHash:string, previousBlockHash:string}>}
   */
  ApiService.channels.getBlock = function(channelName, blockHash){
    return $http.get(cfg.api+'/channels/'+channelName+'/blocks', {params:{peer:'peer1', hash:blockHash}})
      .then(function(response){ return response.data; });
  };









  /**
   * Chaincode module
   */
  ApiService.chaincodes = {};
  /**
   * Queries the names of all the channels that a peer has joined.
   */
  ApiService.chaincodes.list = function(params){
    params = params || {};
    params.peer = params.peer || 'peer1';
    return $http.get(cfg.api+'/chaincodes', {params:params})
      .then(function(response){ return response.data.chaincodes; });
  };









  /**
   * Smart Contract module
   */
  ApiService.sc = {};

  /**
   * @param {string} channelID
   * @param {string} contractId
   * @param {Array<string>} peers - peersId
   * @param {string} fcn
   * @param {Array} [args]
   */
  ApiService.sc.invoke = function(channelID, contractId, peers, fcn, args){
    var payload = {
      peers:peers,
      fcn:fcn,
      args:args||[]
    };
    return $http.post(cfg.api+'/channels/'+channelID+'/chaincodes/'+contractId, payload)
      .then(function(response){ return response.data; });
  };



  /**
   * @param {string} channelID
   * @param {string} contractId
   * @param {string} peer - peerId
   * @param {string} fcn
   * @param {Array} [args]
   */
  ApiService.sc.query = function(channelID, contractId, peer, fcn, args){
    var params = {
      peer : peer,
      fcn  : fcn,
      args : JSON.stringify(args||null)
    };
    return $http.get(cfg.api+'/channels/'+channelID+'/chaincodes/'+contractId, {params:params})
      .then(function(response){ return response.data; });
  };









  /**
   * Transaction module
   */
  ApiService.transaction = {};

  /**
   * @param {string} txId
   */
  ApiService.transaction.getById = function(channelID, txId){
    return $http.get(cfg.api+'/channels/'+channelID+'/transactions/'+txId, {params:{peer:'peer1'}})
      .then(function(response){ return response.data; });
  };

}



angular.module('nsd.service.api', ['nsd.config.env'])
  .service('ApiService', ApiService);
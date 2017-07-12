/**
 * @class ApiService
 * @classdesc
 * @ngInject
 */
function ApiService($log, $http, cfg) {

  // jshint shadow: true
  var ApiService = this;

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









  ApiService.channels = {};
  /**
   * Queries the names of all the channels that a peer has joined.
   */
  ApiService.channels.list = function(){
    return $http.get(cfg.api+'/channels', {params:{peer:'peer1'}})
      .then(function(response){ return response.data.channels; });
  };






  ApiService.chaincodes = {};
  /**
   * Queries the names of all the channels that a peer has joined.
   */
  ApiService.chaincodes.list = function(){
    return $http.get(cfg.api+'/chaincodes', {params:{peer:'peer1'}})
      .then(function(response){ return response.data.chaincodes; });
  };

}



angular.module('nsd.service.api', [])
  .service('ApiService', ApiService);
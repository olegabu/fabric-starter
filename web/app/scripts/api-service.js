/**
 * @class ApiService
 * @classdesc
 * @ngInject
 */
function ApiService($log, $http, cfg) {

  // jshint shadow: true
  var ApiService = this;

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
   */

  /**
   *
   * @param {string} username
   * @param {string} orgName
   * @return {Promise<TokenInfo>}
   * @more curl -X POST http://localhost:4000/users -H "content-type: application/x-www-form-urlencoded" -d 'username=Jim&orgName=org1'
   */
  ApiService.signUp = function(username, orgName) {
    // $log.debug('ApiService.signUp', username, orgName);
    var payload = {
      username:username,
      orgName:orgName
    };
    return $http.post(cfg.api+'/users', payload)
      .then(function(response){ return response.data; });
  };

}




angular.module('nsd.service')
  .service('ApiService', ApiService);
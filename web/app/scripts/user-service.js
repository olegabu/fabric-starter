/**
 * @class UserService
 * @classdesc
 * @ngInject
 */
function UserService($log, $rootScope, cfg, ApiService) {

  // jshint shadow: true
  var UserService = this;

  var user = cfg.users[0];

  UserService.setUser = function(u) {
    user = u;
  };

  UserService.getUser = function() {
    return user;
  };

  UserService.getUsers = function() {
    return cfg.users;
  };


  /**
   * @param {{username:string, orgName:string}} user
   */
  UserService.signUp = function(user) {
    return ApiService.user.signUp(user.username, user.orgName)
      .then(function(/** @type {TokenInfo} */data){
        $rootScope._tokenInfo = data;
        return data;
      });
  };


}

angular.module('nsd.service.user', ['nsd.service.api'])
  .service('UserService', UserService);
// angular.module('userService', []).service('UserService', UserService);
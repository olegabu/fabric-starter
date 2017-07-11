/**
 * @class UserService
 * @classdesc
 * @ngInject
 */
function UserService($log, $rootScope, cfg, ApiService, localStorageService) {

  // jshint shadow: true
  var UserService = this;

  var _user = cfg.users[0];

  UserService.setUser = function(user) {
    _user = user;
  };

  UserService.getUser = function() {
    return _user;
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
        UserService.saveAuthorization(data);
        return data;
      });
  };


  UserService.saveAuthorization = function(user){
    localStorageService.set('user', user);
  };

  UserService.restoreAuthorization = function(){
    var tokenInfo = localStorageService.get('user');
    $log.info('UserService.restoreAuthorization', tokenInfo);
    $rootScope._tokenInfo = tokenInfo;
  };
}

angular.module('nsd.service.user', ['nsd.service.api'])
  .service('UserService', UserService);
// angular.module('userService', []).service('UserService', UserService);
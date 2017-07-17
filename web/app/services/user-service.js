/**
 * @class UserService
 * @classdesc
 * @ngInject
 */
function UserService($log, $rootScope, ApiService, localStorageService) {

  /**
   * @param {{username:string, orgName:string}} user
   */
  UserService.signUp = function(user) {
    return ApiService.user.signUp(user.username, user.orgName)
      .then(function(/** @type {TokenInfo} */tokenInfo){
        $rootScope._tokenInfo = tokenInfo;
        UserService.saveAuthorization(tokenInfo);
        return tokenInfo;
      });
  };


  UserService.logout = function() {
    UserService.saveAuthorization(null);
  };


  UserService.isAuthorized = function(){
    return !!$rootScope._tokenInfo;
  }

  UserService.getUser = function(){
    return $rootScope._tokenInfo;
  }


  UserService.saveAuthorization = function(user){
    if(user){
      user.tokenData = parseTokenData(user.token);
    }
    localStorageService.set('user', user);
  };

  UserService.restoreAuthorization = function(){
    var tokenInfo = localStorageService.get('user');
    $log.info('UserService.restoreAuthorization', !!tokenInfo);

    if(tokenInfo){
      tokenInfo.tokenData = parseTokenData(tokenInfo.token);
      // TODO: check expire time
    }
    $rootScope._tokenInfo = tokenInfo;
  };


  /**
   *
   */
  function parseTokenData(token){
      token = token || "";
      var tokenDataEncoded = token.split('.')[1];
      var tokenData = null;
      try{
        tokenData = JSON.parse(atob(tokenDataEncoded));
      }catch(e){
        $log.warn(e);
      }
      return tokenData;
  }

  return UserService;
}

angular.module('nsd.service.user', ['nsd.service.api', 'LocalStorageModule'])
  .service('UserService', UserService)

  .run(function(UserService){
    UserService.restoreAuthorization();
  });

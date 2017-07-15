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
      .then(function(/** @type {TokenInfo} */data){
        $rootScope._tokenInfo = data;
        UserService.saveAuthorization(data);
        return data;
      });
  };


  UserService.isAuthorized = function(){
    return !!$rootScope._tokenInfo;
  }


  UserService.saveAuthorization = function(user){
    localStorageService.set('user', user);
  };

  UserService.restoreAuthorization = function(){
    var tokenInfo = localStorageService.get('user');
    // if(!tokenInfo || isTokenExpired(tokenInfo.token)){
    //   tokenInfo = null;
    // }
    $log.info('UserService.restoreAuthorization', !!tokenInfo);
    $rootScope._tokenInfo = tokenInfo;
  };


  // TODO: we need to take care of client timezone before using it
  function isTokenExpired(token){
      token = token || "";
      var tokenDataEncoded = token.split('.')[1];
      var tokenData = {};
      try{
        tokenData = JSON.parse(atob(tokenDataEncoded));
      }catch(e){
        $log.warn(e);
        tokenData = {};
      }
      return Date.now() - (tokenData.exp||0)*1000 >= 0;
  }

  return UserService;
}

angular.module('nsd.service.user', ['nsd.service.api', 'LocalStorageModule'])
  .service('UserService', UserService)

  .run(function(UserService){
    UserService.restoreAuthorization();
  });

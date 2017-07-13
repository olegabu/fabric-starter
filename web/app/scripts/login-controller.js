/**
 * @class LoginController
 * @ngInject
 */
function LoginController($scope, UserService, $state, ApiService) {
  var ctl = this;

  ctl.org = null;

  ApiService.getConfig().then(function(config){
    ctl.org = config.org;
  });

  ctl.signUp = function(user){
    return UserService.signUp(user)
    .then(function(){
      $state.go('app.channels');
    });
  };

}


angular.module('nsd.controller.login', ['nsd.service.user'])
.controller('LoginController', LoginController);

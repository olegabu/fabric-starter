/**
 * @class LoginController
 * @ngInject
 */
function LoginController($scope, UserService, $state, ApiService) {
  var ctl = this;

  ctl.config = null;

  // ApiService.getConfig().then(function(config){
  //   ctl.config = config;
  // });

  ctl.signUp = function(user){
    return UserService.signUp(user)
    .then(function(){
      $state.go('app.query');
    });
  };

}


angular.module('nsd.controller.login', ['nsd.service.user'])
.controller('LoginController', LoginController);

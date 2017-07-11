/**
 * @class LoginController
 * @ngInject
 */
function LoginController($scope, UserService, $state) {
  var ctl = this;

  // ctl.organisations = ['org1', 'org2'];

  ctl.signUp = function(user){
    return UserService.signUp(user)
    .then(function(){
      $state.go('app.channels');
    });
  };

}


angular.module('nsd.controller.login', ['nsd.service.user'])
.controller('LoginController', LoginController);

/**
 * @class LoginController
 * @ngInject
 */
function LoginController($scope, UserService) {
  var ctl = this;

  // ctl.organisations = ['org1', 'org2'];

  ctl.signUp = function(user){
    return UserService.signUp(user);
  };

}


angular.module('nsd.controller')
.controller('LoginController', LoginController);

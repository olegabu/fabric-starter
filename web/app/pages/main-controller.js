/**
 * @class MainController
 * @ngInject
 */
function MainController($scope, UserService, $state, ApiService) {
  var ctrl = this;

  ctrl.$state = $state;

  ctrl.visibleMenu = function(state){
    return !(state.abstract || state.data && state.data.visible===false);
  }

  return ctrl;
}


angular.module('nsd.controller.main', [])
  .controller('MainController', MainController);

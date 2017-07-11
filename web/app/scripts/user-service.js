/**
 * @class UserService
 * @classdesc
 * @ngInject
 */
function UserService($log, cfg) {

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

}

angular.module('userService', []).service('UserService', UserService);
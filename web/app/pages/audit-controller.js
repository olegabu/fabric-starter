/**
 * Created by maksim on 7/13/17.
 */
/**
 * @class AuditController
 * @ngInject
 */
function AuditController($scope, UserService, $state) {
  var ctl = this;

  ctl.org = null;


}


angular.module('nsd.controller.audit', ['nsd.service.user'])
  .controller('AuditController', AuditController);

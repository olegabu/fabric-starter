/**
 * Created by maksim on 7/13/17.
 */
/**
 * @class QueryController
 * @ngInject
 */
function QueryController($scope, ChannelService) {
  var ctl = this;



  ctl.scMove = function(){
    ChannelService.scMove('a', 'b', '10');
  };


}


angular.module('nsd.controller.query', ['nsd.service.channel'])
  .controller('QueryController', QueryController);

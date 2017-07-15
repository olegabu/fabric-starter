/**
 * Created by maksim on 7/13/17.
 */
/**
 * @class QueryController
 * @ngInject
 */
function QueryController($scope, ChannelService) {
  var ctl = this;

  ctl.channels = [];
  ctl.chaincodes = [];
  ctl.args = "[]";

  ctl.scMove = function(){
    ChannelService.scMove('a', 'b', '10');
  };


  ctl.getChannels = function(){
    return ChannelService.list().then(function(dataList){
      ctl.channels = dataList;
    });
  };

  ctl.getChaincodes = function(){
    $scope.selectedChannel;
    return ChannelService.listChaincodes().then(function(dataList){
      ctl.chaincodes = dataList;
    });
  };


  ctl.validate = function(val){
    try{
      JSON.parse(val);
      return true;
    }catch(e){
      return false;
    }

  }

  //
  ctl.getChannels();
  $scope.$watch('selectedChannel', ctl.getChaincodes );

}


angular.module('nsd.controller.query', ['nsd.service.channel'])
  .controller('QueryController', QueryController);

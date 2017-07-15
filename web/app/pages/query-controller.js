/**
 * Created by maksim on 7/13/17.
 */
/**
 * @class QueryController
 * @ngInject
 */
function QueryController($scope, ChannelService, $log) {
  var ctl = this;

  ctl.channels = [];
  ctl.chaincodes = [];

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


  ctl.invoke = function(channel, cc, fcn, args){
    try{
      args = JSON.parse(args);
    }catch(e){
      $log.warn(e);
    }

    return ChannelService.invoke(channel.channel_id, cc.name, fcn, args);
  }

  //
  ctl.getChannels();
  $scope.$watch('selectedChannel', ctl.getChaincodes );

}


angular.module('nsd.controller.query', ['nsd.service.channel'])
  .controller('QueryController', QueryController);

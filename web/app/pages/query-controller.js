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
  ctl.transaction = null;
  ctl.invokeInProgress = false;


  ctl.getChannels = function(){
    return ChannelService.list().then(function(dataList){
      ctl.channels = dataList;
    });
  };

  ctl.getChaincodes = function(){
    $scope.selectedChannel;
    // TODO:
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

    ctl.transaction = null;
    ctl.error = null;
    ctl.invokeInProgress = true;

    return ChannelService.invoke(channel.channel_id, cc.name, fcn, args)
      .then(function(data){
        return ChannelService.getTransactionById(data.transaction);
      })
      .then(function(transaction){
        ctl.transaction = transaction;
      })
      .catch(function(response){
        ctl.error = response.data || response;
      })
      .finally(function(){
        ctl.invokeInProgress = false;
      });
  }

  //
  ctl.getChannels();
  $scope.$watch('selectedChannel', ctl.getChaincodes );

}


angular.module('nsd.controller.query', ['nsd.service.channel'])
  .controller('QueryController', QueryController);

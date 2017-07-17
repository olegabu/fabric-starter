/**
 * Created by maksim on 7/13/17.
 */
/**
 * @class QueryController
 * @ngInject
 */
function QueryController($scope, ChannelService, ConfigLoader, $log) {
  var ctl = this;

  ctl.channels = [];
  ctl.chaincodes = [];
  ctl.transaction = null;
  ctl.invokeInProgress = false;

  // init
  var netConfig = ConfigLoader.get().network;
  var orgs = netConfig.getOrgs();
  var allPeers = []
  orgs.forEach(function(org){
    var peers = netConfig.getPeers(org.id);
    allPeers.push.apply(allPeers, peers);
  });
  // allPeers = JSON.parse(JSON.stringify(allPeers));
  // allPeers.unshift({
  //   "server-hostname": "Select peers"
  // });


  ctl.getPeers = function(){
    return allPeers;
  }


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



  ctl.invoke = function(channel, cc, peers, fcn, args){
    try{
      args = JSON.parse(args);
    }catch(e){
      $log.warn(e);
    }

    ctl.transaction = null;
    ctl.error = null;
    ctl.invokeInProgress = true;

    return ChannelService.invoke(channel.channel_id, cc.name, peers, fcn, args)
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

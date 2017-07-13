/**
 * @class ChannelService
 * @classdesc
 * @ngInject
 */
function ChannelService(cfg, ApiService) {

  // jshint shadow: true
  var ChannelService = this;

  /**
   */
  ChannelService.list = function(user) {
    return ApiService.channels.list();
  };


  /**
   */
  ChannelService.listChaincodes = function() {
    return ApiService.chaincodes.list();
  };



  /**
   * @param {string} blockHash
   */
  ChannelService.getLastBlock = function(blockHash) {
    var channelId = 'mychannel';
    return ApiService.channels.get(channelId)
      .then(function(currentBlockHash){
        return ApiService.channels.getBlock(channelId, currentBlockHash);
      });
  };



  /**
   * @param {string} from
   * @param {string} to
   * @param {string} amount
   */
  ChannelService.scMove = function(from, to, amount){
    return ApiService.sc.invoke('move', [from, to, amount]);
  };

}

angular.module('nsd.service.channel', ['nsd.service.api'])
  .service('ChannelService', ChannelService);
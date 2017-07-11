/**
 * @class MarketController
 * @classdesc
 * @ngInject
 */
function MarketController($scope, $log, $interval, $uibModal, $rootScope,
    UserService, PeerService) {

  var ctl = this;
  
  var init = function() {
    ctl.reload();
  };

  $rootScope.$on('chainblock', function(payload){
    ctl.reload();
  });

  $rootScope.$on('userchanged', function(){
    ctl.reload();
  });

  ctl.reload = function(){
    PeerService.getOffers().then(function(list) {
      ctl.list = list;
    });
  };

  
  $scope.$on('$viewContentLoaded', init);

  ctl.user = UserService.getUser();
  
  ctl.open = function(trade) {
    var modalInstance = $uibModal.open({
      templateUrl: 'buy-contract-modal.html',
      controller: 'BuyModalController as ctl',
      resolve: {
        trade: function() {
          return trade;
        }
      }
    });

    modalInstance.result.then(function(trade) {
      PeerService.buy(trade.id);
    });
  };
  
  ctl.cancel = function() {
    modalInstance.dismiss('cancel');
  };

}

function BuyModalController($uibModalInstance, trade) {

  var ctl = this;
  
  ctl.trade = trade;
  
  ctl.ok = function () {
    $uibModalInstance.close(ctl.trade);
  };

  ctl.cancel = function () {
    $uibModalInstance.dismiss('cancel');
  };
}

angular.module('marketController', [])
.controller('MarketController', MarketController)
.controller('BuyModalController', BuyModalController);
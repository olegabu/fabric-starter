/**
 * @class MarketController
 * @classdesc
 * @ngInject
 */
function OfflineController($scope, $log, $interval, $uibModal, localStorageService,
    UserService, PeerService) {

  var ctl = this;

  ctl.requests = [];
  ctl.requestsVerified = [];


  var init = function() {
      _refreshData();
  };

  $scope.$on('$viewContentLoaded', init);

  $interval(init, 5000);

  ctl.user = UserService.getUser();

  ctl.open = function() {
    var modalInstance = $uibModal.open({
      templateUrl: 'verify-contract-modal.html',
      controller: 'VerifyModalController as ctl'
    });

    modalInstance.result.then(function(result) {
      console.log('Window closed:', result);

      console.log(ctl.requests);
      ctl.requests.push(result);

      _updateData();
    });
  };

  ctl.verify = function(paymentRequest){
    var index = ctl.requests.indexOf(paymentRequest);

    PeerService.verify(paymentRequest.description, paymentRequest.amount)
      .then(function(status){
        paymentRequest.status = status;

        if(paymentRequest.status.state==='OK'){
          ctl.requestsVerified = ctl.requestsVerified.concat( ctl.requests.splice(index, 1) );
        }else{
          paymentRequest.description = paymentRequest.status.message;
        }

//        $scope.$digest();
        _updateData();
      });

  };


  ctl.decline = function(paymentRequest){
    ctl.requests.splice(ctl.requests.indexOf(paymentRequest), 1);
    _updateData();
  };



  ctl.submitOnline = function(index){
    var requestVerified = ctl.requestsVerified.splice(index, 1)[0];
    // TODO:
    if(requestVerified.purpose == "coupons"){
        PeerService.payCoupons(requestVerified.from, requestVerified.description);
    }else{
        PeerService.confirm(requestVerified.description);
    }
    _updateData();

  };



  /**
   *
   */

  function _updateData(){
    localStorageService.set('pr', ctl.requests);
    localStorageService.set('prv', ctl.requestsVerified);
  }

  function _refreshData(){
    // requests
    ctl.requests = localStorageService.get('pr') || [];
    ctl.requestsVerified = localStorageService.get('prv') || [];
  }

}




/**
 *
 */
function VerifyModalController($uibModalInstance) {

  var ctl = this;

  ctl.ok = function (paymentRequest) {
    $uibModalInstance.close(paymentRequest);
  };

  ctl.cancel = function () {
    $uibModalInstance.dismiss('cancel');
  };
}

angular.module('offlineController', ['LocalStorageModule'])
  .controller('OfflineController', OfflineController)
  .controller('VerifyModalController', VerifyModalController);


/**
 * @class TimeService
 * @classdesc
 * @ngInject
 */
function TimeService($log, $interval, cfg, PeerService, localStorageService, $rootScope) {

  // jshint shadow: true
  var TimeService = this;

  TimeService.now = new Date(2016, 5, 1, 12, 0);

  $rootScope.$on('chainblock', function(e, payload){
    TimeService.now = new Date(payload.year, payload.month, 1, 12, 0);
  });

  var clockStepMonths = 1;

  var addTime = function() {
    TimeService.now.setMonth(TimeService.now.getMonth() + clockStepMonths);
  };

  TimeService.tick = function() {
    // call monthly function
    addTime();

    PeerService.payCoupons();

  };

  var stop;

  TimeService.clock = function() {
    if(angular.isDefined(stop)) {
      $interval.cancel(stop);
      stop = undefined;
    }
    else {
      stop = $interval(TimeService.tick, 5 * 1000);
    }
  };


  function processCoupons(bonds){
    var list = localStorageService.get('prv') || [];
    list = list.concat(bonds.map(function(item){
        return {
          from: item.issuerId,
          to: "all",
          amount:"1",
          purpose: 'coupons',
          description: item.id,
          status : {state:'OK'}
        }
    }));

    localStorageService.set('prv', list);
  }
}


angular.module('timeService', []).service('TimeService', TimeService);
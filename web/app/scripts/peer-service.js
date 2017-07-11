/**
 * @class PeerService
 * @classdesc
 * @ngInject
 */
function PeerService($log, $q, $http, cfg, UserService) {

  // jshint shadow: true
  var PeerService = this;

  var payload = {
      'jsonrpc': '2.0',
      'params': {
        'type': 1,
        'chaincodeID': {
          name: cfg.chaincodeID
        },
        'ctorMsg': {},
        "attributes": ["role", "name"]
      },
      'id': 0
  };

  var isLoading = {};


  PeerService.buy = function(tradeId) {
    return invoke('buy', ['' + tradeId]);
  };

  PeerService.confirm = function(contractId) {
    return invoke('confirm', [ contractId])
  };

  PeerService.payCoupons = function() {
    return invokeSystem('payCoupons', [])
  };

  PeerService.verify = function(description, price) {
    return query('verifyBuyRequest', [description, price]);
  };


  PeerService.sell = function(contractId, price) {
    return invoke('sell', [ contractId, '' + price])
  };

  PeerService.getOffers = function() {
    return query('getTrades', []);
  };


  PeerService.getContracts = function() {
    return query('getContracts', []);
  };

  PeerService.getBonds = function() {
    return query('getBonds', []);
  };

  PeerService.getAllBonds = function() {
    return query('getBonds', []);
  };

  PeerService.createBond = function(bond) {
    bond.maturityDate = getMaturityDateString(bond.term);
    return invoke('createBond', [getMaturityDateString(bond.term),
      '' + bond.principal, '' + bond.rate, '' + bond.term]);
  };


  var invoke = function(functionName, functionArgs) {
    $log.debug('PeerService.invoke');

    payload.method = 'invoke';
//    payload.params.ctorMsg['function'] = functionName;
    payload.params.ctorMsg.args = encodeToBase64(functionName, functionArgs);
    payload.params.secureContext = UserService.getUser().id;

    $log.debug('payload', payload);

    return $http.post(UserService.getUser().endpoint, angular.copy(payload)).then(function(data) {
      $log.debug('result', data.data.result);
    });
  };

  var invokeSystem = function(functionName, functionArgs) {
    $log.debug('PeerService.invoke');

    payload.method = 'invoke';
    payload.params.ctorMsg.args = encodeToBase64(functionName, functionArgs);
    payload.params.secureContext = "system";

    $log.debug('payload', payload);

    return $http.post(cfg.endpoint, angular.copy(payload)).then(function(data) {
      $log.debug('result', data.data.result);
    });
  };

  var query = function(functionName, functionArgs) {
    $log.debug('PeerService.query');
    if(isLoading[functionName] && isLoading[functionName].$$state.pending) return isLoading[functionName];

    var d = $q.defer();
    isLoading[functionName] = d.promise;

    payload.method = 'query';
//    payload.params.ctorMsg['function'] = functionName;
    payload.params.ctorMsg.args = encodeToBase64(functionName, functionArgs);
    payload.params.secureContext = UserService.getUser().id;


    $log.debug('payload', payload);

    $http.post(UserService.getUser().endpoint, angular.copy(payload)).then(function(res) {
      // $log.debug('result', res.data.result);
      if(res.data.error) {
        logReject(d, res.data.error);
      }
      else if(res.data.result.status === 'OK') {
        d.resolve(JSON.parse(res.data.result.message));
      }
      else {
        logReject(d, res.data.result);
      }
    });

    return d.promise;
  };

  var logReject = function(d, o) {
    $log.error(o);
    d.reject(o);
  };

}

var encodeToBase64 = function(functionName, functionArgs) {
    functionArgs.splice(0, 0, functionName);
//    for (var i = 0; i < functionArgs.length; i++) {
//        functionArgs[i] = btoa(functionArgs[i]);
//    }
    return functionArgs
};

var getMaturityDate = function(term) {
  var now = new Date();
  return new Date(now.getFullYear(), now.getMonth() + term, now.getDate());
};

var getMaturityDateString = function(term) {
  var m = getMaturityDate(term);
  return m.getFullYear() + '.' + (m.getMonth() + 1) + '.' + m.getDate();
};


angular.module('peerService', []).service('PeerService', PeerService);
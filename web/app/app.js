/**
 *
 */
angular.module('nsd.controller', [
  'nsd.controller.main',
  'nsd.controller.login',
  'nsd.controller.info',
  'nsd.controller.query',
]);

angular.module('nsd.service', [
  'nsd.service.api',
  'nsd.service.user',
  'nsd.service.channel'
]);

angular.module('nsd.app',[
   'ui.router',
   'ui.bootstrap',
   'ui.materialize',
   'ui.router.title',

   'LocalStorageModule',
   'jsonFormatter',

   'nsd.config.env',
   'nsd.controller',
   'nsd.service',

   'nsd.directive.form'
])
.config(function($stateProvider, $urlRouterProvider) {

  $urlRouterProvider.otherwise('/query');

  /*
   Custom state options are:
      visible:boolean  (default:true) - 'false' is hide element from menu. setting abstract:true also hide it
      guest:boolean    (default:true) - when 'false' - prevents unauthorized access to the item
      name:string (default:<stateId>) - menu name

  */
  $stateProvider
    .state('app', {
      url: '/',
      abstract:true,
      templateUrl: 'app.html',
      resolve: {
        // $title: function() { return 'Home'; }
        _config: function(ConfigLoader){ return ConfigLoader.load(); }
      }
    })
    .state('app.login', {
      url: 'login',
      templateUrl: 'pages/login.html',
      controller: 'LoginController',
      controllerAs: 'ctl',
      data:{
        visible: false
      }
    })

    .state('app.query', {
      url: 'query',
      templateUrl: 'pages/query.html',
      controller: 'QueryController',
      controllerAs: 'ctl',
      data:{
        name: 'Query/Invoke',
        guest:false,
        // default:true
      }
    })

    .state('app.info', {
      url: 'info',
      templateUrl: 'pages/info.html',
      controller: 'InfoController',
      controllerAs: 'ctl',
      data:{
        name: 'Info',
        guest:false
      }
    });

})
.run(function(UserService, ApiService, $rootScope, $state, $log){
  // goDefault();


  var loginState = 'app.login';

  // https://github.com/angular-ui/ui-router/wiki#state-change-events
  $rootScope.$on('$stateChangeStart',  function(event, toState, toParams, fromState, fromParams, options){
    console.log('$stateChangeStart', toState, fromState);

    var isGuestAllowed = toState.data && toState.data.guest !== false;
    var isLoginState = toState.name == loginState;


    if ( isLoginState && !isGuestAllowed){
      $log.warn('login state cannot be authorized-only');
    }

    if ( !isGuestAllowed && !isLoginState && !UserService.isAuthorized() ){
      event.preventDefault();
      // transitionTo() promise will be rejected with a 'transition prevented' error

      if(fromState.name == ""){
        // just enter the page
        goLogin();
      }
    }
  });

  /**
   *
   */
  function goLogin(){
    $state.go(loginState);
  }

  /**
   *
   */
  // function goDefault(){
  //   var defaultState = getDefaultState();
  //   if(defaultState){
  //     $state.go(defaultState.name);
  //   } else {
  //     $log.warn('No default state');
  //   }
  // }


  /**
   * @return {State}
   */
  function getDefaultState(){
    var states = $state.get()||[];
    for (var i = states.length - 1; i >= 0; i--) {
      if( states[i].data && states[i].data.default===true){
        return states[i];
      }
    }
    return null;
  }

})


/**
 *
 */
.config(function($httpProvider) {
  $httpProvider.interceptors.push('bearerAuthIntercepter');
})

/**
 * inject 'X-Requested-With' header
 * inject 'Authorization: Bearer' token
 */
.factory('bearerAuthIntercepter', function($rootScope){
    return {
        request: function(config) {
            config.headers['X-Requested-With'] = 'XMLHttpRequest'; // make ajax request visible among the others
            config.withCredentials = true;

            if($rootScope._tokenInfo){
              config.headers['Authorization'] = 'Bearer '+$rootScope._tokenInfo.token;
            }
            return config;
        }
    };

})





/**
 * load config from remote endpoint
 * @ngInject
 */
.service('ConfigLoader', function(ApiService, $rootScope){

    /** @type {Promise<FabricConfig>} */
    var _configPromise;

    function _resolveConfig(){
      if( !_configPromise ){
        _configPromise = ApiService.getConfig()
          .then(function(config){
            $rootScope._config = config;
            return config;
          })
          .catch(function(e){
            $rootScope._config = false;
            console.error('Config not loaded:', e);

            // TODO: make nice alert window =)
            e = e || {};
            var message = e.message || e.statustext || (e.status == -1 ? 'No response' : null) || 'Unknown error';
            alert('Error connecting to API server: ' + message);
          });
      }
      return _configPromise;
    }


    return {
      load:_resolveConfig
    };
})

/**
 * @ngInject
 */
.run(function(ConfigLoader){
  ConfigLoader.load();
})



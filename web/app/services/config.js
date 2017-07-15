window.disableThemeSettings = true;

angular.module('nsd.config', [])

// Register environment in AngularJS as constant
// '__env' should be defined in env.js
.constant('env', window.__env);
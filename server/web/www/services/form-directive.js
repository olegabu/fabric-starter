angular.module('nsd.directive.form', [])

  .directive('validateJson', function() {
    return {
      restrict:'A',
      require: 'ngModel',
      link: function(scope, elm, attrs, ctrl) {
        ctrl.$validators.json = function(modelValue, viewValue) {
          if (ctrl.$isEmpty(modelValue)) {
            return true;
          }

          try{
            JSON.parse(viewValue);
            // it is valid
            return true;
          }catch(e){
          // it is invalid
            return false;
          }

        };
      }
    };
  });
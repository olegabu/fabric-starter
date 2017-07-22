angular.module('nsd.directive.certificate', [])

  // see here: https://lapo.it/asn1js
  .directive('certificate', function() {
    return {
      restrict:'E',
      scope: {
        data:'=',
        title:"@"
      },
      templateUrl:'services/certificate.html',
      link: function(scope, elm, attrs, ctrl) {

        scope.$watch('data', decode);

        function decode(){
          var certificate = scope.data;
          var decoded;
          var oids;
          if(certificate){
            // https://lapo.it/asn1js
            var der = Base64.unarmor(certificate);
            decoded = ASN1.decode(der).toJSON();

            oids = getAllObjectIdentifiers(decoded).filter(function(item){ return item !== true; });
          }

          scope.decoded = decoded;
          scope.oids = oids;
        }


        var OBJECT_IDENTIFIER_TYPE = "OBJECT IDENTIFIER";
        var OBJECT_VALUE_TYPE = "PrintableString";


        /**
         * @return {Array<{key:ans1Object, value:ansobject}>}
         */
        function getAllObjectIdentifiers(asn1DecodedObject){
          var elements = _extractOI(asn1DecodedObject);

          var result = [];
          // iterate order is important here
          var current = {};
          for (var i = 0, n = elements.length; i < n; i++) {
            var e = elements[i];

            if(e.type == OBJECT_IDENTIFIER_TYPE){
              current.key = e;
            } else if(e.type == OBJECT_VALUE_TYPE){
              current.value = e;
              result.push(current);
              current = {};
            }
          }
          return result;
        }

        function _extractOI(asn1DecodedObject){
            var result = [];

            if(asn1DecodedObject.type == OBJECT_IDENTIFIER_TYPE || asn1DecodedObject.type == OBJECT_VALUE_TYPE){
              result.push(asn1DecodedObject);
            }else if(asn1DecodedObject.children){
              // iterate order is important here
              for (var i = 0, n = asn1DecodedObject.children.length; i < n; i++) {
                result.push.apply(result, _extractOI(asn1DecodedObject.children[i]) );
              }
            }

            return result;

        }

      }
    };
  });
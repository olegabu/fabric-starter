angular.module('nsd.directive.certificate', [])

  // see here: https://lapo.it/asn1js
  .directive('certificate', function() {
    return {
      restrict:'E',
      scope: {
        data:'=',
        title:"@"
      },
      templateUrl:'components/certificate.html',
      link: function(scope, elm, attrs, ctrl) {

        scope.$watch('data', decode);

        function decode(){
          var certificate = scope.data;
          var decoded;
          var oids;
          var certInfo;
          if(certificate){
            // https://lapo.it/asn1js
            var der = Base64.unarmor(certificate);
            decoded = ASN1.decode(der).toJSON();
            // console.log('decoded', decoded);

            var certInfo = getCertificateInfo(decoded);
            console.log('certInfo', certInfo);

            // oids = getAllObjectIdentifiers(decoded).filter(function(item){ return item !== true; });
          }

          scope.decoded = decoded;
          scope.oids = oids;
          scope.certInfo = angular.copy(certInfo);
        }


        var OBJECT_IDENTIFIER_TYPE = "OBJECT IDENTIFIER";
        var OBJECT_VALUE_TYPE = "PrintableString";

        function getCertificateInfo(decoded){
            var result = {};
            /*
              // I'm no completely sure that it's right
              decoded.children[0] - certificate info
              decoded.children[1] - certificate type
              decoded.children[2] - some binary data (signature? serial number?)
            */
            result.algorithm = decoded.children[1].children[0];
            var dataset = decoded.children[0].children;
            // console.log('dataset', dataset);
            /*
              // I'm no completely sure that it's right
              dataset[0] - version
              dataset[1] - serial number
              dataset[2] - certificate type (same as decoded[1])
              dataset[3] - authority info
              dataset[4] - validity dates
              dataset[5] - certificate info
              dataset[6] - public key
              dataset[7] - extension
            */
            result.from = dataset[4].children[0].value;
            result.to   = dataset[4].children[1].value;

            result.authority  = dataset[3].children.map(__first).map(__keyvalue);
            result.fields     = dataset[5].children.map(__first).map(__keyvalue);
            result.extension  = dataset[7].children[0].children/*.map(__first)*/.map(__keyvalue);

            function __first(item){
              return item.children[0];
            }

            function __keyvalue(item){
              // TODO: use it if the data can be written in reverse order
              // var key = item.children.filter(function(item){ return item.type == OBJECT_IDENTIFIER_TYPE;})[0];
              // var val = item.children.filter(function(item){ return item.type == OBJECT_VALUE_TYPE;})[0];

              // TODO: extension don't work propertly with [0] and [1]
              var key = item.children[0];
              var val = item.children[1];
              return {
                key : key,
                val : val,
                _original:item
              }
            }

            return result;
        }

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
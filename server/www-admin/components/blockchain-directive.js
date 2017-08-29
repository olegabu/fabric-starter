angular.module('nsd.directive.blockchain', ['nsd.service.socket'])

// scope:
// = is for two-way binding
// @ simply reads the value (one-way binding)
// & is used to bind functions
.directive('blockchainLog', function($document, SocketService){
  return {
    restrict:'E',
    replace: false,
    // scope: true,
    // scope: { name:'=', id:'=' },
    template: '<div class="bc-wrapper" id="footerWrap" ng-init="ctl.init()">'
                +'<div id="bc-wrapper-block" ng-class="ctl.getStatusClass()">'
                  +'<i class="material-icons" title="{{ctl.getStatusText()}}">device_hub</i>'

                  +'<div id="details" ng-show="!!ctl.blockInfo" >'
                    +'<p> Block:    {{ctl.blockInfo.header.data_hash|limitTo:25}}...'
                      +'<br> TXID:     {{ctl.blockInfo.data.data[0].payload.header.channel_header.tx_id|limitTo:25}}...'
                      +'<br> Type:     {{ctl.blockInfo.data.data[0].payload.header.channel_header.type}}'
                      +'<br> Created:  {{ctl.blockInfo.data.data[0].payload.header.channel_header.timestamp}}'
                      +'<br> Height:   {{ctl.blockInfo.header.number}}'
                    +'</p>'
                    +'<hr class="line">'
                    +'<certificate title="false" data="ctl.blockInfo.data.data[0].payload.data.actions[0].header.creator.IdBytes"></certificate>'
                  +'</div>'

                  // +'<div class="block" style="opacity: 1; left: 36px;">016</div>'
                  // +'<div class="block" style="opacity: 1; left: 72px;">017</div>'
                  // +'<div class="block" style="opacity: 1; left: 108px;">018</div>'
                  // +'<div class="block" style="opacity: 1; left: 144px;">019</div>'
                  // +'<div class="block" style="opacity: 1; left: 180px;">020</div>'
                  // +'<div class="block" style="opacity: 1; left: 216px;">021</div>'
                  // +'<div class="block lastblock" style="opacity: 1; left: 252px;">022</div>'
                +'</div>'
              +'</div>',
    controllerAs: 'ctl',
    controller: function($scope, $element, $attrs, $transclude, $rootScope){
      var ctl = this;

      var clicked=false;
      var blockCount = 0;
      var blockWidth = 36;

      ctl.blockInfo = null;

      setInterval(function(){
        removeExtraBlocks();
      }, 2000);

      var socket = null;

      var stateClasses = {
        'error' :        'red-text',
        'connected' :    'light-blue-text aqua-text',
        'disconnected' : 'red-text',
        'connecting' :   'orange-text',
        'default' :      '',
      };

      /**
       *
       */
      ctl.init = function(){
        // var socket = io('ws://'+location.hostname+':8155/');
        socket = SocketService.getSocket();

        console.log('chainblock event registered');
        socket.on('chainblock', function(payload){
          console.log('server chainblock:', payload);
          // $rootScope.$emit('chainblock', payload);
          addChainblocks(payload);
        });
      };

      /**
       *
       */
      ctl.getStatusClass = function(){
        return stateClasses[SocketService.getState()] || stateClasses['default'];
      };

      /**
       *
       */
      ctl.getStatusText = function(){
        return SocketService.getState();
      };

      /**
       * @param chainblock
       */
      function addChainblocks(chainblock){
        var width = $(document).width();

        var blockElement = _blockHtml(chainblock).css({left: '+='+width }).animate({ left: '-='+width } );
        blockCount++;
        $element.find('#bc-wrapper-block').append(blockElement);
      }

      function _blockHtml(block){
        var tx = block && block.header && block.header.data_hash;
        return $('<div class="block">'+tx.substr(0,3)+'</div>')
                  .css({left: (blockCount * blockWidth)})
                  .click(_onBlockClick)
                  .hover(getBlockHoverIn(block), onBlockHoverOut);
      }



      function _onBlockClick(e){
        clicked = !clicked;
        return;

        //demo animation
        var $block = $(e.target);
        var width = $(document).width();
        $block.css({left: '+='+width }).animate({ left: '-='+width } );
        e.stopPropagation();
      }

      function getBlockHoverIn(tx){
          // blockInfo
          return function(e){
            // if(!ctl.blockInfo || ctl.blockInfo.txid != tx.txid){
              ctl.blockInfo = tx;
              $scope.$digest();
              // $details.css({left : $(e.target).position().left }).stop(true).fadeIn();
            // }
          }
      }

      function onBlockHoverOut(e){
          if(!clicked){
            ctl.blockInfo = null;
            $scope.$digest();
            // $details.stop(true).fadeOut();
          }
      }

      /**
       * Remove extra blocks
       */
      function removeExtraBlocks(){
        if(blockCount > 10){
          var toRemove = blockCount - 10;
          $element.find('.block:lt('+toRemove+')').animate({opacity: 0}, 800, function(){$('.block:first').remove(); /* blocks.slice(toRemove); */ });
          $element.find('.block').animate({left: '-='+blockWidth*toRemove}, 800, function(){});
          blockCount -= toRemove;
        }
      }

    }//-controller
}});


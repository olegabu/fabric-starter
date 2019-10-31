import {inject} from 'aurelia-framework';
import {LogManager} from 'aurelia-framework';
//import * as toastr from 'toastr';

let log = LogManager.getLogger('AlertService');

const _messageStackMaxSize = 50;

//@inject(toastr)
export class AlertService {

  _alertMessages;

  constructor() {
  //constructor(toastr) {
    // this.toastr = toastr;
    // this.toastr.options.positionClass = 'toast-bottom-right';
    // this.toastr.options.progressBar = true;
    // this.toastr.options.closeButton = true;
    // this.toastr.options.timeOut = 1000;
    // this.toastr.options.extendedTimeOut = 2000;

    this._alertMessages = [];
  }

  onNewMessage = message => {
    let _pending = this._alertMessages.find(x=>x.type === 'pending' && x.scope === message.scope);

    if (this._alertMessages.length >0 && message.type === this._alertMessages[0].type && message.type === 'success' && message.message === this._alertMessages[0].message && message.scope === 'GET'){
      this._alertMessages[0].time = new Date();
    }
    else if (_pending && message.type === 'pending'){
      _pending.time = new Date();
    }
    else if (_pending && message.type !== 'pending'){
      // finish
      this._alertMessages = this._alertMessages.filter (x=> !(x.type === 'pending' && x.scope === message.scope) );
      //this._alertMessages.shift();
      if (this._alertMessages.length >0 && message.type === this._alertMessages[0].type && message.type === 'success' && message.message === this._alertMessages[0].message && message.scope === 'GET'){
        this._alertMessages[0].time = new Date();
      }
      else {
        this._alertMessages.unshift(message);
      }
    }
    else {
      this._alertMessages.unshift(message);
      if (this._alertMessages.length > _messageStackMaxSize){
        this._alertMessages.splice(-1,1);
      }
    }
  };


  pending(m, scope='GET', title = 'Awaiting..') {
    this.onNewMessage({type: 'pending', title: title, message: m, time: new Date(), scope: scope})
  }

  info(m, scope='GET', title = 'Information') {
    //this.toastr.info(m);
    this.onNewMessage({type: 'info', title: title, message: m, time: new Date(), scope: scope})
  }

  error(m, scope='GET', title = 'Error') {
    //this.toastr.error(m);
    this.onNewMessage({type: 'danger', title: title, message: m, time: new Date(), scope: scope})
  }

  success(m, scope='GET', title = 'Success') {
    //this.toastr.success(m);
    this.onNewMessage({type: 'success', title: title, message: m, time: new Date(), scope: scope})
  }


}

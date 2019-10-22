import {containerless, child, children, bindable, inject, BindingEngine, observable, customElement, processContent, TargetInstruction } from 'aurelia-framework';
import {computedFrom } from 'aurelia-framework';
import {AlertService} from './../../services/alert-service';
import moment from 'moment';


@inject(AlertService, BindingEngine)
export class FooterAlertsCustomElement {


  static messagesAcknCount = 0;
  alertStackViewState = 'closed'; // opened, opening, closing
  topAlertState = 'passiv'; // transit

  constructor(alertService, bindingEngine) {
    this.alertService = alertService;
    this.bindingEngine = bindingEngine;
  }

  attached() {
    this.observeData();
  }

  observeData() {
    if (this.subscription) {
      this.subscription.dispose();
    }
    this.subscription = this.bindingEngine
      .expressionObserver(this, 'alertService._alertMessages.length')
      //.collectionObserver(this.alertService._alertMessages)
      //.subscribe(splices => {
      //  this.dataChanged(splices);
      //});
      .subscribe((newValue, oldValue) => {
        this.dataChanged(newValue, oldValue)
      });
  }

  detached() {
    if (this.subscription) {
      this.subscription.dispose();
    }
  }

  // dataChanged(splices) {
  //   //console.debug("dataChanged", splices);
  //   this.topAlertState = 'transit';
  //
  //   setInterval(() => {
  //     this.topAlertState = 'passiv';
  //   }, 10000);
  // }

    dataChanged(newValue, oldValue) {
      if (newValue != oldValue) {
        this.topAlertState = 'passiv';
        this.topAlertState = 'transit';

        setTimeout(() => {
          this.topAlertState = 'passiv';
        }, 5000);
      }
    }


  @computedFrom('alertService._alertMessages.length')
  get alertMessages() {
    return this.alertService._alertMessages;
  }

  @computedFrom('alertService._alertMessages.length', 'staticMessagesAcknCount', 'alertStackViewState')
  get notReadMessagesCount() {
    if (this.alertStackViewState == 'opened'){
      return 0;
    }

    return this.alertService._alertMessages.length >= FooterAlertsCustomElement.messagesAcknCount ? this.alertService._alertMessages.length - FooterAlertsCustomElement.messagesAcknCount : this.alertService._alertMessages.length;
  }

  get staticMessagesAcknCount() {
    return FooterAlertsCustomElement.messagesAcknCount;
  }

  @computedFrom('alertService._alertMessages.length')
  get topMessage() {
    return this.alertService._alertMessages[0];
  }

  toggleAlertStackPanel (){
    if (this.alertStackViewState == 'closed'){

      this.alertStackViewState = 'opened';
      FooterAlertsCustomElement.messagesAcknCount = this.alertService._alertMessages.length;
    }
    else if (this.alertStackViewState == 'opened'){

      this.alertStackViewState = 'closed';
      FooterAlertsCustomElement.messagesAcknCount = this.alertService._alertMessages.length;
    }
  }

  @computedFrom('alertStackViewState')
  get alertPanelClass() {
    if (this.alertStackViewState == 'closed')
      return "notifications-scroll-area d-none";
    else if (this.alertStackViewState == 'opened')
      return "notifications-scroll-area";
    else
      return "hidden";
  }


  // bind(bindingContext) {
  //   this.$parent = bindingContext;
  // }
}


import {CRUD} from "../common/crud";
import {validateTrigger, ValidationControllerFactory, ValidationRules} from 'aurelia-validation';
import {inject} from 'aurelia-framework';
import {BootstrapFormValidationRenderer} from '../resources/elements/bootstrap-form-validation-renderer';

import {EventAggregator} from 'aurelia-event-aggregator';
import {IdentityService} from '../services/identity-service';
import {ChaincodeService} from '../services/chaincode-service';

import 'cleave.js';


@inject(IdentityService, EventAggregator, ChaincodeService, ValidationControllerFactory)
export class Home extends CRUD {
  orgList = [];
  channelList = [];
  discountValidationController = null;
  discountRules_Validate;
  fractionsDigits = 0;
  operationsHistory = [];
  constructor(identityService, eventAggregator, chaincodeService, factory) {
    super(identityService, eventAggregator, chaincodeService);
    this.discountValidationController = factory.createForCurrentScope();
    this.discountValidationController.validateTrigger = validateTrigger.manual;
    this.discountValidationController.addRenderer(new BootstrapFormValidationRenderer());

    this.setupValidation();
  }

  setupValidation() {

    ValidationRules.customRule(
      'greater_zero',
      (value, obj) => {
        if (!value) {
          return true
        }
        return value > 0;
      },
      `\${$displayName} has to be greater than zero.`
    );

    ValidationRules.customRule(
      'greater_balance',
      (value, obj) => {
        if (!value) {
          return true
        }
        return this.organizationAccount.value.amount >= value;
      },
      `\${$displayName} to transfer can't be greater than balance.`
    );

    this.discountRules_Validate = ValidationRules
      .ensure(p => p.amount)
      .displayName('Amount')
      .required()
      .satisfiesRule('greater_zero')
      .satisfiesRule('greater_balance')
      .rules;
  }

  attached() {
    let decinpopt = {
      numeral: true,
      numeralDecimalScale: this.fractionsDigits,
      numeralIntegerScale: 10,
      numeralPositiveOnly: true,
      delimiter: ''
    };
    var amount = new Cleave('#amount', decinpopt);

    this.queryAll();
    this.subscriberBlock = this.eventAggregator.subscribe('block', () => {
      this.queryAll();
    });

    return super.attached()
  }

  detached() {
    this.subscriberBlock.dispose();
  }

  queryAll() {
    this.amount = undefined;
    return Promise.all([
      this.queryOrgs(),
      this.queryChannels(),
      this.queryOrganizations(),
      this.getOrganizationAccount(),
      this.getHistoryOperationsList()
    ])
  }


  queryOrgs() {
    this.chaincodeService.getOrgs('common').then(orgs => {
      this.orgList = [];
      orgs.forEach(k => {
        let orgName = k.id;
        if (!orgName.startsWith('raft') && !orgName.startsWith('orderer') && orgName !== this.identityService.org) {
          this.orgList.push({key: orgName, value: orgName});
        }

      });
    });
  }

  queryChannels() {
    this.chaincodeService.getChannels().then(channels => {
      this.channelList = channels;
    });
  }

  transfer(receiver, amount) {
    this.discountValidationController.reset();
    try {
      this.discountValidationController.validate({object: {"amount": amount}, rules: this.discountRules_Validate})
        .then(result => {
          if (result.valid) {
            return this.chaincodeService.invoke(this.channel, this.chaincode, "transfer", [this.identityService.org, receiver, amount])
          }
        });
    } catch (ex) {
      console.debug(ex);
    }

  }

  queryOrganizations() {
    return this.chaincodeService.query(this.channel, this.chaincode, 'listOrganizations', [])
  }

  getOrganizationAccount() {
    this.chaincodeService.query(this.channel, this.chaincode, 'getOrganizationAccount', []).then(account => {
      this.organizationAccount = account;
    })
  }

  getHistoryOperationsList() {
    this.chaincodeService.query(this.channel, this.chaincode, 'listOperationsHistory', []).then(o => {
      const a = o || [];
      this['operationHistoryList'] = a.map(e => {
        e.id = e.key;
        return e;
      });
    });
  }

  getTokens() {
    return this.chaincodeService.invoke(this.channel, this.chaincode, "getTokens", ["1000000"])
  }

  queryOperationHistory() {
    let x = this.queryAll();
    return new Promise((resolve, reject) => {
      this.queryAll()
        .then(ret => {
          resolve(this.operationHistoryList);
        })
        .catch(err => {
          reject(err);
        });
    });
  }
}

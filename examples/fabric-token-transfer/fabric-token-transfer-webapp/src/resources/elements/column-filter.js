import {noView, children, child, bindable, inject, BindingEngine, customElement, processContent, TargetInstruction } from 'aurelia-framework';

@noView
export class ColumnFilter {
  @bindable viewtype = 'text'; // 'download', 'key', 'datetime'

  @bindable active = true;
  @bindable filter_options = undefined;

  // get storeKey () {
  //   return this.field ? (this.field + '-' + this.resourcekey) : '.-' + this.resourcekey;
  // }

}

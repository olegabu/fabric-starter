import {containerless, child, children, bindable, inject, BindingEngine, customElement, processContent, TargetInstruction } from 'aurelia-framework';

export class WidgetMultiselListCustomElement {
  @bindable options = [];
  @bindable selectedChangeCallback = null;
  //@bindable getOptions = null;
  @bindable onReadError = null;

  @bindable fixHeight = null;

  loading = false;

  dismissFormClicked ($event){
    console.log('dismissFormClicked');

    if (this.dismissFormCallback)
      this.dismissFormCallback();
  }

  optionClicked ($o){
    $o.selected = !$o.selected;

    if (this.selectedChangeCallback != null){
      this.selectedChangeCallback({data: this.options.filter (x=>x.selected)});
    }
  }

}


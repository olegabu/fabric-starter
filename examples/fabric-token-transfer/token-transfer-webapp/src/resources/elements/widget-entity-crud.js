import {
  containerless,
  child,
  children,
  bindable,
  inject,
  BindingEngine,
  customElement,
  processContent,
  TargetInstruction
} from 'aurelia-framework';

export class WidgetEntityCrudCustomElement {
  @bindable showForm = false;
  @bindable showViewOnly = false;
  @bindable entityTitle = null;

  @bindable buttonAVisible = true;
  @bindable buttonAName = "save";
  @bindable buttonACallback = null;

  @bindable buttonBVisible = false;
  @bindable buttonBName = "cancel";
  @bindable buttonBCallback = null;

  @bindable buttonCVisible = false;
  @bindable buttonCName = "delete";
  @bindable buttonCCallback = null;

  @bindable backActionCallback = null;

  backAction($event) {
    if (this.backActionCallback)
      this.backActionCallback();
  }

  buttonAClicked() {
    if (this.buttonACallback)
      this.buttonACallback();
  }

  buttonBClicked($event) {
    if (this.buttonBCallback)
      this.buttonBCallback();
  }

  buttonCClicked($event) {
    if (this.buttonCCallback)
      this.buttonCCallback();
  }

  // bind(bindingContext) {
  //   this.$parent = bindingContext;
  // }
}


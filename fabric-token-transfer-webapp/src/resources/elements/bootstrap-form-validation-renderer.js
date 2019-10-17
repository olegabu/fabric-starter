import {
  ValidationRenderer,
  RenderInstruction,
  ValidateResult
} from 'aurelia-validation';

export class BootstrapFormValidationRenderer {

  render(instruction) {
    // console.log("================== BootstrapFormRenderer =================");
    // console.log(instruction);

    for (let { result, elements } of instruction.unrender) {
      if (!elements || elements.length === 0)
        elements = this.lookupElementsByName(result.propertyName);

      for (let element of elements) {
        this.remove(element, result);
      }
    }

    for (let { result, elements } of instruction.render) {
      // console.log("========== add ==============");
      // console.log(elements);
      if (!elements || elements.length === 0)
        elements = this.lookupElementsByName(result.propertyName);

      for (let element of elements) {
        this.add(element, result);
      }
    }
  }

  lookupElementsByName(name){
    // console.log("========== lookupElementsByName ==============");
    // console.log(name);
    return document.getElementsByName(name);
  }

  add(element, result) {
    if (result.valid) {
      return;
    }

    const formGroup = element.closest('.form-group');
    if (!formGroup) {
      return;
    }


    const formControl = formGroup.querySelector('.form-control');
    if (!formControl) {
      return;
    }

    formControl.classList.add('is-invalid');

    const message = document.createElement('span');
    message.className = 'invalid-feedback';
    message.textContent = result.message;
    message.style = "display: unset";
    message.id = `validation-message-${result.id}`;

    const inputGroup = element.closest('.input-group');
    if (!inputGroup) {
      return;
    }
    inputGroup.appendChild(message);
  }

  remove(element, result) {
    if (result.valid) {
      return;
    }

    const formGroup = element.closest('.form-group');
    if (!formGroup) {
      return;
    }

    const formControl = formGroup.querySelector('.form-control');
    if (!formControl) {
      return;
    }


    const message = element.parentElement.querySelector(`#validation-message-${result.id}`);

    if (message) {
      message.parentElement.removeChild(message);

      if (formControl.parentElement.querySelectorAll('.invalid-feedback').length === 0) {
        formControl.classList.remove('is-invalid');
      }
    }
  }
}

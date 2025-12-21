import { Controller } from '@hotwired/stimulus';

/**
 * Form Validation Controller
 *
 * Validates form inputs and enables/disables submit button
 */
export default class extends Controller<HTMLElement> {
  static targets = ['form', 'submit'];

  declare readonly formTarget: HTMLFormElement;
  declare readonly submitTargets: HTMLButtonElement[];

  connect() {
    this.validate();
    // フォーム内の入力イベントを監視
    this.formTarget.addEventListener('input', this.validate.bind(this));
    this.formTarget.addEventListener('change', this.validate.bind(this));
  }

  disconnect() {
    this.formTarget.removeEventListener('input', this.validate.bind(this));
    this.formTarget.removeEventListener('change', this.validate.bind(this));
  }

  validate() {
    const form = this.formTarget;
    if (!form) return;

    const isValid = form.checkValidity();
    this.submitTargets.forEach((target) => {
      if (target.type === 'submit') {
        target.disabled = !isValid;
      } else {
        // type="button"の場合は、disabled属性を設定し、pointer-eventsで制御
        if (!isValid) {
          target.setAttribute('disabled', 'disabled');
        } else {
          target.removeAttribute('disabled');
        }
      }
    });
  }
}


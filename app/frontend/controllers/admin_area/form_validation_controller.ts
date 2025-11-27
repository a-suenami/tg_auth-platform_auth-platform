import { Controller } from '@hotwired/stimulus';

/**
 * Form Validation Controller
 *
 * Validates form inputs and enables/disables submit button
 */
export default class extends Controller<HTMLElement> {
  static targets = ['form', 'submit'];

  declare readonly formTarget: HTMLFormElement;
  declare readonly submitTarget: HTMLButtonElement;

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
    if (this.submitTarget) {
      this.submitTarget.disabled = !isValid;
    }
  }
}


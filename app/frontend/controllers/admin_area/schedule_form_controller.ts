import { Controller } from '@hotwired/stimulus';

/**
 * Schedule Form Controller
 *
 * Stores local datetime and converts to UTC on submit
 */
export default class extends Controller {
  static targets = ['input'];

  declare readonly inputTarget: HTMLInputElement;
  private hiddenInput: HTMLInputElement | null = null;

  connect() {
    // Create hidden input for UTC value
    this.hiddenInput = document.createElement('input');
    this.hiddenInput.type = 'hidden';
    this.hiddenInput.name = 'public_started_at';
    this.element.appendChild(this.hiddenInput);

    // Remove name from visible input to prevent it from being submitted
    this.inputTarget.removeAttribute('name');
    this.inputTarget.setAttribute('data-local-input', 'true');

    // Convert on change
    this.inputTarget.addEventListener('change', this.convertToUTC.bind(this));

    // Also convert on submit (in case user doesn't trigger change)
    this.element.addEventListener('submit', this.handleSubmit.bind(this));
  }

  convertToUTC() {
    const value = this.inputTarget.value;
    if (!value || value.trim() === '') {
      if (this.hiddenInput) this.hiddenInput.value = '';
      return;
    }

    try {
      const localDate = new Date(value);
      if (!isNaN(localDate.getTime()) && this.hiddenInput) {
        this.hiddenInput.value = localDate.toISOString();
        console.log('Converted to UTC:', this.hiddenInput.value);
      }
    } catch (error) {
      console.error('Failed to convert datetime:', error);
    }
  }

  handleSubmit(event: Event) {
    // Make sure conversion happened
    this.convertToUTC();

    const utcValue = this.hiddenInput?.value;

    // Validate
    if (!utcValue || utcValue.trim() === '') {
      event.preventDefault();
      alert('公開予定日時を入力してください');
      return;
    }

    console.log('Submitting UTC value:', utcValue);
  }
}

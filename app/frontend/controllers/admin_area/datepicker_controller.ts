import { Controller } from '@hotwired/stimulus';

/**
 * Datepicker Controller
 *
 * Manages date selection in the datepicker modal.
 */
export default class extends Controller {
  static targets = ['year', 'month', 'day', 'dateValue'];

  declare readonly yearTarget: HTMLSelectElement;
  declare readonly monthTarget: HTMLSelectElement;
  declare readonly dayTarget: HTMLSelectElement;
  declare readonly dateValueTarget: HTMLInputElement;

  connect() {
    // Set default values to today
    const today = new Date();
    this.yearTarget.value = today.getFullYear().toString();
    this.monthTarget.value = (today.getMonth() + 1).toString();
    this.dayTarget.value = today.getDate().toString();
    this.updateDate();
  }

  updateDate() {
    const year = this.yearTarget.value;
    const month = this.monthTarget.value.padStart(2, '0');
    const day = this.dayTarget.value.padStart(2, '0');
    const dateStr = `${year}-${month}-${day}`;
    this.dateValueTarget.value = dateStr;
  }
}


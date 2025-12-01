import { Controller } from '@hotwired/stimulus';

/**
 * Period Settings Controller
 *
 * Manages period settings dropdown and shows/hides additional form fields based on selection.
 */
export default class extends Controller {
  static targets = ['select', 'content', 'relative', 'fixed', 'text'];

  declare readonly selectTarget: HTMLSelectElement;
  declare readonly contentTarget: HTMLElement;
  declare readonly relativeTarget: HTMLElement;
  declare readonly fixedTarget: HTMLElement;
  declare readonly textTarget: HTMLElement;

  connect() {
    this.handleChange();
  }

  handleChange() {
    const value = this.selectTarget.value;
    const selectedOption = this.selectTarget.options[this.selectTarget.selectedIndex];

    // Update display text
    this.textTarget.textContent = selectedOption.textContent || '期間を設定する';

    // Hide all content sections first
    this.contentTarget.style.display = 'none';
    this.relativeTarget.style.display = 'none';
    this.fixedTarget.style.display = 'none';

    // Show appropriate section based on selection
    if (value === 'relative') {
      this.contentTarget.style.display = 'block';
      this.relativeTarget.style.display = 'block';
    } else if (value === 'fixed') {
      this.contentTarget.style.display = 'block';
      this.fixedTarget.style.display = 'block';
    }
  }
}


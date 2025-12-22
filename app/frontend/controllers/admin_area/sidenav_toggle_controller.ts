import { Controller } from '@hotwired/stimulus';

/**
 * Sidenav Toggle Controller
 *
 * Toggles the visibility of the side navigation menu.
 * When toggled, the menu slides out to the left while maintaining its width.
 */
export default class extends Controller {
  private pageContent: HTMLElement | null = null;

  connect() {
    // Find the page content element
    this.pageContent = this.element.closest('.l-page')?.querySelector('.l-page-content') as HTMLElement | null;
  }

  toggle() {
    if (this.pageContent) {
      this.pageContent.classList.toggle('is-sidenav-hidden');
    }
  }
}


import { Controller } from '@hotwired/stimulus';

/**
 * User Tag Assignment Form Controller
 *
 * Manages the chip-based UI for adding/removing manual tags to users.
 * Uses AJAX POST/DELETE for individual tag operations (no form submit).
 *
 * Routes:
 * - POST   /admin/users/:user_id/tags     → create (add tag)
 * - DELETE /admin/users/:user_id/tags/:tag_id → destroy (remove tag)
 * - GET    /admin/users/:user_id/tags/history → tag_history (turbo frame)
 */
export default class extends Controller {
  static targets = ['container', 'selector', 'placeholder', 'history'];
  static values = {
    baseUrl: String,
  };

  declare readonly containerTarget: HTMLElement;
  declare readonly selectorTarget: HTMLSelectElement;
  declare readonly hasPlaceholderTarget: boolean;
  declare readonly placeholderTarget: HTMLElement;
  declare readonly hasHistoryTarget: boolean;
  declare readonly historyTarget: HTMLElement;
  declare baseUrlValue: string;

  /**
   * Add tag from dropdown selection via AJAX POST
   */
  async addTag() {
    const tagId = this.selectorTarget.value;
    const selectedOption = this.selectorTarget.options[this.selectorTarget.selectedIndex];
    const tagName = selectedOption.dataset.name;

    if (!tagId) return;

    try {
      const response = await fetch(this.baseUrlValue, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.csrfToken(),
        },
        body: JSON.stringify({ tag_id: tagId }),
      });

      if (!response.ok) {
        const data = await response.json();
        alert(data.error || 'タグの追加に失敗しました');
        return;
      }

      // Hide placeholder if exists
      if (this.hasPlaceholderTarget) {
        this.placeholderTarget.style.display = 'none';
      }

      // Create chip element
      const chip = this.createChip(tagId, tagName || '');
      this.containerTarget.appendChild(chip);

      // Remove from dropdown
      selectedOption.remove();
      this.selectorTarget.value = '';

      // Re-initialize UIkit icons
      this.initializeIcon(chip);

      // Reload tag history
      this.reloadHistory();
    } catch (error) {
      console.error('Failed to add tag:', error);
      alert('タグの追加に失敗しました');
    }
  }

  /**
   * Remove tag chip via AJAX DELETE
   */
  async removeTag(event: Event) {
    const chip = (event.target as HTMLElement).closest('.tag-chip');
    if (!chip) return;

    const tagId = chip.getAttribute('data-tag-id');
    const tagName = chip.getAttribute('data-tag-name');

    if (!tagId || !tagName) return;

    try {
      const response = await fetch(`${this.baseUrlValue}/${tagId}`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': this.csrfToken(),
        },
      });

      if (!response.ok) {
        const data = await response.json();
        alert(data.error || 'タグの削除に失敗しました');
        return;
      }

      // Remove chip
      chip.remove();

      // Add back to dropdown
      this.addOptionToDropdown(tagId, tagName);

      // Show placeholder if no tags
      this.updatePlaceholderVisibility();

      // Reload tag history
      this.reloadHistory();
    } catch (error) {
      console.error('Failed to remove tag:', error);
      alert('タグの削除に失敗しました');
    }
  }

  /**
   * Get CSRF token from meta tag
   */
  private csrfToken(): string {
    const meta = document.querySelector('meta[name="csrf-token"]');
    return meta?.getAttribute('content') || '';
  }

  /**
   * Create a chip element
   */
  private createChip(tagId: string, tagName: string): HTMLElement {
    const chip = document.createElement('span');
    chip.className = 'uk-label uk-margin-small-right tag-chip';
    chip.setAttribute('data-tag-id', tagId);
    chip.setAttribute('data-tag-name', tagName);
    chip.setAttribute('data-action', 'click->user-tag-assignment-form#removeTag');
    chip.style.cursor = 'pointer';
    chip.innerHTML = `${tagName} <span uk-icon="icon: close; ratio: 0.8"></span>`;

    return chip;
  }

  /**
   * Add option back to dropdown and sort alphabetically
   */
  private addOptionToDropdown(tagId: string, tagName: string) {
    const option = document.createElement('option');
    option.value = tagId;
    option.setAttribute('data-name', tagName);
    option.textContent = tagName;
    this.selectorTarget.appendChild(option);

    // Sort options alphabetically (skip first placeholder option)
    const options = Array.from(this.selectorTarget.options).slice(1);
    options.sort((a, b) => a.text.localeCompare(b.text));
    options.forEach((opt) => this.selectorTarget.appendChild(opt));
  }

  /**
   * Show/hide placeholder based on chip count
   */
  private updatePlaceholderVisibility() {
    if (!this.hasPlaceholderTarget) return;

    const hasChips = this.containerTarget.querySelectorAll('.tag-chip').length > 0;
    this.placeholderTarget.style.display = hasChips ? 'none' : 'inline';
  }

  /**
   * Initialize UIkit icon component
   */
  private initializeIcon(element: HTMLElement) {
    const iconElement = element.querySelector('[uk-icon]');
    if (iconElement && (window as any).UIkit) {
      (window as any).UIkit.icon(iconElement);
    }
  }

  /**
   * Reload tag history turbo frame
   */
  private async reloadHistory() {
    if (!this.hasHistoryTarget) return;

    const historyUrl = `${this.baseUrlValue}/history`;

    try {
      const response = await fetch(historyUrl, {
        headers: {
          Accept: 'text/html',
          'X-CSRF-Token': this.csrfToken(),
        },
      });

      if (response.ok) {
        const html = await response.text();
        // Replace the turbo-frame content
        this.historyTarget.outerHTML = html;
      }
    } catch (error) {
      console.error('Failed to reload history:', error);
    }
  }
}

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
    // Support both .tag-chip (old style) and .c-user-detail-tag__item (modal style)
    const chip = (event.target as HTMLElement).closest('.tag-chip') ||
                 (event.target as HTMLElement).closest('.c-user-detail-tag__item');
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
    // Check if we're in a modal (has .c-user-detail-tag__list parent)
    const container = this.containerTarget;
    const isModal = container.classList.contains('c-user-detail-tag__list');

    if (isModal) {
      // Modal style: use c-user-detail-tag__item structure
      const chip = document.createElement('div');
      chip.className = 'c-user-detail-tag__item tag-chip';
      chip.setAttribute('data-tag-id', tagId);
      chip.setAttribute('data-tag-name', tagName);

      const closeIcon = `<svg width="12" height="12" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M0.283203 15.2539C0.166016 15.1432 0.0878906 15.013 0.0488281 14.8633C0.016276 14.7135 0.0195312 14.5638 0.0585938 14.4141C0.0976562 14.2643 0.172526 14.1341 0.283203 14.0234L6.5332 7.76367L0.283203 1.51367C0.172526 1.40299 0.0976562 1.27279 0.0585938 1.12305C0.0260417 0.973307 0.0260417 0.823568 0.0585938 0.673828C0.0976562 0.524089 0.172526 0.39388 0.283203 0.283203C0.39388 0.166016 0.524089 0.0911458 0.673828 0.0585938C0.823568 0.0195312 0.973307 0.0195312 1.12305 0.0585938C1.2793 0.0911458 1.41276 0.166016 1.52344 0.283203L7.77344 6.5332L14.0234 0.283203C14.1341 0.166016 14.2643 0.0911458 14.4141 0.0585938C14.5638 0.0195312 14.7135 0.0195312 14.8633 0.0585938C15.013 0.0911458 15.1465 0.166016 15.2637 0.283203C15.3743 0.39388 15.4492 0.524089 15.4883 0.673828C15.5273 0.823568 15.5273 0.973307 15.4883 1.12305C15.4492 1.27279 15.3743 1.40299 15.2637 1.51367L9.01367 7.76367L15.2637 14.0234C15.3743 14.1341 15.446 14.2643 15.4785 14.4141C15.5176 14.5638 15.5176 14.7135 15.4785 14.8633C15.446 15.013 15.3743 15.1432 15.2637 15.2539C15.153 15.3711 15.0195 15.446 14.8633 15.4785C14.7135 15.5176 14.5638 15.5176 14.4141 15.4785C14.2643 15.4395 14.1341 15.3646 14.0234 15.2539L7.77344 9.00391L1.52344 15.2539C1.41276 15.3646 1.28255 15.4395 1.13281 15.4785C0.983073 15.5176 0.833333 15.5176 0.683594 15.4785C0.533854 15.4395 0.400391 15.3646 0.283203 15.2539Z" fill="currentColor"/></svg>`;
      chip.innerHTML = `
        <span class="c-user-detail-tag__item__text">${tagName}</span>
        <a href="#" class="c-user-detail-tag__item__remove" data-action="click->user-tag-assignment-form#removeTag" aria-label="タグを削除">
          ${closeIcon}
        </a>
      `;
      return chip;
    } else {
      // Old style: use uk-label
      const chip = document.createElement('span');
      chip.className = 'uk-label uk-margin-small-right tag-chip';
      chip.setAttribute('data-tag-id', tagId);
      chip.setAttribute('data-tag-name', tagName);
      chip.setAttribute('data-action', 'click->user-tag-assignment-form#removeTag');
      chip.style.cursor = 'pointer';
      chip.innerHTML = `${tagName} <span uk-icon="icon: close; ratio: 0.8"></span>`;
      return chip;
    }
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

    // Support both .tag-chip (old style) and .c-user-detail-tag__item.tag-chip (modal style)
    const hasChips = this.containerTarget.querySelectorAll('.tag-chip').length > 0;
    this.placeholderTarget.style.display = hasChips ? 'none' : 'block';
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

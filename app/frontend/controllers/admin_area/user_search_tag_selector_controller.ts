import { Controller } from "@hotwired/stimulus";

/**
 * User Search Tag Selector Controller
 *
 * Manages the chip-based UI for selecting tags in user search filter.
 *
 * Features:
 * - Display selected tags as chips with remove button
 * - Dropdown to add new tags
 * - Dynamic add/remove with automatic dropdown updates
 * - Hidden inputs for form submission
 */
export default class extends Controller {
  static targets = ["container", "selector", "placeholder"];

  declare readonly containerTarget: HTMLElement;
  declare readonly selectorTarget: HTMLSelectElement;
  declare readonly hasPlaceholderTarget: boolean;
  declare readonly placeholderTarget: HTMLElement;

  /**
   * Add tag from dropdown selection
   */
  addTag() {
    const tagId = this.selectorTarget.value;
    const selectedOption =
      this.selectorTarget.options[this.selectorTarget.selectedIndex];
    const tagName = selectedOption.dataset.name;

    if (!tagId) return;

    // Hide placeholder if exists
    if (this.hasPlaceholderTarget) {
      this.placeholderTarget.style.display = "none";
    }

    // Create chip element
    const chip = this.createChip(tagId, tagName || "");
    this.containerTarget.appendChild(chip);

    // Remove from dropdown
    selectedOption.remove();
    this.selectorTarget.value = "";

    // Re-initialize UIkit icons
    this.initializeIcon(chip);
  }

  /**
   * Remove tag chip and restore to dropdown
   */
  removeTag(event: Event) {
    const chip = (event.target as HTMLElement).closest(".tag-chip");
    if (!chip) return;

    const tagId = chip.getAttribute("data-tag-id");
    const tagName = chip.getAttribute("data-tag-name");

    if (!tagId || !tagName) return;

    // Remove chip
    chip.remove();

    // Add back to dropdown
    this.addOptionToDropdown(tagId, tagName);

    // Show placeholder if no tags
    this.updatePlaceholderVisibility();
  }

  /**
   * Check if we're in v202601 UI (new design)
   */
  private isNewUI(): boolean {
    return this.containerTarget.classList.contains("c-user-detail-tag__list");
  }

  /**
   * Create a chip element with hidden input
   */
  private createChip(tagId: string, tagName: string): HTMLElement {
    const chip = document.createElement("div");
    chip.setAttribute("data-tag-id", tagId);
    chip.setAttribute("data-tag-name", tagName);

    if (this.isNewUI()) {
      // v202601 styling
      chip.className = "c-user-detail-tag__item tag-chip";
      chip.innerHTML = `
        <span class="c-user-detail-tag__item__text">${tagName}</span>
        <a href="#" class="c-user-detail-tag__item__remove" data-action="click->user-search-tag-selector#removeTag">
          <svg class="c-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <line x1="18" y1="6" x2="6" y2="18"></line>
            <line x1="6" y1="6" x2="18" y2="18"></line>
          </svg>
        </a>
      `;
    } else {
      // Old UI styling (UIkit)
      chip.className = "uk-label uk-label-primary uk-margin-small-right tag-chip";
      chip.style.cursor = "pointer";
      chip.innerHTML = `${tagName} <span uk-icon="icon: close; ratio: 0.8"></span>`;
    }

    // Create hidden input for form submission
    const input = document.createElement("input");
    input.type = "hidden";
    input.name = "tag_ids[]";
    input.value = tagId;
    input.id = `search_tag_${tagId}`;
    chip.appendChild(input);

    return chip;
  }

  /**
   * Add option back to dropdown and sort alphabetically
   */
  private addOptionToDropdown(tagId: string, tagName: string) {
    const option = document.createElement("option");
    option.value = tagId;
    option.setAttribute("data-name", tagName);
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

    const hasChips =
      this.containerTarget.querySelectorAll(".tag-chip").length > 0;
    this.placeholderTarget.style.display = hasChips ? "none" : "inline";
  }

  /**
   * Initialize UIkit icon component
   */
  private initializeIcon(element: HTMLElement) {
    const iconElement = element.querySelector("[uk-icon]");
    if (iconElement && (window as unknown as { UIkit?: { icon: (el: Element) => void } }).UIkit) {
      (window as unknown as { UIkit: { icon: (el: Element) => void } }).UIkit.icon(iconElement);
    }
  }
}

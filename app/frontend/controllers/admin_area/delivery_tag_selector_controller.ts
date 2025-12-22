import { Controller } from "@hotwired/stimulus";

/**
 * Delivery Tag Selector Controller
 *
 * Manages the chip-based UI for selecting user tags in delivery forms.
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
    event.preventDefault();
    event.stopPropagation();

    const target = event.target as HTMLElement;
    const chip = target.closest(".tag-chip") as HTMLElement | null;
    if (!chip) return;

    const tagId = chip.getAttribute("data-tag-id");
    const tagName = chip.getAttribute("data-tag-name");

    if (!tagId || !tagName) return;

    // Remove hidden input (now sibling of chip)
    const hiddenInput = this.containerTarget.parentElement?.querySelector(
      `input[type="hidden"][data-tag-id="${tagId}"]`
    );
    if (hiddenInput) {
      hiddenInput.remove();
    }

    // Remove chip
    chip.remove();

    // Add back to dropdown
    this.addOptionToDropdown(tagId, tagName);

    // Show placeholder if no tags
    this.updatePlaceholderVisibility();
  }

  /**
   * Create a chip element and hidden input (as siblings)
   */
  private createChip(tagId: string, tagName: string): HTMLElement {
    const chip = document.createElement("span");
    chip.className = "uk-label uk-label-primary uk-margin-small-right tag-chip";
    chip.setAttribute("data-tag-id", tagId);
    chip.setAttribute("data-tag-name", tagName);
    chip.setAttribute("data-action", "click->delivery-tag-selector#removeTag");
    chip.style.cursor = "pointer";
    chip.innerHTML = `${tagName} <span uk-icon="icon: close; ratio: 0.8"></span>`;

    // Create hidden input as sibling (in parent container)
    const input = document.createElement("input");
    input.type = "hidden";
    input.name = "delivery[user_tag_ids][]";
    input.value = tagId;
    input.id = `delivery_user_tag_${tagId}`;
    input.setAttribute("data-tag-id", tagId);

    // Insert hidden input in the form (parent of container)
    const form = this.containerTarget.closest("form");
    if (form) {
      form.appendChild(input);
    }

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
    if (iconElement && (window as any).UIkit) {
      (window as any).UIkit.icon(iconElement);
    }
  }
}

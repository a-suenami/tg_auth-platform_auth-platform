import { Controller } from '@hotwired/stimulus';
import { toggleDropdown, closeAllDropdowns, isClickInsideDropdown } from '@app/utils/dropdown';
import { createMoreVerticalIcon } from '@app/utils/icons';
import { conditionFactories } from '@app/utils/condition-factory';

/**
 * Condition Block Controller
 *
 * Manages condition blocks and adding conditions.
 */
export default class extends Controller {
  static targets = ['list', 'dropdown', 'empty'];

  declare readonly listTarget: HTMLElement;
  declare readonly dropdownTarget: HTMLElement;
  declare readonly emptyTarget: HTMLElement;

  connect() {
    // Close dropdown when clicking outside
    document.addEventListener('click', this.handleOutsideClick.bind(this));

    // Initialize select classes for existing selects
    this.initializeSelectClasses();

    // Update empty state visibility
    this.updateEmptyState();
  }

  disconnect() {
    document.removeEventListener('click', this.handleOutsideClick.bind(this));
  }

  toggleDropdown(event: Event) {
    event.preventDefault();
    event.stopPropagation();

    const button = event.currentTarget as HTMLElement;
    const dropdownId = button.getAttribute('data-dropdown-toggle');
    if (!dropdownId) return;

    toggleDropdown(dropdownId);
  }

  addCondition(event: Event) {
    event.preventDefault();
    event.stopPropagation();

    const button = event.currentTarget as HTMLElement;
    const conditionType = button.getAttribute('data-condition-type');
    if (!conditionType) return;

    // Close dropdown
    const dropdown = button.closest('.c-condition-block__add-condition__dropdown') as HTMLElement;
    if (dropdown) {
      closeAllDropdowns();
    }

    // Add condition based on type
    this.createCondition(conditionType);
  }

  private createCondition(type: string) {
    const list = this.listTarget;
    if (!list) return;

    // Create divider if there are existing items
    const existingItems = list.querySelectorAll('.c-condition-block__item');
    if (existingItems.length > 0) {
      const divider = document.createElement('div');
      divider.className = 'c-condition-block__item__divider';
      list.appendChild(divider);
    }

    // Create condition item
    const item = document.createElement('div');
    item.className = 'c-condition-block__item';

    const content = document.createElement('div');
    content.className = 'c-condition-block__item__content';

    // Create content using factory
    const factory = conditionFactories[type];
    if (factory) {
      const contentFragment = factory((select) => this.initializeSelectClass(select));
      content.appendChild(contentFragment);
    } else {
      console.warn(`Unknown condition type: ${type}`);
      return;
    }

    const menuButton = document.createElement('button');
    menuButton.className = 'c-condition-block__item__menu';
    menuButton.type = 'button';
    menuButton.setAttribute('data-dropdown-toggle', `condition-menu-dropdown-${Date.now()}-${Math.random()}`);
    menuButton.setAttribute('data-action', 'click->condition-block#toggleItemMenu');
    // メニューアイコンを追加
    menuButton.appendChild(createMoreVerticalIcon());

    // Create dropdown for condition menu
    const conditionDropdown = document.createElement('div');
    conditionDropdown.className = 'c-condition-block__item__dropdown';
    conditionDropdown.id = menuButton.getAttribute('data-dropdown-toggle') || '';

    const deleteButton = document.createElement('button');
    deleteButton.className = 'c-condition-block__item__dropdown__item';
    deleteButton.type = 'button';
    deleteButton.setAttribute('data-action', 'click->condition-block#removeCondition');
    deleteButton.textContent = '削除';

    conditionDropdown.appendChild(deleteButton);
    item.appendChild(conditionDropdown);

    item.appendChild(content);
    item.appendChild(menuButton);
    list.appendChild(item);

    // Initialize select classes for new selects
    const newSelects = item.querySelectorAll('.c-condition-block__item__pill:is(select)') as NodeListOf<HTMLSelectElement>;
    newSelects.forEach((select) => {
      this.initializeSelectClass(select);
    });

    // Update empty state visibility
    this.updateEmptyState();
  }

  handleSelectChange(event: Event) {
    const select = event.currentTarget as HTMLSelectElement;
    if (!select) return;
    this.initializeSelectClass(select);
  }

  toggleItemMenu(event: Event) {
    event.preventDefault();
    event.stopPropagation();

    const button = event.currentTarget as HTMLElement;
    const dropdownId = button.getAttribute('data-dropdown-toggle');
    if (!dropdownId) return;

    toggleDropdown(dropdownId);
  }

  removeCondition(event: Event) {
    event.preventDefault();
    event.stopPropagation();

    const button = event.currentTarget as HTMLElement;
    const item = button.closest('.c-condition-block__item') as HTMLElement;
    if (!item) return;

    // Remove the item and its divider if it exists
    const divider = item.previousElementSibling;
    if (divider && divider.classList.contains('c-condition-block__item__divider')) {
      divider.remove();
    }
    item.remove();

    // Update empty state
    this.updateEmptyState();
  }

  private initializeSelectClasses() {
    const selects = this.element.querySelectorAll('.c-condition-block__item__pill:is(select)') as NodeListOf<HTMLSelectElement>;
    selects.forEach((select) => {
      this.initializeSelectClass(select);
    });
  }

  private initializeSelectClass(select: HTMLSelectElement) {
    if (!select || select.tagName !== 'SELECT') return;

    const selectedOption = select.options[select.selectedIndex];
    const isEmpty = !selectedOption || !selectedOption.value || selectedOption.value === '';

    if (isEmpty) {
      select.setAttribute('data-unselected', 'true');
    } else {
      select.removeAttribute('data-unselected');
    }
  }

  private updateEmptyState() {
    if (!this.emptyTarget) return;

    const items = this.listTarget.querySelectorAll('.c-condition-block__item');
    if (items.length === 0) {
      this.emptyTarget.style.display = 'flex';
    } else {
      this.emptyTarget.style.display = 'none';
    }
  }

  private handleOutsideClick(event: Event) {
    const target = event.target as HTMLElement;
    const isInside = isClickInsideDropdown(target, [
      '.c-condition-block__add-condition__dropdown',
      '.c-condition-block__item__dropdown',
    ]);

    if (!isInside) {
      closeAllDropdowns();
    }
  }
}


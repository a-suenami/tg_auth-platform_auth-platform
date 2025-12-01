import { Controller } from '@hotwired/stimulus';
import { toggleDropdown, closeAllDropdowns, isClickInsideDropdown } from '@app/utils/dropdown';
import { createMoreVerticalIcon } from '@app/utils/icons';

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

    // Create content based on condition type
    if (type === 'current-membership') {
      const select1 = document.createElement('select');
      select1.className = 'c-condition-block__item__pill';
      const option1 = document.createElement('option');
      option1.value = 'current-membership';
      option1.selected = true;
      option1.textContent = '現在購読中のメンバーシップ';
      select1.appendChild(option1);

      const text = document.createElement('span');
      text.className = 'c-condition-block__item__text';
      text.textContent = 'が';

      const select2 = document.createElement('select');
      select2.className = 'c-condition-block__item__pill';
      select2.setAttribute('data-action', 'change->condition-block#handleSelectChange');
      const option2 = document.createElement('option');
      option2.value = '';
      option2.selected = true;
      option2.textContent = '選択してください';
      select2.appendChild(option2);

      const select3 = document.createElement('select');
      select3.className = 'c-condition-block__item__pill';
      const option3 = document.createElement('option');
      option3.value = 'is';
      option3.selected = true;
      option3.textContent = 'である';
      select3.appendChild(option3);

      content.appendChild(select1);
      content.appendChild(text);
      content.appendChild(select2);
      content.appendChild(select3);

      // Initialize select class
      this.initializeSelectClass(select2);
    } else if (type === 'duration-membership') {
      const select1 = document.createElement('select');
      select1.className = 'c-condition-block__item__pill';
      select1.setAttribute('data-action', 'change->condition-block#handleSelectChange');
      const option1_1 = document.createElement('option');
      option1_1.value = '3';
      option1_1.selected = true;
      option1_1.textContent = '3';
      const option1_2 = document.createElement('option');
      option1_2.value = '1';
      option1_2.textContent = '1';
      const option1_3 = document.createElement('option');
      option1_3.value = '2';
      option1_3.textContent = '2';
      select1.appendChild(option1_1);
      select1.appendChild(option1_2);
      select1.appendChild(option1_3);

      const select2 = document.createElement('select');
      select2.className = 'c-condition-block__item__pill';
      select2.setAttribute('data-action', 'change->condition-block#handleSelectChange');
      const option2_1 = document.createElement('option');
      option2_1.value = 'day';
      option2_1.selected = true;
      option2_1.textContent = '日';
      const option2_2 = document.createElement('option');
      option2_2.value = 'month';
      option2_2.textContent = 'ヶ月';
      const option2_3 = document.createElement('option');
      option2_3.value = 'year';
      option2_3.textContent = '年';
      select2.appendChild(option2_1);
      select2.appendChild(option2_2);
      select2.appendChild(option2_3);

      const select3 = document.createElement('select');
      select3.className = 'c-condition-block__item__pill';
      const option3 = document.createElement('option');
      option3.value = 'duration-membership';
      option3.selected = true;
      option3.textContent = '以上購読中のメンバーシップ';
      select3.appendChild(option3);

      const text = document.createElement('span');
      text.className = 'c-condition-block__item__text';
      text.textContent = 'が';

      const select4 = document.createElement('select');
      select4.className = 'c-condition-block__item__pill';
      select4.setAttribute('data-action', 'change->condition-block#handleSelectChange');
      const option4 = document.createElement('option');
      option4.value = '';
      option4.selected = true;
      option4.textContent = 'Membership A / Membership B';
      select4.appendChild(option4);

      const select5 = document.createElement('select');
      select5.className = 'c-condition-block__item__pill';
      const option5 = document.createElement('option');
      option5.value = 'is';
      option5.selected = true;
      option5.textContent = 'である';
      select5.appendChild(option5);

      content.appendChild(select1);
      content.appendChild(select2);
      content.appendChild(select3);
      content.appendChild(text);
      content.appendChild(select4);
      content.appendChild(select5);

      // Initialize select classes
      this.initializeSelectClass(select1);
      this.initializeSelectClass(select2);
      this.initializeSelectClass(select4);
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


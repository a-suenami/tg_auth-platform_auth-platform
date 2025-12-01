import { Controller } from '@hotwired/stimulus';
import { toggleDropdown, closeAllDropdowns, isClickInsideDropdown } from '@app/utils/dropdown';

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
    // メニューアイコンを追加（既存のアイコンをコピー）
    const existingMenuIcon = document.querySelector('.c-condition-block__item__menu svg');
    if (existingMenuIcon) {
      menuButton.appendChild(existingMenuIcon.cloneNode(true) as SVGElement);
    } else {
      // フォールバック: 3つのドットをSVGで作成
      const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
      svg.setAttribute('width', '4');
      svg.setAttribute('height', '15');
      svg.setAttribute('viewBox', '0 0 4 15');
      svg.setAttribute('fill', 'none');
      svg.setAttribute('xmlns', 'http://www.w3.org/2000/svg');
      const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
      path.setAttribute('d', 'M-1.38306e-07 1.58594C-1.25329e-07 1.28906 0.0703124 1.02083 0.210937 0.78125C0.356771 0.541666 0.549479 0.351562 0.789062 0.210937C1.02865 0.0703121 1.29167 -3.77921e-07 1.57812 -3.654e-07C1.86979 -3.52651e-07 2.13542 0.0703122 2.375 0.210937C2.61458 0.351562 2.80469 0.541666 2.94531 0.78125C3.09115 1.02083 3.16406 1.28906 3.16406 1.58594C3.16406 1.8724 3.09115 2.13542 2.94531 2.375C2.80469 2.61458 2.61458 2.80469 2.375 2.94531C2.13542 3.08594 1.86979 3.15625 1.57812 3.15625C1.29167 3.15625 1.02865 3.08594 0.789062 2.94531C0.549479 2.80469 0.356771 2.61458 0.210937 2.375C0.0703123 2.13542 -1.50827e-07 1.8724 -1.38306e-07 1.58594ZM-3.93402e-07 7.42187C-3.80653e-07 7.13021 0.0703121 6.86458 0.210937 6.625C0.35677 6.38542 0.549479 6.19271 0.789062 6.04687C1.02865 5.90625 1.29167 5.83594 1.57812 5.83594C1.86979 5.83594 2.13542 5.90625 2.375 6.04687C2.61458 6.19271 2.80469 6.38542 2.94531 6.625C3.09115 6.86458 3.16406 7.13021 3.16406 7.42187C3.16406 7.71354 3.09115 7.97656 2.94531 8.21094C2.80469 8.45052 2.61458 8.64062 2.375 8.78125C2.13542 8.92708 1.86979 9 1.57812 9C1.29167 9 1.02865 8.92708 0.789062 8.78125C0.549479 8.64062 0.35677 8.45052 0.210937 8.21094C0.0703121 7.97656 -4.06152e-07 7.71354 -3.93402e-07 7.42187ZM-6.48499e-07 13.2578C-6.3575e-07 12.9661 0.0703119 12.7005 0.210937 12.4609C0.35677 12.2214 0.549479 12.0312 0.789062 11.8906C1.02865 11.75 1.29167 11.6797 1.57812 11.6797C1.86979 11.6797 2.13542 11.75 2.375 11.8906C2.61458 12.0312 2.80469 12.2214 2.94531 12.4609C3.09115 12.7005 3.16406 12.9661 3.16406 13.2578C3.16406 13.5495 3.09115 13.8151 2.94531 14.0547C2.80469 14.2943 2.61458 14.4844 2.375 14.625C2.13542 14.7708 1.86979 14.8437 1.57812 14.8437C1.29167 14.8437 1.02865 14.7708 0.789062 14.625C0.549478 14.4844 0.35677 14.2943 0.210937 14.0547C0.0703118 13.8151 -6.61249e-07 13.5495 -6.48499e-07 13.2578Z');
      path.setAttribute('fill', 'currentColor');
      svg.appendChild(path);
      menuButton.appendChild(svg);
    }

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


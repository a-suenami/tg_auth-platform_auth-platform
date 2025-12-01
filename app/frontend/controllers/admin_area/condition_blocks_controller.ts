import { Controller } from '@hotwired/stimulus';

/**
 * Condition Blocks Controller
 *
 * Manages multiple condition blocks and their empty state.
 */
export default class extends Controller {
  static targets = ['blocks', 'empty'];

  declare readonly blocksTarget: HTMLElement;
  declare readonly emptyTarget: HTMLElement;

  private blockCounter = 0;

  connect() {
    this.updateEmptyState();
    // Count existing blocks
    const existingBlocks = this.blocksTarget.querySelectorAll('.c-condition-block');
    this.blockCounter = existingBlocks.length;

    // Close dropdown when clicking outside
    document.addEventListener('click', this.handleOutsideClick.bind(this));
  }

  disconnect() {
    document.removeEventListener('click', this.handleOutsideClick.bind(this));
  }

  private handleOutsideClick(event: Event) {
    const target = event.target as HTMLElement;
    const dropdown = target.closest('.c-condition-block__header__dropdown');
    const button = target.closest('[data-dropdown-toggle]');

    if (!dropdown && !button) {
      document.querySelectorAll('[data-dropdown-open="true"]').forEach((d) => {
        d.setAttribute('data-dropdown-open', 'false');
      });
    }
  }

  addBlock(event: Event) {
    event.preventDefault();
    event.stopPropagation();

    this.blockCounter++;
    const blockNumber = this.blockCounter;

    // Create condition block
    const block = document.createElement('div');
    block.className = 'c-condition-block';
    block.setAttribute('data-controller', 'condition-block');

    // Create header
    const header = document.createElement('div');
    header.className = 'c-condition-block__header';

    const title = document.createElement('div');
    title.className = 'c-condition-block__title';
    title.textContent = `条件ブロック${blockNumber}`;

    const menuButton = document.createElement('button');
    menuButton.className = 'c-condition-block__header__menu';
    menuButton.type = 'button';
    menuButton.setAttribute('data-dropdown-toggle', `block-menu-dropdown-${blockNumber}`);
    menuButton.setAttribute('data-action', 'click->condition-blocks#toggleBlockMenu');
    // Menu icon SVG
    const menuIcon = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
    menuIcon.setAttribute('width', '4');
    menuIcon.setAttribute('height', '15');
    menuIcon.setAttribute('viewBox', '0 0 4 15');
    menuIcon.setAttribute('fill', 'none');
    menuIcon.setAttribute('xmlns', 'http://www.w3.org/2000/svg');
    const menuPath = document.createElementNS('http://www.w3.org/2000/svg', 'path');
    menuPath.setAttribute('d', 'M-1.38306e-07 1.58594C-1.25329e-07 1.28906 0.0703124 1.02083 0.210937 0.78125C0.356771 0.541666 0.549479 0.351562 0.789062 0.210937C1.02865 0.0703121 1.29167 -3.77921e-07 1.57812 -3.654e-07C1.86979 -3.52651e-07 2.13542 0.0703122 2.375 0.210937C2.61458 0.351562 2.80469 0.541666 2.94531 0.78125C3.09115 1.02083 3.16406 1.28906 3.16406 1.58594C3.16406 1.8724 3.09115 2.13542 2.94531 2.375C2.80469 2.61458 2.61458 2.80469 2.375 2.94531C2.13542 3.08594 1.86979 3.15625 1.57812 3.15625C1.29167 3.15625 1.02865 3.08594 0.789062 2.94531C0.549479 2.80469 0.356771 2.61458 0.210937 2.375C0.0703123 2.13542 -1.50827e-07 1.8724 -1.38306e-07 1.58594ZM-3.93402e-07 7.42187C-3.80653e-07 7.13021 0.0703121 6.86458 0.210937 6.625C0.35677 6.38542 0.549479 6.19271 0.789062 6.04687C1.02865 5.90625 1.29167 5.83594 1.57812 5.83594C1.86979 5.83594 2.13542 5.90625 2.375 6.04687C2.61458 6.19271 2.80469 6.38542 2.94531 6.625C3.09115 6.86458 3.16406 7.13021 3.16406 7.42187C3.16406 7.71354 3.09115 7.97656 2.94531 8.21094C2.80469 8.45052 2.61458 8.64062 2.375 8.78125C2.13542 8.92708 1.86979 9 1.57812 9C1.29167 9 1.02865 8.92708 0.789062 8.78125C0.549479 8.64062 0.35677 8.45052 0.210937 8.21094C0.0703121 7.97656 -4.06152e-07 7.71354 -3.93402e-07 7.42187ZM-6.48499e-07 13.2578C-6.3575e-07 12.9661 0.0703119 12.7005 0.210937 12.4609C0.35677 12.2214 0.549479 12.0312 0.789062 11.8906C1.02865 11.75 1.29167 11.6797 1.57812 11.6797C1.86979 11.6797 2.13542 11.75 2.375 11.8906C2.61458 12.0312 2.80469 12.2214 2.94531 12.4609C3.09115 12.7005 3.16406 12.9661 3.16406 13.2578C3.16406 13.5495 3.09115 13.8151 2.94531 14.0547C2.80469 14.2943 2.61458 14.4844 2.375 14.625C2.13542 14.7708 1.86979 14.8437 1.57812 14.8437C1.29167 14.8437 1.02865 14.7708 0.789062 14.625C0.549478 14.4844 0.35677 14.2943 0.210937 14.0547C0.0703118 13.8151 -6.61249e-07 13.5495 -6.48499e-07 13.2578Z');
    menuPath.setAttribute('fill', 'currentColor');
    menuIcon.appendChild(menuPath);
    menuButton.appendChild(menuIcon);

    // Create dropdown for block menu
    const blockDropdown = document.createElement('div');
    blockDropdown.className = 'c-condition-block__header__dropdown';
    blockDropdown.id = `block-menu-dropdown-${blockNumber}`;

    const deleteButton = document.createElement('button');
    deleteButton.className = 'c-condition-block__header__dropdown__item';
    deleteButton.type = 'button';
    deleteButton.setAttribute('data-action', 'click->condition-blocks#removeBlock');
    deleteButton.textContent = '削除';

    blockDropdown.appendChild(deleteButton);

    header.appendChild(title);
    header.appendChild(menuButton);
    header.appendChild(blockDropdown);

    // Create list
    const list = document.createElement('div');
    list.className = 'c-condition-block__list';
    list.setAttribute('data-condition-block-target', 'list');

    // Create empty state
    const empty = document.createElement('div');
    empty.className = 'c-condition-block__empty';
    empty.setAttribute('data-condition-block-target', 'empty');
    const emptyText = document.createElement('div');
    emptyText.className = 'c-condition-block__empty__text';
    emptyText.textContent = '条件がありません';
    empty.appendChild(emptyText);
    list.appendChild(empty);

    // Create add condition wrapper
    const addConditionWrapper = document.createElement('div');
    addConditionWrapper.className = 'c-condition-block__add-condition-wrapper';

    const addConditionButton = document.createElement('button');
    addConditionButton.className = 'c-condition-block__add-condition';
    addConditionButton.type = 'button';
    addConditionButton.setAttribute('data-dropdown-toggle', `condition-type-dropdown-${blockNumber}`);
    addConditionButton.setAttribute('data-action', 'click->condition-block#toggleDropdown');

    // Plus icon SVG
    const plusIcon = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
    plusIcon.setAttribute('width', '10');
    plusIcon.setAttribute('height', '10');
    plusIcon.setAttribute('viewBox', '0 0 10 10');
    plusIcon.setAttribute('fill', 'none');
    plusIcon.setAttribute('xmlns', 'http://www.w3.org/2000/svg');
    const plusPath = document.createElementNS('http://www.w3.org/2000/svg', 'path');
    plusPath.setAttribute('d', 'M0 4.9043C0 4.72461 0.0644531 4.57031 0.193359 4.44141C0.322266 4.30859 0.476562 4.24219 0.65625 4.24219H4.24805V0.65625C4.24805 0.476562 4.3125 0.322266 4.44141 0.193359C4.57031 0.0644531 4.72461 0 4.9043 0C5.08789 0 5.24414 0.0644531 5.37305 0.193359C5.50195 0.322266 5.56641 0.476562 5.56641 0.65625V4.24219H9.15234C9.33203 4.24219 9.48633 4.30859 9.61523 4.44141C9.74414 4.57031 9.80859 4.72461 9.80859 4.9043C9.80859 5.08789 9.74414 5.24414 9.61523 5.37305C9.48633 5.49805 9.33203 5.56055 9.15234 5.56055H5.56641V9.1582C5.56641 9.33398 5.50195 9.48633 5.37305 9.61523C5.24414 9.74414 5.08789 9.80859 4.9043 9.80859C4.72461 9.80859 4.57031 9.74414 4.44141 9.61523C4.3125 9.48633 4.24805 9.33398 4.24805 9.1582V5.56055H0.65625C0.476562 5.56055 0.322266 5.49805 0.193359 5.37305C0.0644531 5.24414 0 5.08789 0 4.9043Z');
    plusPath.setAttribute('fill', 'currentColor');
    plusIcon.appendChild(plusPath);

    const addConditionText = document.createElement('span');
    addConditionText.className = 'c-condition-block__add-condition__text';
    addConditionText.textContent = '条件を追加';

    addConditionButton.appendChild(plusIcon);
    addConditionButton.appendChild(addConditionText);

    // Create dropdown
    const dropdown = document.createElement('div');
    dropdown.className = 'c-condition-block__add-condition__dropdown';
    dropdown.id = `condition-type-dropdown-${blockNumber}`;

    const dropdownItem1 = document.createElement('button');
    dropdownItem1.className = 'c-condition-block__add-condition__dropdown__item';
    dropdownItem1.type = 'button';
    dropdownItem1.setAttribute('data-condition-type', 'current-membership');
    dropdownItem1.setAttribute('data-action', 'click->condition-block#addCondition');
    dropdownItem1.textContent = '現在購読中のメンバーシップ';

    const dropdownItem2 = document.createElement('button');
    dropdownItem2.className = 'c-condition-block__add-condition__dropdown__item';
    dropdownItem2.type = 'button';
    dropdownItem2.setAttribute('data-condition-type', 'duration-membership');
    dropdownItem2.setAttribute('data-action', 'click->condition-block#addCondition');
    dropdownItem2.textContent = '一定期間以上購読中のメンバーシップ';

    dropdown.appendChild(dropdownItem1);
    dropdown.appendChild(dropdownItem2);

    addConditionWrapper.appendChild(addConditionButton);
    addConditionWrapper.appendChild(dropdown);

    // Assemble block
    block.appendChild(header);
    block.appendChild(list);
    block.appendChild(addConditionWrapper);

    // Add to blocks container
    this.blocksTarget.appendChild(block);

    // Initialize Stimulus controller for the new block
    // Stimulus will automatically connect controllers when elements are added to the DOM
    // Use requestAnimationFrame to ensure DOM is fully updated before Stimulus scans
    requestAnimationFrame(() => {
      const application = (window as any).Stimulus;
      if (application && typeof application.load === 'function') {
        application.load(block);
      }
    });

    // Update empty state
    this.updateEmptyState();
  }

  toggleBlockMenu(event: Event) {
    event.preventDefault();
    event.stopPropagation();

    const button = event.currentTarget as HTMLElement;
    const dropdownId = button.getAttribute('data-dropdown-toggle');
    if (!dropdownId) return;

    const dropdown = document.getElementById(dropdownId) as HTMLElement;
    if (!dropdown) return;

    const isOpen = dropdown.getAttribute('data-dropdown-open') === 'true';

    // Close all dropdowns
    document.querySelectorAll('[data-dropdown-open="true"]').forEach((d) => {
      d.setAttribute('data-dropdown-open', 'false');
    });

    // Toggle this dropdown
    if (!isOpen) {
      dropdown.setAttribute('data-dropdown-open', 'true');
    }
  }

  removeBlock(event: Event) {
    event.preventDefault();
    event.stopPropagation();

    const button = event.currentTarget as HTMLElement;
    const block = button.closest('.c-condition-block') as HTMLElement;
    if (!block) return;

    block.remove();

    // Update empty state
    this.updateEmptyState();
  }

  private updateEmptyState() {
    if (!this.emptyTarget) return;

    const blocks = this.blocksTarget.querySelectorAll('.c-condition-block');
    if (blocks.length === 0) {
      this.emptyTarget.style.display = 'flex';
    } else {
      this.emptyTarget.style.display = 'none';
    }
  }
}


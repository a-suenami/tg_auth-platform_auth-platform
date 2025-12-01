import { Controller } from '@hotwired/stimulus';
import { toggleDropdown } from '@app/utils/dropdown';
import { createMoreVerticalIcon, createPlusIcon } from '@app/utils/icons';
import { DropdownMixin } from './dropdown_mixin';
import { updateEmptyState as updateEmptyStateUtil } from '@app/utils/empty-state';

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
    DropdownMixin.handleOutsideClick(event, [
      '.c-condition-block__header__dropdown',
    ]);
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
    // Menu icon
    menuButton.appendChild(createMoreVerticalIcon());

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

    // Plus icon
    addConditionButton.appendChild(createPlusIcon());

    const addConditionText = document.createElement('span');
    addConditionText.className = 'c-condition-block__add-condition__text';
    addConditionText.textContent = '条件を追加';

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

    toggleDropdown(dropdownId);
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

    updateEmptyStateUtil(
      this.blocksTarget,
      this.emptyTarget,
      '.c-condition-block'
    );
  }
}


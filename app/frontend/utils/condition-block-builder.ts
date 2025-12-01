/**
 * Condition Block Builder
 *
 * Builder class for creating condition block DOM elements.
 */

import { createMoreVerticalIcon, createPlusIcon } from '@app/utils/icons';

/**
 * Builder class for condition blocks.
 * Encapsulates the logic for creating condition block HTML structure.
 */
export class ConditionBlockBuilder {
  /**
   * Builds a complete condition block element.
   *
   * @param blockNumber - Unique number for this block
   * @returns HTMLElement representing the condition block
   */
  static build(blockNumber: number): HTMLElement {
    const block = document.createElement('div');
    block.className = 'c-condition-block';
    block.setAttribute('data-controller', 'condition-block');

    // Create header
    const header = this.buildHeader(blockNumber);
    block.appendChild(header);

    // Create list
    const list = this.buildList();
    block.appendChild(list);

    // Create add condition wrapper
    const addConditionWrapper = this.buildAddConditionWrapper(blockNumber);
    block.appendChild(addConditionWrapper);

    return block;
  }

  /**
   * Builds the header section of a condition block.
   *
   * @param blockNumber - Unique number for this block
   * @returns HTMLElement representing the header
   */
  private static buildHeader(blockNumber: number): HTMLElement {
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
    menuButton.appendChild(createMoreVerticalIcon());

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

    return header;
  }

  /**
   * Builds the list section of a condition block.
   *
   * @returns HTMLElement representing the list
   */
  private static buildList(): HTMLElement {
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

    return list;
  }

  /**
   * Builds the add condition wrapper section.
   *
   * @param blockNumber - Unique number for this block
   * @returns HTMLElement representing the add condition wrapper
   */
  private static buildAddConditionWrapper(blockNumber: number): HTMLElement {
    const addConditionWrapper = document.createElement('div');
    addConditionWrapper.className = 'c-condition-block__add-condition-wrapper';

    const addConditionButton = document.createElement('button');
    addConditionButton.className = 'c-condition-block__add-condition';
    addConditionButton.type = 'button';
    addConditionButton.setAttribute('data-dropdown-toggle', `condition-type-dropdown-${blockNumber}`);
    addConditionButton.setAttribute('data-action', 'click->condition-block#toggleDropdown');

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

    return addConditionWrapper;
  }
}


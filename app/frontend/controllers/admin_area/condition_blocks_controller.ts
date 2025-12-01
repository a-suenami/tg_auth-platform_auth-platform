import { Controller } from '@hotwired/stimulus';
import { toggleDropdown } from '@app/utils/dropdown';
import { DropdownMixin } from './dropdown_mixin';
import { updateEmptyState as updateEmptyStateUtil } from '@app/utils/empty-state';
import { ConditionBlockBuilder } from '@app/utils/condition-block-builder';

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

    // Build block using builder
    const block = ConditionBlockBuilder.build(blockNumber);

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


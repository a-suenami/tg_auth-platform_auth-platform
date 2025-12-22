/**
 * Dropdown Mixin
 *
 * Provides common functionality for controllers that manage dropdowns.
 * This mixin handles outside click detection to close dropdowns.
 */

import { closeAllDropdowns, isClickInsideDropdown } from '@app/utils/dropdown';

/**
 * Mixin for dropdown functionality.
 * Provides a common `handleOutsideClick` method that can be used by controllers.
 */
export const DropdownMixin = {
  /**
   * Handles clicks outside dropdown elements.
   * Closes all dropdowns if the click is outside any dropdown or toggle button.
   *
   * @param event - The click event
   * @param dropdownSelectors - Array of CSS selectors for dropdown containers to check
   */
  handleOutsideClick(
    event: Event,
    dropdownSelectors: string[] = []
  ): void {
    const target = event.target as HTMLElement;
    const isInside = isClickInsideDropdown(target, dropdownSelectors);

    if (!isInside) {
      closeAllDropdowns();
    }
  },
};


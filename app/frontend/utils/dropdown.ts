/**
 * Dropdown utility functions
 *
 * Common functions for managing dropdown open/close state.
 */

/**
 * Toggles a dropdown by its ID.
 * Closes all other dropdowns before opening the target one.
 *
 * @param dropdownId - The ID of the dropdown element to toggle
 * @returns true if the dropdown was opened, false if it was closed
 */
export function toggleDropdown(dropdownId: string): boolean {
  const dropdown = document.getElementById(dropdownId) as HTMLElement;
  if (!dropdown) return false;

  const isOpen = dropdown.getAttribute('data-dropdown-open') === 'true';

  // Close all dropdowns
  closeAllDropdowns();

  // Toggle this dropdown
  if (!isOpen) {
    dropdown.setAttribute('data-dropdown-open', 'true');
    return true;
  }

  return false;
}

/**
 * Closes all dropdowns that have the data-dropdown-open attribute set to "true".
 */
export function closeAllDropdowns(): void {
  document.querySelectorAll('[data-dropdown-open="true"]').forEach((d) => {
    d.setAttribute('data-dropdown-open', 'false');
  });
}

/**
 * Checks if a click target is inside a dropdown or its toggle button.
 *
 * @param target - The element that was clicked
 * @param dropdownSelectors - Array of CSS selectors for dropdown containers
 * @returns true if the click is inside a dropdown or toggle button
 */
export function isClickInsideDropdown(
  target: HTMLElement,
  dropdownSelectors: string[] = []
): boolean {
  const toggle = target.closest('[data-dropdown-toggle]');
  if (toggle) return true;

  for (const selector of dropdownSelectors) {
    const dropdown = target.closest(selector);
    if (dropdown) return true;
  }

  return false;
}


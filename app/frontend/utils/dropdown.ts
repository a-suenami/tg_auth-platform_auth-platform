/**
 * Dropdown utility functions
 *
 * Common functions for managing dropdown open/close state.
 */

/**
 * Sets or removes z-index on the ancestor table cell (td) for table dropdowns.
 * This ensures the dropdown appears above other table rows.
 *
 * @param dropdown - The dropdown element
 * @param zIndex - The z-index value to set, or null to remove
 */
function setTableCellZIndex(dropdown: HTMLElement | null, zIndex: string | null): void {
  if (!dropdown) return;

  // Only process table row action dropdowns
  if (!dropdown.classList.contains('c-table-row-action__dropdown')) return;

  // Find the ancestor td element
  const td = dropdown.closest('td') as HTMLTableCellElement;
  if (!td) return;

  if (zIndex) {
    td.style.zIndex = zIndex;
  } else {
    td.style.zIndex = '';
  }
}

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
    // Set z-index on the table cell for table dropdowns
    setTableCellZIndex(dropdown, '10');
    return true;
  }

  return false;
}

/**
 * Closes all dropdowns that have the data-dropdown-open attribute set to "true".
 */
export function closeAllDropdowns(): void {
  document.querySelectorAll('[data-dropdown-open="true"]').forEach((d) => {
    const dropdown = d as HTMLElement;
    // Remove z-index from table cell before closing
    setTableCellZIndex(dropdown, null);
    dropdown.setAttribute('data-dropdown-open', 'false');
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


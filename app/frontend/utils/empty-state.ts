/**
 * Empty State Utility Functions
 *
 * Common functions for managing empty state visibility.
 */

/**
 * Updates the visibility of an empty state element based on the number of items.
 *
 * @param container - The container element that holds the items
 * @param emptyElement - The empty state element to show/hide
 * @param itemSelector - CSS selector for items within the container
 */
export function updateEmptyState(
  container: HTMLElement,
  emptyElement: HTMLElement,
  itemSelector: string
): void {
  const items = container.querySelectorAll(itemSelector);
  const hasItems = items.length > 0;

  if (hasItems) {
    emptyElement.style.display = 'none';
  } else {
    emptyElement.style.display = 'flex';
  }
}


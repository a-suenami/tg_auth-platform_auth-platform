/**
 * Condition Factory
 *
 * Factory functions for creating condition elements based on condition type.
 */

/**
 * Creates a select element with options.
 *
 * @param className - CSS class name for the select
 * @param options - Array of {value, text} objects for options
 * @param selectedValue - Value of the option to select
 * @param hasChangeAction - Whether to add change action attribute
 * @returns HTMLSelectElement
 */
function createSelect(
  className: string,
  options: Array<{ value: string; text: string }>,
  selectedValue?: string,
  hasChangeAction: boolean = false
): HTMLSelectElement {
  const select = document.createElement('select');
  select.className = className;
  if (hasChangeAction) {
    select.setAttribute('data-action', 'change->condition-block#handleSelectChange');
  }

  options.forEach((opt) => {
    const option = document.createElement('option');
    option.value = opt.value;
    option.textContent = opt.text;
    if (opt.value === selectedValue || (!selectedValue && opt.value === options[0]?.value)) {
      option.selected = true;
    }
    select.appendChild(option);
  });

  return select;
}

/**
 * Creates a text span element.
 *
 * @param className - CSS class name for the span
 * @param text - Text content
 * @returns HTMLSpanElement
 */
function createTextSpan(className: string, text: string): HTMLSpanElement {
  const span = document.createElement('span');
  span.className = className;
  span.textContent = text;
  return span;
}

/**
 * Creates content for "current-membership" condition type.
 *
 * @param initializeSelectClass - Callback to initialize select class for unselected selects
 * @returns DocumentFragment containing the condition content
 */
export function createCurrentMembershipCondition(
  initializeSelectClass: (select: HTMLSelectElement) => void
): DocumentFragment {
  const fragment = document.createDocumentFragment();

  // Select 1: 現在購読中のメンバーシップ
  const select1 = createSelect('c-condition-block__item__pill', [
    { value: 'current-membership', text: '現在購読中のメンバーシップ' },
  ]);

  // Text: が
  const text = createTextSpan('c-condition-block__item__text', 'が');

  // Select 2: 選択してください
  const select2 = createSelect(
    'c-condition-block__item__pill',
    [{ value: '', text: '選択してください' }],
    '',
    true
  );

  // Select 3: である
  const select3 = createSelect('c-condition-block__item__pill', [
    { value: 'is', text: 'である' },
  ]);

  fragment.appendChild(select1);
  fragment.appendChild(text);
  fragment.appendChild(select2);
  fragment.appendChild(select3);

  // Initialize select class for unselected select
  initializeSelectClass(select2);

  return fragment;
}

/**
 * Creates content for "duration-membership" condition type.
 *
 * @param initializeSelectClass - Callback to initialize select class for unselected selects
 * @returns DocumentFragment containing the condition content
 */
export function createDurationMembershipCondition(
  initializeSelectClass: (select: HTMLSelectElement) => void
): DocumentFragment {
  const fragment = document.createDocumentFragment();

  // Select 1: Number (3, 1, 2)
  const select1 = createSelect(
    'c-condition-block__item__pill',
    [
      { value: '3', text: '3' },
      { value: '1', text: '1' },
      { value: '2', text: '2' },
    ],
    '3',
    true
  );

  // Select 2: Unit (日, ヶ月, 年)
  const select2 = createSelect(
    'c-condition-block__item__pill',
    [
      { value: 'day', text: '日' },
      { value: 'month', text: 'ヶ月' },
      { value: 'year', text: '年' },
    ],
    'day',
    true
  );

  // Select 3: 以上購読中のメンバーシップ
  const select3 = createSelect('c-condition-block__item__pill', [
    { value: 'duration-membership', text: '以上購読中のメンバーシップ' },
  ]);

  // Text: が
  const text = createTextSpan('c-condition-block__item__text', 'が');

  // Select 4: Membership A / Membership B
  const select4 = createSelect(
    'c-condition-block__item__pill',
    [{ value: '', text: 'Membership A / Membership B' }],
    '',
    true
  );

  // Select 5: である
  const select5 = createSelect('c-condition-block__item__pill', [
    { value: 'is', text: 'である' },
  ]);

  fragment.appendChild(select1);
  fragment.appendChild(select2);
  fragment.appendChild(select3);
  fragment.appendChild(text);
  fragment.appendChild(select4);
  fragment.appendChild(select5);

  // Initialize select classes for unselected selects
  initializeSelectClass(select1);
  initializeSelectClass(select2);
  initializeSelectClass(select4);

  return fragment;
}

/**
 * Condition type factory map.
 */
export const conditionFactories: Record<
  string,
  (initializeSelectClass: (select: HTMLSelectElement) => void) => DocumentFragment
> = {
  'current-membership': createCurrentMembershipCondition,
  'duration-membership': createDurationMembershipCondition,
};


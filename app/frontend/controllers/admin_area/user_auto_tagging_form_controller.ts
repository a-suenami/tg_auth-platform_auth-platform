import { Controller } from '@hotwired/stimulus';

/**
 * User Auto Tagging Form Controller
 *
 * Manages dynamic form fields for auto-tagging rules with nested rule blocks and conditions.
 *
 * Structure:
 * - UserAutoTagging (main form)
 *   - Schedule (optional time range)
 *   - RuleBlocks (OR logic between blocks)
 *     - Rules (AND logic within block)
 *       - Condition type (membership, plan, prefecture, gender, age, account_link)
 *       - Config (JSON stored as string, built from UI fields)
 */
export default class extends Controller {
  static targets = ['ruleBlocksContainer', 'ruleBlockTemplate', 'ruleTemplate'];

  declare readonly ruleBlocksContainerTarget: HTMLElement;
  declare readonly ruleBlockTemplateTarget: HTMLTemplateElement;
  declare readonly ruleTemplateTarget: HTMLTemplateElement;

  private blockIndex = 0;

  /**
   * Lifecycle: Called when controller connects to DOM
   * - Initialize block counter from existing data
   * - Load existing rules from DB and populate UI fields
   */
  connect() {
    const initialCount = this.element.getAttribute('data-initial-block-count');
    this.blockIndex = initialCount ? parseInt(initialCount) : 0;

    this.initializeExistingRules();
  }

  /**
   * Add a new rule block
   * - Clone template HTML
   * - Replace NEW_RECORD placeholder with unique timestamp
   * - Append to container
   * - Auto-add one empty rule to the new block
   */
  addRuleBlock(event: Event) {
    event.preventDefault();

    const content = this.ruleBlockTemplateTarget.content.cloneNode(true) as DocumentFragment;
    const html = new XMLSerializer().serializeToString(content);
    const timestamp = new Date().getTime().toString();
    const replaced = html.replace(/NEW_RECORD/g, timestamp);

    const wrapper = document.createElement('div');
    wrapper.innerHTML = replaced;

    const newBlock = wrapper.firstElementChild as HTMLElement;
    this.ruleBlocksContainerTarget.appendChild(newBlock);
    this.blockIndex++;
    this.updateBlockNumbers();

    // Automatically add one rule to the new block
    const rulesContainer = newBlock.querySelector('.rules-container') as HTMLElement;
    if (rulesContainer) {
      this.addRuleToBlock(newBlock);
    }
  }

  /**
   * Remove a rule block
   * - If existing block (from DB): mark _destroy = '1' and hide
   * - If new block (not saved): remove from DOM completely
   */
  removeRuleBlock(event: Event) {
    event.preventDefault();

    const removeBtn = (event.target as HTMLElement).closest('.remove-block') as HTMLElement;
    if (!removeBtn) return;

    const block = removeBtn.closest('.rule-block') as HTMLElement;
    const destroyInput = block.querySelector('input[name*="_destroy"]') as HTMLInputElement;

    if (destroyInput) {
      destroyInput.value = '1';
      block.style.display = 'none';
    } else {
      block.remove();
    }

    this.updateBlockNumbers();
  }

  /**
   * Add a rule within a block (button click handler)
   */
  addRule(event: Event) {
    event.preventDefault();

    const addBtn = (event.target as HTMLElement).closest('.add-rule') as HTMLElement;
    if (!addBtn) return;

    const block = addBtn.closest('.rule-block') as HTMLElement;
    this.addRuleToBlock(block);
  }

  /**
   * Add a rule to a specific block (helper method)
   * - Clone rule template
   * - Extract block ID from existing inputs in the block
   * - Replace NEW_RECORD placeholders:
   *   - [rule_blocks_attributes][BLOCK_ID] stays same as parent block
   *   - [rules_attributes][RULE_ID] gets new timestamp
   * This ensures rules belong to correct block in form submission
   */
  private addRuleToBlock(block: HTMLElement) {
    const rulesContainer = block.querySelector('.rules-container') as HTMLElement;
    const content = this.ruleTemplateTarget.content.cloneNode(true) as DocumentFragment;

    // Get the block ID from an existing input in the block
    const blockPositionInput = block.querySelector('input[name*="rule_blocks_attributes"]') as HTMLInputElement;
    const blockIdMatch = blockPositionInput?.name.match(/\[rule_blocks_attributes\]\[([^\]]+)\]/);
    const blockId = blockIdMatch ? blockIdMatch[1] : new Date().getTime().toString();

    const ruleTimestamp = new Date().getTime().toString();

    const html = new XMLSerializer().serializeToString(content);
    // Replace with both block ID and rule ID
    let replaced = html.replace(/\[rule_blocks_attributes\]\[NEW_RECORD\]/g, `[rule_blocks_attributes][${blockId}]`);
    replaced = replaced.replace(/\[rules_attributes\]\[NEW_RECORD\]/g, `[rules_attributes][${ruleTimestamp}]`);

    const wrapper = document.createElement('div');
    wrapper.innerHTML = replaced;

    const newRule = wrapper.firstElementChild as HTMLElement;
    rulesContainer.appendChild(newRule);
    this.updateRuleNumbers(block);
  }

  /**
   * Remove a rule
   * - Similar to removeRuleBlock: mark for destroy or remove from DOM
   */
  removeRule(event: Event) {
    event.preventDefault();

    const removeRuleBtn = (event.target as HTMLElement).closest('.remove-rule') as HTMLElement;
    if (!removeRuleBtn) return;

    const rule = removeRuleBtn.closest('.rule-item') as HTMLElement;
    const destroyInput = rule.querySelector('input[name*="_destroy"]') as HTMLInputElement;

    if (destroyInput) {
      destroyInput.value = '1';
      rule.style.display = 'none';
    } else {
      rule.remove();
    }

    const block = removeRuleBtn.closest('.rule-block') as HTMLElement;
    this.updateRuleNumbers(block);
  }

  /**
   * Handle condition type change (membership, plan, prefecture, etc.)
   * - Show/hide corresponding config section
   * - Rebuild JSON config
   */
  handleConditionTypeChange(event: Event) {
    const select = event.target as HTMLSelectElement;
    const rule = select.closest('.rule-item, .p-user-auto-tagging__rule') as HTMLElement;
    const configFields = rule.querySelector('.config-fields, .p-user-auto-tagging__config-fields') as HTMLElement;
    this.showConfigFields(select.value, configFields);
    this.buildConfigJSON(rule);
  }

  /**
   * Handle subscription type change (current vs duration)
   * - Show/hide duration input fields
   * - Rebuild JSON config
   */
  handleSubscriptionTypeChange(event: Event) {
    const select = event.target as HTMLSelectElement;
    const configSection = select.closest('.config-membership, .config-plan, .config-prefecture, .config-gender, .config-age, .config-account_link, .p-user-auto-tagging__config-section') as HTMLElement;
    const durationFields = configSection.querySelector('.duration-fields, .p-user-auto-tagging__duration-fields') as HTMLElement;

    if (select.value === 'duration') {
      durationFields.style.display = 'block';
    } else {
      durationFields.style.display = 'none';
    }

    const rule = select.closest('.rule-item') as HTMLElement;
    this.buildConfigJSON(rule);
  }

  /**
   * Handle any field change in config
   * - Rebuild JSON config when user changes any input/select/checkbox
   */
  handleFieldChange(event: Event) {
    const field = event.target as HTMLElement;
    const rule = field.closest('.rule-item, .p-user-auto-tagging__rule') as HTMLElement;
    this.buildConfigJSON(rule);
  }

  /**
   * Initialize existing rules when editing
   * - Parse config JSON from hidden textarea (from DB)
   * - Show correct config section based on condition type
   * - Populate UI fields from parsed config
   */
  private initializeExistingRules() {
    this.element.querySelectorAll('.rule-item, .p-user-auto-tagging__rule').forEach(ruleElement => {
      const rule = ruleElement as HTMLElement;
      const conditionTypeSelect = rule.querySelector('.condition-type-select') as HTMLSelectElement;
      const configFields = rule.querySelector('.config-fields, .p-user-auto-tagging__config-fields') as HTMLElement;
      const configJsonField = rule.querySelector('.config-json-field') as HTMLTextAreaElement;

      if (!conditionTypeSelect || !configFields || !configJsonField) return;

      const conditionType = conditionTypeSelect.value;
      if (!conditionType) return;

      // Show the correct config section
      this.showConfigFields(conditionType, configFields);

      // Parse and populate config if exists
      try {
        const config = JSON.parse(configJsonField.value || '{}');
        this.populateConfigFields(rule, conditionType, config);
      } catch (error) {
        console.error('Failed to parse config JSON:', error);
      }
    });
  }

  /**
   * Populate UI fields from config object (for edit page)
   * - Checkbox: check if value is in array
   * - Number: set value
   * - Select/Text: set value
   * - Special handling for subscription type to show duration fields
   */
  private populateConfigFields(rule: HTMLElement, conditionType: string, config: Record<string, any>) {
    const configSection = rule.querySelector('.config-' + conditionType + ', .p-user-auto-tagging__config-section.config-' + conditionType) as HTMLElement;
    if (!configSection) return;

    configSection.querySelectorAll('[data-field]').forEach(field => {
      const fieldName = (field as HTMLElement).getAttribute('data-field');
      if (!fieldName) return;

      if (!config[fieldName]) return;

      const inputField = field as HTMLInputElement;

      if (inputField.type === 'checkbox') {
        // Checkbox: check if value is in array
        if (Array.isArray(config[fieldName]) && config[fieldName].includes(inputField.value)) {
          inputField.checked = true;
        }
      } else if (inputField.type === 'number') {
        // Number input
        inputField.value = config[fieldName].toString();
      } else {
        // Text/Select
        inputField.value = config[fieldName];
      }

      // Show duration fields if subscription type is "duration"
      if (inputField.classList.contains('subscription-type-select')) {
        const durationFields = configSection.querySelector('.duration-fields') as HTMLElement;
        if (durationFields && inputField.value === 'duration') {
          durationFields.style.display = 'block';
        }
      }
    });
  }

  /**
   * Show/hide config fields based on condition type
   * - Hide all config-* sections
   * - Show only the section matching condition type
   */
  private showConfigFields(conditionType: string, configFields: HTMLElement) {
    // configFieldsコンテナ自体の表示制御（p-scopedはcontents）
    if (configFields) {
      const isProjectScoped = configFields.classList.contains('p-user-auto-tagging__config-fields');
      configFields.style.display = isProjectScoped ? 'contents' : 'block';
    }

    // Hide all config sections
    configFields
      .querySelectorAll('[class^="config-"], .p-user-auto-tagging__config-section')
      .forEach(section => {
      (section as HTMLElement).style.display = 'none';
    });

    // Show relevant config section
    if (conditionType) {
      const section = configFields.querySelector(
        '.config-' + conditionType + ', .p-user-auto-tagging__config-section.config-' + conditionType
      ) as HTMLElement;
      if (section) {
        // config-sectionはcontentsで表示、それ以外はblock
        const isProjectScoped = section.classList.contains('p-user-auto-tagging__config-section');
        section.style.display = isProjectScoped ? 'contents' : 'block';
      }
    }
  }

  /**
   * Build JSON config from UI fields
   * - Collect all fields with data-field attribute
   * - Different handling for checkbox (array), number, text/select
   * - Store JSON string in hidden textarea for form submission
   *
   * Example output:
   * {
   *   "subscription_type": "duration",
   *   "duration_value": 30,
   *   "duration_unit": "days",
   *   "values": ["Membership A", "Membership B"]
   * }
   */
  private buildConfigJSON(rule: HTMLElement) {
    const conditionTypeSelect = rule.querySelector('.condition-type-select') as HTMLSelectElement;
    const conditionType = conditionTypeSelect?.value;
    if (!conditionType) return;

    const configSection = rule.querySelector(
      '.config-' + conditionType + ', .p-user-auto-tagging__config-section.config-' + conditionType
    ) as HTMLElement;
    if (!configSection) return;

    const config: Record<string, any> = {};

    // Collect values from fields
    configSection.querySelectorAll('[data-field]').forEach(field => {
      const fieldName = (field as HTMLElement).getAttribute('data-field');
      if (!fieldName) return;

      if ((field as HTMLInputElement).type === 'checkbox') {
        // Checkbox: build array of checked values
        if (!config[fieldName]) config[fieldName] = [];
        if ((field as HTMLInputElement).checked) {
          config[fieldName].push((field as HTMLInputElement).value);
        }
      } else if ((field as HTMLInputElement).type === 'number') {
        // Number: parse integer
        const value = parseInt((field as HTMLInputElement).value);
        if (!isNaN(value) && value > 0) {
          config[fieldName] = value;
        }
      } else {
        // Text/Select: use value directly
        const value = (field as HTMLInputElement).value;
        if (value) {
          config[fieldName] = value;
        }
      }
    });

    // Store JSON in hidden textarea
    const jsonField = rule.querySelector('.config-json-field') as HTMLInputElement;
    if (jsonField) {
      jsonField.value = JSON.stringify(config);
    }
  }

  /**
   * Update block numbers (display and position)
   * - Loop through visible blocks
   * - Update "条件ブロック 1", "条件ブロック 2", etc.
   * - Update hidden position input for Rails ordering
   */
  private updateBlockNumbers() {
    this.element.querySelectorAll('.rule-block:not([style*="display: none"])').forEach((block, index) => {
      const blockNumber = block.querySelector('.block-number');
      const positionInput = block.querySelector('input[name*="[position]"]') as HTMLInputElement;
      if (blockNumber) blockNumber.textContent = (index + 1).toString();
      if (positionInput) positionInput.value = index.toString();
    });
  }

  /**
   * Update rule numbers within a block
   * - Similar to updateBlockNumbers but for rules within one block
   */
  private updateRuleNumbers(block: HTMLElement) {
    block.querySelectorAll('.rule-item:not([style*="display: none"])').forEach((rule, index) => {
      const ruleNumber = rule.querySelector('.rule-number');
      const positionInput = rule.querySelector('input[name*="[position]"]') as HTMLInputElement;
      if (ruleNumber) ruleNumber.textContent = (index + 1).toString();
      if (positionInput) positionInput.value = index.toString();
    });
  }
}
